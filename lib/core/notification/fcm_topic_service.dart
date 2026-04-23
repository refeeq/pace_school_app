import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Service to manage FCM topic subscriptions
class FcmTopicService {
  static const String _topicsBoxName = 'fcm_topics';
  static const String _lastSubscribedTopicsKey = 'last_subscribed_topics';

  static List<String> _normalizeTopicList(List<String> topics) {
    final seen = <String>{};
    final out = <String>[];
    for (final t in topics) {
      final trimmed = t.trim();
      if (trimmed.isEmpty) continue;
      if (seen.add(trimmed)) out.add(trimmed);
    }
    return out;
  }

  /// Aligns FCM subscriptions with [desiredTopics] from the API.
  ///
  /// Uses set difference so unchanged topics do not trigger extra
  /// subscribe/unsubscribe calls. Local storage is updated to [desiredTopics]
  /// after attempts complete (intended state; FCM may lag until next sync).
  static Future<void> syncSubscribedTopics(List<String> desiredTopics) async {
    final desired = _normalizeTopicList(desiredTopics);
    final previous = _normalizeTopicList(await _getStoredTopics());
    final prevSet = previous.toSet();
    final desiredSet = desired.toSet();

    if (prevSet == desiredSet) {
      log('FcmTopicService: Sync — topics unchanged, skipping FCM');
      return;
    }

    final toUnsubscribe = prevSet.difference(desiredSet).toList();
    if (toUnsubscribe.isNotEmpty) {
      log(
        'FcmTopicService: Sync — removing ${toUnsubscribe.length} topic(s) '
        'no longer in API list: $toUnsubscribe',
      );
      await unsubscribeFromTopics(toUnsubscribe);
    }

    if (desired.isEmpty) {
      if (prevSet.isNotEmpty) {
        await _clearStoredTopics();
        log('FcmTopicService: Sync — API returned no topics; storage cleared');
      }
      return;
    }

    final toSubscribe = desiredSet.difference(prevSet).toList();
    if (toSubscribe.isNotEmpty) {
      await subscribeToTopics(toSubscribe, persistStorage: false);
    }

    await _storeSubscribedTopics(desired);
  }

  /// Subscribe to a list of FCM topics
  ///
  /// Each topic will be subscribed individually. Errors for individual
  /// topics are logged but won't stop the subscription process.
  ///
  /// [persistStorage]: when false, Hive is not updated (used by [syncSubscribedTopics]
  /// which persists the full desired set after subscribe + unsubscribe).
  static Future<void> subscribeToTopics(
    List<String> topics, {
    bool persistStorage = true,
  }) async {
    if (topics.isEmpty) {
      log('FcmTopicService: No topics to subscribe to');
      return;
    }

    log('FcmTopicService: Subscribing to ${topics.length} topics: $topics');

    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    int successCount = 0;
    int failureCount = 0;

    for (final topic in topics) {
      final trimmedTopic = topic.trim();
      
      // Validate topic name (FCM allows: [a-zA-Z0-9-_.~%])
      if (trimmedTopic.isEmpty) {
        log('FcmTopicService: Skipping empty topic');
        failureCount++;
        continue;
      }

      try {
        await messaging.subscribeToTopic(trimmedTopic);
        log('FcmTopicService: Successfully subscribed to topic: $trimmedTopic');
        successCount++;
      } catch (e) {
        log('FcmTopicService: Failed to subscribe to topic "$trimmedTopic": $e');
        failureCount++;
      }
    }

    log('FcmTopicService: Subscription complete - Success: $successCount, Failed: $failureCount');

    if (persistStorage && successCount > 0) {
      await _storeSubscribedTopics(_normalizeTopicList(topics));
    }
  }

  /// Unsubscribe from a list of FCM topics
  /// 
  /// Each topic will be unsubscribed individually. Errors for individual
  /// topics are logged but won't stop the unsubscription process.
  static Future<void> unsubscribeFromTopics(List<String> topics) async {
    if (topics.isEmpty) {
      log('FcmTopicService: No topics to unsubscribe from');
      return;
    }

    log('FcmTopicService: Unsubscribing from ${topics.length} topics: $topics');

    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    int successCount = 0;
    int failureCount = 0;

    for (final topic in topics) {
      final trimmedTopic = topic.trim();
      
      if (trimmedTopic.isEmpty) {
        log('FcmTopicService: Skipping empty topic');
        failureCount++;
        continue;
      }

      try {
        await messaging.unsubscribeFromTopic(trimmedTopic);
        log('FcmTopicService: Successfully unsubscribed from topic: $trimmedTopic');
        successCount++;
      } catch (e) {
        log('FcmTopicService: Failed to unsubscribe from topic "$trimmedTopic": $e');
        failureCount++;
      }
    }

    log('FcmTopicService: Unsubscription complete - Success: $successCount, Failed: $failureCount');
  }

  /// Unsubscribe from all previously subscribed topics
  /// 
  /// This reads the last known subscribed topics from storage and unsubscribes from them.
  static Future<void> unsubscribeFromAllTopics() async {
    try {
      final topics = await _getStoredTopics();
      if (topics.isNotEmpty) {
        await unsubscribeFromTopics(topics);
        await _clearStoredTopics();
      }
    } catch (e) {
      log('FcmTopicService: Error unsubscribing from all topics: $e');
    }
  }

  /// Store subscribed topics for later cleanup
  static Future<void> _storeSubscribedTopics(List<String> topics) async {
    try {
      if (!Hive.isBoxOpen(_topicsBoxName)) {
        await Hive.openBox(_topicsBoxName);
      }
      final box = Hive.box(_topicsBoxName);
      await box.put(_lastSubscribedTopicsKey, topics);
    } catch (e) {
      log('FcmTopicService: Error storing topics: $e');
    }
  }

  /// Get stored subscribed topics
  static Future<List<String>> _getStoredTopics() async {
    try {
      if (!Hive.isBoxOpen(_topicsBoxName)) {
        await Hive.openBox(_topicsBoxName);
      }
      final box = Hive.box(_topicsBoxName);
      final topics = box.get(_lastSubscribedTopicsKey);
      if (topics is List) {
        return topics.cast<String>();
      }
      return [];
    } catch (e) {
      log('FcmTopicService: Error getting stored topics: $e');
      return [];
    }
  }

  /// Get the list of topics currently stored (last subscribed).
  /// Use this to derive studcode from e.g. "stud_3333" when notification data
  /// does not include studcode.
  static Future<List<String>> getStoredTopics() async {
    return _getStoredTopics();
  }

  /// Clear stored topics
  static Future<void> _clearStoredTopics() async {
    try {
      if (!Hive.isBoxOpen(_topicsBoxName)) {
        await Hive.openBox(_topicsBoxName);
      }
      final box = Hive.box(_topicsBoxName);
      await box.delete(_lastSubscribedTopicsKey);
    } catch (e) {
      log('FcmTopicService: Error clearing stored topics: $e');
    }
  }
}
