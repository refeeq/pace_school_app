import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/constants/db_constants.dart';
import 'package:school_app/core/models/auth_model.dart';
import 'package:school_app/core/models/parent_model.dart';
import 'package:school_app/core/notification/fcm_topic_service.dart';
import 'package:school_app/core/provider/attendance_provider.dart';
import 'package:school_app/core/provider/circular_provider.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/core/provider/leave_provider.dart';
import 'package:school_app/core/provider/nav_provider.dart';
import 'package:school_app/core/provider/notification_provider.dart';
import 'package:school_app/core/provider/parent_provider.dart';
import 'package:school_app/core/provider/parent_update_provider.dart';
import 'package:school_app/core/provider/student_fee_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';

/// Clears all user-specific data from Hive and resets all providers.
/// Call this before firing AuthLoggedOutEvent to ensure no stale data
/// persists when a different user logs in.
Future<void> clearAllUserDataOnLogout(BuildContext context) async {
  // 1. Unsubscribe from FCM topics
  try {
    await FcmTopicService.unsubscribeFromAllTopics();
  } catch (_) {
    // Continue with logout even if topic unsubscription fails
  }

  // 2. Clear all user-specific Hive boxes
  await Hive.box<ParentModel>(PARENTDB).clear();
  await Hive.box('communication').clear();
  await Hive.box('notificationCount').clear();
  await Hive.box('documentExpiry').clear();
  await Hive.box('allNotification').clear();
  await Hive.box('fcm_topics').clear();
  await Hive.box<AuthModel>(USERDB).clear();

  // 3. Reset all providers
  if (context.mounted) {
    _resetProviders(context);
  }
}

void _resetProviders(BuildContext context) {
  Provider.of<StudentProvider>(context, listen: false).clearOnLogout();
  Provider.of<ParentProvider>(context, listen: false).clearOnLogout();
  Provider.of<NavProvider>(context, listen: false).clearOnLogout();
  Provider.of<ParentUpdateProvider>(context, listen: false).clearOnLogout();
  Provider.of<StudentFeeProvider>(context, listen: false).clearOnLogout();
  Provider.of<AttendenceProvider>(context, listen: false).clearOnLogout();
  Provider.of<CircularProvider>(context, listen: false).clearOnLogout();
  Provider.of<CommunicationProvider>(context, listen: false).clearOnLogout();
  Provider.of<LeaveProvider>(context, listen: false).clearOnLogout();
  Provider.of<NotificationProvider>(context, listen: false).clearOnLogout();
}
