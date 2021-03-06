
import 'package:flutter/material.dart';

import 'login.dart';
import 'passwd.dart';
import 'home.dart';
import 'register.dart';
import 'switchPlatform.dart';

Map<String, WidgetBuilder>  routes = {
  LoginPage.route: (BuildContext context) => new LoginPage(),
  PasswordPage.route: (BuildContext context) => new PasswordPage(),
  HomePage.route: (BuildContext context) => new HomePage(),
  RegisterPage.route: (BuildContext context) => new RegisterPage(),
  SwitchPlatformPage.route: (BuildContext context) => new SwitchPlatformPage()
};
