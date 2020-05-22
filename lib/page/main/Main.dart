import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
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

  var _reSetWindow=false;

  bool _showLeyBoard=false;
  String _token="GZC3xRmauT4FF83b31gKPjr48d8OZbdNY9t+Zp8ergXVEFhwGjCBqw==@b26u.cn.rongnav.com;b26u.cn.rongcfg.com";
  @override
  void initState() {
    // TODO: implement initState
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
              if(_focusNode.hasFocus){
                isShowEmoji=false;
              }
            }
          });
        }
        Timer(Duration(milliseconds: 100), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));
      },
    );

  }
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if(_showLeyBoard){
      debugPrint("didChangeDependencies：${MediaQuery.of(context).viewInsets.bottom}");
      setState(() {
        keyHeight=MediaQuery.of(context).viewInsets.bottom;//获取键盘的高度，最好是持久化保存的数据，暂时使用临时获取的
        isShowEmoji=true;
      });
      //print("键盘的高度 = $keyHeight");

    }


    Timer(Duration(milliseconds: 100), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));

  }
  @override
  void dispose() {
    // TODO: implement dispose
    KeyboardVisibilityNotification().dispose();
    _focusNode.dispose();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();

  }
  double bootomHeight=0.0;
  FocusNode _focusNode = FocusNode();
  bool isShowEmoji=false;
  double keyHeight=0.0;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print('-----------build=--------------');

    dynamic value=ModalRoute.of(context).settings.arguments;
    String  taggetid=value["taggetid"];
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
                       ),),
                      IconButton(onPressed: (){
                        //emoji一直都是显示的。控制的是键盘的打开与关闭。键盘的打开与关闭打开不用考虑，当主动关闭时，emoji也需要关闭。
                        debugPrint("当前_showLeyBoard：$_showLeyBoard,当前isShowEmoji：$isShowEmoji");
                        if(_showLeyBoard){
                          FocusScope.of(context).requestFocus(FocusNode());
                        }else{
                          _focusNode.unfocus();
                          FocusScope.of(context).requestFocus(_focusNode);
                        }
                       }, icon: _showLeyBoard?Icon(Icons.keyboard):Icon(Icons.sentiment_satisfied),
                      ),
                      IconButton(onPressed: (){
                        //发送成功。发送中。发送失败
                        if(_msgController.text.isEmpty){
                          return;
                        }
                        TextMessage txtMessage = TextMessage.obtain(_msgController.text);
                        Provider.of<ChatProvider>(context,listen: false).sendMsg(txtMessage,taggetid,RCMessageDirection.Send);
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
        ],
      ),
    );
  }
}
class ChatItem extends StatelessWidget{

  ChatItem({Key key, this.messageBean}) : super(key: key);
  final Message messageBean;

  @override
  Widget build(BuildContext context) {
    //
    return Consumer(builder: (_,ChatProvider provider,child){
      return   buildChatWidget(messageBean);
    });
  }
  //判断在哪边显示，以及显示什么内容
  Widget buildChatWidget(Message messageBean) {

    if(RCMessageDirection.Receive==messageBean.messageDirection){
      Map map=jsonDecode(messageBean.content.encode());
      String strContent=map["content"];
      print("收到的：$strContent");
      switch(messageBean.objectName){
        case TextMessage.objectName:
          return Align(
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
                    child: Text(strContent),
                  ),
                ),
              ],
            ),
          );
        case ImageMessage.objectName:
          return Align(
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
                    child: CachedNetworkImage(
                      imageUrl: "http://via.placeholder.com/350x150",
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
              ],
            ),
          );
      }
    }else if(RCMessageDirection.Send==messageBean.messageDirection){
      Map map=jsonDecode(messageBean.content.encode());
      String strContent=map["content"];
      print("发送的的：$strContent");

      switch(messageBean.objectName){
        case TextMessage.objectName:
         return Container(
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  child:Bubble(
                    direction: BubbleDirection.right,
                    color: Colors.purple,
                    child: Text(strContent),
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
        case ImageMessage.objectName:
          return Container(
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Flexible(
                    child:Bubble(
                      direction: BubbleDirection.right,
                      color: Colors.purple,
                      child: CachedNetworkImage(
                        imageUrl: "http://via.placeholder.com/350x150",
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
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
      }

    }else{

    }
  }

}