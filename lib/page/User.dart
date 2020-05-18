import 'package:flutter/material.dart';

class UserModel with ChangeNotifier{
  int _count=0;

  int get count => _count;

  set count(int value) {
    _count = value;
  } //提供用户的操作
  void addCount(){
    _count++;
    notifyListeners();
  }

  void updateUserInfo(){

  }
}