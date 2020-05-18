import 'package:fastdev/bean/MessageBean.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier{
  List<MessageBean> _msgList;

  List<MessageBean> get msgList => _msgList==null?List():_msgList;

  void updateList(MessageBean messageBean){
    if(_msgList==null){
      _msgList=List();
      _msgList.add(messageBean);
      notifyListeners();
    }else{
      _msgList.add(messageBean);
      notifyListeners();
    }

  }

}