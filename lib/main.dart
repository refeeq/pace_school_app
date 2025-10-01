import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/app.dart';
import 'package:school_app/core/bloc/AuthBloc/auth_listener_bloc.dart';
import 'package:school_app/core/bloc/bloc/login_bloc.dart';
import 'package:school_app/core/provider/admission_register_provider.dart';
import 'package:school_app/core/provider/attendance_provider.dart';
import 'package:school_app/core/provider/auth_provider.dart';
import 'package:school_app/core/provider/circular_provider.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/core/provider/contactus_provider.dart';
import 'package:school_app/core/provider/guest_provider.dart';
import 'package:school_app/core/provider/ios_update_provider.dart';
import 'package:school_app/core/provider/leave_provider.dart';
import 'package:school_app/core/provider/nav_provider.dart';
import 'package:school_app/core/provider/notification_provider.dart';
import 'package:school_app/core/provider/parent_provider.dart';
import 'package:school_app/core/provider/school_provider.dart';
import 'package:school_app/core/provider/student_fee_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/services/dependecyInjection.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/auth_listener.dart';
import 'package:school_app/views/screens/bus_track/cubit/bus_track_cubit.dart';
import 'package:school_app/views/screens/contact_us/cubit/contact_us_cubit.dart';
import 'package:school_app/views/screens/family_fee/cubit/family_fee_cubit.dart';
import 'package:school_app/views/screens/leave/bloc/leave_bloc.dart';
import 'package:school_app/views/screens/open_house/bloc/open_house_bloc.dart';
import 'package:school_app/views/screens/sibilingRegister/cubit/sibiling_registration_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}
// Name:FirebaseConsoleAPNS
// Key ID:Q4BXXK36HC

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   systemNavigationBarColor: ConstColors.secondary,
    //   statusBarColor: ConstColors.primary,
    // ));
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthListenerBloc>(
          create: (context) =>
              AuthListenerBloc()..add(const AuthStateChanged()),
        ),
        BlocProvider<LoginBloc>(create: (context) => LoginBloc()),
        BlocProvider<OpenHouseBloc>(create: (context) => OpenHouseBloc()),
        BlocProvider<LeaveBloc>(create: (context) => LeaveBloc()),
        BlocProvider<SibilingRegistrationCubit>(
          create: (context) => SibilingRegistrationCubit(),
        ),
        BlocProvider<ContactUsCubit>(create: (context) => ContactUsCubit()),
        BlocProvider<FamilyFeeCubit>(create: (context) => FamilyFeeCubit()),
        BlocProvider<BusTrackCubit>(
          create: (context) => locator<BusTrackCubit>(),
        ),
      ],
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AttendenceProvider()),
          ChangeNotifierProvider(create: (_) => NavProvider()),
          ChangeNotifierProvider(create: (_) => StudentFeeProvider()),
          ChangeNotifierProvider(create: (_) => ParentProvider()),
          ChangeNotifierProvider(create: (_) => AttendenceProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => StudentProvider()),
          ChangeNotifierProvider(create: (_) => CircularProvider()),
          ChangeNotifierProvider(create: (_) => SchoolProvider()),
          ChangeNotifierProvider(create: (_) => AdmissionRegisterProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ChangeNotifierProvider(create: (_) => ContactUsProvider()),
          ChangeNotifierProvider(create: (_) => GuestProvider()),
          ChangeNotifierProvider(create: (_) => CommunicationProvider()),
          ChangeNotifierProvider(create: (_) => LeaveProvider()),
          ChangeNotifierProvider(create: (_) => AutoUpdateProvider()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 720),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (_, child) {
            return MaterialApp(
              key: scaffoldKey,
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              title: AppEnivrornment.appName,
              theme: ThemeData(
                textTheme: GoogleFonts.poppinsTextTheme(),
                // primarySwatch: Colors.blue,
                // scaffoldBackgroundColor: Colors.white,
                appBarTheme: AppBarTheme(
                  centerTitle: true,
                  foregroundColor: ConstColors.backgroundColor,
                  surfaceTintColor: ConstColors.backgroundColor,
                  shadowColor: ConstColors.backgroundColor,
                  backgroundColor: ConstColors.primary,
                  // elevation: 2,
                  iconTheme: const IconThemeData(color: Colors.black),
                  actionsIconTheme: const IconThemeData(color: Colors.black),
                  titleTextStyle: GoogleFonts.nunitoSans(
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              home: const AuthListener(),
              // routes: ,
            );
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    // PushNotificationService().setupFcm(context);
    super.initState();
  }
}
