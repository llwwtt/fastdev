
import 'dart:io';
import 'package:common_utils/common_utils.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:fastdev/globalconfig/EnvironmentConfig.dart';
import 'package:flutter/cupertino.dart';

class NetUtil {
  static BuildContext context = null;
  static final host = 'http://192.168.1.22';
//  static final baseUrl = host + '/api/';
  static final baseUrl = host + '/zkpt-zhcx/';
  static ContentType formUrlencodedContentType =
  ContentType.parse("application/x-www-form-urlencoded");
  static ContentType jsonContentType =
  ContentType("application", "json", charset: "utf-8");
  // ignore: argument_type_not_assignable
  static final Dio _dio = new Dio(new BaseOptions(
      method: "get",
      baseUrl: baseUrl,
      connectTimeout: 5000,
      receiveTimeout: 5000,
      followRedirects: true));

  /// 代理设置，方便抓包来进行接口调节
//  static void setProxy() {
//    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
//      // config the http client
//      client.findProxy = (uri) {
//        //proxy all request to localhost:8888
//        return "PROXY localhost:8888";
//      };
//      // you can also create a new HttpClient to dio
//      // return new HttpClient();
//    };
//  }

//  static String token;

  static final LogicError unknowError = LogicError(-1, "未知异常");
  ///get
  static Future<Map<String, dynamic>> getJson<T>(
      String uri, Map<String, dynamic> paras,Map<String, dynamic> expandHeard) =>
      _httpJson("get", uri, data: paras,expandHeard: expandHeard).then(logicalErrorTransform);

  static Future<Map<String, dynamic>> getForm<T>(
      String uri, Map<String, dynamic> paras,Map<String, dynamic> expandHeard) =>
      _httpJson("get", uri, data: paras, dataIsJson: false,expandHeard: expandHeard)
          .then(logicalErrorTransform);

  /// 表单方式的post
  static Future<Map<String, dynamic>> postForm<T>(
      String uri, Map<String, dynamic> paras,Map<String, dynamic> expandHeard) =>
      _httpJson("post", uri, data: paras, dataIsJson: false,expandHeard: expandHeard)
          .then(logicalErrorTransform);

  /// requestBody (json格式参数) 方式的 post
  static Future<Map<String, dynamic>> postJson(
      String uri, Map<String, dynamic> body,Map<String, dynamic> expandHeard) =>
      _httpJson("post", uri, data: body,expandHeard: expandHeard).then(logicalErrorTransform);

  static Future<Map<String, dynamic>> deleteJson<T>(
      String uri, Map<String, dynamic> body,Map<String, dynamic> expandHeard) =>
      _httpJson("delete", uri, data: body,expandHeard: expandHeard).then(logicalErrorTransform);

  /// requestBody (json格式参数) 方式的 put
  static Future<Map<String, dynamic>> putJson<T>(
      String uri, Map<String, dynamic> body,Map<String, dynamic> expandHeard) =>
      _httpJson("put", uri, data: body,expandHeard: expandHeard).then(logicalErrorTransform);

  /// 表单方式的 put
  static Future<Map<String, dynamic>> putForm<T>(
      String uri, Map<String, dynamic> body,Map<String, dynamic> expandHeard) =>
      _httpJson("put", uri, data: body, dataIsJson: false,expandHeard: expandHeard)
          .then(logicalErrorTransform);

  /// 文件上传  返回json数据为字符串
  static Future<T> putFile<T>(String uri, String filePath) {
    var name =
    filePath.substring(filePath.lastIndexOf("/") + 1, filePath.length);
    var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);

    FormData formData=FormData.fromMap({
      "multipartFile": MultipartFile.fromFile("./text.txt",filename: "upload.txt")
    });
//    FormData formData = new FormData.from({
//      "multipartFile": new UploadFileInfo(new File(filePath), name,
//          contentType: ContentType.parse("image/$suffix"))
//    });

 //   var enToken = token == null ? "" : Uri.encodeFull(token);
//    return _dio
//        .put<Map<String, dynamic>>("$uri?token=$enToken", data: formData)
//        .then(logicalErrorTransform);
  }


  static Future<Response<Map<String, dynamic>>> _httpJson(
      String method, String uri,
      {Map<String, dynamic> expandHeard,Map<String, dynamic> data, bool dataIsJson = true}) {
    ///对token进行编码
//    var enToken = token == null ? "" : Uri.encodeFull(token);

    /// 如果为 get方法，则进行参数拼接
    if (method == "get") {
      dataIsJson = false;
      if (data == null) {
        data = new Map<String, dynamic>();
      }
//      data["token"] = token;
    }

    if (EnvironmentConfig.TEST) {
      LogUtil.e("请求信息---------start---------");
      LogUtil.e(uri);
      LogUtil.e(expandHeard);
      LogUtil.e(data);
      LogUtil.e("请求信息---------end---------");
    }

    /// 根据当前 请求的类型来设置 如果是请求体形式则使用json格式
    /// 否则则是表单形式的（拼接在url上）
    ///   ///表示期望以那种格式(方式)请求数据

    Options op;
    if (dataIsJson) {
      op = new Options(contentType: jsonContentType.toString());

    } else {
      op = new Options(
          contentType: formUrlencodedContentType.toString());
    }
    //扩展的头
    if(expandHeard!=null&&expandHeard.isNotEmpty){
      expandHeard.forEach((key,value){
        op.headers[key]=expandHeard[key];
      });
    }

    op.method = method;
    ///cookie管理。
//    _dio.interceptors.add(CookieManager(CookieJar()));

    ///添加拦截器。。。可以做一些需要的操作
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options){
        return options;
      },
      onResponse: (Response response){
        return response;
      },
      onError: (DioError error){
        return error;
      }
    ));
    //日志拦截器,测试环境需要输出日志，生产环境不需要
    _dio.interceptors.add(LogInterceptor(
      request: false,
      requestBody: false,
      requestHeader: false,
      responseBody: false,
      responseHeader: false
    ));

    /// 发起请求
    return _dio.request<Map<String, dynamic>>(
        uri,
        data: data,
        options: op);

  }

  /// 对请求返回的数据进行统一的处理
  /// 如果成功则将我们需要的数据返回出去，否则进异常处理方法，返回异常信息
  static Future<T> logicalErrorTransform<T>(Response<Map<String, dynamic>> resp) {
    //数据返回
    if (resp.data != null) {
      if (resp.data["code"] == 0) {
        T realData = resp.data["data"];
        return Future.value(realData);
      }
    }
    if (EnvironmentConfig.TEST) {
      LogUtil.e("接口返回信息---------start---------");
      LogUtil.e("all：$resp");
      LogUtil.e("allData:${resp.data}");
      LogUtil.e("接口返回信息---------end---------");
    }
    //封装的业务逻辑错误
    LogicError error;
    if (resp.data != null && resp.data["code"] != 0) {
      if (resp.data['data'] != null) {
        /// 失败时  错误提示在 data中时
        /// 收到token过期时  直接进入登录页面
        Map<String, dynamic> realData = resp.data["data"];
        error = new LogicError(resp.data["code"], realData['codeMessage']);
      } else {
        /// 失败时  错误提示在 message中时
        error = new LogicError(resp.data["code"], resp.data["message"]);
      }

      /// token失效 重新登录  后端定义的code码
      if (resp.data["code"] == 10000000) {
//        NavigatorUtils.goPwdLogin(context);

      }
      if(resp.data["code"] == 80000000){
        //操作逻辑
      }
    } else {
      error = unknowError;
    }
    return Future.error(error);
  }

  ///  获取token
  ///获取授权token
  static getToken() async {
//    String token = await LocalStorage.get(LocalStorage.TOKEN_KEY);
    String token="123";
    return token;
  }
}

class LogicError {
  int errorCode;
  String msg;

  LogicError(errorCode, msg) {
    this.errorCode = errorCode;
    this.msg = msg;
  }
}

enum PostType { json, form, file }
