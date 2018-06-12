import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'pages/login.dart';
import 'pages/home.dart';
import 'pages/routes.dart';
import 'pages/switchPlatform.dart';

import 'utils/cache.dart';
import 'utils/style.dart';
import 'utils/db.dart';
import 'utils/func.dart';
import 'utils/network.dart';

void main() {
    NetWork.isDebug = false;

  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  Future<Cache> getData() async {
    await DB.getDB();
    return await Cache.getInstace();
  }

  Widget _getHomePage() {
    String token = Cache.instance.token ?? '';
    String cdAdd = Cache.instance.cdadd ?? '';

    if (token.length > 0) {
      if (cdAdd.length > 0) {
        return new HomePage();
      } else {
        return new SwitchPlatformPage();
      }
    } else {
      return new LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      localizationsDelegates: [
        // ... app-specific localization delegate[s] here
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('zh', 'ZH'), // Chinese
        // ... other locales the app supports
      ],
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
        primaryColor: Style.COLOR_THEME,
        accentColor: Style.COLOR_THEME,
      ),
      home: Cache.instance != null
          ? _getHomePage()
          : new FutureBuilder<Cache>(
              future: getData(),
              builder: (BuildContext context, AsyncSnapshot<Cache> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Func.loadingWidget(context);
                  default:
                    if (snapshot.hasData) {
                      print('main FutureBuild....');

                      return _getHomePage();
                    } else {
                      return new Center(child: new CircularProgressIndicator());
                    }
                }
              },
            ),
      routes: routes,
    );
  }
}
