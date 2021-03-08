//
//  AppData.dart
//  flutter_hot_update
//
//  Created by Client on 2021/3/4.
//  Copyright © 2021 Client. All rights reserved.
//

import 'dart:async';
import 'dart:convert';
import 'dart:convert' show utf8;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'AppConf.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'AppStartStateMgr.dart';
import 'ControlMgr.dart';

class AppData {
  Map<String, dynamic> _appConf;
  String _docPath;

  static Map<String, dynamic> json2Map(String jsonStr) {
    if (jsonStr == null || jsonStr == "") return Map();
    return json.decode(jsonStr);
  }

  static Future<String> appDocPath() async {
    return appPath(getApplicationDocumentsDirectory);
  }

  static Future<String> appPath(Function directoryProvider) async {
    final Directory dir = await directoryProvider();
    String appDocPath = dir.path + '/';
    if (appDocPath.endsWith("/")) {
      appDocPath = appDocPath.substring(0, appDocPath.length - 1);
    }
    return appDocPath;
  }

  Future<bool> download(
      {@required String remotePath,
      @required String localPath,
      String desc}) async {
    return await _downloadImp(
        desc: desc, remotePath: remotePath, localPath: localPath);
  }

  Future<bool> _downloadImp(
      {@required String remotePath,
      @required String localPath,
      String desc}) async {
    var url = "$LocalServerRoot/wwwroot/$remotePath";
    try {
      var response = await Dio().download(url, localPath);
      print(response);
      return response.statusCode == 200;
    } catch (e) {
      print("$desc下载失败：$url $e");
      print("$desc下载失败：$url $e");
    }
    return false;
  }

  Future<void> init() async {
    await initAppConf();
  }

  Future<void> initAppConf() async {
    print("初始化本地资源...");
    //App读写目录:_docPath
    _docPath = await appDocPath();

    //读取App配置文件
    var response = await Dio().get("$LocalServerRoot/wwwroot/$AppJsonFilePath",
        options: Options(responseType: ResponseType.bytes));
    Uint8List bytes = response.data;
    if (bytes == null || bytes.length == 0) {
      bytes = null;
    }
    String jsonStr = utf8.decode(bytes, allowMalformed: true);
    _appConf = json2Map(jsonStr);

    if (_appConf == null || _appConf.isEmpty) {
      print("通过app.json文件反序列化的Map为空!");
      return false;
    }
    //初始化自定义组件
    if (_appConf["customs"] != null) {
      if (_appConf["customs"] is List) {
        List list = _appConf["customs"];
        Map<String, dynamic> customsMap = Map();
        _appConf["customs"] = customsMap;
        for (var i = 0; i < list.length; ++i) {
          var cnt = 0;
          var repeats = List();
          var dirKey = list[i];
          var customList = _appConf[dirKey];
          _appConf.remove(dirKey);
          for (String type in customList) {
            if (type == null || type.isEmpty) continue;
            cnt++;
            if (customsMap.containsKey(type)) {
              repeats.add(type);
            }
            String path = "$dirKey/$type.json";
            String localPath = "$_docPath/wwwroot/$path";
            bool result = await download(
              remotePath: path,
              localPath: localPath,
              desc: "下载$type控件配置",
            );
            if (result) {
              print("下载成功: $path");
            } else {
              print("下载失败: $path");
            }
            final file = File('$localPath');
            var contents = await file.readAsString();
            if (contents != null || contents.isNotEmpty) {
              customsMap[type] = json2Map(contents);
              print("本地读取成功(${result ? "新" : "旧"}): $path");
            } else {
              print("本地读取失败: $path");
            }
          }
          print("$dirKey 解析 $cnt 个自定义控件！重复覆盖：${repeats.length} $repeats");
        }
        //解析自定义控件
        await controlMgr.parseCustom(_appConf["customs"]);
        appStartStateMgr.changeState("正在初始化本地资源");
      }
    }
  }
}

AppData appData = new AppData();
