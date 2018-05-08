
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class NetWork {

  static bool isDebug = true;

  static http.Client _client = new http.Client();

  ///
  /// 服务端接口
  ///

  static String _server = isDebug ? "http://122.225.71.14:8990" : "http://139.196.190.11:8990";//测试
//   static final String DL_API = "http://139.196.190.11:8990";//正式

  ///
  ///短信验证
  ///
  static String apiVerify = _server + "/api/verify.json";

  ///
  /// 用户注册
  ///
  static String apiRegister = _server + "/api/register.json";
  ///
  /// 用户登录
  ///
  static String apiLogin = _server + "/api/login.json";
  ///
  /// 找回密码
  ///
  static String apiFindPassword = _server + "/api/findpwd.json";
  ///
  /// 修改密码
  ///
  static String apiModifyPassword = _server + "/api/modifypwd.json";
  ///
  /// 平台数据
  ///
  static String apiPlatformList = _server + '/api/getlinks.json';

  ///
  /// 修改平台数据
  ///
  static String apiSetPlatformList = _server + '/api/setlinks.json';

  ///
  /// 获取用户列表
  ///
  static String apiGetUsers = _server+'/api/getusers.json';

  ///
  /// 修改用户信息
  ///
  static String apiSetUsers = _server+'/api/setusers.json';

  static Future<http.Response > post(String url, Map<String, dynamic> params) async {
    print('''$url => post: ${json.encode(params)}''');
    try {
      return _client.post(url, body: params);
    } catch (e){
      print('post error: $e');
      return null;
    }
  }

  static Map decodeJson(String data) {
    try {
      return json.decode(data);
    } catch (e){
      print(e.toString());
      return {
        'Code': -1,
        'Message': e.toString()
      };
    }
  }

  static Future<http.Response> getPhoneCode(String phone, bool isRegister) async {
    Map<String, dynamic> params = {
      'Unm': phone,
      'Tp': isRegister ? '1' : '2'
    };

    return post(apiVerify, params);
  }

  static Future<http.Response> getPlatforms(String name, String token, {bool isManager = false}){
    Map<String, dynamic> params = {
      'Unm': name,
      'Token': token,
      'Type': isManager ? '1' : '2',
      "Cndo":''
    };

    return post(apiPlatformList, params);
  }

}