import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../model/userInfo.dart';
import '../model/platformInfo.dart';

import '../utils/index.dart';

import 'login.dart';

class UserEditPage extends StatefulWidget{

  final UserInfo user;

  const UserEditPage({this.user});

  @override
  State<StatefulWidget> createState() {
    return new UserEditState();
  }
}


class UserEditState extends State<UserEditPage>{

  UserInfo _user;
  bool _loading = false;
  bool _autoValidate = false;

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();

    _user = widget.user ?? new UserInfo();
    print(widget.user.toString());
  }

  Widget _getMenus({
    String preText,
    String initString,
    String hintText,
    bool enable = true,
    bool obscureText,
    TextInputType type,
    FormFieldSetter<String> onSave,
    FormFieldValidator<String> validator,
  }){
    return new Container(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child:new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(preText),
            Expanded(child: new TextFormField(
              initialValue: initString,
              keyboardType: type ?? TextInputType.text,
              onSaved: onSave,
              validator: validator ?? (String value) => null,
              obscureText: obscureText ?? false,
              style: enable == false ? new TextStyle(color: Colors.grey) : null,
              enabled: enable,
              decoration: new InputDecoration.collapsed(
                  hintText: hintText),
            ),),
          ],
        ));
  }

  List<PlatformInfo> parsePlatforms(List<dynamic> data) {
    return data.map((json) => new PlatformInfo.fromJson(json)).toList();
  }

  Future<Null>  _handleSubmitted() async {
    FocusScope.of(context).requestFocus(new FocusNode());

    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autoValidate = true; // Start validating on every change.
//      Func.showMessage('请先修复错误,再确认');
      return;
    } else {
      form.save();
    }

    setState(() {
      _loading = true;
    });

    http.Response response = await NetWork.post(NetWork.apiSetUsers, {
      'Unm': Cache.instance.username,
      'Token': Cache.instance.token,
      'Type': widget.user == null ? '1' : '2',
      'Users': [_user].toString()
    });

    Future.delayed(new Duration(milliseconds: 200), () async {
      setState(() {
        _loading = false;
      });

      if(response.statusCode == 200) {
        print(response.body);

        Map data = NetWork.decodeJson(response.body);
        if(data['Code'] != 0){
          Func.showMessage(data['Message']);
        } else {
          Func.showMessage(widget.user == null ? '新增用户成功！': '修改用户信息成功！');
          Future.delayed(new Duration(milliseconds: 200),(){
            Navigator.pop(context, 'done');
          });
        }
      }
    });
  }

  Future<http.Response> _getData() async {
    return NetWork.getPlatforms(Cache.instance.username, Cache.instance.token);
  }


  Widget _getRowSwitch(String text, Widget child){
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Text(text),
        child
      ],
    );
  }

  Widget _getPlatFormList2(){

    List<Widget> children = <Widget>[
    ];

    if(_user.cdnos != null && _user.cdnos.length > 0){

      children.add( _getRowSwitch('全部', new CupertinoSwitch(
          value: _user.all == null ? true : _user.all == 1,
          onChanged: (bool value){
            setState(() {
              _user.all = value ? 1 : 2;
              _user.cdnos.forEach((CdNos c) => c.auth = value ? 1 : 2);
//              print(_user);
            });
          })
      ));
      children.add(new Divider(height: 1.0));

      for(int i = 0, len = _user.cdnos.length; i < len; i++){
        CdNos c = _user.cdnos[i];
        children.add( _getRowSwitch(c.name, new CupertinoSwitch(
            value: c.auth == 1,
            onChanged: (bool value){
              setState(() {
                _user.cdnos[i].auth = value?1:2;

                if(value) {
                  for (int j = 0, len = _user.cdnos.length; j < len; j++) {
                    if(_user.cdnos[j].auth == 2){
                      _user.all = 2;
                      return;
                    }
                  }

                  _user.all = 1;
                } else {
                  _user.all = 2;
                }
              });
            }))
        );
        children.add(new Divider(height: 1.0));
      }

    }

    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Text('平台权限：'),
        new Expanded(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children)
        )
      ],
    );
  }

  Widget _getPlatFormList(){

    if(widget.user == null && _user.cdnos == null){
      return new FutureBuilder<http.Response>(
          future: _getData(),
          builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot){
            if (snapshot.hasData) {
              http.Response response = snapshot.data;
              if (response.statusCode != 200) {
                return new Text('获取平台信息失败: ${response.toString()}');
              } else {
                Map data = NetWork.decodeJson(response.body);

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
                  List<PlatformInfo> platform = parsePlatforms(data['Response']);
                  _user.all = 1;
                  for(int i = 0, len = platform.length; i < len; i++){
                    if(_user.cdnos == null){
                      _user.cdnos = new List<CdNos>();
                    }

                    _user.cdnos.add(new CdNos(auth: 1, name: platform[i].name, cdno: platform[i].cdno));
                  }

                  return _getPlatFormList2();
                }
              }
            } else {
              return new Padding(
                  padding: EdgeInsets.all(4.0),
                  child: _getRowSwitch('平台权限: ', new CircularProgressIndicator())
              );
            }
          });
    } else {
      return _getPlatFormList2();
    }
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
                  _getMenus(preText: '用 户 名：', hintText: '请输入手机号', initString: widget.user == null ? '':_user.unm,
                      onSave: (String value) => _user.unm = value,
                      validator: Func.validateNull('请输入手机号'),
                      enable: widget.user == null ? true :  false
                  ),
                  new Divider(height: 1.0,),

                  _getMenus(preText: '用户姓名：', hintText: '请输入姓名', initString: widget.user == null ? '': _user.upid,
                    onSave: (String value) => _user.upid = value,
                    validator: Func.validateNull('请输入姓名'),
                  ),
                  new Divider(height: 1.0,),

                  _getMenus(preText: '部门名称：', hintText: '请输入部门/单位/组织等', initString: widget.user == null ? '': _user.udep,
                      onSave: (String value) => _user.udep = value,
                      validator: Func.validateNull('请输入部门/单位/组织等')
                  ),
                  new Divider(height: 1.0,),

                  _getMenus(preText: '单位工号：', hintText: '请输入工号', initString: widget.user == null ? '': _user.ujob,
                      onSave: (String value) => _user.ujob = value,
                      validator: Func.validateNull('请输入工号')
                  ),
                  new Divider(height: 1.0,),

                  _getMenus(preText: '用户密码：', hintText: '请输入密码', initString: widget.user == null ? '': _user.upd,
                      onSave: (String value) => _user.upd = value,
                      validator: (String value) => null,
                  ),
                  new Divider(height: 1.0,),

                  _getRowSwitch('是否有效：', new CupertinoSwitch(
                      value: _user.enable == 1,
                      onChanged: (bool value) {
                        setState(() {
                          _user.enable = value ? 1 : 2;
                        });
                      })
                  ),
                  new Divider(height: 1.0,),
                  _getRowSwitch('管 理 员：', new CupertinoSwitch(
                      value: _user.admin == 1,
                      onChanged: (bool value) {
                        setState(() {
                          _user.admin = value ? 1 : 2;
                        });
                      }
                      )),
                  new Divider(height: 1.0,),
                  _getPlatFormList(),
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
          title: new Text(widget.user != null ? '用户信息':'新增用户'),
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