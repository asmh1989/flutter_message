import 'package:flutter/material.dart';

import '../utils/cache.dart';
import '../pages/login.dart';


class HomePage extends StatefulWidget{
  const HomePage({Key key}): super(key: key);

  static final String route = '/home';

  @override
  State<StatefulWidget> createState() {
    return new HomeState();
  }
}

class HomeState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('设备卡号'),
      ),
      body: new Text('hello'),

      floatingActionButton:new FloatingActionButton(
        onPressed: () async{
          Cache cache = await Cache.getInstace();
          cache.remove(KEY_TOKEN);
          cache.remove(KEY_ADMIN);
          Navigator.pushReplacementNamed(context, LoginPage.route);
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(
          Icons.lock_open,
          semanticLabel: '注销',
        ),
      )
    );
  }
}


