import 'package:flutter/material.dart';

import 'package:flyte/scaffold.dart';
import 'package:flyte/tools.dart';

void main() {
  const scaffoldWidget = ScaffoldWidget();

  Tools().toolsSetParams();

  runApp(const MaterialApp(
    title: 'Flyte',
    debugShowCheckedModeBanner: false,
    home: scaffoldWidget,
  ));
}
