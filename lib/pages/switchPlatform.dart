import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/network.dart';
import '../utils/cache.dart';
import '../utils/platformInfo.dart';
import '../utils/assets.dart';

import '../utils/style.dart';
import '../utils/db.dart';
import '../utils/func.dart';

import 'home.dart';
import 'login.dart';
import 'platformEdit.dart';

class SwitchPlatformPage extends StatefulWidget {
  const SwitchPlatformPage({Key key, this.isManager = false}) : super(key: key);

  static const String route = '/switchPlatform';

  final bool isManager;
  @override
  State<StatefulWidget> createState() {
    return new SwitchPlatformPageState();
  }
}

class SwitchPlatformPageState extends State<SwitchPlatformPage> {

  List<PlatformInfo>  _platforms;

  Future<http.Response> _getData() async {
    return NetWork.getPlatforms(Cache.instance.username, Cache.instance.token, isManager: widget.isManager);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _click(int index) async {
    PlatformInfo info = _platforms[index];

    if(!widget.isManager) {

      KeyValue value = new KeyValue(
          key: Cache.instance.username, value: info.cdno);

      await DB.instance.insertOrUpdate<KeyValue>(
          value, where: '${KeyValueTable.key} = ?', whereArgs: [value.key]);

      Cache.instance.setStringValue(KEY_CDNO, info.cdno);
      Cache.instance.setStringValue(KEY_CDADD, info.name);
      Cache.instance.setStringValue(KEY_CDURL, info.cdurl);
      Cache.instance.setStringValue(KEY_CDTOKEN, info.cdtoken);

      if (Navigator.canPop(context)) {
        Navigator.pop(context, 'refresh');
      } else {
        Navigator.pushReplacementNamed(context, HomePage.route);
      }
    } else {
      Navigator.push(context, new MaterialPageRoute(
          builder: (BuildContext context) => new PlatformEdit(info: info,))
      );
    }
  }

  List<PlatformInfo> parsePlatforms(List<dynamic> data) {
    return data.map((json) => new PlatformInfo.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [];
    if(widget.isManager){
      actions.add(new IconButton(icon: new Icon(Icons.add),
          tooltip: '增加平台',
          onPressed: (){
            Navigator.push(context, new MaterialPageRoute(
                builder: (BuildContext context) => new PlatformEdit()
            ));
          }));
    }

    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text(widget.isManager ? '平台列表' : '平台选择'),
          actions: actions,
        ),
        body: new FutureBuilder<http.Response>(
            future: _getData(),
            builder:
                (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Func.loadingWidget(context);
                default:
                  if (snapshot.hasData) {
                    http.Response response = snapshot.data;
                    if (response.statusCode != 200) {
                      return Func.logoutWidget(context, response.toString());
                    } else {
                      Map data = NetWork.decodeJson(response.body);
//                      print(data);

                      if (data['Code'] != 0) {
                        return new Center(
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new Text(data['Message']),
                                new SizedBox(height: 10.0,),
                                new RaisedButton(
                                    child: new Text('登出'),
                                    onPressed: (){
                                      Navigator.pushReplacementNamed(context, LoginPage.route);
                                    })
                              ],
                            )
                        );
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
                                          title: new Text(item.name, style: new TextStyle(color:  item.eb == 2 ? Colors.grey :Colors.black),),
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

  @override
  void dispose() {
    super.dispose();
    if(_platforms != null){
      _platforms.clear();
    }
  }
}
