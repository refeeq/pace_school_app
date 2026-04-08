import 'platform_check_stub.dart'
    if (dart.library.io) 'platform_check_io.dart' as impl;

bool get isIOS => impl.isIOS;
bool get isAndroid => impl.isAndroid;
