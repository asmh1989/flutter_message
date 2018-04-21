import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../pages/login.dart';

class Func {
  static bool  validatePhone(String value) {
    final RegExp phoneExp = new RegExp(r'^((1[3-8][0-9])+\d{8})$');
    return phoneExp.hasMatch(value);
  }

  static Widget loadingWidget(BuildContext context) =>  new Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: new Center(
        child: new CircularProgressIndicator(),
      )
  );

  static Widget logoutWidget(BuildContext context, String msg, [Widget button]) =>  new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(msg),
          new SizedBox(height: 10.0),
          button??new RaisedButton(
              child: new Text('退出登录'),
              onPressed: (){
                Navigator.pushReplacementNamed(context, LoginPage.route);
              })
        ],
      )
  );

  static Widget topLoadingWidgetInChildren () => new Positioned.fill(
      child: new GestureDetector(
          onTap: (){},
          behavior: HitTestBehavior.opaque,
          child: new Center(
              child: new Theme(
                data: new ThemeData(
                  accentColor: Colors.red,
                ),
                child: new Container(
                    height: 60.0,
                    width: 60.0,
                    child:new CircularProgressIndicator(
                    )
                ),
              )
          )
      ));

  static  FormFieldValidator<String>  validateNull(String msg){
    return (String value) {
      if(value.isEmpty){
        return msg;
      }

      return null;
    };
  }

  static void showMessage(GlobalKey<ScaffoldState> key, String value) {
    key.currentState.showSnackBar(new SnackBar(
        content: new Text(value, textAlign: TextAlign.center)
    ));
  }

  /// 标准的unix时间戳 需要扩大1000倍
  static String getYearMonthDay(int mill){
//    print('getYearMonthDay=$mill');
    DateTime time = new DateTime.fromMillisecondsSinceEpoch(mill);
    var formatter = new DateFormat('yyyy-MM-dd');
    return formatter.format(time);
  }

  static String getFullTimeString(int mill){
    DateTime time = new DateTime.fromMillisecondsSinceEpoch(mill);
    var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(time);
  }

  static String mapToString(Map map){
    return json.encode(map);
  }

}