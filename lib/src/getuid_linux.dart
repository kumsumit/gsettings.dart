import 'dart:ffi';
import 'dart:io';

typedef _GetuidC = Int32 Function();
typedef _GetuidDart = int Function();

/// Gets the user ID of the current user.
int getuid() {
  // Choose the libc name appropriate for the current platform.
  String libName;
  switch (Platform.operatingSystem) {
    case 'linux':
      libName = 'libc.so.6';
      break;
    case 'macos':
      libName = 'libc.dylib';
      break;
    case 'android':
      libName = 'libc.so';
      break;
    default:
      throw 'Unable to determine UID on this system';
  }

  final dylib = DynamicLibrary.open(libName);
  final getuidP = dylib.lookupFunction<_GetuidC, _GetuidDart>('getuid');
  return getuidP();
}
