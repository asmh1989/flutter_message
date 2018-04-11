import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/cache.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new LoginPageState();
  }
}

class LoginPageState extends State<LoginPage> {
  Cache _cache;
  String _username, _passwd;
  bool _remember, _loading=false;

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



  @override
  Widget build(BuildContext context) {

    List<Widget> children = <Widget>[
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Image.asset(
              ImageAssets.poweredByTMDBLogo,
              width: 32.0,
            ),
            new Expanded(child: Text('登录'))
          ],
        )
    ];

    if(_loading){
      children.add(const Center (
          child: const CircularProgressIndicator()
        )
      );
    }


    return new Scaffold(
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
