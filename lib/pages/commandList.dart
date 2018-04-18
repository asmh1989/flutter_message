import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'commandEdit.dart';

import '../utils/db.dart';
import '../utils/style.dart';
import '../utils/func.dart';

import '../ui/swide_widget.dart';

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
    return DB.instance.query<CommandValue>();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('指令管理'),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.add),
              tooltip: '添加指令',
              onPressed: () async {
                Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new CommandEditPage(title: Command.NEW))
                );

              }),
        ],
      ),
      body: new FutureBuilder<List<CommandValue>>(
          future: _getData(),
          builder: (BuildContext context, AsyncSnapshot<List<CommandValue>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Func.loadingWidget(context);
              default:
                List<CommandValue> values = snapshot.data;
//                print('find CommandValue = ${values.length}');

                return new Container(
                    color: Style.COLOR_BACKGROUND,
                    height: MediaQuery.of(context).size.height,
                    child: values.length > 0 ? new ListView.builder(
                        itemCount: values.length,
                        itemBuilder: (BuildContext context,
                            int index) {

                          CommandValue value = values[index];

                          final List<FXRightSideButton> buttons= [
                            new FXRightSideButton(name: '编辑',
                                backgroundColor: Colors.grey,
                                fontColor: Colors.white,
                                onPress: (){
                                  Navigator.push(context, new MaterialPageRoute(
                                      builder: (BuildContext context) => new CommandEditPage(
                                        title: Command.EDIT,
                                        titleValue: value.title,
                                        contentValue: value.content,
                                      )));
                                }),
                            new FXRightSideButton(name: '删除',
                                backgroundColor: Colors.red,
                                fontColor: Colors.white,
                                onPress: () async {
                                  await DB.instance.delete<CommandValue>(
                                      where: '${CommandValueTable.title} = ?',
                                      whereArgs: [value.title]
                                  );

                                  setState(() {

                                  });
                                })
                          ];

                          final Decoration decoration = new BoxDecoration(
                            border: new Border(
                              bottom: Divider.createBorderSide(context),
                            ),
                          );
                          return new FXLeftSlide(
                            key: new Key('$index'),
                            child: new DecoratedBox(
                              position: DecorationPosition.foreground,
                              decoration: decoration,
                              child:new ListTile(
                                title: new Text(value.title),
                                subtitle: new Text(
                                    values[index].content),
                              ),
                            ),
                            buttons: buttons,
                          );

                        }) : null
                );
            }
          }
      ),

    );
  }
}