import 'package:flutter/material.dart';
import 'package:fluttermap/fluttermap.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Map<dynamic, dynamic> _res = {};
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new RaisedButton(
                child: new Text('获取定位数据'),
                onPressed: ()async {
                  Map<dynamic, dynamic> data = await Fluttermap.getLocation;                  
                  _res = {
                    'lat': data['lat'],
                    'lng': data['lng'],
                    'adress': data['address']
                  };

                  print('获取定位数据, $data');
                }
              ),
              new SizedBox(height: 16.0),
              new RaisedButton(
                child: new Text('打开地图'),
                onPressed: () {
                  Fluttermap.openMap(
                    lat: _res['lat']??0.0,
                    lng: _res['lng']??0.0,
                    addr: _res['address']??''
                  );
                },
              )
            ],
          )
        ),
      ),
    );
  }
}
