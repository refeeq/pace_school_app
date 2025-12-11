import 'package:school_app/core/config/app_status.dart';

class CommonResModel {
  AppStates status;
  final String? message;
  final dynamic data;

  CommonResModel({required this.status, this.message, this.data});
}
