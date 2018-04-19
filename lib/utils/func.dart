import 'package:flutter/material.dart';

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

  static Widget logoutWidget(BuildContext context, String msg) =>  new Container(
      height: MediaQuery.of(context).size.height,
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new Text(msg),
          new RaisedButton(
              child: new Text('登出'),
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

    return '${time.year}-${time.month}-${time.day}';
  }
}