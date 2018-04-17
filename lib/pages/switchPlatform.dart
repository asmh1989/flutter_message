import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/network.dart';
import '../utils/cache.dart';
import '../utils/platformInfo.dart';
import '../utils/assets.dart';

import '../utils/style.dart';
import '../utils/db.dart';

import 'home.dart';

class SwitchPlatformPage extends StatefulWidget {
  const SwitchPlatformPage({Key key}) : super(key: key);

  static const String route = '/switchPlatform';
  @override
  State<StatefulWidget> createState() {
    return new SwitchPlatformPageState();
  }
}

class SwitchPlatformPageState extends State<SwitchPlatformPage> {

  List<PlatformInfo>  _platforms;

  Future<http.Response> _getData() async {
    return NetWork.getPlatforms(Cache.instance.username, Cache.instance.token);
  }

  final GlobalKey<ScaffoldState> _scaffKey = new GlobalKey<ScaffoldState>();

  void _showMessage(String msg) {
    _scaffKey.currentState.showSnackBar(new SnackBar(
      content: new Text(msg, textAlign: TextAlign.center),
    ));
  }

  void _click(int index) async {

    PlatformInfo info = _platforms[index];

    KeyValue value = new KeyValue(key: Cache.instance.username, value: info.cdno);

    await DB.instance.insertOrUpdate<KeyValue>(value, where: '${KeyValueTable.key} = ?', whereArgs: [value.key]);

    Cache.instance.setStringValue(KEY_CDNO, info.cdno);
    Cache.instance.setStringValue(KEY_CDADD, info.name);
    Cache.instance.setStringValue(KEY_CDURL, info.cdurl);
    Cache.instance.setStringValue(KEY_CDTOKEN, info.cdtoken);

    if(Navigator.canPop(context)) {
      Navigator.pop(context, 'refresh');
    } else {
      Navigator.pushReplacementNamed(context, HomePage.route);
    }

  }

  List<PlatformInfo> parsePlatforms(List<dynamic> data) {
    return data.map((json) => new PlatformInfo.fromJson(json)).toList();
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
                      print(data);

                      if (data['Code'] != 0) {
                        return new Center(child: new Text(data['Message']),);
                      } else {
                        _platforms = parsePlatforms(data['Response']);

                        return new Container(
                            color: Style.COLOR_BACKGROUND,
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            height: MediaQuery.of(context).size.height,
                            child: new ListView.builder(
                              itemCount: _platforms.length,
                              itemBuilder: (BuildContext context, int index) {
                                PlatformInfo item = _platforms[index];

                                final Decoration decoration = new BoxDecoration(
                                  border: new Border(
                                    bottom: Divider.createBorderSide(context),
                                  ),
                                );

                                return new Container(
                                    color: Colors.white,
                                    child: new DecoratedBox(
                                        position: DecorationPosition.foreground,
                                        decoration: decoration,
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
                                            _click(index);
                                          },
                                        )
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
