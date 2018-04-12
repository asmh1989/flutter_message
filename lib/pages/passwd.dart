import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/style.dart';
import '../utils/assets.dart';


class PasswordPage extends StatefulWidget{
  const PasswordPage({Key key}): super(key: key);

  static String route = '/passwd';

  @override
  State<StatefulWidget> createState() {
    return new PasswordState();
  }
}

enum RightWidgetType {
  PHONE,
  MESSAGE,
  PASSWORD,
}


class PasswordState extends State<PasswordPage>{

  final TextEditingController _controller = new TextEditingController();

  Widget _getRightWidget(RightWidgetType type) {
    switch(type){
      case RightWidgetType.PHONE:
        return
          new GestureDetector(
              onTap: () {

              },
              child: new Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.0),
                child: new Image.asset(
                  ImageAssets.clearfill,
                  height: 20.0,
                  fit: BoxFit.fill,
                  color: Colors.black38,
                ),
              )
          );
      case RightWidgetType.PASSWORD:
        return new GestureDetector(
            onTap: (){

            },
            child: new Padding(
              padding: EdgeInsets.all(12.0),
              child: new Image.asset(
                ImageAssets.ic_close_dialog,
                height: 25.0,
                fit: BoxFit.fill,
              ),
            )
        );
      case RightWidgetType.MESSAGE:
        return new RaisedButton(
          color: const Color(0xFF029de0),
          highlightColor: const Color(0xFF029de0),
          child: const Text('获取验证码',
              style: const TextStyle(
                inherit: false,
                fontSize: 14.0,
                color: Colors.white,
                textBaseline: TextBaseline.alphabetic,
              )
          ),
          padding: EdgeInsets.symmetric(vertical: 6.0),
          onPressed: this._confirm,
        );
    }
  }

  Widget _getTextFeildForm(String imageName, String hintText, RightWidgetType type ) {
    return new Container(
        height: 60.0,
        child:  new TextFormField(
          obscureText: type == RightWidgetType.PASSWORD,
          decoration: new InputDecoration(
            prefixIcon: new Padding(
              padding: EdgeInsets.all(12.0),
              child: new Image.asset(
                imageName,
                height: 25.0,
                fit: BoxFit.fill,
              ),
            ),
            suffixIcon: _getRightWidget(type),
            border: const UnderlineInputBorder(),
            hintText: hintText,
            contentPadding: EdgeInsets.symmetric(vertical: 12.0),
          ),
        )
    );
  }
  Future<Null> _confirm () async {
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> children = <Widget>[
      new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          _getTextFeildForm(ImageAssets.icon_reg_account, '请输入手机号', RightWidgetType.PHONE),
          _getTextFeildForm(ImageAssets.icon_reg_verification, '请输入验证码', RightWidgetType.MESSAGE),
          _getTextFeildForm(ImageAssets.icon_reg_password, '请输入新密码', RightWidgetType.PASSWORD),
          _getTextFeildForm(ImageAssets.icon_ensure_password, '请确认新密码', RightWidgetType.PASSWORD),
          new SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 0.0 : 30.0),
          new RaisedButton(
            color: const Color(0xFF029de0),
            highlightColor: const Color(0xFF029de0),
            child: const Text('确认', style: Style.loginTextStyle),
            padding: EdgeInsets.all(10.0),
            onPressed: this._confirm,
          ),

        ],
      ),
    ];

    return new Scaffold(
        appBar: new AppBar(
          title: const Text('忘记密码'),
        ),
        body: new Container(
          padding: const EdgeInsets.all(30.0),

          child: new Stack(
            children: children,
          ),
        )

    );
  }
}