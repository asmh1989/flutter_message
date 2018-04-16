import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../utils/style.dart';
import '../utils/assets.dart';
import '../ui/clearTextFieldForm.dart';
import '../ui/passwordField.dart';

import '../utils/func.dart';
import '../utils/network.dart';

const double SPACE = 20.0;

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key key}) : super (key: key);

  static const String route = '/reigister';

  @override
  State<StatefulWidget> createState() {
    return new RegisterPageState();
  }
}

class PersonData {
  String username = '';
  String phoneCode= '';
  String name = '';
  String department = '';
  String jobNumber = '';
  String password_1 = '';
  String password_2 = '';
}

class RegisterPageState extends State<RegisterPage> {

  bool _loading = false;

  bool _autovalidate = false;
  PersonData person = new PersonData();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<ClearTextFieldFormState> _userKey = new GlobalKey<ClearTextFieldFormState>();


  void _showMessage(String value) {
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(value, textAlign: TextAlign.center)
    ));
  }

  Future<Null>  _handleSubmitted() async {
    FocusScope.of(context).requestFocus(new FocusNode());

    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      _showMessage('请先修复错误,再确认');
      return;
    } else {
      form.save();
    }

    if(person.password_1 != person.password_2){
      _showMessage('两次密码输入不一致');
      return;
    }

    setState(() {
      _loading = true;
    });

    http.Response response = await NetWork.post(NetWork.FIND_PWD, {
      'Unm': person.username,
      'Ver': person.phoneCode,
      'Npd': person.password_1,
      'Upid': person.name,
      'Udep': person.department,
      'Ujob': person.jobNumber
    });

    Future.delayed(new Duration(milliseconds: 200), () async {
      setState(() {
        _loading = false;
      });

      if(response.statusCode == 200) {
        print(response.body);

        Map data = NetWork.decodeJson(response.body);
        if(data['Code'] != 0){
          _showMessage(data['Message']);
        } else {
          _showMessage('注册成功');
          Future.delayed(new Duration(milliseconds: 1000),(){
            Navigator.pop(context);
          });
        }
      }
    });



  }

  String _validateName(String value) {
    if (value.isEmpty)
      return '手机号不能为空';
    if (!Func.validatePhone(value))
      return '手机号码格式错误';
    return null;
  }

  FormFieldValidator<String>  _validateNull(String msg){
    return (String value) {
      if(value.isEmpty){
        return msg;
      }

      return null;
    };
  }

  Future<Null> _getPhoneCode() async {

    String phone = _userKey.currentState.text;
    if(!Func.validatePhone(phone)) {
      _userKey.currentState.clear();
      _showMessage('手机号格式错误');
      return;
    }

    setState(() {
      _loading = true;
    });

    http.Response response= await NetWork.getPhoneCode(phone, true);

    Future.delayed(new Duration(milliseconds: 200), () async {
      setState(() {
        _loading = false;
      });

      if(response.statusCode == 200) {
        print(response.body);

        Map data = NetWork.decodeJson(response.body);
        if(data['Code'] != 0){
          _showMessage(data['Message']);
        } else {
          _showMessage('已发送');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> children = <Widget>[
      new Form (
        key: _formKey,
        autovalidate: _autovalidate,
        child:new SingleChildScrollView(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new ClearTextFieldForm(
                    key: _userKey,
                    icon: new Image.asset(
                      ImageAssets.icon_reg_account,
                      height: 25.0,
                    ),
                    hintText: '请输入手机号',
                    keyboardType: TextInputType.phone,
                    onSaved: (String value) { person.username = value;},
                    validator: _validateName,
              ),
              new SizedBox(height: SPACE),
              new TextFormField(
                    validator: _validateNull('验证码不能为空'),
                    keyboardType: TextInputType.number,
                    onSaved: (String value) { person.phoneCode = value; },
                    decoration: new InputDecoration(
                      prefixIcon: new Padding(
                        padding: EdgeInsets.all(12.0),
                        child: new Image.asset(
                          ImageAssets.icon_reg_verification,
                          height: 25.0,
                        ),
                      ),
                      suffixIcon: new RaisedButton(
                        color: const Color(0xFF029de0),
                        highlightColor: const Color(0xFF029de0),
                        child: const Text('获取验证码',
                            style: const TextStyle(
                              inherit: false,
                              fontSize: 14.0,
                              color: Colors.white,
                              textBaseline: TextBaseline.alphabetic,
                            )
                        ),
                        padding: EdgeInsets.symmetric(vertical: 6.0),
                        onPressed: this._getPhoneCode,
                      ),
                      border: const UnderlineInputBorder(),
                      hintText: '请输入验证码',
                    ),
              ),
              new SizedBox(height: SPACE),
              new ClearTextFieldForm(
                icon: new Image.asset(
                  ImageAssets.icon_reg_name,
                  height: 25.0,
                ),
                hintText: '请输入姓名',
                onSaved: (String value) { person.name = value;},
                validator: _validateNull('请输入姓名'),
              ),
              new SizedBox(height: SPACE),
              new ClearTextFieldForm(
                icon: new Image.asset(
                  ImageAssets.icon_reg_department,
                  height: 25.0,
                ),
                hintText: '请输入部门/单位/组织等',
                onSaved: (String value) { person.department = value;},
                validator: _validateNull('请输入部门/单位/组织等'),
              ),
              new SizedBox(height: SPACE),
              new ClearTextFieldForm(
                icon: new Image.asset(
                  ImageAssets.icon_reg_account,
                  height: 25.0,
                ),
                hintText: '请输入工号',
                onSaved: (String value) { person.jobNumber = value;},
                validator: _validateNull('请输入工号'),
              ),
              new SizedBox(height: SPACE),
              new PasswordField(
                  icon: new Image.asset(
                    ImageAssets.icon_reg_password,
                    height: 25.0,
                  ),
                  hintText: '请输入密码',
                  validator: _validateNull('密码不能为空'),
                  onSaved: (String value) {person.password_1 = value;},
              ),
              new SizedBox(height: SPACE),
              new PasswordField(
                  icon: new Image.asset(
                    ImageAssets.icon_ensure_password,
                    height: 25.0,
                  ),
                  hintText: '请确认密码',
                  validator: _validateNull('确认不能为空'),
                  onSaved: (String value) {person.password_2 = value;},
              ),
              new SizedBox(height: SPACE* 2),
//              new SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 0.0 : 30.0),
              new RaisedButton(
                color: const Color(0xFF029de0),
                highlightColor: const Color(0xFF029de0),
                child: const Text('注册', style: Style.loginTextStyle),
                padding: EdgeInsets.all(10.0),
                onPressed: _handleSubmitted,
              ),

            ],
          ),
        ),
      ),
    ];

    if(_loading){
      children.add(
          new Positioned.fill(
              child: new GestureDetector(
                  onTap: (){},
                  behavior: HitTestBehavior.opaque,
                  child: new Center(
                      child: new Theme(
                        data: new ThemeData(
                          accentColor: Colors.red,
                        ),
                        child: new Container(
                            height: 60.0,
                            width: 60.0,
                            child:new CircularProgressIndicator(
                            )
                        ),
                      )
                  )
              )
          )
      );
    }

    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: const Text('新用户注册'),
        ),
        body: new Container(
          padding: const EdgeInsets.all(30.0),

          child: new Stack(
            children: children,
          ),
        )

    );
  }
}