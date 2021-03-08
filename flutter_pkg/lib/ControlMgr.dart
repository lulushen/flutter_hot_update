import 'package:flutter/material.dart';

import 'container/XContainer.dart';

typedef ControlCreator = Widget Function(Map conf);

class ControlMgr {
  Map<String, ControlCreator> _controlCreators;
  Map<String, Map<String, dynamic>> _customsConf = Map();
  void init() {
    //初始化容器
    if (_controlCreators != null) return;
    _controlCreators = new Map<String, ControlCreator>();
    _addControlCreator("XContainer", (conf) => XContainer(conf: conf));
  }

  void _addControlCreator(String type, ControlCreator creator) {
    if (_controlCreators.containsKey(type)) {
      print("Control类型已存在!Type:$type");
      return;
    }
    _controlCreators[type] = creator;
  }
  Future<void> parseCustom(Map customs) async {
    if (customs == null) return;
    var cnt = 0, types = customs.keys.toList();
    for (var type in types) {
      if (customs[type] is Map) {
        cnt++;
        _customsConf[type] = customs[type];
        _addControlCreator(type, __createCustomControl);
      }
    }
    print("解析 $cnt/${customs.length} 个自定义控件！");
  }
  Widget __createCustomControl(Map conf) {
    String type = conf["type"];
    var customControlConf = _customsConf[type];
    String name = conf["name"];
    if (name != null && name.isNotEmpty) {
      customControlConf["name"] = name;
    }
    return createControl(customControlConf);
  }
  Widget createControl(Map conf) {
    String str;
    if (conf != null) {
      String type = conf["type"];
      if (_controlCreators.containsKey(type)) {
        return _controlCreators[type](conf);
      } else {
        str = "指定类型的Control不存在！Type:$type}";
        print(str);
        return _controlCreators["XContainer"](conf);
      }
    } else {
      str = "controlMgr.createControl conf参数不能为null";
      print(str);
    }
    return null;
  }
}

ControlMgr controlMgr = new ControlMgr();
