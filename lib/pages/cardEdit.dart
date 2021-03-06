import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:fluttermap/fluttermap.dart';

import '../utils/index.dart';
import '../model/cardInfo.dart';

class CardEdit extends StatefulWidget {
  final CardInfo card;

  const CardEdit({this.card});

  @override
  State<StatefulWidget> createState() {
    return new CardEditState();
  }
}

class CardEditState extends State<CardEdit> {
  CardInfo _card;
  bool _loading = false;
  bool _autoValidate = false;
  bool _enable = false;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _controller;

  Widget _getMenus({
    String preText,
    String initString,
    String hintText,
    bool enable = true,
    bool obscureText,
    TextInputType type,
    FormFieldSetter<String> onSave,
    FormFieldValidator<String> validator,
    Widget btn,
    TextEditingController controller,
  }) {
    TextEditingController controller2 = controller ??
        new TextEditingController(text: initString.replaceAll('\n', '') ?? '');
    if (controller == null && Theme.of(context).platform == TargetPlatform.iOS) {
      controller2.addListener(() {
        _formKey.currentState.save();
      });
    }

    return new Container(
        padding: EdgeInsets.all(8.0),
        child:new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(preText),
            Expanded(child: new TextFormField(
              controller: controller2,
              keyboardType: type ?? TextInputType.text,
              onSaved: onSave,
              validator: validator ?? (String value) => null,
              obscureText: obscureText ?? false,
              style: enable == false ? new TextStyle(color: Colors.grey) : null,
              enabled: enable,
              decoration: new InputDecoration.collapsed(
                  hintText: hintText),
            ),),

            btn?? Container()
          ],
        ));
  }

  Future<http.Response> _post([bool isGet = false, String no]) async {
    String url = Cache.instance.cdurl +
        (isGet ? '/api/getnos.json' : '/api/setnos.json');

    if (isGet) {
      return NetWork.post(url, {
        'Unm': Cache.instance.username,
        'Cdtoken': Cache.instance.cdtoekn,
        'Token': Cache.instance.token,
        'No': no ?? '',
        'Idx': '1',
        'Size': '100'
      });
    } else {
      return NetWork.post(url, {
        'Unm': Cache.instance.username,
        'Cdtoken': Cache.instance.cdtoekn,
        'Token': Cache.instance.token,
        'Nos': [_card].toString(),
      });
    }
  }

  void _getCardInfo() async {
    if (_controller.text.length == 0) {
      Func.showMessage('请输入设备卡号！');
    } else {
      setState(() {
        _loading = true;
      });
      http.Response response = await _post(true, _controller.text);
      setState(() {
        _loading = false;
      });

      if (response.statusCode == 200) {
        print(response.body);

        Map data = NetWork.decodeJson(response.body);
        if (data['Code'] != 0) {
          Func.showMessage(data['Message']);
        } else {
          List<CardInfo> cards = CardInfo.parseCards(data['Response']);
          if (cards.length == 0) {
            Func.showMessage('暂无该设备卡号！');
            setState(() {
              _enable = true;
            });
          } else {
            setState(() {
              _enable = true;
              _card = cards[0];
//              print(_card);
            });
          }
        }
      }
    }
  }

  Future<Null> _handleSubmitted() async {
    FocusScope.of(context).requestFocus(new FocusNode());

    final FormState form = _formKey.currentState;
    if (_controller.text.length == 0) {
      Func.showMessage('请输入设备卡号！');
      return;
    } else {
      form.save();
    }

    if(_enable == false){
      Func.showMessage('请先获取信息! ');
      return;
    }

    setState(() {
      _loading = true;
    });

    http.Response response = await _post();

    Future.delayed(new Duration(milliseconds: 200), () async {
      setState(() {
        _loading = false;
      });

      if (response.statusCode == 200) {
        print(response.body);

        Map data = NetWork.decodeJson(response.body);
        if (data['Code'] != 0) {
          Func.showMessage(data['Message']);
        } else {
          Func.showMessage(widget.card == null ? '添加卡成功！' : '修改卡信息成功！');
          Future.delayed(new Duration(milliseconds: 500), () {
            Navigator.pop(context, 'done');
          });
        }
      } else {
        Func.showMessage(response.body);
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _card = widget.card ?? new CardInfo();

    if (widget.card == null) {
      _card.insdt = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt();
//      print('当前时间: microsecond = ${DateTime.now().microsecondsSinceEpoch}, ${DateTime.now().millisecondsSinceEpoch}');
    } else {
      _enable = true;
    }
    _controller = new TextEditingController(text: _card.no);
  }

  @override
  Widget build(BuildContext context) {
    print('build _card=$_card');

    List<Widget> children = <Widget>[
      new SingleChildScrollView(
          child: new Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _getMenus(
                      preText: '设备卡号：',
                      hintText: '请输入设备卡号',
                      initString: _card.no,
                      onSave: (String value) => _card.no = value,
                      enable: widget.card == null ? true : false,
                      controller: _controller,
                      btn: widget.card != null
                          ? null
                          : new RaisedButton(
                        color: const Color(0xFF029de0),
                        highlightColor: const Color(0xFF029de0),
                        child: const Text('获取信息',
                            style: const TextStyle(
                              inherit: false,
                              fontSize: 12.0,
                              color: Colors.white,
                              textBaseline: TextBaseline.alphabetic,
                            )),
                        onPressed: this._getCardInfo,
                      )),
                  new Divider(
                    height: 1.0,
                  ),
                  _getMenus(
                    preText: '设备卡名：',
                    hintText: '请输入设备卡名',
                    initString: _card.nnm,
                    onSave: (String value) => _card.nnm = value,
                    enable: _enable,
                  ),
                  new Divider(
                    height: 1.0,
                  ),
                  _getMenus(
                      preText: '操作人员：',
                      hintText: '请输入操作员',
                      initString: _card.opnm,
                      onSave: (String value) => _card.opnm = value,
                      enable: _enable),
                  new Divider(
                    height: 1.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Row(
                      children: <Widget>[
                        new Text('安装时间：'),
                        new InkWell(
                            onTap: !_enable ? null : () {
                              DateTime time = new DateTime.fromMillisecondsSinceEpoch(
                                  _card.insdt * 1000);
                              Func.selectDate(context, time, (DateTime date) {
                                setState(() {
                                  _card.insdt =
                                      (date.millisecondsSinceEpoch ~/ 1000).toInt();
                                });
                              });
                            },
                            child: Row(
                                children: <Widget>[
                                  new Text('${Func.getYearMonthDay(_card.insdt * 1000)}'),
                                  Icon(Icons.arrow_drop_down)]
                            )
                        ),
                        new SizedBox(width: 12.0,),
                        new InkWell(
                            onTap: !_enable ? null : () {
                              DateTime time = new DateTime.fromMillisecondsSinceEpoch(
                                  _card.insdt * 1000);
                              Func.selectTime(context, TimeOfDay.fromDateTime(time), (TimeOfDay date) {
                                setState(() {
                                  _card.insdt =  (new DateTime(time.year, time.month, time.day, date.hour, date.minute).millisecondsSinceEpoch ~/ 1000).toInt();
                                });
                              });
                            },
                            child:Row(
                                children: <Widget>[ new Text('${Func.getHourMin(_card.insdt * 1000)}'),
                                Icon(Icons.arrow_drop_down)
                                ])
                        ),
                      ],

                    ),
                  ),
                  new Divider(
                    height: 1.0,
                  ),
                  _getMenus(
                      preText: '添加备注：',
                      hintText: '请输入备注',
                      initString: _card.re,
                      onSave: (String value) => _card.re = value,
                      enable: _enable),
                  new Divider(
                    height: 1.0,
                  ),
                  _getMenus(
                      preText: '安装地址：',
                      hintText: '请输入安装地址',
                      initString: _card.addr,
                      onSave: (String value) => _card.addr = value,
                      enable: _enable,
                      btn: !_enable
                          ? null
                          : new RaisedButton.icon(
                          color: const Color(0xFF029de0),
                          highlightColor: const Color(0xFF029de0),
                          icon: new Icon(Icons.location_on,
                              size: 10.0, color: Colors.white),
                          label: const Text('定位当前',
                              style: const TextStyle(
                                inherit: false,
                                fontSize: 12.0,
                                color: Colors.white,
                                textBaseline: TextBaseline.alphabetic,
                              )),
                          onPressed: () async {
                            _formKey.currentState.save();
                            Map<dynamic, dynamic> data =
                            await Fluttermap.getLocation;
                            print('获取定位数据, $data');
                            if (data['error'] == null) {
                              try {
                                setState(() {
                                  _card.addr = data['address'];
                                  _card.coord = {
                                    'Lat': data['lat'],
                                    'Lng': data['lng'],
                                  };
                                });
                              } catch (e) {}
                            } else {
                              Func.showMessage(data['error']);
                            }
                          })),
                  new Divider(
                    height: 1.0,
                  ),
                  new SizedBox(
                    height: 20.0,
                  ),
                  new RaisedButton(
                    color: const Color(0xFF029de0),
                    highlightColor: const Color(0xFF029de0),
                    child: new Text(widget.card == null ? '确认添加' : '确认修改',
                        style: Style.loginTextStyle),
                    padding: EdgeInsets.all(10.0),
                    onPressed: _handleSubmitted,
                  ),
                ]),
          )),
    ];

    if (_loading) {
      children.add(Func.topLoadingWidgetInChildren());
    }
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(widget.card == null ? '添加卡' : '修改卡'),
      ),
      body: new Padding(
          padding: EdgeInsets.all(8.0),
          child: new Stack(
            children: children,
          )),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
