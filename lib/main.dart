import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flyte/scaffold.dart';
import 'package:flyte/tools.dart';

void main() {
  const scaffoldWidget = ScaffoldWidget();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  Tools().toolsSetParams();

  runApp(const MaterialApp(
    title: 'Flyte',
    debugShowCheckedModeBanner: false,
    home: scaffoldWidget,
  ));
}
