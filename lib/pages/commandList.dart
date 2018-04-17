import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../utils/db.dart';
import '../utils/style.dart';


class CommandEditPage extends StatelessWidget{

  final String title;

  const CommandEditPage({Key key, @required this.title}): assert(title != null), super(key:key);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(''),
      ),
    );
  }
}



class CommandListPage extends StatefulWidget{
  const CommandListPage({Key key}): super(key: key);

  static const String route = '/home/commonds';

  @override
  State<StatefulWidget> createState() {
    return new CommandListPageState();
  }
}

class CommandListPageState extends State<CommandListPage>{

  Future<List<CommandValue>> _getData() async{
    return DB.instance.getValues<CommandValue>();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('指令管理'),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.add),
              tooltip: '添加指令',
              onPressed: (){

          }),
        ],
      ),
      body: new FutureBuilder<List<CommandValue>>(
          future: _getData(),
          builder: (BuildContext context, AsyncSnapshot<List<CommandValue>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return new Center(child: new CircularProgressIndicator());
              default:
                if (snapshot.hasData) {
                  List<CommandValue> values = snapshot.data;
                }

                return new Container(
                    color: Style.COLOR_BACKGROUND,
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    height: MediaQuery.of(context).size.height
                );
            }
          }
      ),

    );
  }
}