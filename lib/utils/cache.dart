import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

const String KEY_TOKEN = "__token";
const String KEY_CDADD = "__cdadd";
const String KEY_USERNAME = "__username";
const String KEY_PASSWORD = "__password";
const String KEY_REMEMBER = "__remember";
const String KEY_ADMIN = '__admin';
const String KEY_CDNO = '__cdno';
const String KEY_CDURL='__cdurl';
const String KEY_CDTOKEN = '__cdtoken';

class Cache {
  Cache._(this._prefs);

  static Cache instance;
  final SharedPreferences _prefs;

  static Future<Cache> getInstace() async {
    if(instance == null){
      Future<SharedPreferences> prefs = SharedPreferences.getInstance();
      instance = new Cache._(await prefs);
    }

    return instance;
  }

  String get token => _getString(KEY_TOKEN);
  String get cdadd => _getString(KEY_CDADD);
  String get username => _getString(KEY_USERNAME);
  String get password => _getString(KEY_PASSWORD);
  bool get remember => _getBool(KEY_REMEMBER);
  int get admin => _getInt(KEY_ADMIN);
  String get cdno => _getString(KEY_CDNO);
  String get cdurl => _getString(KEY_CDURL);
  String get cdtoekn => _getString(KEY_CDTOKEN);

  String _getString(String key){
    return  _prefs.getString(key)?? "";
  }

  bool _getBool(String key) {
    return _prefs.getBool(key)?? false;
  }

  int _getInt(String key) {
    return _prefs.getInt(key);
  }

  Future<bool> setStringValue(String key, String value) async {
    return _prefs.setString(key, value);
  }

  Future<bool> setBoolValue(String key, bool value) async => _prefs.setBool(key, value);

  Future<bool> setIntValue(String key, int value) async => _prefs.setInt(key, value);
  void remove(String key) {
    _prefs.remove(key);
  }
}

