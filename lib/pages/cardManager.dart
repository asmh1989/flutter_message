import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'switchPlatform.dart';
import 'cardEdit.dart';
import 'cardDetail.dart';
import 'msgDetail.dart';

import '../utils/index.dart';

import '../model/cardInfo.dart';
import '../model/msgInfo.dart';

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


  Future<http.Response> _getMsg() async {
    List<CardValue> cards = await DB.instance.query<CardValue>(where: '${CardValueTable.cdno} = ?', whereArgs: [Cache.instance.cdno]);
    if(cards.length > 0){
      String url = Cache.instance.cdurl +'/api/getmsgs.json';
      String s = '';

      for(int i=0, len = cards.length; i < len; i++){
        if (_snm.length > 0) {
          if (cards[i].no.contains(_snm)) {
            s += cards[i].no + ",";
          } else {
            s += "";
          }
        } else {
          s += cards[i].no + ",";
        }
      }

      Map<String, dynamic> data = {
        'Unm': Cache.instance.username,
        'Cdtoken': Cache.instance.cdtoekn,
        'Token': Cache.instance.token,
        'Idx': '1',
        'Size': '100'
      };
      if(s.length > 1){
        data['Nolst'] = s.substring(0, s.length -1);
      }

      return NetWork.post(url, data);
    } else {
      widget.cache.msg.clear();
      return null;
    }
  }

  Future<Null> _handleRefresh() async{
    if(widget.type == CardType.CARD){
      widget.cache.cards.clear();
    } else {
      widget.cache.msg.clear();
    }
    setState(() {

    });
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
      child: new RefreshIndicator(
        onRefresh: _handleRefresh,
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
                    widget.cache.clearCards();
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
                                widget.cache.clearCards();
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
                      child: new CircleAvatar(child: Image.asset(ImageAssets.icon_card), backgroundColor: Style.COLOR_THEME),
                    ),
                    title: new Text(item.no.length == 0 ?item.no : '${item.nnm}（${item.no}）'),
                    subtitle: new Text(item.addr),
                    trailing: new Text(Func.getFullTimeString(item.insdt* 1000), style: TextStyle(color: Colors.grey),),
                    onTap: () async {
                      await Navigator.push(context, new MaterialPageRoute(builder: (context)=> new CardDetailPage(card: item)));
                      widget.cache.clearCards();
                    },
                  )
              )
          );
        },
      )),
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
                  child: new Text(data['Message']),
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

  Widget _getMsgListWidget2(){
    _autoClose.clear();

    return new Expanded(
      child:new RefreshIndicator(
        onRefresh: _handleRefresh,
        child: new ListView.builder(
        itemCount: widget.cache.msg.length,
        itemBuilder: (BuildContext context, int index) {
          MsgInfo item = widget.cache.msg[index];

          final List<FXRightSideButton> buttons= [

            new FXRightSideButton(name: '删除',
                backgroundColor: Colors.red,
                fontColor: Colors.white,
                onPress: ()  {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => new AlertDialog(
                        content: new Text('您确定要删除消息吗？'),
                        actions: <Widget>[
                          new FlatButton(onPressed: (){
                            Navigator.pop(context);
                          }, child: new Text('取消')),
                          new FlatButton(onPressed: () async {
                            Navigator.pop(context);

                            DB.instance.delete<CardValue>(where: '${CardValueTable.no} = ?', whereArgs: [item.nomsg.no]);
                            widget.cache.clearMsg();
                            setState(() {

                            });

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
                      child: new CircleAvatar(child: Image.asset(ImageAssets.icon_card), backgroundColor: Style.COLOR_THEME),
                    ),
                    title: new Text(item.nomsg.nnm.length == 0 ?item.no : '${item.nomsg.nnm}（${item.no}）'),
                    subtitle: new Text(item.t),
                    trailing: new Text(Func.getFullTimeString(int.parse(item.rst)* 1000), style: TextStyle(color: Colors.grey),),
                    onTap: () async {
                      await Navigator.push(context, new MaterialPageRoute(builder: (context)=> new MsgDetailPage(card: item.nomsg)));
                      widget.cache.clearCards();
                    },
                  )
              )
          );
        },
      ),
      ));
  }

  Widget _getMsgListWidget(){
    if(!isNotify && widget.cache.msg.length > 0) {
      return _getMsgListWidget2();
    }
    isNotify = false;

    return new FutureBuilder<http.Response>(
        future: _getMsg(),
        builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return new Expanded(child: new Container(child: new Center(child: new CircularProgressIndicator(),),));
          } else {
            if(snapshot.connectionState == ConnectionState.done && !snapshot.hasData){
              return new Expanded(child: new Center(child: new Text('没有消息')));
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
                    child: new Text(data['Message'])
                );
              } else {
                widget.cache.msg.clear();
                widget.cache.msg.addAll(MsgInfo.parseMessages(data['Response']));
                if(widget.cache.msg.length == 0){
                  return  new Expanded(child: new Center(child: new Text('没有消息')));
                }

                return _getMsgListWidget2();

              }
            }
          }

        });
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

    _snm = widget.type == CardType.CARD ? widget.cache.snm : widget.cache.snm2;
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

    _controller = new TextEditingController(text: widget.type == CardType.CARD ?  widget.cache.snm : widget.cache.snm2);
    _controller.addListener((){
      if(widget.type == CardType.CARD){
        _userKey.currentState.notify(widget.cache.snm = _controller.text);
      } else {
        _userKey.currentState.notify(widget.cache.snm2 = _controller.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

//    print('cardManager , snm=${widget.cache.snm}');
    _controller.text = widget.type == CardType.CARD ?  widget.cache.snm : widget.cache.snm2;
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
                  child: new Text('清除',style: new TextStyle(color: Style.COLOR_THEME),
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
  List<MsgInfo> msg = new List<MsgInfo>();

  String snm = '';
  String snm2 = '';

  void clearMsg(){
    snm2 = '';
    msg.clear();
  }

  void clear(){
    snm = '';
    snm2 = '';
    cards.clear();
    msg.clear();
  }

  void clearCards(){
    snm = '';
    cards.clear();
  }
}