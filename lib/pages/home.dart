import 'package:flutter/material.dart';

import 'login.dart';
import 'switchPlatform.dart';
import 'commandList.dart';
import 'passwd.dart';
import 'userManager.dart';
import 'cardManager.dart';
import 'cardEdit.dart';
import 'msgDetail.dart';
import 'msgManager.dart';


import '../utils/index.dart';

class HomePage extends StatefulWidget{
  const HomePage({Key key}): super(key: key);

  static const String route = '/home';

  @override
  State<StatefulWidget> createState() {
    return new HomeState();
  }
}

class HomeState extends State<HomePage> {

  int _currentIndex = 0;

//  PageController _controller;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  AppBar _getAppBar() {
    if(_currentIndex == 0 || _currentIndex == 1) {
      return new AppBar(
        backgroundColor: Style.COLOR_THEME,
        title: new Text(_currentIndex == 0 ? '设备卡号' : '消息列表'),
        actions: <Widget>[
          new IconButton(
              icon: const Icon(Icons.add),
              tooltip: _currentIndex == 0 ? '添加卡' : '新建消息',
              onPressed: () async {
                final result = await Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => _currentIndex == 0 ? new CardEdit() : new MsgDetailPage()));

                if(result != null){
                  if(_currentIndex == 0){
                    CardManagerPage.clear();
                  } else {
                    MsgManagerPage.clear();
                  }

                  setState(() {

                  });
                }

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
//    _controller = new PageController(initialPage: _currentIndex);
  }

  Widget _getPersonView() {
    List<Widget> children = <Widget>[

      new Container(height: 8.0, color: Style.COLOR_BACKGROUND,),
      new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Divider(height: 0.5),
          _getMenu(ImageAssets.myinfo_icon_1, '平台切换', () async {

            /// 默认返回会主动刷新界面
            final result = await Navigator.pushNamed(context, SwitchPlatformPage.route);
            print('switchPlatform result: $result');
            if(result != null){
              MsgManagerPage.clear();
              CardManagerPage.clear();
            }

          }),
          new Divider(height: 0.5),
          _getMenu(ImageAssets.myinfo_icon_2, '指令管理', () {

            Navigator.push(context, new MaterialPageRoute(
                builder: (BuildContext context)=> new CommandListPage())
            );
          }),
          new Divider(height: 0.5),
        ],
      ),

    ];

    /// 管理员权限
    if(Cache.instance.admin == 1) {
      children.addAll(<Widget>[
        new Container(height: 8.0, color: Style.COLOR_BACKGROUND,),
        new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new Divider(height: 0.5),
              _getMenu(ImageAssets.ic_platform_manage, '平台管理', () {
                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new SwitchPlatformPage(isManager: true,)
                ));
              }),
              new Divider(height: 0.5),
              _getMenu(ImageAssets.ic_user_manage, '用户管理', () {
                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new UserManagerPage()
                ));
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
              Navigator.push(context, new MaterialPageRoute(
                  builder: (BuildContext context)=> new PasswordPage(isModify: true,))
              );
            }),
            new Divider(height: 0.5),
            _getMenu(ImageAssets.myinfo_icon_4, '退出登录', () {

              showDialog(
                  context: context,
                  builder: (BuildContext context) => new AlertDialog(
                    content: new Text('是否退出当前账号'),
                    actions: <Widget>[
                      new FlatButton(onPressed: (){
                        Navigator.pop(context);
                      }, child: new Text('取消')),
                      new FlatButton(onPressed: () async {
                        Cache cache = await Cache.getInstace();
                        cache.remove(KEY_TOKEN);
                        cache.remove(KEY_ADMIN);
                        CardManagerPage.clear();
                        MsgManagerPage.clear();
                        Navigator.pushReplacementNamed(context, LoginPage.route);
                      }, child: new Text('确定'))
                    ],
                  )
              );

            }),
            new Divider(height: 0.5),
          ]
      ),
    ]);

    return new Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
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
        SingleChildScrollView(
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: children
            )),
        new Expanded(child: new Container(
          color: Style.COLOR_BACKGROUND,
        ))
      ],
    );
  }

  Widget _getBody() {

    switch(_currentIndex){
      case 0:
        return new CardManagerPage();
      case 1:
        return new MsgManagerPage();
      default:
        return  _getPersonView();

    }

//    return new PageView(
//      physics: new NeverScrollableScrollPhysics(),
//      controller: _controller,
//      children: <Widget>[
//        new CardManagerPage(type: CardType.CARD, show: (String value)=>Func.showMessage(_scaffoldKey, value),),
//        new Text('hello 1'),
//      ],
//    );
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
//          _controller.jumpToPage(index);
          _currentIndex = index;
        });
      },
    );

    return new Scaffold(
        key: _scaffoldKey,
        appBar: _getAppBar(),
        body: _getBody(),
        bottomNavigationBar: new Theme(
            data: new ThemeData(
              canvasColor: const Color(0xfff5f5f5),
            ),
            child: botNavBar
        ),
        floatingActionButton: NetWork.isDebug ? new FloatingActionButton(
          onPressed: () async{
            Cache cache = await Cache.getInstace();
            cache.remove(KEY_TOKEN);
            cache.remove(KEY_ADMIN);
            CardManagerPage.clear();
            MsgManagerPage.clear();
            Navigator.pushReplacementNamed(context, LoginPage.route);
          },
          backgroundColor: Colors.redAccent,
          child: const Icon(
            Icons.lock_open,
            semanticLabel: '注销',
          ),
        ) : null
    );
  }

  @override
  void dispose() {
    super.dispose();
//    _controller.dispose();
  }
}


