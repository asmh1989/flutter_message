import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'login.dart';
import 'switchPlatform.dart';
import 'cardEdit.dart';
import 'cardDetail.dart';

import '../utils/index.dart';

import '../model/cardInfo.dart';

import '../ui/underLine.dart';
import '../ui/swide_widget.dart';

enum CardType {
  CARD,
  MESSAGE
}


class _FutureCardList extends StatefulWidget{

  final CardType type;
  final PageCache cache;

  const _FutureCardList({Key key, @required this.type, @required this.cache}): super(key:key);

  @override
  State<StatefulWidget> createState() {
    return new _FutureCardListState();
  }
}

class _FutureCardListState extends State<_FutureCardList>{

  bool isNotify = false;
  String _snm = '';

  Map<Key, AutoClose> _autoClose = new Map<Key, AutoClose>();

  void notify(String snm){
    if(_snm == snm) return;
    _snm = snm;
    isNotify = true;

    setState(() {

    });
  }


  Future<http.Response> _getCardData() async{
    String url = Cache.instance.cdurl+'/api/getunos.json';

    Map<String, dynamic> params =  {
      'Unm': Cache.instance.username,
      'Cdtoken': Cache.instance.cdtoekn,
      'Token': Cache.instance.token,
      'No': _snm,
      'Idx': '1',
      'Size': '100'
    };

    return NetWork.post(url, params);
  }

  Future<http.Response> _setCardData(CardInfo card) async{
    String url = Cache.instance.cdurl+'/api/setnos.json';

    card.type = '2';
    return  NetWork.post(url, {
      'Unm': Cache.instance.username,
      'Cdtoken': Cache.instance.cdtoekn,
      'Token': Cache.instance.token,
      'Nos': [card].toString(),
    });
  }

  Widget _getCardListWidget2(){
    _autoClose.clear();

    return new Expanded(
      child: new ListView.builder(
        itemCount: widget.cache.cards.length,
        itemBuilder: (BuildContext context, int index) {
          CardInfo item = widget.cache.cards[index];

          final List<FXRightSideButton> buttons= [
            new FXRightSideButton(name: '编辑',
                backgroundColor: Colors.grey,
                fontColor: Colors.white,
                onPress: () async {
                  final result = await Navigator.push(context, new MaterialPageRoute(
                      builder: (BuildContext context) => new CardEdit(
                        card: item,
                      )));

                  if(result != null) {
                    widget.cache.clear();
                    setState(() {

                    });
                  }
                }),
            new FXRightSideButton(name: '删除',
                backgroundColor: Colors.red,
                fontColor: Colors.white,
                onPress: ()  {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => new AlertDialog(
                        content: new Text('您确定要删除卡号吗？'),
                        actions: <Widget>[
                          new FlatButton(onPressed: (){
                            Navigator.pop(context);
                          }, child: new Text('取消')),
                          new FlatButton(onPressed: () async {
                            Navigator.pop(context);

                            http.Response response = await _setCardData(item);
                            if(response.statusCode == 200) {
                              print(response.body);

                              Map data = NetWork.decodeJson(response.body);
                              if(data['Code'] != 0){
                                Func.showMessage(data['Message']);
                              } else {
                                widget.cache.clear();
                                setState(() {

                                });
                              }
                            } else {
                              Func.showMessage(response.body);
                            }

                          }, child: new Text('确定'))
                        ],
                      )
                  );
                })
          ];

          return new FXLeftSlide(
              key: new Key('$index'),
              onOpen: (Key key,  AutoClose autoClose) => _autoClose[key] = autoClose,
              startTouch: () {
                _autoClose.forEach((Key key, AutoClose autoClose){
                  autoClose();
                });

                _autoClose.clear();
              },
              buttons: buttons,
              child: new UnderLine(
                  child: new ListTile(
                    leading: new Padding(
                      padding: EdgeInsets.all(2.0),
                      child: new Image.asset(ImageAssets.icon_card, color: Style.COLOR_THEME,),
                    ),
                    title: new Text(item.nnm.length == 0 ?item.no : '${item.nnm}（${item.no}）'),
                    subtitle: new Text(item.addr),
                    trailing: new Text(Func.getFullTimeString(item.insdt* 1000)),
                    onTap: () async {
                      await Navigator.push(context, new MaterialPageRoute(builder: (context)=> new CardDetailPage(card: item)));
                      widget.cache.clear();
                    },
                  )
              )
          );
        },
      ),
    );
  }


  Widget _getCardListWidget(){
//    print('isNotify=$isNotify, len=${widget.cache.cards.length}, snm=${widget.cache.snm}');
    if(!isNotify && widget.cache.cards.length > 0) return _getCardListWidget2();
    isNotify = false;

    return new FutureBuilder<http.Response>(
        future: _getCardData(),
        builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return new Expanded(child: new Container(child: new Center(child: new CircularProgressIndicator(),),));
          } else {
            if(snapshot.connectionState == ConnectionState.done && !snapshot.hasData){
              return new Expanded(child: new Center(child: Image.asset(ImageAssets.ic_card_list_tips, width: 160.0)));
            }
            http.Response response = snapshot.data;
            if (response.statusCode != 200) {
              return new Expanded( child: Func.logoutWidget(context, response.body, new RaisedButton(
                child: new Text('平台切换'),
                onPressed: () => Navigator.pushNamed(context, SwitchPlatformPage.route),
              )));
            } else {
              Map data = NetWork.decodeJson(response.body);

              print(Func.mapToString(data));

              if (data['Code'] != 0) {
                print(Func.mapToString(data));
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
                widget.cache.cards.clear();
                widget.cache.cards.addAll(CardInfo.parseCards(data['Response']));
                if(widget.cache.cards.length == 0){
                  return new Expanded(child: new Center(child: Image.asset(ImageAssets.ic_card_list_tips,  width: 160.0,)));
                }

                return _getCardListWidget2();

              }
            }
          }

        });
  }

  Widget _getMsgListWidget(){
    return new Text('消息');
  }

  @override
  Widget build(BuildContext context) {
    if(widget.type == CardType.CARD){
      return _getCardListWidget();
    } else {
      return _getMsgListWidget();
    }
  }

  @override
  void initState() {
    super.initState();

    _snm = widget.cache.snm;
  }

  @override
  void dispose() {
    super.dispose();
    _autoClose.clear();

//    print('disposed .... ');
//    _cards?.clear();
  }
}

class CardManagerPage extends StatefulWidget{

  final CardType type;
  final PageCache cache;
  const CardManagerPage({@required this.type, @required this.cache});

  @override
  State<StatefulWidget> createState() {
    return new CardManagerState();
  }
}

class CardManagerState extends State<CardManagerPage>{

  final GlobalKey<_FutureCardListState> _userKey = new GlobalKey<_FutureCardListState>();
  TextEditingController _controller;


  @override
  void initState() {
    super.initState();

    _controller = new TextEditingController(text: widget.cache.snm);
    _controller.addListener((){
      _userKey.currentState.notify(widget.cache.snm = _controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {

//    print('cardManager , snm=${widget.cache.snm}');
    _controller.text = widget.cache.snm;
    return new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Container(
            color: Style.COLOR_BACKGROUND,
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            child: new Theme(data: new ThemeData(
                primaryColor: Colors.white,
                accentColor: Colors.white,
                hintColor: Colors.white
            ), child: new TextField(
              controller: _controller,
              decoration: new InputDecoration(
                prefixIcon: new Icon(Icons.search, color: Colors.grey,),
                suffixIcon: new GestureDetector(
                  onTap: (){
                    if(_controller.text.length == 0) return;
                    _controller.clear();
                    _userKey.currentState.notify('');
                  },
                  child: new Text('清除',style: new TextStyle(fontWeight: FontWeight.w700, color: Style.COLOR_THEME),
                  ),
                ),
                hintText: '搜索',
                hintStyle: new TextStyle(color: Colors.grey),
                fillColor: Colors.white,
                filled: true,
                contentPadding: EdgeInsets.all(8.0),
              ),
            )),
          ),
          new _FutureCardList(
            key: _userKey,
            cache: widget.cache,
            type: widget.type,
          ),
        ]);
  }


}

class PageCache {
  List<CardInfo> cards = new List<CardInfo>();
  String snm = '';

  void clear(){
    snm='';
    cards.clear();
  }
}