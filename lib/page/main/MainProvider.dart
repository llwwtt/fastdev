import 'dart:convert';

import 'package:fastdev/bean/MessageBean.dart';
import 'package:flutter/material.dart';
import 'package:rongcloud_im_plugin/rongcloud_im_plugin.dart';

class ChatProvider with ChangeNotifier{


  double keyBoardHeight;
  void setKeyBoardHeight(double height){
    this.keyBoardHeight=height;
    notifyListeners();
  }
  double getKeyBoardHeight(){
    return keyBoardHeight;
  }



  String privateUserId="18811785120";
  List<MessageBean> _msgList;

  List<MessageBean> get msgList => _msgList==null?List():_msgList;
  //在构造函数中初始化接收
  ChatProvider(){
    if(_msgList==null){
      _msgList=List();
    }
    
    RongcloudImPlugin.onMessageReceivedWrapper = (Message msg, int left, bool hasPackage, bool offline) {
      Map map=jsonDecode(msg.content.encode());
      String strContent=map["content"];
      _msgList.add(MessageBean("、", "、", strContent, 1, 1, "msgTime",1 ));
      notifyListeners();
    };
  }
  ///发送消息
  void sendMsg(MessageBean messageBean,){
    TextMessage txtMessage = new TextMessage();
    txtMessage.content = messageBean.msg;
    RongcloudImPlugin.sendMessage(RCConversationType.Private, "15011381883", txtMessage).then((msg){
      _msgList.add(messageBean);
      notifyListeners();

    });
  }
  ///删除消息
  void deleteMsg(){

  }
  void refreshMsgList(){
    RongcloudImPlugin.onMessageReceivedWrapper = (Message msg, int left, bool hasPackage, bool offline) {
      print("接收到的信息receive message messsageId:"+msg.content.encode()+" left:"+left.toString());
    };
  }

}