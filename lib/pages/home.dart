import 'package:flutter/material.dart';

import '../utils/cache.dart';
import '../pages/login.dart';
import '../utils/assets.dart';
import '../utils/style.dart';

import 'switchPlatform.dart';


class HomePage extends StatefulWidget{
  const HomePage({Key key}): super(key: key);

  static const String route = '/home';

  @override
  State<StatefulWidget> createState() {
    return new HomeState();
  }
}

class HomeState extends State<HomePage> {

  int _currentIndex = 2;

  AppBar _getAppBar() {
    if(_currentIndex == 0 || _currentIndex == 1) {
      return new AppBar(
        backgroundColor: Style.COLOR_THEME,
        title: new Text(_currentIndex == 0 ? '设备卡号' : '消息列表'),
        actions: <Widget>[
          new IconButton(
              icon: const Icon(Icons.add),
              tooltip: '添加卡',
              onPressed: () {

              }
          ),
        ],
      );
    }

    return null;
  }

  Color _getSelectColor(int index) {
    return _currentIndex == index ? Style.COLOR_THEME : null;
  }

  Widget _getMenu(String image, String title, GestureTapCallback onTap) {
    return new ListTile(
      leading: new Padding(
          padding: EdgeInsets.all(8.0),
          child: new Image.asset(image,
          )),
      title: new Text(title, style: new TextStyle(fontSize: 14.0),),
      trailing: new Icon(Icons.navigate_next),

      onTap: onTap,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _getPersonView() {

    List<Widget> children = <Widget>[
      new Container(
          height: 180.0 +  MediaQuery.of(context).padding.top,
          decoration: new BoxDecoration(
              image: new DecorationImage(image: new AssetImage(ImageAssets.ic_bg_person), fit: BoxFit.cover)
          ),
          child: new Column (
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Image.asset(ImageAssets.icon_mine_photo,
                height: 72.0,
                width: 72.0,
              ),
              new SizedBox(height: 8.0),
              new Text(Cache.instance.username, style: new TextStyle(
                  color: Colors.white,
                  fontSize: 16.0
              )),
              new Text(Cache.instance.cdadd, style: new TextStyle(
                  color: Colors.white, fontSize: 16.0
              )),
              new SizedBox(height: 20.0),
            ],
          )
      ),
      new Container(height: 8.0, color: Style.COLOR_BACKGROUND,),
      new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Divider(height: 0.5),
          _getMenu(ImageAssets.myinfo_icon_1, '平台切换', () async {
            final result = await Navigator.pushNamed(context, SwitchPlatformPage.route);
            print('switchPlatform result: $result');

            if(result != null) {
              setState(() {

              });
            }
          }),
          new Divider(height: 0.5),
          _getMenu(ImageAssets.myinfo_icon_2, '指令管理', () {

          }),
          new Divider(height: 0.5),
        ],
      ),

    ];

    if(Cache.instance.admin == 2) {
      children.addAll(<Widget>[
        new Container(height: 8.0, color: Style.COLOR_BACKGROUND,),
        new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Divider(height: 0.5),
              _getMenu(ImageAssets.ic_platform_manage, '平台管理', () {
              }),
              new Divider(height: 0.5),
              _getMenu(ImageAssets.ic_user_manage, '用户管理', () {

              }),
              new Divider(height: 0.5),
            ]        ),
      ]);
    }

    children.addAll(<Widget>[
      new Container(height: 8.0, color: Style.COLOR_BACKGROUND,),
      new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Divider(height: 0.5),
            _getMenu(ImageAssets.myinfo_icon_3, '修改密码', () {
            }),
            new Divider(height: 0.5),
            _getMenu(ImageAssets.myinfo_icon_4, '退出登录', () {

            }),
            new Divider(height: 0.5),
          ]        ),
      new Expanded(child: new Container(
        color: Style.COLOR_BACKGROUND,
      ))
    ]);

    return new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: children
    );
  }

  Widget _getBody() {
    switch(_currentIndex){
      case 2:
        return _getPersonView();
      default:
        return new Text('hello $_currentIndex');
    }
  }

  @override
  Widget build(BuildContext context) {

    BottomNavigationBar botNavBar = new BottomNavigationBar(
      items: [
        new BottomNavigationBarItem(
          icon: new Image.asset(ImageAssets.ic_tab_card_normal, color: _getSelectColor(0), height: Style.BAR_HEIGHT,),
          title: new Text('卡号列表'),
        ),
        new BottomNavigationBarItem(
          icon: new Image.asset(ImageAssets.ic_tab_msg_normal, color: _getSelectColor(1), height: Style.BAR_HEIGHT,),
          title: new Text('消息列表'),
        ),
        new BottomNavigationBarItem(
          icon: new Image.asset(ImageAssets.ic_tab_mine_normal, color: _getSelectColor(2), height: Style.BAR_HEIGHT,),
          title: new Text('个人中心'),
        ),
      ],
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      fixedColor: Style.COLOR_THEME,
      iconSize: 16.0,
      onTap: (int index) {
        setState(() {
          _currentIndex = index;
        });
      },
    );

    return new Scaffold(
        appBar: _getAppBar(),
        body: _getBody(),
        bottomNavigationBar: new Theme(
            data: new ThemeData(
              canvasColor: const Color(0xfff5f5f5),
            ),
            child: botNavBar
        ),
        floatingActionButton:new FloatingActionButton(
          onPressed: () async{
            Cache cache = await Cache.getInstace();
            cache.remove(KEY_TOKEN);
            cache.remove(KEY_ADMIN);
            Navigator.pushReplacementNamed(context, LoginPage.route);
          },
          backgroundColor: Colors.redAccent,
          child: const Icon(
            Icons.lock_open,
            semanticLabel: '注销',
          ),
        )
    );
  }
}


