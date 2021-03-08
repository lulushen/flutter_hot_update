//
//  MyApp.dart
//  flutter_hot_update
//
//  Created by Client on 2021/3/4.
//  Copyright © 2021 Client. All rights reserved.
//

import 'package:flutter/material.dart';

import 'AppData.dart';
import 'AppStartStateMgr.dart';
import 'ControlMgr.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    controlMgr.init();
    appData.initAppConf();
    appStartStateMgr.addChangeCallBack((state, count, total) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget homeWidget = controlMgr.createControl({"type": "home_page"});
    return MaterialApp(
      title: "Flutter Hot Update Demo",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: homeWidget ?? Container(),
      ),
    );
  }
}
