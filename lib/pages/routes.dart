
import 'package:flutter/material.dart';

import 'login.dart';
import 'passwd.dart';
import 'home.dart';

Map<String, WidgetBuilder>  routes = {
  LoginPage.route: (BuildContext context) => new LoginPage(),
  PasswordPage.route: (BuildContext context) => new PasswordPage(),
  HomePage.route: (BuildContext context) => new HomePage(),
};
