import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:emoji_picker/emoji_picker.dart';
import 'package:fastdev/bean/MessageBean.dart';
import 'package:fastdev/mywidgets/Bubble.dart';
import 'package:fastdev/mywidgets/ChatButtle.dart';
import 'package:fastdev/page/main/MainProvider.dart';
import 'package:fastdev/page/user/LoginProvider.dart';
import 'package:fastdev/screen/ScreenAdapter.dart';
import 'package:flustars/flustars.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:provider/provider.dart';
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

  
  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((d)=>_getRenderBox());

    super.initState();

    ///系统自带键盘弹出监听
    KeyboardVisibilityNotification().addNewListener(
      onChange: (bool visible) async {
        _showLeyBoard=visible;
        ///打开时判断当前imoji是否在显示,显示则关闭，
        setState(() {
          if(visible){
            _reSetWindow=true;
          }else{
            _reSetWindow=false;
          }
        });
        debugPrint("重置${_reSetWindow}");
        Timer(Duration(milliseconds: 100), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
//        Timer(Duration(milliseconds: 500), () => _scrollController.animateTo(_scrollController.position.maxScrollExtent,
//            duration: Duration(milliseconds: 10), curve: Curves.bounceIn));

      },
    );
    _focusNode.addListener((){
      if(_focusNode.hasFocus){

        if(isShowEmoji==true){
          setState(() {
            isShowEmoji=false;
          });
        }

      }
    });

  }
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
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
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

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
                      Flexible(child: TextField(
                        controller: _msgController,
                        focusNode: _focusNode,
                      ),
                      ),
                      IconButton(onPressed: (){
                        if(_showLeyBoard&&isShowEmoji==false){
                          _focusNode.unfocus();
                          Timer(Duration(milliseconds: 100), (){
                            setState(() {
                              isShowEmoji=true;
                            });
                          });
                        }else if(_showLeyBoard==false&&isShowEmoji==true){
                          setState(() {
                            isShowEmoji=false;
                          });
                          FocusScope.of(context).requestFocus(_focusNode);
                        }else{
                          setState(() {
                            isShowEmoji=true;
                          });
                        }
                       }, icon: _showLeyBoard?Icon(Icons.keyboard):Icon(Icons.sentiment_satisfied))
                      ,
                      IconButton(onPressed: (){
                        //发送成功。发送中。发送失败
                        if(_msgController.text.isEmpty){
                          return;
                        }
                        MessageBean msg=MessageBean("未du", "2020-05-08", _msgController.text, 0, Random().nextInt(2), "2020-05-08", 0);
                        Provider.of<ChatProvider>(context,listen: false).updateList(msg);
                        _msgController.clear();
                        Timer(Duration(milliseconds: 100), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
                       }, icon: Icon(Icons.send))
                    ],
                  ),
                ),
                Offstage(
                    key: _key,
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