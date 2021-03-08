//
//  XContainer.swift
//  flutter_hot_update
//
//  Created by Client on 2021/3/6.
//  Copyright © 2021 Client. All rights reserved.
//

import 'package:flutter/material.dart';

class XContainer extends StatelessWidget {
  XContainer({Key key, this.conf}) : super(key: key);

  final Map conf;

  Map get cf => conf['conf'] ?? {};

  @override
  Widget build(BuildContext context) {
    Map cf = conf["conf"];
    var width, height, color;

    if (cf != null) {
      if (cf.containsKey("width")) {
        width = cf["width"];
      }
      if (cf.containsKey("height")) {
        height = cf["height"];
      }
      if (cf.containsKey("color")) {
        color = str2Color(cf["color"]);
      }
    }
    return Container(
        color: color ?? Colors.transparent, width: width, height: height);
  }

  Color str2Color(String str, [Color defaultColor]) {
    if (str != null && str.isNotEmpty) {
      str = str.replaceFirst(r'#', r'0x');
      return Color(int.parse(str));
    }
    return defaultColor;
  }
}
