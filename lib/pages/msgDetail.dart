import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'commandList.dart';

import '../model/cardInfo.dart';
import '../model/msgInfo.dart';

import '../ui/clearTextFieldForm.dart';
import '../ui/disableButton.dart';

import '../utils/index.dart';

class MsgDetailPage extends StatefulWidget {

  final CardInfo card;

  const MsgDetailPage({this.card});

  @override
  State<StatefulWidget> createState() {
    return new MsgDetailState();
  }
}

class MsgDetailState extends State<MsgDetailPage> {
  CardInfo _card;

  final GlobalKey<ClearTextFieldFormState> _noKey = new GlobalKey<ClearTextFieldFormState>();
  final GlobalKey<ClearTextFieldFormState> _inputKey = new GlobalKey<ClearTextFieldFormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<DisableButtonState> _sendKey = new GlobalKey<DisableButtonState>();

  List<MsgInfo> _msg = new List<MsgInfo>();
  int _page = 1;

  ScrollController _controller;

  /// 根据时间间隔load信息流
  Future<Null> _getData([String stime = '', String etime = '']) async {

    String url = Cache.instance.cdurl+'/api/getmsgs.json';
    Map<String, dynamic> data = {
      'Unm': Cache.instance.username,
      'Cdtoken': Cache.instance.cdtoekn,
      'Token': Cache.instance.token,
      'No': _card.no,
      'Cdno': Cache.instance.cdno
    };

    if(stime.length == 0 && etime.length == 0){
      data['Size'] = '10';
      data['Idx'] = '1';
    } else if(stime.length > 0){
      data['Stime'] = stime;
      data['Size'] = '10';
      data['Idx'] = '$_page';
    } else {
      data['Etime'] = etime;
    }

    http.Response response =  await NetWork.post(url, data);

    if(response.statusCode != 200){
      Func.showMessage(_scaffoldKey, response.body);
    } else {
      print(response.body);
      Map data = NetWork.decodeJson(response.body);
      if(data['Code'] != 0){
        Func.showMessage(_scaffoldKey, data['Message']);
      } else {
        List<MsgInfo> list =  MsgInfo.parseMessages(data['Response'])??new List<MsgInfo>();
        if(stime.length > 0){
          _page++;
          if(list.length == 0){
            Func.showMessage(_scaffoldKey, '没有更多历史消息！');
          } else {
            _msg.insertAll(0, list);
            setState(() {

            });
            var scrollPosition = _controller.position;

            if(scrollPosition.viewportDimension > scrollPosition.minScrollExtent){
              _controller.animateTo(
                scrollPosition.minScrollExtent,
                duration: new Duration(milliseconds: 100),
                curve: Curves.easeOut,
              );
            }
          }
        } else {
          if(list.length == 0 ){
            Func.showMessage(_scaffoldKey, '没有更多新消息！');
          } else {
            _msg.addAll(list);
            if(etime.length > 0){
              setState(() {

              });
            }

            new Future.delayed(new Duration(milliseconds: 200), () async {
              var scrollPosition = _controller.position;

//            if (scrollPosition.viewportDimension < scrollPosition.maxScrollExtent+100) {
//              await _controller.animateTo(
//                scrollPosition.maxScrollExtent+ 50.0,
//                duration: new Duration(milliseconds: 200),
//                curve: Curves.easeOut,
//              );
              _controller.jumpTo(scrollPosition.maxScrollExtent);

//              print('${_controller.offset} ${scrollPosition.minScrollExtent}, ${scrollPosition.maxScrollExtent} ....111111');
              //            }
            });


          }
        }
      }
    }
  }

  Future<http.Response> _send(String content){
    String url = Cache.instance.cdurl+'/api/sendmsg.json';

    Map<String, dynamic> data = {
      'Unm': Cache.instance.username,
      'Cdtoken': Cache.instance.cdtoekn,
      'Token': Cache.instance.token,
      'No': _card.no,
      'Cdno': Cache.instance.cdno,
      'Mtext':content
    };

    return NetWork.post(url, data);
  }

  _getMsgStatus(int st){
    if(st == -1) return '失败';
    else if(st == 0) return '待发';
    else return '成功';
  }

  _getRow(MsgInfo info){

    List<Widget> children = <Widget>[
      new Container(
        constraints: new BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        decoration: new BoxDecoration(
          color: info.tp == 0 ? Colors.grey : Style.COLOR_THEME,
          borderRadius: new BorderRadius.all(Radius.circular(6.0)),

//            image: new DecorationImage(
//                image: new AssetImage(info.tp == 0 ?ImageAssets.bubble_gray : ImageAssets.bubble_blue),
//                fit: BoxFit.fill,
//                centerSlice: new Rect.fromLTRB(12.0, 12.0, 38.0, 12.0)
//            )
        ),
        padding: new EdgeInsets.only(left: 8.0, right: 12.0, top: 8.0, bottom: 6.0),
        child: new Text(info.t, style: new TextStyle(fontSize: 14.0),),
      )
    ];

    if(info.st == -1){
      Widget child = new Container(
        padding: new EdgeInsets.only(bottom: 2.0, top: 2.0, left: 6.0, right: 6.0),
        decoration: new BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        child: new Text(_getMsgStatus(info.st), style: TextStyle(color: Colors.white),),
      );
      if(info.tp == 0){
        children.add(SizedBox(width: 4.0,));
        children.add(child);
      } else {
        children.insert(0, SizedBox(width: 4.0,));
        children.insert(0, child);
      }
    }

    if(info.tp == 0){
      return new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Padding(padding: EdgeInsets.all(4.0), child: Func.getCircleAvatar(40.0, const Color(0xFFE9E9E9), ImageAssets.icon_card)),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Text(info.unm, style: const TextStyle(color: Colors.grey, fontSize: 12.0) , textAlign: TextAlign.left),
              new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: children
              )
            ],
          )
        ],
      );
    } else {
      return new Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              new Text(info.unm, style: const TextStyle(color: Style.COLOR_THEME, fontSize: 12.0), textAlign: TextAlign.right,),
              new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: children
              )
            ],
          ),
          new Padding(padding: EdgeInsets.all(4.0), child: Func.getCircleAvatar(40.0, Style.COLOR_THEME, ImageAssets.icon_me)),
        ],
      );
    }
  }

  Widget _getAppBar() {
    if(widget.card == null){
      return new AppBar(
        title: new Text('新建信息'),
      );
    } else {
      return new AppBar(
        title: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Text(_card.nnm, style: new TextStyle(color: Colors.white, fontSize: 16.0),),
            new Text(_card.no, style: new TextStyle(color: const Color(0xFFD0F1FF), fontSize: 12.0),)
          ],
        ),
        actions: <Widget>[
          new IconButton(icon: new Image.asset(ImageAssets.ic_mark, height: 44.0,), onPressed: () async{
            final result = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController controller = new TextEditingController(text: _card.nnm);
                  return new AlertDialog(
                      title: new Text('设置备注'),
                      actions: <Widget>[

                        new Center(child: new RaisedButton(
                            color:  Color(0xFF029de0),
                            highlightColor:  Color(0xFF029de0),
                            child:  Text('提交', style:  TextStyle(color: Colors.white, fontSize: 16.0)),
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            onPressed: () async {
                              Navigator.pop(context);
                              String url = Cache.instance.cdurl+'/api/setnos.json';

                              http.Response response = await NetWork.post(url, {
                                'Unm': Cache.instance.username,
                                'Cdtoken': Cache.instance.cdtoekn,
                                'Token': Cache.instance.token,
                                'Nos': [_card].toString(),
                              });

                              if(response.statusCode != 200){
                                Func.showMessage(_scaffoldKey, response.body);
                              } else {
                                Map data = NetWork.decodeJson(response.body);
                                if(data['Code'] != 0){
                                  Func.showMessage(_scaffoldKey, data['Message']);
                                } else {
                                  Func.showMessage(_scaffoldKey, '设置备注成功！');
                                  setState(() {
                                    _card.nnm = controller.text;
                                  });
                                }
                              }

                            }))
                      ],
                      content: Func.getWhiteTheme(
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Divider(),
                            new Padding(padding: new EdgeInsets.symmetric(vertical: 10.0),child:new Row(
                              children: <Widget>[
                                new Text('卡号: ', style: new TextStyle(color: Colors.grey),),
                                new Expanded(child: new Text(_card.no, style: new TextStyle(color: Colors.grey),))
                              ],
                            )),
                            new Divider(),

                            new TextField(
                              controller: controller,
                              decoration: new InputDecoration(
                                prefixText: '备注: ',
                                hintText: '请输入备注',
                                hintStyle: const TextStyle(color: Colors.grey),
                              ),
                            ),
                            new Divider(),
                          ],

                        ),

                      )
                  );
                }
            );

            if(result == true) {
              setState(() {

              });
            }
          })
        ],
      );
    }
  }

  Widget _getMsgList2(){
    if(_msg.length == 0){
      return new Text('');
    }

    return new ListView.builder(
        controller: _controller,
        itemCount: _msg.length,
        itemBuilder: (BuildContext context, int index){
          MsgInfo msg = _msg[index];

          return new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Padding(padding: EdgeInsets.all(12.0),
                  child: new Center(
                      child: new Text(Func.getFullTimeString(int.parse(msg.rst) * 1000),
                        style: new TextStyle(color: Colors.grey),)
                  )
              ),
              _getRow(msg)
            ],
          );
        }
    );
  }

  Widget _getMsgList(){
    if(_card.no.length == 0) {
      return new Text('');
    } else {
      if(_msg.length == 0) {
        return new FutureBuilder<http.Response>(
            future: _getData(),
            builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot){
              if(snapshot.connectionState == ConnectionState.done){
                return _getMsgList2();
              } else if(snapshot.connectionState == ConnectionState.waiting){
                return new Container(child: new Center(child: new CircularProgressIndicator(),));
              } else {
                return new Container(child: new Center(child: new Text(snapshot.error.toString())));
              }
            });
      } else {
        return _getMsgList2();
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _card = widget.card ?? null;
    _controller = new ScrollController();
  }

  @override
  Widget build(BuildContext context) {

    try {
//      print('${_controller.offset} ....');
      if(_controller.position.maxScrollExtent > 0){
        new Future.delayed(new Duration(milliseconds: 17), (){
          _controller.animateTo(
            _controller.position.maxScrollExtent,
            duration: new Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
        );
      }
    } catch(e){}


    List<Widget> children = new List<Widget>();
    if(_card.no.length == 0){
      children.add(Container(
        padding: new EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(child: ClearTextFieldForm(
              key: _noKey,
              hintText: '请输入卡号',
              keyboardType: TextInputType.number,
              border: OutlineInputBorder(),
            ),
            ),
            IconButton(icon: Image.asset(ImageAssets.ic_mark, height: 44.0,),onPressed: (){},)

          ],
        ),
      ));
      children.add(Divider());
    }

    children.add(Expanded(child: _getMsgList()));

    children.add(new Container(
      color: Color(0xFFECF0F3),
      padding: EdgeInsets.all(6.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new IconButton(icon: new Image.asset(ImageAssets.icon_add_command, height: 44.0,), onPressed: ()async {
            final result = await Navigator.push(context, new MaterialPageRoute(
                builder: (BuildContext context)=> new CommandListPage(result: true,)));

            if(result != null){
              _inputKey.currentState.text = result;
            }
          }),
          Expanded(child: Func.getWhiteTheme(ClearTextFieldForm(
            key: _inputKey,
            border: new OutlineInputBorder(),
            keyboardType: TextInputType.text,
            contentPadding: EdgeInsets.all(12.0),
            maxLine: null,
            clearColor: Colors.grey,
            filled: true,
            filledColor: Colors.white,
            listener: (){
              _sendKey.currentState.setDisabled(_inputKey.currentState.text.length == 0);
            },
          ))),
          SizedBox(width: 8.0,),
          DisableButton(
              key: _sendKey,
              onPressed: () async{
                if(_card.no.length == 0){
                  if(_noKey.currentState.text.length == 0){
                    Func.showMessage(_scaffoldKey, '请输入卡号');
                    return;
                  }
                  _card.no = _noKey.currentState.text;
                }

                http.Response response = await _send(_inputKey.currentState.text);
                if(response.statusCode != 200){
                  Func.showMessage(_scaffoldKey, response.body);
                } else {
//                  Func.showMessage(_scaffoldKey, '已发送');
                  FocusScope.of(context).requestFocus(new FocusNode());
                  _inputKey.currentState.clear();

                  CardValue value = new CardValue(cdno: Cache.instance.cdno, no: _card.no);
                  await DB.instance.insertOrUpdate<CardValue>(value, where: '${CardValueTable.no} = ?', whereArgs: [value.no]);

                  if(_msg.length > 0){
                    await _getData('', _msg[_msg.length - 1].rst);
                  } else {
                    await _getData();
                    setState(() {

                    });
                  }

                }
              }),
        ],
      ),
    ));

    return new Scaffold(
      key: _scaffoldKey,
      appBar: _getAppBar(),
      body: new Container(
        color: Colors.white,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}