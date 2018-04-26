import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fluttermap/fluttermap.dart';

import '../model/cardInfo.dart';

import '../utils/index.dart';

import 'msgDetail.dart';

class CardDetailPage extends StatefulWidget {
  final CardInfo card;
  const CardDetailPage({@required this.card});

  @override
  State<StatefulWidget> createState() {
    return new CardDetailState();
  }
}

class CardDetailState extends State<CardDetailPage> {
  CardInfo _card;

  @override
  void initState() {
    super.initState();
    _card = widget.card ?? new CardInfo();
  }

  void _get() async {
    String url = Cache.instance.cdurl + '/api/getnos.json';

    http.Response response = await NetWork.post(url, {
      'Unm': Cache.instance.username,
      'Cdtoken': Cache.instance.cdtoekn,
      'Token': Cache.instance.token,
      'No': _card.no ?? '',
      'Idx': '1',
      'Size': '100'
    });

    if (response.statusCode == 200) {
      Map data = NetWork.decodeJson(response.body);
      if (data['Code'] == 0) {
        List<CardInfo> cards = CardInfo.parseCards(data['Response']);
        if (cards.length > 0 && mounted) {
          setState(() {
            _card = cards[0];
          });
        }
      }
    }
  }

  bool get isRightLocation {
    try {
      double lat = _card.coord['Lat'];
      double lng = _card.coord['Lng'];
      if (lat != 0.0 && lng != 0.0)
        return true;
    } catch (e) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Stack(
            children: <Widget>[
              new Container(
                  height: 150.0 + MediaQuery.of(context).padding.top,
                  width: MediaQuery.of(context).size.width,
                  padding: new EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top),
                  decoration: new BoxDecoration(
                      image: new DecorationImage(
                          image: new AssetImage(ImageAssets.ic_bg_person),
                          fit: BoxFit.cover)),
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Image.asset(
                        ImageAssets.ic_card_detail,
                        height: 72.0,
                        width: 72.0,
                      ),
                      new SizedBox(height: 8.0),
                      new Text(_card.no,
                          style: new TextStyle(
                              color: Colors.white, fontSize: 16.0)),
                    ],
                  )),
              new Container(
                padding: new EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top),
                child: new IconButton(
                    icon: new Image.asset(
                      ImageAssets.icon_back,
                      height: 44.0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              )
            ],
          ),
          new Expanded(
              child: new Container(
            color: Style.COLOR_BACKGROUND,
            padding: EdgeInsets.only(top: 8.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                new Expanded(
                    child: new Container(
                        color: Style.COLOR_BACKGROUND,
                        child: new SingleChildScrollView(
                            child: new Container(
                                color: Colors.white,
                                child: new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      new Divider(height: 0.5),
                                      new Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0, horizontal: 16.0),
                                          child: new Text('基本信息',
                                              style: new TextStyle(
                                                  color: Style.COLOR_THEME,
                                                  fontWeight:
                                                      FontWeight.w700))),
                                      new Divider(height: 0.5),
                                      new ListTile(
                                        title: new Text(_card.nnm),
                                        subtitle: new Text('设备卡名'),
                                      ),
                                      new Divider(height: 0.5),
                                      new ListTile(
                                        title: new Text(_card.no),
                                        subtitle: new Text('设备卡号'),
                                      ),
                                      new Divider(height: 0.5),
                                      new ListTile(
                                        title: new Text(_card.addr),
                                        subtitle: new Text('安装地址'),
                                        trailing: !isRightLocation ? null : new IconButton(icon: new Icon(Icons.location_on), onPressed: (){
                                          Fluttermap.openMap(
                                            lat: _card.coord['Lat'],
                                            lng: _card.coord['Lng'],
                                            nnm: _card.nnm,
                                            cdno: _card.cdno,
                                            re: _card.re,
                                            addr: _card.addr
                                          );
                                        },),
                                      ),
                                      new Divider(height: 0.5),
                                      new ListTile(
                                        title: new Text(_card.opnm),
                                        subtitle: new Text('操作员'),
                                      ),
                                      new Divider(height: 0.5),
                                      new ListTile(
                                        title: new Text(Func.getFullTimeString(
                                            _card.insdt * 1000)),
                                        subtitle: new Text('安装时间'),
                                      ),
                                      new Divider(height: 0.5),
                                      new ListTile(
                                        title: new Text(_card.re),
                                        subtitle: new Text('备注'),
                                      ),
                                      new Divider(height: 0.5),
                                    ]))))),
                new Container(
                  color: Style.COLOR_BACKGROUND,
                  padding: EdgeInsets.all(16.0),
                  child: new RaisedButton(
                    color: const Color(0xFF029de0),
                    highlightColor: const Color(0xFF029de0),
                    child: const Text('发消息', style: Style.loginTextStyle),
                    padding: EdgeInsets.all(10.0),
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  new MsgDetailPage(
                                    card: _card,
                                  )));

                      _get();
                    },
                  ),
                )
              ],
            ),
          )),
        ],
      ),
    );
  }
}
