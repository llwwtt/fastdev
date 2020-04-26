import 'dart:io';

import 'package:dio/dio.dart';

import 'DioManager.dart';
import 'common_error_handler_utils.dart';



/// 所有接口请求

class ApiInterface {
  static final String _API_GET = "user/";


  static Future<Map<String, dynamic>> getSmsCode(
      String flag, String phoneNum, String vefifyCode) async {
    return NetUtil.postJson(_API_GET,
        {"flagId": flag, "phone": phoneNum, "vefifyCode": vefifyCode},{});
  }


  static final String _API_GET_TEAM_FUND = '';
  static Future<Map<String, dynamic>> getTeamFund(
      LoginInvalidHandler handler) async {
    return NetUtil.getJson(_API_GET_TEAM_FUND, {},{})
        .catchError(handler.loginInvalidHandler);
  }
  static final String REGISTER = '/zkpt-zhcx/user/v1/register';

  static Future<Map<String, dynamic>> register(
      String phone, String pwd) async {
    return NetUtil.postJson(REGISTER,
        {
          "password": pwd,
          "phoneNumber": phone,

          },
        {});
  }
}
