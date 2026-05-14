import 'package:flutter/foundation.dart';

const String _authApiPath = '/api/v1/users';
const String _storeApiPath = '/api/v1';

String get apiBaseUrl {
  if (kIsWeb) {
    return 'http://localhost:5000$_authApiPath';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:5000$_authApiPath';
    default:
      return 'http://localhost:5000$_authApiPath';
  }
}

String get apiStoreBaseUrl {
  if (kIsWeb) {
    return 'http://localhost:5000$_storeApiPath';
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:5000$_storeApiPath';
    default:
      return 'http://localhost:5000$_storeApiPath';
  }
}
