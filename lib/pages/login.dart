import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/cache.dart';
import '../utils/assets.dart';
import '../utils/style.dart';
import '../utils/func.dart';
import '../utils/network.dart';
import '../utils/db.dart';

import '../ui/clearTextFieldForm.dart';

import 'passwd.dart';
import 'home.dart';
import 'register.dart';
import 'switchPlatform.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  static const String route = '/login';

  @override
  State<StatefulWidget> createState() {
    return new LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  Cache _cache ;
  String _username, _password;
  bool _remember,  _loading=false;

  @override
  void initState() {
    super.initState();

    _cache = Cache.instance;
    _username = _cache.username??'';
    _password = _cache.password??'';
    _remember = _cache.remember?? false;

  }

  void _showMessage(String msg) {
    _scaffKey.currentState.showSnackBar(new SnackBar(
      content: new Text(msg, textAlign: TextAlign.center),
    ));
  }

  Future<Null> _login () async {
    FocusScope.of(context).requestFocus(new FocusNode());

    /// 验证用户名
    if(!Func.validatePhone(_userKey.currentState.text)) {
      _showMessage('手机号格式不正确');
      _userKey.currentState.clear();
      return;
    }

    if(_passwdKey.currentState.text.length == 0) {
      _showMessage('密码为空');
      return;
    }


    setState(() {
      _loading = true;
    });

    http.Response response= await NetWork.post(NetWork.LOGIN, {
      'Unm': _userKey.currentState.text,
      'Upd': _passwdKey.currentState.text,
    });

    Future.delayed(new Duration(milliseconds: 200), () async {
      setState(() {
        _loading = false;
      });

      if(response.statusCode == 200) {
        print(response.body);

        Map data = NetWork.decodeJson(response.body);
        if(data['Code'] != 0){
          _showMessage(data['Message']);
          _passwdKey.currentState.clear();
        } else {
          _cache.setStringValue(KEY_USERNAME, _userKey.currentState.text);
          _cache.setStringValue(KEY_PASSWORD, _passwdKey.currentState.text);

          Map res = data['Response'];

          if(res != null){
            await _cache.setStringValue(KEY_TOKEN, res['Token']);
            await _cache.setIntValue(KEY_ADMIN, res['Admin']);

            KeyValue value = await DB.instance.queryOne<KeyValue>(where: '${KeyValueTable.key} = ?', whereArgs: [_userKey.currentState.text]);

            print('found cdadd = ${value.value}');
            if(value == null){
              Navigator.pushReplacementNamed(context, SwitchPlatformPage.route);
            } else {
              Navigator.pushReplacementNamed(context, HomePage.route);
            }
          } else {
            _showMessage('返回格式错误: $res');
          }

        }
      }
    });

  }


  final GlobalKey<ClearTextFieldFormState> _userKey = new GlobalKey<ClearTextFieldFormState>();
  final GlobalKey<ClearTextFieldFormState> _passwdKey = new GlobalKey<ClearTextFieldFormState>();
  final GlobalKey<ScaffoldState> _scaffKey = new GlobalKey<ScaffoldState>();

  List<Widget> _buildLoginForm() {
    return <Widget>[
      new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Image.asset(
              ImageAssets.ic_login_logo,
              width: 150.0,
              height: 40.0,
            ),
            new SizedBox(height: 20.0),
            new Container(
                height: 60.0,
                child: new Theme(
                  data: new ThemeData(
                      primaryColor: Colors.white,
                      accentColor: Colors.white,
                      hintColor: Colors.white
                  ),
                  child: new ClearTextFieldForm(
                    key: _userKey,
                    icon: new Image.asset(
                      ImageAssets.icon_account,
                      height: 25.0,
                      width: 22.0,
                    ),
                    keyboardType: TextInputType.phone,
                    hintText: '请输入您的账号',
                    hintStyle: Style.inputTextStyle,
                    initialValue: _remember ? _username: '',
                    style: Style.inputTextStyle,
                  ),
                )
            ),
            new Container(
                height: 60.0,
                child: new Theme(
                  data: new ThemeData(
                      primaryColor: Colors.white,
                      accentColor: Colors.white,
                      hintColor: Colors.white
                  ),
                  child: new ClearTextFieldForm(
                    key: _passwdKey,
                    obscureText: true,
                    initialValue: _remember ? _password : '',
                    style: Style.inputTextStyle,
                    hintStyle: Style.inputTextStyle,
                    hintText: '请输入密码',
                    icon: new Image.asset(
                      ImageAssets.icon_password,
                      height: 25.0,
                      width: 22.0,
                    ),
                  ),
                )
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new GestureDetector(
                  onTap: () {
                    setState(() {
                      _remember = !_remember;
                    });
                    _cache.setBoolValue(KEY_REMEMBER, _remember);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: new Image.asset(
                        _remember ? ImageAssets.icon_no_check_down : ImageAssets
                            .icon_no_check_up,
                        height: 20.0,
                        width: 20.0
                    ),
                  ),
                ),
                new Text('记住密码', style: Style.tipsTextStyle)
              ],
            ),
            new SizedBox(height: 30.0),
            new RaisedButton(
              color: const Color(0xFF029de0),
              highlightColor: const Color(0xFF029de0),
              child: const Text('登 录', style: Style.loginTextStyle),
              padding: EdgeInsets.all(10.0),
              onPressed: this._login,
            ),
            new SizedBox(height: 10.0),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, PasswordPage.route);
                    },
                    child: new Text('忘记密码?', style: Style.tipsTextStyle)
                ),
                new GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, RegisterPage.route);
                    },
                    child: new Text('新用户注册', style: Style.tipsTextStyle,))
              ],
            )
          ],
        ),
      ),
      new Positioned(
        bottom: 20.0,
        left: 0.0,
        right: 0.0,
        child: new Center(
          child: new Text('度量云  技术支持',
              style: new TextStyle(fontSize: 12.0, color: Colors.white70)),
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {

//    print('remember=$_remember, username=$_username, passwd=$_passwd');

    List<Widget> children = _buildLoginForm();

    if(_loading){
      children.add(
          new Positioned.fill(
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
              )
          )
      );
    }
    return new Scaffold(
        key: _scaffKey,
        resizeToAvoidBottomPadding: false,
        body: new Container(
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const<Color>[const Color(0xFF779ac2), const Color(0xFF4ca8d9), const Color(0xFF417eaa)],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child:new Stack(
              children: children,
            )

        )
    );
  }
}
