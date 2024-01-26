import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

enum AppDevice { ios, android }

class Tools {
  static final Tools tools = Tools._internal();

  bool appIsAnonymous = false;
  AppDevice? appDevice;

  String? userId;
  String? userName;
  String? userPicture;

  factory Tools() {
    return tools;
  }

  Tools._internal();

  void toolsSetParams() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      appDevice = AppDevice.ios;
      userId = 'ios';
      userName = 'Mr. iOS';
      userPicture = 'https://www.freeiconspng.com/img/4084';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      appDevice = AppDevice.android;
      userId = 'android';
      userName = 'Mrs. Android';
      userPicture = 'https://www.freeiconspng.com/img/3089';
    }
  }
}
