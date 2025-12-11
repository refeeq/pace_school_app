import 'package:school_app/app.dart';

class ApiConstatns {
  static String baseUrl = AppEnivrornment.url;
  // static String baseUrl =
  //     'http://10.30.141.25/ERP_DEMO/app-api/index.php?page=';

  static String login = '${baseUrl}login';
  static String verifyOTP = '${baseUrl}otpVerify';
  static String setFcmToken = '${baseUrl}setFcmToken';
  static String getStudents = '${baseUrl}studentDetails';
  static String getStudentProfile = '${baseUrl}studentProfile';
  static String getStudentMenu = '${baseUrl}studentMenu';
  static String getGuestMenu = '${baseUrl}guestMenu';
  static String getCircular = '${baseUrl}studentCircular';
  static String getParentCircular = '${baseUrl}parentCircular';
  static String getSchoolInfo = '${baseUrl}schoolInfo';
  static String getParentProfile = '${baseUrl}parentProfile';
  static String getParentProfileTab = '${baseUrl}parentProfileTab';

  static String getStudentFee = '${baseUrl}studentFee';
  static String studentFeeSubmit = '${baseUrl}studentFeeSubmit';
  static String studentAttendance = '${baseUrl}studentAttendance';
  static String getAdmissionData = '${baseUrl}getRegSiblingDet';
  static String guestGetRegDet = '${baseUrl}guestGetRegDet';
  static String siblingRegistration = '${baseUrl}siblingRegistration';
  static String siblingRegistrationList = '${baseUrl}getRegisteredSiblings';
  static String guestOnlineRegistration = '${baseUrl}guestOnlineRegistration';
  static String getAllNotifications = '${baseUrl}getNotifications';
  static String readNotification = '${baseUrl}readNotifications';
  static String contactUs = '${baseUrl}contactUs';
  static String guestContactUs = '${baseUrl}guestContactUs';
  static String studentFeeLedger = '${baseUrl}studentFeeLedger';
  static String getCommunicationStudentList = '${baseUrl}getComStudents';
  static String getCommunicationTileList = '${baseUrl}getCommunications';
  static String getCommunicationsBifur = '${baseUrl}getCommunicationsBifur';

  static String getAllLeaveResons = '${baseUrl}getLeaveReasonTypes';
  static String getAllLeaveList = '${baseUrl}getAppliedLeaves';
  static String applyLeave = '${baseUrl}applyLeave';
  static String updateParentEmailOtp = '${baseUrl}updateParentEmailOtp';
  static String updateParentEmail = '${baseUrl}updateParentEmail';
  static String updateParentMobileOtp = '${baseUrl}updateParentMobileOtp';
  static String updateParentMobile = '${baseUrl}updateParentMobile';
  static String viewFeeRcpt = '${baseUrl}studView';
  static String availableProgrssReport = '${baseUrl}availableProgrssReport';
  static String progrssReport = '${baseUrl}progrssReport';
  static String updateStudentDocumentDetails =
      '${baseUrl}updateStudentDocumentDetails';

  //open House
  static String openHouse = '${baseUrl}openHouse';
  static String addOpenhouseApp = '${baseUrl}addOpenhouseApp';
  // family fee
  static String getFamilyFee = '${baseUrl}familyFee';
  static String submitFamilyFee = '${baseUrl}familyFeeSubmit';
  // tracking
  static String getTracking = '${baseUrl}getStudentTrack';
}
