import 'dart:async';

import 'package:fastdev/page/main/Main.dart';
import 'package:fastdev/screen/ScreenAdapter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

import 'LoginProvider.dart';

class LoginMain extends StatefulWidget{


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return LoginWidget();
  }

}
class LoginWidget  extends State<LoginMain>{
  var _currChild_1 = Container(
    key: ValueKey("1"),
    child: Image.asset("images/img_5.webp",fit: BoxFit.fill,height: Adapt.screenH(),width: Adapt.screenW(),),
  );
  var _currChild_2 = Container(
    key: ValueKey("2"),
    child: Image.asset("images/img_6.webp",fit: BoxFit.fill,height: Adapt.screenH(),width: Adapt.screenW(),),

  );
  var _currChild_3 = Container(
    key: ValueKey("3"),
    child: Image.asset("images/img_7.webp",fit: BoxFit.fill,height: Adapt.screenH(),width: Adapt.screenW(),),

  );
  var _currChild_4 = Container(
    key: ValueKey("4"),
    child: Image.asset("images/img_8.webp",fit: BoxFit.fill,height: Adapt.screenH(),width: Adapt.screenW(),),

  );
  var _container;
  List<Widget> bgImgList=List();
  int index=0;
  Timer _timer;
  List<dynamic> list222=List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    bgImgList.add(_currChild_1);
    bgImgList.add(_currChild_2);
    bgImgList.add(_currChild_3);
    bgImgList.add(_currChild_4);
    int max=bgImgList.length;
    _timer=Timer.periodic(Duration(milliseconds: 2000),(timer){

      setState(() {
        index=index+1;
        if(index==max){
          index=0;
        }
      });

    });

//    _container=_currChild_1;
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
  }
  TextEditingController userConTroller=TextEditingController();
  TextEditingController pwdConTroller=TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      resizeToAvoidBottomInset:false,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          AnimatedSwitcher(
            duration: Duration(seconds: 1),
            child: bgImgList[index],
            transitionBuilder: (Widget widget,Animation<double> value){
              return FadeTransition(opacity: value,
                child: widget,
              );
            },
            switchInCurve: Curves.easeInCirc,
            switchOutCurve: Curves.easeInOut,
          ),
          Card(
            color: Color.fromARGB(150, 248, 248, 255),
            margin: EdgeInsets.only(top: 50,bottom: 50,left: 18,right: 18),
            child: Column(
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 50),
                      child: ClipOval(
                        child: Container(
                          width: 100,
                          height: 100,
                          child: Image.asset("images/img_1.jpeg",fit: BoxFit.cover,),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text("欢迎使用综合服务",
                        ),
                    ),
                    Container(
                      child:  TextField(
                        controller: userConTroller,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      width: Adapt.screenW()-100,
                    ),
                    Container(
                      child:  TextField(
                        controller: pwdConTroller,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.vpn_key)
                        ),
                      ),
                      width: Adapt.screenW()-100,
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.0),
                      width: Adapt.screenW()-100,
                      child: CupertinoButton(onPressed: (){
                        Provider.of<LoginInfo>(context,listen: false).setLoginInfo(userConTroller.text, pwdConTroller.text);
                        Navigator.pushNamed(context, "/FriendsPage");

                      },
                          pressedOpacity: .5,
                          color: Colors.blueAccent,
                          child: Text("登录")),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 15),
                      width: Adapt.screenW()-100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("忘记密码"),
                          Text("立即注册")
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

}