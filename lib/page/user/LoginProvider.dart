import 'package:flutter/cupertino.dart';

class LoginInfo with ChangeNotifier{
  String _userName;
  String _pwd;
  LoginInfo(this._userName,this._pwd);

  setLoginInfo(String username,String pwd){
    this._userName=username;
    this._pwd=pwd;
    notifyListeners();
  }

  String get userName => _userName;

  String get pwd => _pwd;

}