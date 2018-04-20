import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_message/model/platformInfo.dart';
import '../utils/func.dart';
import '../utils/style.dart';
import '../utils/network.dart';
import '../utils/cache.dart';


class PlatformEdit extends StatefulWidget{

  const PlatformEdit({this.info});

  final PlatformInfo info;

  @override
  State<StatefulWidget> createState() {
    return new PlatformEditState();
  }
}


class PlatformEditState extends State<PlatformEdit>{

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  PlatformInfo _info;
  bool _loading = false;
  bool _autoValidate = false;

  static const String hint_1 = '请输入平台序列';
  static const String hint_2 = '请输入接入号';
  static const String hint_3 = '请输入接入全号';
  static const String hint_4 = '请接入平台名称';
  static const String hint_5 = '请接入平台连接';

  @override
  void initState() {
    super.initState();

    _info = widget.info?? new PlatformInfo();
    if(widget.info == null){
      _info.exp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toInt();
//      print('当前时间: microsecond = ${DateTime.now().microsecondsSinceEpoch}, ${DateTime.now().millisecondsSinceEpoch}');
    }
  }


  Future<Null> _selectDate(BuildContext context, DateTime selectedDate, ValueChanged<DateTime> selectDate) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: new DateTime(2015, 8),
        lastDate: new DateTime(2201)
    );
    if (picked != null && picked != selectedDate)
      selectDate(picked);
  }

  Widget _getMenus({
    String preText,
    String initString,
    String hintText,
    bool enable,
    TextInputType type,
    FormFieldSetter<String> onSave,
    FormFieldValidator<String> validator,
  }){
    return new TextFormField(
      initialValue: initString,
      keyboardType: type ?? TextInputType.text,
      onSaved: onSave,
      validator: validator,
      enabled: enable??true,
      decoration: new InputDecoration(
        prefixIcon: new Text(preText),
        hintText: hintText,
        border: new UnderlineInputBorder(borderSide: BorderSide.none),
      ),

    );
  }

  Future<Null>  _handleSubmitted() async {
    FocusScope.of(context).requestFocus(new FocusNode());

    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true; // Start validating on every change.
      Func.showMessage(_scaffoldKey, '请先修复错误,再确认');
      return;
    } else {
      form.save();
    }

    setState(() {
      _loading = true;
    });

    http.Response response = await NetWork.post(NetWork.SET_PLATFORM_LIST, {
      'Unm': Cache.instance.username,
      'Token': Cache.instance.token,
      'Links': [_info].toString()
    });

    Future.delayed(new Duration(milliseconds: 200), () async {
      setState(() {
        _loading = false;
      });

      if(response.statusCode == 200) {
        print(response.body);

        Map data = NetWork.decodeJson(response.body);
        if(data['Code'] != 0){
          Func.showMessage(_scaffoldKey, data['Message']);
        } else {
          Func.showMessage(_scaffoldKey, widget.info == null ? '新增平台成功！': '修改平台信息成功！');
          Future.delayed(new Duration(milliseconds: 500),(){
            Navigator.pop(context, 'done');
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = <Widget>[
      new SingleChildScrollView(
          child: new Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child:  new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _getMenus(preText: '平台序列：', hintText: hint_1, initString: widget.info == null ? '':'${_info.lno}',
                      onSave: (String value) => _info.lno = int.parse(value),
                      validator: Func.validateNull(hint_1),
                      type: TextInputType.number
                  ),
                  _getMenus(preText: '接 入 号：', hintText: hint_2, initString: widget.info == null ? '': _info.cdno,
                      onSave: (String value) => _info.cdno = value,
                      validator: Func.validateNull(hint_2),
                      enable: widget.info == null ? true :  false
                  ),
                  _getMenus(preText: '接入全号：', hintText: hint_3, initString: widget.info == null ? '': _info.cdnm,
                      onSave: (String value) => _info.cdnm = value,
                      validator: Func.validateNull(hint_3)
                  ),
                  _getMenus(preText: '平台名称：', hintText: hint_4, initString: widget.info == null ? '': _info.name,
                      onSave: (String value) => _info.name = value,
                      validator: Func.validateNull(hint_4)
                  ),
                  _getMenus(preText: '平台连接：', hintText: hint_5, initString: widget.info == null ? '': _info.cdurl,
                      onSave: (String value) => _info.cdurl = value,
                      validator: Func.validateNull(hint_5)
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Text('是否有效：'),
                      new CupertinoSwitch(
                          value: _info.eb == 1,
                          onChanged: (bool value) {
                            setState(() {
                              _info.eb = value ? 1 : 2;
                            });
                          }
                      )
                    ],
                  ),
                  new Divider(height: 1.0,),
                  new InkWell(
                    onTap: (){
                      DateTime time = new DateTime.fromMillisecondsSinceEpoch(_info.exp * 1000);
                      _selectDate(context, time, (DateTime date){
                        setState(() {
                          _info.exp = (date.millisecondsSinceEpoch ~/ 1000).toInt();
                        });
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text('有 效 期：'),
                          new Text('${Func.getYearMonthDay(_info.exp * 1000)}'),
                          new Icon(Icons.navigate_next,
                              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade700 : Colors.white70
                          ),
                        ],
                      ),
                    ),
                  ),
                  new Divider(height: 1.0,),
                  new SizedBox(height: 20.0,),
                  new RaisedButton(
                    color: const Color(0xFF029de0),
                    highlightColor: const Color(0xFF029de0),
                    child: const Text('提交', style: Style.loginTextStyle),
                    padding: EdgeInsets.all(10.0),
                    onPressed: _handleSubmitted,
                  ),
                ]
            ),
          )
      ),
    ];

    if(_loading){
      children.add(Func.topLoadingWidgetInChildren());
    }


    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text('平台信息'),
        ),

        body: new Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),

          child: new Stack(
            children: children,
          ),
        )
    );
  }
}