import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'userEdit.dart';

import '../model/userInfo.dart';

import '../utils/index.dart';

import '../ui/underLine.dart';

typedef  void ShowTips(String msg);
typedef  void ClickCallback(UserInfo user);

class _FutureUserList extends StatefulWidget{
  final ShowTips show;
  final ClickCallback callback;
  const _FutureUserList({Key key, @required this.show, @required this.callback}) :super(key:key);

  @override
  State<StatefulWidget> createState() {
    return new _FutureUserListState();
  }
}

class _FutureUserListState extends State<_FutureUserList>{

  String _snm = '';
  List<UserInfo> _users;
  bool isNotify = false;

  Future<http.Response> _getData() async{
    Map<String, dynamic> params =  {
      'Unm': Cache.instance.username,
      'Token': Cache.instance.token,
      'Snm': _snm??''
    };

    return NetWork.post(NetWork.GET_USERS, params);
  }

  Widget _getUserListWidget(){
    return new Expanded(
      child: new ListView.builder(
        itemCount: _users.length,
        itemBuilder: (BuildContext context, int index) {
          UserInfo item = _users[index];

          return new UnderLine(
              child: new ListTile(
                leading: new Padding(
                  padding: EdgeInsets.all(8.0),
                  child: new Image.asset(_getImageName(item.enable)),
                ),
                title: new Text(item.upid, style: new TextStyle(color: item.enable == 1 ? Colors.black : Colors.grey),),
                subtitle: new Text(item.unm),
                trailing: new Text(_getUpdateTime(item.ut), style: new TextStyle(color: item.enable == 1 ? Colors.black : Colors.grey),),
                onTap: () {
                  if(widget.callback != null){
                    widget.callback(item);
                  }
                },
              )
          );
        },
      ),
    );
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

  void notify(String snm){
    if(_snm == snm) return;
    _snm = snm;
    isNotify = true;

    setState(() {

    });
  }

  @override
  void dispose() {
    super.dispose();
    _users?.clear();
  }

  @override
  Widget build(BuildContext context) {
//    print('build _snm=$_snm, _isNotify = $isNotify');
    if(_users != null && !isNotify && _users.length > 0) return _getUserListWidget();
    isNotify = false;
    return new FutureBuilder<http.Response>(
        future: _getData(),
        builder: (BuildContext context, AsyncSnapshot<http.Response> snapshot) {
          if (snapshot.hasData) {
            http.Response response = snapshot.data;
            if (response.statusCode != 200) {
              return new Expanded(child: Func.logoutWidget(context, response.body));
            } else {
              Map data = NetWork.decodeJson(response.body);

//              print(data);

              if (data['Code'] != 0) {
                return new Expanded(child: Func.logoutWidget(context, data['Message']));
              } else {
                _users =  parseUsers(data['Response']);
                if(_users.length == 0){
                  return new Center(child: new Text('没有搜索到相关信息'));
                }

                return _getUserListWidget();

              }
            }
          } else {
            return new Expanded(child: new Container(child: new Center(child: new CircularProgressIndicator(),),));
          }
        });
  }
}

class UserManagerPage extends StatefulWidget{
  const UserManagerPage();

  @override
  State<StatefulWidget> createState() {
    return new UserManagerState();
  }

}

class UserManagerState extends State<UserManagerPage>{

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<_FutureUserListState> _userKey = new GlobalKey<_FutureUserListState>();
  TextEditingController _controller = new TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      _userKey.currentState.notify(_controller.text);
    });
  }

  void _click(UserInfo user){
    _push(user: user);
  }

  void _push({UserInfo user}) async{
    final result = Navigator.push(context, new MaterialPageRoute(
        builder: (BuildContext context) => new UserEditPage(user: user,)));

    if(result != null){
      _controller.clear();
      _userKey.currentState.notify('');
    }
  }

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text('用户列表'),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.add),
              tooltip: '增加',
              onPressed: ()=> _push()
          )
        ],
      ),

      body:new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Container(
              color: Style.COLOR_BACKGROUND,
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
              child: new TextField(
                controller: _controller,
                onSubmitted: (String value){
                },
                decoration: new InputDecoration(
                    prefixIcon: new Icon(Icons.search),
                    suffixIcon: new InkWell(
                      onTap: (){
                        if(_controller.text.length == 0) return;
                        _controller.clear();
                        _userKey.currentState.notify('');
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
            new _FutureUserList(
              key: _userKey,
              show: (String msg){
                Func.showMessage(_scaffoldKey, msg);
              },
              callback: _click,
            ),
          ]),
    );
  }
}