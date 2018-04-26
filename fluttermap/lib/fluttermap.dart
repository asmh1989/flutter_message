import 'dart:async';

import 'package:flutter/services.dart';

class Fluttermap {
  static const MethodChannel _channel = const MethodChannel('hdkj/fluttermap');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<dynamic> get getLocation async {
    return await _channel.invokeMethod('getLocation');
  }

  static void openMap({
    double lat = 0.0,
    double lng = 0.0,
    String cdno = '',
    String re = '',
    String nnm = '',
    String addr = '',
  }) {
    _channel.invokeMethod('openMap', {
      "Addr": addr,
      "Lat": lat,
      "Lng": lng,
      "Re": re,
      "Nnm": nnm,
      "CDNO": cdno
    });
  }
}
