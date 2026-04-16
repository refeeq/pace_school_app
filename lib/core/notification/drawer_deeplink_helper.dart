import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/contactus_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/main.dart';
import 'package:school_app/views/components/web_view_screen.dart';
import 'package:school_app/views/screens/contact_us/contact_us.dart';
import 'package:school_app/views/screens/family_fee/cubit/family_fee_cubit.dart';
import 'package:school_app/views/screens/family_fee/pages/family_fee_screen.dart';
import 'package:school_app/views/screens/parent/parent_settings_screen/parent_settings_screen_view.dart';
import 'package:school_app/views/screens/school_information_screen/school_information_screen_view.dart';
import 'package:school_app/views/screens/sibilingRegister/page/sibiling_registration_list.dart';
import 'package:school_app/views/screens/student/report_card/report_card_list_page.dart';

import 'package:school_app/core/notification/fcm_topic_service.dart';

bool _isReportCardDrawerKey(String k) {
  final t = k.trim();
  return t == 'Report Card' || t == 'ReportCard';
}

Future<String?> _resolveStudCodeForDrawer(Map<String, dynamic> data) async {
  try {
    final raw = data['studcode']?.toString().trim();
    if (raw != null && raw.isNotEmpty) return raw;

    final topicRaw = data['topic']?.toString().trim();
    if (topicRaw != null &&
        topicRaw.isNotEmpty &&
        topicRaw.startsWith('stud_') &&
        topicRaw.length > 5) {
      return topicRaw.substring(5);
    }

    final topics = await FcmTopicService.getStoredTopics();
    for (final t in topics) {
      final s = t.toString().trim();
      if (s.startsWith('stud_') && s.length > 5) {
        return s.substring(5);
      }
    }
  } catch (e, st) {
    log('drawer_deeplink: resolve studcode error: $e\n$st');
  }
  return null;
}

/// Same [drawer_key] values as parent drawer ([DrawerWidget]): SchoolInfo,
/// SiblingRegistration, ContactUs, Settings, familyFee, Report Card / ReportCard,
/// or WebView via [url] + optional [web_title] when key is `WebView` / `CustomWeb`.
Future<bool> navigateToDrawerScreen({
  required String drawerKey,
  String? studcode,
  String? url,
  String? webTitle,
}) async {
  final context = navigatorKey.currentContext;
  final state = navigatorKey.currentState;
  if (context == null || state == null) {
    log('drawer_deeplink: No navigator');
    return false;
  }

  final key = drawerKey.trim();

  try {
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final sc = studcode?.trim();
    if (sc != null && sc.isNotEmpty) {
      studentProvider.selectStudentWithStudId(sc);
    }

    switch (key) {
      case 'SchoolInfo':
        state.push(MaterialPageRoute(builder: (_) => SchoolInformationScreenView()));
        return true;
      case 'SiblingRegistration':
        state.push(
          MaterialPageRoute(builder: (_) => const SibilingRegistrationList()),
        );
        return true;
      case 'ContactUs':
        Provider.of<ContactUsProvider>(context, listen: false).updatesubmitContactUs();
        state.push(MaterialPageRoute(builder: (_) => const ContactUsScreen()));
        return true;
      case 'Settings':
        state.push(
          MaterialPageRoute(builder: (_) => const ParentSettingsScreenView()),
        );
        return true;
      case 'familyFee':
      case 'FamilyFee':
        BlocProvider.of<FamilyFeeCubit>(context).fetchfee();
        state.push(MaterialPageRoute(builder: (_) => const FamilyFeeScreen()));
        return true;
      default:
        if (_isReportCardDrawerKey(key)) {
          final id =
              sc ?? studentProvider.selectedStudentModel(context).studcode;
          studentProvider.getReportNamesByClass(id);
          state.push(MaterialPageRoute(builder: (_) => const ReportCardListPage()));
          return true;
        }
        if (key == 'WebView' ||
            key == 'CustomWeb' ||
            key == 'webview' ||
            key == 'WEBVIEW') {
          final loadUrl = url?.trim();
          if (loadUrl == null || loadUrl.isEmpty) {
            log('drawer_deeplink: WebView requires url in data');
            return false;
          }
          final title = (webTitle?.trim().isNotEmpty == true)
              ? webTitle!.trim()
              : ' ';
          state.push(
            MaterialPageRoute(
              builder: (_) => WebViewScreen(reponseUrl: loadUrl, title: title),
            ),
          );
          return true;
        }
        log('drawer_deeplink: Unknown drawer_key "$key"');
        return false;
    }
  } catch (e, st) {
    log('drawer_deeplink error: $e\n$st');
    return false;
  }
}

/// Reads [drawer_key] / [drawerKey] from FCM [data] and navigates.
Future<bool> navigateToDrawerFromNotificationData(Map<String, dynamic> data) async {
  final raw = data['drawer_key']?.toString().trim() ??
      data['drawerKey']?.toString().trim();
  if (raw == null || raw.isEmpty) {
    log('drawer_deeplink: missing drawer_key');
    return false;
  }
  final stud = await _resolveStudCodeForDrawer(data);
  final url = data['url']?.toString().trim();
  final webTitle = data['web_title']?.toString().trim() ??
      data['webTitle']?.toString().trim();
  return navigateToDrawerScreen(
    drawerKey: raw,
    studcode: stud,
    url: url,
    webTitle: webTitle,
  );
}
