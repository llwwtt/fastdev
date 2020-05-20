import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:emoji_picker/emoji_picker.dart';
import 'package:fastdev/bean/MessageBean.dart';
import 'package:fastdev/globalconfig/EnvironmentConfig.dart';
import 'package:fastdev/mywidgets/Bubble.dart';
import 'package:fastdev/mywidgets/ChatButtle.dart';
import 'package:fastdev/page/main/MainProvider.dart';
import 'package:fastdev/page/user/LoginProvider.dart';
import 'package:fastdev/screen/ScreenAdapter.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
///实现思路
///1。键盘打开时记录键盘的高度。因为emoji也需要使用这个高度。
///2。关于listview自动滚到最底部。分两种情况当处于系统键盘时，直接调用jump即可。当处于emoji时，由于是Stack布局，所以上一层的布局和下一层没关系。需要设置一个高度，把
///list抬起来。这样切换键盘就会自动滚动到最底部了
///3。关于输入框的闪动问题。预计加入动画来解决。暂时还为结局
class MainPage extends StatefulWidget{
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin{
  TextEditingController _msgController=TextEditingController();

  ScrollController _scrollController=ScrollController(
    keepScrollOffset: true
  );

  var _endHeiht=0.0;

  var _reSetWindow=false;

  bool _showLeyBoard=false;
  bool _changeState=false;
  String _token="GZC3xRmauT4FF83b31gKPjr48d8OZbdNY9t+Zp8ergXVEFhwGjCBqw==@b26u.cn.rongnav.com;b26u.cn.rongcfg.com";
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((d)=>_getRenderBox());
    RongcloudImPlugin.init(EnvironmentConfig.APPKEY);
    RongcloudImPlugin.connect(_token).then((result){
      debugPrint("链接结果 $result");
    });
    super.initState();

    ///系统自带键盘弹出监听
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) async {
        _showLeyBoard=visible;
        ///打开时判断当前imoji是否在显示,显示则关闭，
        if(mounted){
          setState(() {
            debugPrint("kkkkkkkkkkk====回掉");


            if(visible){
              isShowEmoji=true;
            }else{
              if(_showLeyBoard){
                isShowEmoji=false;
              }
            }
          });
        }
//        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
//            duration: Duration(milliseconds: 500), curve: Curves.bounceIn);
        Timer(Duration(milliseconds: 100), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));


      },
    );
    _focusNode.addListener((){

//      if(_focusNode.hasFocus){
//        _reSetWindow=true;
//      }else{
//        _reSetWindow=false;
//      }
    });


  }
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
//    Timer(Duration(milliseconds: 100), () => _scrollController.animateTo(_scrollController.position.maxScrollExtent,
//        duration: Duration(milliseconds: 2000), curve: Curves.bounceIn));
    debugPrint("=====didChangeDependencies");

    Timer(Duration(milliseconds: 100), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));

  }
  @override
  void dispose() {
    // TODO: implement dispose
    KeyboardVisibilityNotification().dispose();
    _scrollController.dispose();
    super.dispose();

  }
  Key _listKey=Key("123123");
  double bootomHeight=0.0;
  FocusNode _focusNode = FocusNode();
  bool isShowEmoji=false;
  onGetHistoryMessages() async {
    List msgs = await RongcloudImPlugin.getHistoryMessage(RCConversationType.Private, "18811785120", 0, 10);
    print("get history message");
    for(Message m in msgs) {
      print("sentTime = "+m.content.encode());
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
//    if(_showLeyBoard){
//      double keyHeight=MediaQuery.of(context).viewInsets.bottom;//获取键盘的高度，最好是持久化保存的数据，暂时使用临时获取的
//      Provider.of<ChatProvider>(context,listen: false).setKeyBoardHeight(keyHeight);
//    }
    return Scaffold(
      resizeToAvoidBottomInset: _reSetWindow,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Expanded(child: Padding(padding: EdgeInsets.only(bottom:5),
                  child:ListView.builder(itemBuilder: (c,i){
                    return ChatItem(messageBean: Provider.of<ChatProvider>(context).msgList[i],);
                  },
                    itemCount: Provider.of<ChatProvider>(context).msgList.length,
                    key: _listKey,
                    reverse: false,
                    controller: _scrollController,
                    physics: BouncingScrollPhysics(),
                  ),
                ),
                flex: 1,
                ),
                Container(
                  width: Adapt.screenW(),
                  height: 50,
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      IconButton(onPressed: (){

                       }, icon: Icon(Icons.keyboard_voice),
                        padding: EdgeInsets.all(1.0),

                      ),
//                      Flexible(child: TextField(
//                        controller: _msgController,
//                        focusNode: _focusNode,
//                      ),
//                      ),
                       Flexible(child: RawKeyboardListener(focusNode: FocusNode(), child: TextField(
                         controller: _msgController,
                         focusNode: _focusNode,
//                         onSubmitted: (keyValue){
//                           LogUtil.e("-----------start---------$keyValue");
//                         },

                         ),
                         onKey: (RawKeyEvent event){
//                           RawKeyDownEvent rawKeyDownEvent = event.data;
                           RawKeyEventDataAndroid rawKeyEventDataAndroid = event.data;
                           debugPrint("kkkkkkkkkkk====${rawKeyEventDataAndroid.keyCode}");


                         },
                         autofocus: true,
//                         key: UniqueKey(),
                       )),
                      IconButton(onPressed: (){
                        _changeState=true;

                        debugPrint("当前_showLeyBoard：$_showLeyBoard,当前isShowEmoji：$isShowEmoji");
                        if(_showLeyBoard){

                          debugPrint("关闭");
                          debugPrint("kkkkkkkkkkk====if");

                          FocusScope.of(context).requestFocus(FocusNode());

//                          _focusNode.unfocus();
                        }else{
                          debugPrint("打开");
                          debugPrint("kkkkkkkkkkk====else");
                          _focusNode.unfocus();
                          FocusScope.of(context).requestFocus(_focusNode);
                        }


                       }, icon: _showLeyBoard?Icon(Icons.keyboard):Icon(Icons.sentiment_satisfied),
                        key: _key,
                      )
                      ,
                      IconButton(onPressed: (){
                        //发送成功。发送中。发送失败
                        if(_msgController.text.isEmpty){
                          return;
                        }
                        MessageBean msg=MessageBean("未du", "2020-05-08", _msgController.text, 0, 0, "2020-05-08", 0);
                        Provider.of<ChatProvider>(context,listen: false).sendMsg(msg);
                        _msgController.clear();
                        Timer(Duration(milliseconds: 100), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
                       }, icon: Icon(Icons.send))
                    ],
                  ),
                ),
                Offstage(
                    offstage: isShowEmoji==false,
                  child: Container(child:EmojiPicker(
                    keyBoardHeight: 271,
                    rows: 3,
                    columns: 7,
                    recommendKeywords: ["racing", "horse"],
                    numRecommended: 10,
                    onEmojiSelected: (emoji, category) {
                      _msgController.text=_msgController.text+emoji.emoji;
                    },
                  ),
                  )
                )
                ,
              ],
            ),
          ),
//          Positioned(child: Container(
//            width: Adapt.screenW(),
//            height: 50,
//            color: Colors.white,
//            child: Row(
//              children: <Widget>[
//                IconButton(onPressed: (){
//
//                }, icon: Icon(Icons.keyboard_voice),
//                  padding: EdgeInsets.all(1.0),
//
//                ),
//                Flexible(child: TextField(
//                  controller: _msgController,
//                  focusNode: _focusNode,
//                ),
//                ),
//                IconButton(onPressed: (){
//                  debugPrint("当前_showLeyBoard：$_showLeyBoard,当前isShowEmoji：$isShowEmoji");
//                  if(_showLeyBoard&&isShowEmoji==true){
////                          _focusNode.unfocus();
////                          setState(() {
////                            isShowEmoji=true;
////                          });
////                          Timer(Duration(milliseconds: 100), (){
////                            setState(() {
////                              isShowEmoji=true;
////                            });
////                          });
//                  }else if(_showLeyBoard==false&&isShowEmoji==true){
//                    setState(() {
//                      isShowEmoji=true;
//                    });
//                    _focusNode.unfocus();
//                    FocusScope.of(context).requestFocus(_focusNode);
//                  }else{
//                    setState(() {
//                      isShowEmoji=true;
//                    });
//                  }
//                }, icon: _showLeyBoard?Icon(Icons.keyboard):Icon(Icons.sentiment_satisfied))
//                ,
//                IconButton(onPressed: (){
//                  //发送成功。发送中。发送失败
//                  if(_msgController.text.isEmpty){
//                    return;
//                  }
//                  MessageBean msg=MessageBean("未du", "2020-05-08", _msgController.text, 0, 0, "2020-05-08", 0);
//                  Provider.of<ChatProvider>(context,listen: false).sendMsg(msg);
//                  _msgController.clear();
//                  Timer(Duration(milliseconds: 100), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
//                }, icon: Icon(Icons.send))
//              ],
//            ),
//          ),
//          bottom: 317,
//          )
        ],
      ),
    );
  }
  //定义一个key
  GlobalKey _key = GlobalKey();
  _getRenderBox() {
    //获取`RenderBox`对象
    RenderBox renderBox = _key.currentContext.findRenderObject();

    debugPrint("高度:${renderBox.size.height}");
  }
}
class ChatItem extends StatelessWidget{

  ChatItem({Key key, this.messageBean}) : super(key: key);
  final MessageBean messageBean;
  FocusNode _commentFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    //
    return Consumer(builder: (_,ChatProvider provider,child){

      return messageBean.msgSource==1?Container(
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
                child: ClipOval(
                  child: Container(
                    width: 50,
                    height: 50,
                    child: Image.asset("images/img_1.jpeg",fit: BoxFit.cover,),
                  ),
                ),
              ),
              Flexible(
                child:Bubble(
                  direction: BubbleDirection.left,
                  color: Colors.purple,
                  child: Text(messageBean.msg),
                ),
              ),
            ],
          ),
        ),
      ):Container(
        child: Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Flexible(
                child:Bubble(
                  direction: BubbleDirection.right,
                  color: Colors.purple,
                  child: Text(messageBean.msg),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: ClipOval(
                  child: Container(
                    width: 50,
                    height: 50,
                    child: Image.asset("images/img_1.jpeg",fit: BoxFit.cover,),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

}