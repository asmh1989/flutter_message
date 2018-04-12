
import 'package:flutter/material.dart';

import 'login.dart';
import 'passwd.dart';

Map<String, WidgetBuilder>  Routes = {
  LoginPage.route: (BuildContext context) => new LoginPage(),
  PasswordPage.route: (BuildContext context) => new PasswordPage(),
};
