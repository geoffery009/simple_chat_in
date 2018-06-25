import 'dart:async';

import 'package:flutter/services.dart';

class SimpleChatIn {
  static const MethodChannel _channel =
      const MethodChannel('simple_chat_in');

  static Future<String> get platformVersion =>
      _channel.invokeMethod('getPlatformVersion');
}
