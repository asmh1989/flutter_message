import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'cardEdit.dart';
import 'cardDetail.dart';

import '../helper/pageHelper.dart';

import '../utils/index.dart';

import '../model/cardInfo.dart';

import '../ui/underLine.dart';
import '../ui/swide_widget.dart';

PageHelper<CardInfo> _pageHelper = new PageHelper<CardInfo>();


class _FutureCardList extends StatefulWidget{


  const _FutureCardList({Key key}): super(key:key);

  @override
  State<StatefulWidget> createState() {
    return new _FutureCardListState();
  }
}

class _FutureCardListState extends State<_FutureCardList>{

  Map<Key, AutoClose> _autoClose = new Map<Key, AutoClose>();

  void notify(String snm){
    if(_pageHelper.snm == snm) return;
    _pageHelper.snm = snm;

    setState(() {
      _handleRefresh();
    });
  }


  Future<http.Response> _getCardData() async{
    String url = Cache.instance.cdurl+'/api/getunos.json';

    Map<String, dynamic> params =  {
      'Unm': Cache.instance.username,
      'Cdtoken': Cache.instance.cdtoekn,
      'Token': Cache.instance.token,
      'No': _pageHelper.snm,
      'Idx': '1',
      'Size': '100'
    };

    return NetWork.post(url, params);
  }


  Future<Null> _handleRefresh() async{
    try {
//      http.Response response = await _getCardData();
//      await new Future.delayed(new Duration(milliseconds: 1000));

      _getCardData().then((http.Response response)  async  {

        if (response != null && response.statusCode == 200) {
          print(response.body);
          Map data = NetWork.decodeJson(response.body);
          if (data['Code'] == 0) {
            List<dynamic> list = data['Response'];
            List<CardInfo> cards = CardInfo.parseCards(list);
            if (cards.length > 0) {
              _pageHelper.addData(cards, clear: true);
            }

            if (mounted) {
              try {
                setState(() {

                });
              } catch(e){}
            }

          } else {
            Func.showMessage(data['Message']);
          }
        } else {
          Func.showMessage('应用平台连接失败，请尝试切换一下！');
        }
      });

    } catch (e){
      Func.showMessage('应用平台连接失败，请尝试切换一下！');
    }
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

    if(_pageHelper.datas.length == 0){

      return new Expanded(
          child: new Stack(
            children: <Widget>[
              new Center(
                  child: Image.asset(ImageAssets.ic_card_list_tips,  width: 160.0,)),
              new RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: new ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                  )
              ),
            ],
          ));
    }

    return new Expanded(
      child: new RefreshIndicator(
          onRefresh: _handleRefresh,
          child: new NotificationListener(
              onNotification: _pageHelper.handle,
              child: new ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _pageHelper.createController(),
                itemCount: _pageHelper.itemCount(),
                itemBuilder: (BuildContext context, int index) {
                  CardInfo item = _pageHelper.datas[index];

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
                            _handleRefresh();
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
                                        _pageHelper.datas.removeAt(index);
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
                            title: new Text(item.no.length == 0 ?item.no : '${item.nnm}(${item.no})', maxLines: 1,),
                            subtitle: new Text(item.addr, maxLines: 2,),
                            trailing: new Text(Func.getFullTimeString(item.insdt* 1000), style: TextStyle(color: Colors.grey),),
                            onTap: () async {
                              await Navigator.push(context, new MaterialPageRoute(builder: (context)=> new CardDetailPage(card: item)));
                              _handleRefresh();
                            },
                          )
                      )
                  );
                },
              ))),
    );
  }

//  Widget _getCardListWidget(){
//
//    return new FutureBuilder<http.Response>(
//        future: _getCardData(),
//        builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot){
//          if(snapshot.connectionState == ConnectionState.waiting){
//            return new Expanded(child: new Container(child: new Center(child: new CircularProgressIndicator(),),));
//          } else {
//            if(snapshot.connectionState == ConnectionState.done && !snapshot.hasData){
//              return new Expanded(child: new Center(child: Image.asset(ImageAssets.ic_card_list_tips, width: 160.0)));
//            }
//            http.Response response = snapshot.data;
//            if (response.statusCode != 200) {
//              return new Expanded( child: Func.logoutWidget(context, response.body, new RaisedButton(
//                child: new Text('平台切换'),
//                onPressed: () => Navigator.pushNamed(context, SwitchPlatformPage.route),
//              )));
//            } else {
//              Map data = NetWork.decodeJson(response.body);
//
//              if (data['Code'] != 0) {
//                print(Func.mapToString(data));
//                return new Center(
//                  child: new Text(data['Message']),
//                );
//              } else {
//                widget.cache.cards.clear();
//                widget.cache.cards.addAll(CardInfo.parseCards(data['Response']));
//                if(widget.cache.cards.length == 0){
//                  return new Expanded(child: new Center(child: Image.asset(ImageAssets.ic_card_list_tips,  width: 160.0,)));
//                }
//
//                return _getCardListWidget2();
//
//              }
//            }
//          }
//        });
//  }
//

  @override
  Widget build(BuildContext context) {
    _pageHelper.init((){
      _handleRefresh();
    });
    return _getCardListWidget2();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _autoClose.clear();

  }
}


class CardManagerPage extends StatefulWidget{

  const CardManagerPage();

  @override
  State<StatefulWidget> createState() {
    return new CardManagerState();
  }

  static clear(){
    _pageHelper.clear();
  }
}

class CardManagerState extends State<CardManagerPage>{

  final GlobalKey<_FutureCardListState> _userKey = new GlobalKey<_FutureCardListState>();
  TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = new TextEditingController(text: _pageHelper.snm);
    _controller.addListener((){
      _userKey.currentState.notify(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {

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
          ),
        ]);
  }

}