import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../helper/pageHelper.dart';
import '../model/msgInfo.dart';
import '../model/cardInfo.dart';

import 'msgDetail.dart';

import '../utils/index.dart';
import '../ui/underLine.dart';
import '../ui/swide_widget.dart';
import '../utils/global_data.dart';

PageHelper<MsgInfo> _pageHelper = new PageHelper<MsgInfo>();

class MsgList extends StatefulWidget {

  MsgList({Key key}) :super(key:key);

  @override
  _MsgListState createState() => new _MsgListState();
}

class _MsgListState extends State<MsgList> {
  Map<Key, AutoClose> _autoClose = new Map<Key, AutoClose>();

  void notify(String snm){
    if(_pageHelper.snm == snm) return;
    _pageHelper.snm = snm;

    setState(() {
      _handleRefresh();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  Future<http.Response> _getMsg() async {
    List<dynamic> cards = await DB.instance.query( CardValueTable.name, where: '${CardValueTable.cdno} = ?', whereArgs: [Cache.instance.cdno]);
    if(cards.length > 0){
      String url = Cache.instance.cdurl +'/api/getmsgs.json';
      String s = '';

      for(int i=0, len = cards.length; i < len; i++){
//        if (_pageHelper.snm.length > 0) {
//          if (cards[i].no.contains(_pageHelper.snm)) {
//            s += cards[i].no + ",";
//          } else {
//            s += "";
//          }
//        } else {
          s += cards[i].no + ",";
//        }
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
      } else {
        data['No'] = _pageHelper.snm;
      }

      return NetWork.post(url, data);
    } else {
      return null;
    }
  }

  Future<Null> _handleRefresh() async{

    _getMsg().then((http.Response response){
      if(response != null && response.statusCode == 200){
        Map data = NetWork.decodeJson(response.body);
        if(data['Code'] == 0){
          List<dynamic> list = data['Response'];
          List<MsgInfo> msg = MsgInfo.parseMessages(list);
          if(msg.length > 0){
            _pageHelper.addData(msg, clear: true);
          }

          if(mounted){
            try {
              setState(() {

              });
            } catch(e){}
          }

        } else {
          Func.showMessage(data['Message']);
        }
      }
    });
  }

  List<MsgInfo> filter(List<MsgInfo> data){
    return data.where((f) => f.no.contains(_pageHelper.snm??'')).toList();
  }

  @override
  Widget build(BuildContext context) {
    _pageHelper.init((){
      _handleRefresh();
    });
    if(_pageHelper.datas.length == 0){
      return new Expanded(
          child: new Stack(
            children: <Widget>[
              new Center(
                  child: Text('没有消息')),
              new RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: new ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                  )
              ),
            ],
          ));
    }


    List<MsgInfo> data = _pageHelper.datas;
    data =  filter(data);

    return new Expanded(
        child:new RefreshIndicator(
          onRefresh: _handleRefresh,
          child: new NotificationListener(
              onNotification: _pageHelper.handle,
              child:  new ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _pageHelper.createController(),
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  MsgInfo item =data[index];

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

                                    await DB.instance.delete(CardValueTable.name, where: '${CardValueTable.no} = ?', whereArgs: [item.no]);
                                    _pageHelper.datas.removeAt(index);
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
                          child:  Padding(padding: EdgeInsets.all(12.0),
                  child: new Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: new CircleAvatar(
                                      child: Image.asset(ImageAssets.icon_card, width: 30.0,),
                                      backgroundColor: Style.COLOR_THEME),
                                ),
                                Expanded(child: InkWell(
                                  child: new Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Text(item.nomsg.nnm.isEmpty ? item.no :item.nomsg.nnm ,
                                        maxLines: 1,
                                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text('卡号:${item.no}', style: TextStyle(color: Colors.grey)),
                                          Text(Func.getFullTimeString(int.parse(item.rst)* 1000, false), style: TextStyle(color: Colors.grey),),

                                        ],),
                                      Text(item.t??'', maxLines: 2, style: TextStyle(color: Colors.grey)),
                                    ],
                                  ) ,
                                  onTap: () async {
                                    await Navigator.push(context, new MaterialPageRoute(builder: (context)=> new MsgDetailPage(card: new CardInfo(
                                        no: item.no,
                                        re: item.re,
                                        nnm: item.nomsg.nnm,
                                        opnm: item.nomsg.opnm,
                                        insdt: item.nomsg.insdt,
                                        addr: item.nomsg.addr,
                                        coord: item.nomsg.coord
                                    ))));

                                    _handleRefresh();
                                  },
                                )
                                )
                              ]
                          )


                      ))
                  );
                },
              )),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    _autoClose.clear();
  }
}

class MsgManagerPage extends StatefulWidget {
  @override
  _MsgManagerPageState createState() => new _MsgManagerPageState();

  static clear(){
    _pageHelper.clear();
  }
}


class _MsgManagerPageState extends State<MsgManagerPage> with Global {

  TextEditingController _controller;
  final GlobalKey<_MsgListState> _userKey = new GlobalKey<_MsgListState>();


  @override
  void initState() {
    super.initState();

    _controller = new TextEditingController(text: _pageHelper.snm);
    _controller.addListener((){
      _userKey.currentState.notify(_controller.text??'');
    });

    setMsgRefresh(()=> _pageHelper.clear());
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
          new MsgList(
            key: _userKey,
          )
        ]);
  }
}
