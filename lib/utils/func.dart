import 'package:flutter/material.dart';

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
}