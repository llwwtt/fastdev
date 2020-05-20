
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyApp2 extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp2> {
  FocusNode _focusNode = FocusNode();
  String s="";
  void initState() {
    //super.initState();
    print("初始化_DemoState");
    //HongWai();
    //_initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: Text("测试"),
          ),
          body: Center(child: HongWai() //Text('data'),
              )),
    );
  }

  Widget HongWai() => RawKeyboardListener(
    focusNode: FocusNode(),
    onKey: (RawKeyEvent event) {
      print("-------------start");
      RawKeyDownEvent rawKeyDownEvent = event;
      RawKeyEventDataAndroid rawKeyEventDataAndroid = rawKeyDownEvent.data;
      if (rawKeyEventDataAndroid.keyCode == 288) {
        //
      }
      print("keyCode: ${rawKeyEventDataAndroid.keyCode}");
    },
    child: Container(child:TextField()),
  );
}