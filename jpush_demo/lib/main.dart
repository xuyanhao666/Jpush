import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:jpush_flutter/jpush_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String debugLable = 'Unknown'; /*错误信息*/
  String register_id = 'no id';
  final JPush jpush = JPush(); /* 初始化极光插件*/
  @override
  void initState() {
    super.initState();
    initPlatformState(); /*极光插件平台初始化*/
  }

  Future<void> initPlatformState() async {
    ///创建 JPush
    JPush jpush = JPush();
    FlutterAppBadger.isAppBadgeSupported().then((onValue){
      if (onValue) {
        print('支持角标设置');
      } else {
        print('不支持角标设置');
      }
    });
    jpush.setup(
      appKey: "8451470e6e3f7b083178b1f4",
      channel: "flutter_channel",
      production: false,
      debug: true,
    );

    //获取注册的id
    jpush.getRegistrationID().then((rid) {
      print("获取注册的id:$rid");
      setState(() {
        register_id = rid;
      });
    });

    String platformVersion;
    try {
      /*监听响应方法的编写*/
      jpush.addEventHandler(
          // 接收通知回调方法。
          onReceiveNotification: (Map<String, dynamic> message) async {
        print(">>>>>>>>>>>>>>>>>flutter 接收到推送: $message");
        FlutterAppBadger.updateBadgeCount(99);
        setState(() {
          debugLable = "接收到推送: $message";
        });
      },
          // 点击通知回调方法。
          onOpenNotification: (Map<String, dynamic> message) async {
        print(">>>>>>>>>>>>>>>>>flutter 打开推送提醒: $message");
      },
          // 接收自定义消息回调方法。
          onReceiveMessage: (Map<String, dynamic> message) async {
        print(">>>>>>>>>>>>>>>>>flutter 收到推送消息提醒: $message");
        FlutterAppBadger.updateBadgeCount(99);
        var fireDate = DateTime.fromMillisecondsSinceEpoch(
            DateTime.now().millisecondsSinceEpoch + 1000);
        var localNotification = LocalNotification(
          id: 234,
          title: '我是推送测试标题',
          buildId: 1,
          content: '看到了说明已经成功了',
          fireTime: fireDate,
          subtitle: '一个测试',
          badge: 77
        );
        jpush.sendLocalNotification(localNotification).then((res) {
          setState(() {
            debugLable = res;
          });
        });
      });
    } on PlatformException {
      platformVersion = '平台版本获取失败，请检查！';
    } catch (e) {
      print('极光sdk配置异常');
    }

    if (!mounted) {
      return;
    }

    setState(() {
      debugLable = platformVersion;
    });
  }

  /*编写视图*/
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('极光推送'),
        ),
        body: Center(
            child: Column(children: [
          Text('结果: $debugLable\n'),
          Text('ID:====== $register_id'),
          RaisedButton(
              child: Text(
                '点击发送推送消息\n',
              ),
              onPressed: () {
                /*三秒后出发本地推送*/
                print('三秒后出发本地推送');
                var fireDate = DateTime.fromMillisecondsSinceEpoch(
                    DateTime.now().millisecondsSinceEpoch + 3000);
                var localNotification = LocalNotification(
                  id: 234,
                  title: '我是推送测试标题',
                  buildId: 1,
                  content: '看到了说明已经成功了',
                  fireTime: fireDate,
                  subtitle: '一个测试',
                );
                jpush.sendLocalNotification(localNotification).then((res) {
                  setState(() {
                    debugLable = res;
                  });
                });
              }),
        ])),
      ),
    );
  }
}
