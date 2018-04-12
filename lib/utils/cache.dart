import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

const String KEY_TOKEN = "__token";
const String KEY_CDADD = "__cdadd";
const String KEY_USERNAME = "__username";
const String KEY_PASSWORD = "__password";
const String KEY_REMEMBER = "__remember";

class Cache {
  Cache._(this._prefs);

  static Cache _instance;
  final SharedPreferences _prefs;

  static Future<Cache> getInstace() async {
    if(_instance == null){
      Future<SharedPreferences> prefs = SharedPreferences.getInstance();
      _instance = new Cache._(await prefs);
    }

    return _instance;
  }

  String get token => _getString(KEY_TOKEN);
  String get cdadd => _getString(KEY_CDADD);
  String get username => _getString(KEY_USERNAME);
  String get passwd => _getString(KEY_PASSWORD);
  bool get remember => _getBool(KEY_REMEMBER);

  String _getString(String key){
    return  _prefs.getString(key)?? "";
  }

  bool _getBool(String key) {
    return _prefs.getBool(key)?? false;
  }

  Future<bool> setStringValue(String key, String value) async {
    return _prefs.setString(key, value);
  }

  Future<bool> setBoolValue(String key, bool value) async => _prefs.setBool(key, value);

}

