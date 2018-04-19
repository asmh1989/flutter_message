import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

import '../model/userInfo.dart';

import '../utils/index.dart';

class UserManagerPage extends StatefulWidget{
  const UserManagerPage();

  @override
  State<StatefulWidget> createState() {
    return new UserManagerState();
  }

}

class UserManagerState extends State<UserManagerPage>{

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController _controller = new TextEditingController();
  List<UserInfo> _users;

  String _snm = '';
  String _currentSnm = '';

  Future<http.Response> _getData() async{
    Map<String, dynamic> params =  {
      'Unm': Cache.instance.username,
      'Token': Cache.instance.token,
      'Snm': _snm??''
    };

    return NetWork.post(NetWork.GET_USERS, params);
  }

  void _click(int index){

  }

  String _getImageName(int enable){
    if(enable == 1){
      return ImageAssets.ic_avatar_blue;
    } else if(enable == 2){
      return ImageAssets.ic_avatar_grey;
    } else if(enable == 0){
      return ImageAssets.ic_avatar_green;
    }
    return ImageAssets.ic_avatar_blue;
  }

  String _getUpdateTime(int ut){
    return Func.getFullTimeString(ut* 1000);
  }

  List<UserInfo> parseUsers(List<dynamic> data) {
    return data.map((json) => new UserInfo.fromJson(json)).toList();
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if(_controller.text == _snm || _controller.text.length == 0) return;
      setState(() {
        _snm = _controller.text;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _users?.clear();
  }

  Widget _getHeader(Widget child){
    return new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Container(
            color: Style.COLOR_BACKGROUND,
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
            child: new TextField(
              controller: _controller,
              decoration: new InputDecoration(
                  prefixIcon: new Icon(Icons.search),
                  suffixIcon: new InkWell(
                    onTap: (){
                      setState(() {
                        _snm = _currentSnm = '';
                        _controller.clear();
                      });
                    },
                    child: new Text('清除',
                      style: new TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  hintText: '搜索',
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.all(8.0),
                  border: new OutlineInputBorder(
                      borderSide: new BorderSide(color: Colors.white, width: 0.5))),
            ),
          ),
          child,
        ]);
  }

  Widget _getUserListWidget(){
    return _getHeader(
      new Expanded(
          child: new ListView.builder(
            itemCount: _users.length,
            itemBuilder: (BuildContext context, int index) {
              UserInfo item = _users[index];

              final Decoration decoration = new BoxDecoration(
                border: new Border(
                  bottom: Divider.createBorderSide(context),
                ),
              );

              return new Container(
                  color: Colors.white,
                  child: new DecoratedBox(
                      position: DecorationPosition.foreground,
                      decoration: decoration,
                      child: new ListTile(
                        leading: new Padding(
                          padding: EdgeInsets.all(8.0),
                          child: new Image.asset(_getImageName(item.enable)),
                        ),
                        title: new Text(item.upid),
                        subtitle: new Text(item.unm),
                        trailing: new Text(_getUpdateTime(item.ut)),
                        onTap: () {
                          _click(index);
                        },
                      )
                  )
              );
            },
          )),
    );
  }

  Widget get _getLoadingWidget =>
      new Expanded(
          child: new Center(
            child: new CircularProgressIndicator(),
          )
      );


  @override
  Widget build(BuildContext context) {

    bool needLoading = true;
    if(_users != null && _users.length > 0 && _snm == _currentSnm){
      needLoading = false;
    }

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('用户列表'),
      ),

      body: !needLoading ? _getUserListWidget() : new FutureBuilder<http.Response>(
          future: _getData(),
          builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return _getHeader(_getLoadingWidget);
              default:
                if (snapshot.hasData) {
                  http.Response response = snapshot.data;
                  if (response.statusCode != 200) {
                    return Func.logoutWidget(context, response.toString());
                  } else {
                    Map data = NetWork.decodeJson(response.body);

                    print(data);

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
                      _users =  parseUsers(data['Response']);
                      if(_users.length > 0){
                        _currentSnm = _snm;
                      } else {
                        Future.delayed(
                            new Duration(milliseconds: 100),
                                () => Func.showMessage(_scaffoldKey, '没有搜索到相关信息！'));
                      }

                      return _getUserListWidget();

                    }
                  }
                } else {
                  return _getHeader(_getLoadingWidget);
                }
            }}
      ),
    );
  }
}