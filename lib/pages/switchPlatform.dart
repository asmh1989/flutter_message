import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/network.dart';
import '../utils/cache.dart';
import '../utils/platformInfo.dart';
import '../utils/assets.dart';

import '../utils/style.dart';

class SwitchPlatformPage extends StatefulWidget {
  const SwitchPlatformPage({Key key}) : super(key: key);

  static const String route = '/switchPlatform';
  @override
  State<StatefulWidget> createState() {
    return new SwitchPlatformPageState();
  }
}

class SwitchPlatformPageState extends State<SwitchPlatformPage> {
  Future<http.Response> _getData() async {
    return NetWork.getPlatforms(Cache.instance.username, Cache.instance.token);
  }

  final GlobalKey<ScaffoldState> _scaffKey = new GlobalKey<ScaffoldState>();

  void _showMessage(String msg) {
    _scaffKey.currentState.showSnackBar(new SnackBar(
      content: new Text(msg, textAlign: TextAlign.center),
    ));
  }

  List<PlatformInfo> parsePlatforms(List<dynamic> data) {
    return data.map((json) => new PlatformInfo.fromJson(json)).toList();
  }

  Widget _buildListTile(
      BuildContext context, PlatformInfo item, GestureTapCallback onTap) {
    return new Container(
        color: Colors.white,
        child: new ListTile(
          leading: new Padding(
            padding: EdgeInsets.all(8.0),
            child: new Image.asset(
                item.eb == 2 ? ImageAssets.ic_off : ImageAssets.ic_on),
          ),
          title: new Text(item.name),
          trailing: new Icon(Icons.navigate_next),
          onTap: onTap,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffKey,
        appBar: new AppBar(
          title: new Text('平台选择'),
        ),
        body: new FutureBuilder<http.Response>(
            future: _getData(),
            builder:
                (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return new Center(child: new CircularProgressIndicator());
                default:
                  if (snapshot.hasData) {
                    http.Response response = snapshot.data;
                    if (response.statusCode != 200) {
                      return new Center(
                        child: new Text(response.toString()),
                      );
                    } else {
                      Map data = NetWork.decodeJson(response.body);
                      if (data['Code'] != 0) {
                        _showMessage(data['Message']);
                        return null;
                      } else {
                        print(data);
                        List<PlatformInfo> platforms =
                            parsePlatforms(data['Response']);

                        return new Container(
                            color: Style.COLOR_BACKGROUND,
                            height: MediaQuery.of(context).size.height,
                            child: new ListView.builder(
                              itemCount: platforms.length,
                              itemBuilder: (BuildContext contex, int index) {
                                PlatformInfo item = platforms[index];
                                return new Container(
                                    color: Colors.white,
                                    child: new ListTile(
                                      leading: new Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: new Image.asset(item.eb == 2
                                            ? ImageAssets.ic_off
                                            : ImageAssets.ic_on),
                                      ),
                                      title: new Text(item.name),
                                      trailing: new Icon(Icons.navigate_next),
                                      onTap: () {
                                        print('click $index');
                                      },
                                    ));
                              },
                            ));
                      }
                    }
                  }
              }
            }));
  }
}
