import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/cache.dart';
import '../utils/assets.dart';
import '../utils/style.dart';
import 'passwd.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  static String route = '/login';

  @override
  State<StatefulWidget> createState() {
    return new LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  Cache _cache;
  String _username = '', _passwd = '';
  bool _remember = false, _loading=false;

  @override
  void initState() {
    super.initState();

    Cache.getInstace().then((Cache cache) {
      this._cache = cache;
      setState(() {
        _username = cache.username;
        _passwd = cache.passwd;
        _remember = cache.remember;
      });
    });
  }


  Future<Null> _login () async {
    await Cache.getInstace();
  }



  final TextEditingController _controller = new TextEditingController();


  @override
  Widget build(BuildContext context) {

    List<Widget> children = <Widget>[
      Center(
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
                  child: new TextFormField(
                    controller: _controller,
                    style: Style.inputTextStyle,
                    decoration: new InputDecoration(
                      prefixIcon: new Padding(
                        padding: EdgeInsets.all(12.0),
                        child: new Image.asset(
                          ImageAssets.icon_account,
                          height: 25.0,
                          width: 22.0,
                          fit: BoxFit.fill,
                        ),
                      ),
                      border: const UnderlineInputBorder(),
                      hintText: '请输入您的账号',
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                      hintStyle: Style.inputTextStyle,
                    ),
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
                  child: new TextFormField(
                    obscureText: true,
                    style: Style.inputTextStyle,
                    decoration: new InputDecoration(
                      prefixIcon: new Padding(
                        padding: EdgeInsets.all(12.0),
                        child: new Image.asset(
                          ImageAssets.icon_password,
                          height: 25.0,
                          width: 22.0,
                          fit: BoxFit.fill,
                        ),
                      ),
                      border:  new UnderlineInputBorder(),
                      hintText: '请输入密码',
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                      hintStyle: Style.inputTextStyle,
                    ),
                  ),
                )
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new GestureDetector(
                  onTap: () {
                    _cache.setBoolValue(KEY_REMEMBER, !_remember);
                    setState(() { _remember = !_remember; });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: new Image.asset(
                        _remember ? ImageAssets.icon_no_check_up : ImageAssets.icon_no_check_down,
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
                    onTap: (){
                      Navigator.pushNamed(context, PasswordPage.route);
                    },
                    child: new Text('忘记密码?', style: Style.tipsTextStyle)
                ),
                new GestureDetector(
                    onTap: (){

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
          child: new Text('度量云  技术支持', style: new TextStyle(fontSize: 12.0, color: Colors.white70)),
        ),
      )
    ];

    if(_loading){
      children.add(const Center (
          child: const CircularProgressIndicator()
      )
      );
    }


    return new Scaffold(
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
            child: new Stack(
              children: children,
            )
        )
    );
  }
}
