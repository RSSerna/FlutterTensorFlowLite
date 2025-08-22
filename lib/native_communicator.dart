import 'package:flutter/services.dart';

class NativeCommunicator {
  static const String channelName = 'com.example.native_communicator';
  static const MethodChannel _channel = MethodChannel(channelName);

  static Future<String> getPlatformVersion() async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String>? invokeNativeMethod(String methodName,
      [dynamic arguments]) async {
    try {
      final result = await _channel.invokeMethod(methodName, arguments);
      return result;
    } on PlatformException catch (e) {
      throw Exception('Failed to invoke native method: ${e.message}');
    }
  }
}
