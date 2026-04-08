import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/parent_update_request_model.dart';
import 'package:school_app/core/repository/parent_update/repository.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/core/utils/utils.dart';

class ParentUpdateProvider with ChangeNotifier {
  ParentUpdateRepository repository = locator<ParentUpdateRepository>();

  /// Per-request-type state, keyed by a simple string identifier.
  final Map<String, AppStates> _requestStates = {};

  AppStates historyState = AppStates.Unintialized;
  ParentUpdateRequestListModel? historyModel;

  AppStates stateFor(String key) => _requestStates[key] ?? AppStates.Unintialized;

  void _setState(String key, AppStates state, {bool notify = true}) {
    _requestStates[key] = state;
    if (notify) notifyListeners();
  }

  void resetState(String key) {
    _requestStates.remove(key);
    notifyListeners();
  }

  /// Clears all cached user data. Call on logout.
  void clearOnLogout() {
    _requestStates.clear();
    historyState = AppStates.Unintialized;
    historyModel = null;
    notifyListeners();
  }

  Future<bool> _ensureInternet(BuildContext context) async {
    final hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      showToast('No internet connection!', context, type: ToastType.error);
    }
    return hasInternet;
  }

  /// Safely read status and message from API response. Returns null if response is not a Map.
  (bool success, String message)? _parseResponseMap(dynamic data) {
    if (data is! Map) return null;
    final status = data['status'];
    final message = data['message']?.toString() ?? '';
    return (status == true, message);
  }

  Future<bool> submitStudentPassportRequest({
    required String admissionNo,
    String? passportNumber,
    required String expiryDate,
    required String documentPath,
    required BuildContext context,
  }) async {
    const key = 'student_passport';
    _setState(key, AppStates.Initial_Fetching);

    if (!await _ensureInternet(context)) {
      _setState(key, AppStates.NoInterNetConnectionState);
      return false;
    }

    final respon = await repository.requestStudentPassportUpdate(
      admissionNo: admissionNo,
      passportNumber: passportNumber,
      expiryDate: expiryDate,
      documentPath: documentPath,
    );

    if (respon.isLeft) {
      log(respon.left.message.toString());
      _setState(key, AppStates.Error);
      showToast(respon.left.message ?? 'Failed to submit request', context, type: ToastType.error);
      return false;
    }
    final parsed = _parseResponseMap(respon.right);
    if (parsed == null) {
      _setState(key, AppStates.Error);
      showToast('Invalid response from server', context, type: ToastType.error);
      return false;
    }
    if (parsed.$1) {
      _setState(key, AppStates.Fetched);
      showToast(parsed.$2, context, type: ToastType.success);
      return true;
    }
    _setState(key, AppStates.Error);
    showToast(parsed.$2, context, type: ToastType.error);
    return false;
  }

  Future<bool> submitStudentEidRequest({
    required String admissionNo,
    required String emiratesId,
    required String expiryDate,
    required String documentPath,
    required BuildContext context,
  }) async {
    const key = 'student_eid';
    _setState(key, AppStates.Initial_Fetching);

    if (!await _ensureInternet(context)) {
      _setState(key, AppStates.NoInterNetConnectionState);
      return false;
    }

    final respon = await repository.requestStudentEidUpdate(
      admissionNo: admissionNo,
      emiratesId: emiratesId,
      expiryDate: expiryDate,
      documentPath: documentPath,
    );

    if (respon.isLeft) {
      log(respon.left.message.toString());
      _setState(key, AppStates.Error);
      showToast(respon.left.message ?? 'Failed to submit request', context, type: ToastType.error);
      return false;
    }
    final parsed = _parseResponseMap(respon.right);
    if (parsed == null) {
      _setState(key, AppStates.Error);
      showToast('Invalid response from server', context, type: ToastType.error);
      return false;
    }
    if (parsed.$1) {
      _setState(key, AppStates.Fetched);
      showToast(parsed.$2, context, type: ToastType.success);
      return true;
    }
    _setState(key, AppStates.Error);
    showToast(parsed.$2, context, type: ToastType.error);
    return false;
  }

  Future<bool> submitStudentPhotoRequest({
    required String admissionNo,
    required String photoPath,
    required BuildContext context,
  }) async {
    const key = 'student_photo';
    _setState(key, AppStates.Initial_Fetching);

    if (!await _ensureInternet(context)) {
      _setState(key, AppStates.NoInterNetConnectionState);
      return false;
    }

    final respon = await repository.requestStudentPhotoUpdate(
      admissionNo: admissionNo,
      photoPath: photoPath,
    );

    if (respon.isLeft) {
      log(respon.left.message.toString());
      _setState(key, AppStates.Error);
      showToast(respon.left.message ?? 'Failed to submit request', context, type: ToastType.error);
      return false;
    }
    final parsed = _parseResponseMap(respon.right);
    if (parsed == null) {
      _setState(key, AppStates.Error);
      showToast('Invalid response from server', context, type: ToastType.error);
      return false;
    }
    if (parsed.$1) {
      _setState(key, AppStates.Fetched);
      showToast(parsed.$2, context, type: ToastType.success);
      return true;
    }
    _setState(key, AppStates.Error);
    showToast(parsed.$2, context, type: ToastType.error);
    return false;
  }

  Future<bool> submitFatherPhotoRequest({
    required String photoPath,
    required BuildContext context,
  }) async {
    const key = 'father_photo';
    _setState(key, AppStates.Initial_Fetching);

    if (!await _ensureInternet(context)) {
      _setState(key, AppStates.NoInterNetConnectionState);
      return false;
    }

    final respon = await repository.requestFatherPhotoUpdate(
      photoPath: photoPath,
    );

    if (respon.isLeft) {
      log(respon.left.message.toString());
      _setState(key, AppStates.Error);
      showToast(respon.left.message ?? 'Failed to submit request', context, type: ToastType.error);
      return false;
    }
    final parsed = _parseResponseMap(respon.right);
    if (parsed == null) {
      _setState(key, AppStates.Error);
      showToast('Invalid response from server', context, type: ToastType.error);
      return false;
    }
    if (parsed.$1) {
      _setState(key, AppStates.Fetched);
      showToast(parsed.$2, context, type: ToastType.success);
      return true;
    }
    _setState(key, AppStates.Error);
    showToast(parsed.$2, context, type: ToastType.error);
    return false;
  }

  Future<bool> submitMotherPhotoRequest({
    required String photoPath,
    required BuildContext context,
  }) async {
    const key = 'mother_photo';
    _setState(key, AppStates.Initial_Fetching);

    if (!await _ensureInternet(context)) {
      _setState(key, AppStates.NoInterNetConnectionState);
      return false;
    }

    final respon = await repository.requestMotherPhotoUpdate(
      photoPath: photoPath,
    );

    if (respon.isLeft) {
      log(respon.left.message.toString());
      _setState(key, AppStates.Error);
      showToast(respon.left.message ?? 'Failed to submit request', context, type: ToastType.error);
      return false;
    }
    final parsed = _parseResponseMap(respon.right);
    if (parsed == null) {
      _setState(key, AppStates.Error);
      showToast('Invalid response from server', context, type: ToastType.error);
      return false;
    }
    if (parsed.$1) {
      _setState(key, AppStates.Fetched);
      showToast(parsed.$2, context, type: ToastType.success);
      return true;
    }
    _setState(key, AppStates.Error);
    showToast(parsed.$2, context, type: ToastType.error);
    return false;
  }

  Future<bool> submitFatherEmailRequest({
    required String email,
    required BuildContext context,
  }) async {
    const key = 'father_email';
    _setState(key, AppStates.Initial_Fetching);

    if (!await _ensureInternet(context)) {
      _setState(key, AppStates.NoInterNetConnectionState);
      return false;
    }

    final respon = await repository.requestFatherEmailUpdate(
      email: email,
    );

    if (respon.isLeft) {
      log(respon.left.message.toString());
      _setState(key, AppStates.Error);
      showToast(respon.left.message ?? 'Failed to submit request', context, type: ToastType.error);
      return false;
    }
    final parsed = _parseResponseMap(respon.right);
    if (parsed == null) {
      _setState(key, AppStates.Error);
      showToast('Invalid response from server', context, type: ToastType.error);
      return false;
    }
    if (parsed.$1) {
      _setState(key, AppStates.Fetched);
      showToast(parsed.$2, context, type: ToastType.success);
      return true;
    }
    _setState(key, AppStates.Error);
    showToast(parsed.$2, context, type: ToastType.error);
    return false;
  }

  Future<bool> submitFatherEidRequest({
    required String emiratesId,
    required String expiryDate,
    required String documentPath,
    required BuildContext context,
  }) async {
    const key = 'father_eid';
    _setState(key, AppStates.Initial_Fetching);

    if (!await _ensureInternet(context)) {
      _setState(key, AppStates.NoInterNetConnectionState);
      return false;
    }

    final respon = await repository.requestFatherEidUpdate(
      emiratesId: emiratesId,
      expiryDate: expiryDate,
      documentPath: documentPath,
    );

    if (respon.isLeft) {
      log(respon.left.message.toString());
      _setState(key, AppStates.Error);
      showToast(respon.left.message ?? 'Failed to submit request', context, type: ToastType.error);
      return false;
    }
    final parsed = _parseResponseMap(respon.right);
    if (parsed == null) {
      _setState(key, AppStates.Error);
      showToast('Invalid response from server', context, type: ToastType.error);
      return false;
    }
    if (parsed.$1) {
      _setState(key, AppStates.Fetched);
      showToast(parsed.$2, context, type: ToastType.success);
      return true;
    }
    _setState(key, AppStates.Error);
    showToast(parsed.$2, context, type: ToastType.error);
    return false;
  }

  Future<bool> submitMotherEidRequest({
    required String emiratesId,
    required String expiryDate,
    required String documentPath,
    required BuildContext context,
  }) async {
    const key = 'mother_eid';
    _setState(key, AppStates.Initial_Fetching);

    if (!await _ensureInternet(context)) {
      _setState(key, AppStates.NoInterNetConnectionState);
      return false;
    }

    final respon = await repository.requestMotherEidUpdate(
      emiratesId: emiratesId,
      expiryDate: expiryDate,
      documentPath: documentPath,
    );

    if (respon.isLeft) {
      log(respon.left.message.toString());
      _setState(key, AppStates.Error);
      showToast(respon.left.message ?? 'Failed to submit request', context, type: ToastType.error);
      return false;
    }
    final parsed = _parseResponseMap(respon.right);
    if (parsed == null) {
      _setState(key, AppStates.Error);
      showToast('Invalid response from server', context, type: ToastType.error);
      return false;
    }
    if (parsed.$1) {
      _setState(key, AppStates.Fetched);
      showToast(parsed.$2, context, type: ToastType.success);
      return true;
    }
    _setState(key, AppStates.Error);
    showToast(parsed.$2, context, type: ToastType.error);
    return false;
  }

  Future<bool> submitAddressRequest({
    String? homeAddress,
    String? flatNo,
    String? buildingName,
    String? comNumber,
    int? communityId,
    required BuildContext context,
  }) async {
    const key = 'address';
    _setState(key, AppStates.Initial_Fetching);

    if (!await _ensureInternet(context)) {
      _setState(key, AppStates.NoInterNetConnectionState);
      return false;
    }

    final respon = await repository.requestAddressUpdate(
      homeAddress: homeAddress,
      flatNo: flatNo,
      buildingName: buildingName,
      comNumber: comNumber,
      communityId: communityId,
    );

    if (respon.isLeft) {
      log(respon.left.message.toString());
      _setState(key, AppStates.Error);
      showToast(respon.left.message ?? 'Failed to submit request', context, type: ToastType.error);
      return false;
    }
    final parsed = _parseResponseMap(respon.right);
    if (parsed == null) {
      _setState(key, AppStates.Error);
      showToast('Invalid response from server', context, type: ToastType.error);
      return false;
    }
    if (parsed.$1) {
      _setState(key, AppStates.Fetched);
      showToast(parsed.$2, context, type: ToastType.success);
      return true;
    }
    _setState(key, AppStates.Error);
    showToast(parsed.$2, context, type: ToastType.error);
    return false;
  }

  Future<void> fetchParentUpdateRequests() async {
    historyState = AppStates.Initial_Fetching;
    notifyListeners();

    final hasInternet = await InternetConnectivity().hasInternetConnection;
    if (!hasInternet) {
      historyState = AppStates.NoInterNetConnectionState;
      notifyListeners();
      return;
    }

    final respon = await repository.getParentUpdateRequests();
    if (respon.isLeft) {
      log(respon.left.message.toString());
      historyState = AppStates.Error;
    } else {
      historyModel = respon.right;
      historyState =
          historyModel?.status == true ? AppStates.Fetched : AppStates.Error;
    }
    notifyListeners();
  }
}

