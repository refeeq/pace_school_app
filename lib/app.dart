import 'package:firebase_core/firebase_core.dart';
import 'package:school_app/schools/cbsa/cbsa_firebase_options.dart';
import 'package:school_app/schools/demo/demo_firebase_options.dart';
import 'package:school_app/schools/sisd/sisd_firebase_options.dart';

import 'schools/dpsa/dpsa_firabse_options.dart';
import 'schools/gaes/gaes_firebase_options.dart';
import 'schools/iiss/iiss_firebase_options.dart';
import 'schools/pace/pace_firebase_options.dart';
import 'schools/pbss/pbss_firebase_options.dart';
import 'schools/pcbs/pcbs_firebase_options.dart';
import 'schools/pmbs/pmbs_firebase_options.dart';

abstract class AppEnivrornment {
  static late String appName;
  static late String bundleName;
  static late String firbaseName;
  static late String appFullName;
  static late String appImageName;
  static late String url;
  static late String appUrl;
  static late String appId;
  static late FirebaseOptions firebaseOptions;
  static late AppEnvironmentNames _appEnvironmentNames;

  static AppEnvironmentNames get environment => _appEnvironmentNames;

  static void setupEnv(AppEnvironmentNames environmentNames) {
    _appEnvironmentNames = environmentNames;
    switch (environmentNames) {
      case AppEnvironmentNames.pace:
        {
          firbaseName = "pacesharjah";
          bundleName = "com.pacesharjah.schoolapp";
          appName = "PACE INTL";
          appFullName = "PACE International School";
          url = "https://pace.paceeducation.com/app-api/index.php?page=";
          firebaseOptions = PaceDefaultFirebaseOptions.currentPlatform;
          appImageName = "assets/logo/pace.png";
          appId = "6444666599";
          appUrl =
              "https://apps.apple.com/us/app/pace-international-school/id6444666599";
          break;
        }

      case AppEnvironmentNames.gaes:
        {
          firbaseName = "gulfasia";
          bundleName = "com.gaes.schoolapp";
          appName = "PACE GAES";
          appFullName = "Gulf Asian English School";
          url = "https://gaes.paceeducation.com/app-api/index.php?page=";
          firebaseOptions = GaesDefaultFirebaseOptions.currentPlatform;
          appImageName = "assets/logo/gaes.png";
          appId = "1669154397";
          appUrl =
              "https://apps.apple.com/us/app/gulf-asian-english-school/id1669154397";
          break;
        }
      case AppEnvironmentNames.iiss:
        {
          firbaseName = "iisspace";
          appName = "PACE IISS";
          bundleName = "com.iiss.schoolapp";
          appFullName = "India International School";
          url = "https://iiss.paceeducation.com/app-api/index.php?page=";
          firebaseOptions = IissDefaultFirebaseOptions.currentPlatform;
          appImageName = "assets/logo/iiss.png";
          appId = "1671960770";
          appUrl =
              "https://apps.apple.com/us/app/india-international-school/id1671960770";
          break;
        }
      case AppEnvironmentNames.cbsa:
        {
          firbaseName = "cbsabudhabi";
          appName = "CBS Abudhabi";
          bundleName = "com.cbsa.schoolapp";
          appFullName = "Creative British school";
          url = "https://cbsa.paceeducation.com/app-api/index.php?page=";
          firebaseOptions = CbsaDefaultFirebaseOptions.currentPlatform;
          appImageName = "assets/logo/cbsa.png";
          appId = "1672283771";
          appUrl = "https://apps.apple.com/us/app/cbs-abudhabi/id1672283771";
          break;
        }

      case AppEnvironmentNames.dpsa:
        {
          firbaseName = "dpsajman";
          appName = "DPS Ajman";
          bundleName = "com.dpsa.schoolapp";
          appFullName = "Delhi Private School Ajman";
          url = "https://dpsa.paceeducation.com/app-api/index.php?page=";
          firebaseOptions = DpsaDefaultFirebaseOptions.currentPlatform;
          appImageName = "assets/logo/dpsa.png";
          appId = "1672202447";
          appUrl =
              "https://apps.apple.com/us/app/delhi-private-school-ajman/id1672202447";
          break;
        }

      case AppEnvironmentNames.pbss:
        {
          firbaseName = "pacepbss";
          bundleName = "com.pbss.schoolapp";
          appName = "PACE PBSS";
          appFullName = "PACE British school";
          url = "https://pbss.paceeducation.com/app-api/index.php?page=";
          firebaseOptions = PbssDefaultFirebaseOptions.currentPlatform;
          appImageName = "assets/logo/pbss.png";
          appId = "1672935157";
          appUrl =
              "https://apps.apple.com/us/app/pace-british-school/id1672935157";
          break;
        }

      case AppEnvironmentNames.pmbss:
        {
          firbaseName = "pacepmbs";
          appName = "PACE PMBS";
          bundleName = "com.pmbss.schoolapp";
          appFullName = "PACE Modern British School";
          url = "https://pmbs.paceeducation.com/app-api/index.php?page=";
          firebaseOptions = PmbsDefaultFirebaseOptions.currentPlatform;
          appImageName = "assets/logo/pmbs.png";
          appId = "1671476154";
          appUrl =
              "https://apps.apple.com/us/app/pace-modern-british-school/id1671476154";
          break;
        }

      case AppEnvironmentNames.pcbs:
        {
          firbaseName = "pacepcbs";
          appName = "PACE PCBS";
          bundleName = "com.pcbs.schoolapp";
          appFullName = "PACE Creative British School";
          url = "https://pcbs.paceeducation.com/app-api/index.php?page=";
          firebaseOptions = PcbsDefaultFirebaseOptions.currentPlatform;
          appImageName = "assets/logo/pcbs.png";
          appId = "1673237688";
          appUrl =
              "https://appstoreconnect.apple.com/apps/1673237688/appstore/ios/version/deliverable";
          break;
        }
      case AppEnvironmentNames.sisd:
        {
          firbaseName = "springfield-international";
          appName = "Springfield";
          bundleName = "com.sisd.schoolapp";
          appFullName = "SPRINGFIELD INTERNATIONAL SCHOOL";
          url = "https://sisd.paceeducation.com/app-api/index.php?page=";
          firebaseOptions = SisdDefaultFirebaseOptions.currentPlatform;
          appImageName = "assets/logo/sisd.jpg";
          appId = "6654914077";
          appUrl =
              "https://apps.apple.com/us/app/springfield-international/id6654914077";
          break;
        }
      case AppEnvironmentNames.demo:
        {
          firbaseName = "demo";
          appName = "DEMO";
          bundleName = "com.demo.schoolapp";
          appFullName = "DEMO SCHOOL";
          url = "https://demo.paceeducation.com/app-api/index.php?page=";
          firebaseOptions = DemoDefaultFirebaseOptions.currentPlatform;
          appImageName = "assets/logo/sisd.jpg";
          appId = "1671476154";
          appUrl =
              "https://apps.apple.com/us/app/pace-modern-british-school/id1671476154";
          break;
        }
    }
  }
}

enum AppEnvironmentNames {
  pace,
  gaes,
  iiss,
  cbsa,
  dpsa,
  pbss,
  pmbss,
  pcbs,
  sisd,
  demo,
}






// # application bundle identifier
// APP_BUNDLE="com.iiss.schoolapp";


// # application bundle identifier
// APP_BUNDLE="com.cbsa.schoolapp";



// # application bundle identifier
// APP_BUNDLE="com.dpsa.schoolapp";



// # application bundle identifier
// APP_BUNDLE="com.pmbs.schoolapp";


// # application bundle identifier
// APP_BUNDLE="com.pcbs.schoolapp";


// # application bundle identifier
// APP_BUNDLE="com.pbss.schoolapp";
