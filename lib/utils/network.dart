
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class NetWork {

  static http.Client _client = new http.Client();

  ///
  /// 服务端接口
  ///

  static const String DL_API = "http://122.225.71.14:8990";//测试
//   static final String DL_API = "http://139.196.190.11:8990";//正式

  ///
  ///短信验证
  ///
  static const String VERIFY = DL_API + "/api/verify.json";

  ///
  /// 用户注册
  ///
  static const String REGISTER = DL_API + "/api/register.json";
  ///
  /// 用户登录
  ///
  static const String LOGIN = DL_API + "/api/login.json";
  ///
  /// 找回密码
  ///
  static const String FIND_PWD = DL_API + "/api/findpwd.json";
  ///
  /// 修改密码
  ///
  static const String MODIFY_PWD = DL_API + "/api/modifypwd.json";
  ///
  /// 平台数据
  ///
  static const String PLATFORM_LIST = DL_API + '/api/getlinks.json';


  static Future<http.Response > post(String url, Map<String, dynamic> params) async {
      return  _client.post(url, body: params);
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

    return post(VERIFY, params);
  }

  static Future<http.Response> getPlatforms(String name, String token){
    Map<String, dynamic> params = {
      'Unm': name,
      'Token': token,
      'Type': '2',
      "Cndo":''
    };

    return post(PLATFORM_LIST, params);
  }
}