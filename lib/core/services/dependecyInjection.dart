import 'package:get_it/get_it.dart';
import 'package:school_app/core/repository/admission/repository.dart';
import 'package:school_app/core/repository/admission/repository_impl.dart';
import 'package:school_app/core/repository/attendance/repository.dart';
import 'package:school_app/core/repository/attendance/repository_impl.dart';
import 'package:school_app/core/repository/circular/repository.dart';
import 'package:school_app/core/repository/circular/repository_impl.dart';
import 'package:school_app/core/repository/communication/repository.dart';
import 'package:school_app/core/repository/communication/repository_impl.dart';
import 'package:school_app/core/repository/contactUs/repository.dart';
import 'package:school_app/core/repository/contactUs/repository_impl.dart';
import 'package:school_app/core/repository/guest/repository.dart';
import 'package:school_app/core/repository/guest/repository_impl.dart';
import 'package:school_app/core/repository/leaveApplication/repository.dart';
import 'package:school_app/core/repository/leaveApplication/repository_impl.dart';
import 'package:school_app/core/repository/notification/repository.dart';
import 'package:school_app/core/repository/notification/repository_impl.dart';
import 'package:school_app/core/repository/parent/repository.dart';
import 'package:school_app/core/repository/parent/repository_impl.dart';
import 'package:school_app/core/repository/repository.dart';
import 'package:school_app/core/repository/repository_impl.dart';
import 'package:school_app/core/repository/school/repository.dart';
import 'package:school_app/core/repository/school/repository_impl.dart';
import 'package:school_app/core/repository/student/repository.dart';
import 'package:school_app/core/repository/student/repository_impl.dart';
import 'package:school_app/core/services/api_services.dart';
import 'package:school_app/views/screens/bus_track/cubit/bus_track_cubit.dart';
import 'package:school_app/views/screens/bus_track/repository/bus_track_repository.dart';
import 'package:school_app/views/screens/family_fee/repository/family_fee_repository.dart';
import 'package:school_app/views/screens/open_house/repository/open_house_repository.dart';

GetIt locator = GetIt.instance;

void serviceLocators() {
  locator.registerLazySingleton<DioAPIServices>(() => DioAPIServices());
  locator.registerLazySingleton<OpenHouseRepository>(
    () => OpenHouseRepository(apiServices: locator()),
  );
  locator.registerLazySingleton<Repository>(() => RepsitoryImpl(locator()));
  locator.registerLazySingleton<StudentRepository>(
    () => StudentRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<CircularRepository>(
    () => CircularRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<SchoolRepository>(
    () => SchoolRepositoyImpl(locator()),
  );
  locator.registerLazySingleton<ParentRepository>(
    () => ParentRepositoryimpl(locator()),
  );
  locator.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<AdmissionRepository>(
    () => AdmissionRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<ContactUsRepository>(
    () => ContactUsRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<GuestRepository>(
    () => GuestRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<CommunicationRepository>(
    () => CommunicationRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<LeaveApplicationRepository>(
    () => LeaveApplicationRepositoryImpl(locator()),
  );
  locator.registerLazySingleton<FamilyFeeRepository>(
    () => FamilyFeeRepository(dioAPIServices: locator()),
  );
  // tracking
  locator.registerLazySingleton<BusTrackRepository>(
    () => BusTrackRepository(dioAPIServices: locator()),
  );
  locator.registerLazySingleton<BusTrackCubit>(() => BusTrackCubit());
}
