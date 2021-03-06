import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'commandEdit.dart';

import '../utils/db.dart';
import '../utils/style.dart';
import '../utils/func.dart';

import '../ui/swide_widget.dart';

class CommandListPage extends StatefulWidget{
  final bool result;
  const CommandListPage({Key key, this.result = false}): super(key: key);

  static const String route = '/home/commonds';

  @override
  State<StatefulWidget> createState() {
    return new CommandListPageState();
  }
}

class CommandListPageState extends State<CommandListPage>{

  Map<Key, AutoClose> _autoClose = new Map<Key, AutoClose>();
  List<CommandValue> _values = new List<CommandValue>();


  Future<Null> _getData() async{
    List<dynamic> l = await DB.instance.query(CommandValueTable.name);
    _values.clear();
    _values.addAll(l.cast<CommandValue>());
  }

  @override
  void dispose() {
    super.dispose();
    _autoClose.clear();
  }

  Widget _getList(){
    return new Container(
        color: Style.COLOR_BACKGROUND,
        height: MediaQuery.of(context).size.height,
        child: _values.length > 0 ? new ListView.builder(
            itemCount: _values.length,
            itemBuilder: (BuildContext context,
                int index) {

              CommandValue value = _values[index];

              final List<FXRightSideButton> buttons= [
                new FXRightSideButton(name: '编辑',
                    backgroundColor: Colors.grey,
                    fontColor: Colors.white,
                    onPress: () async {
                      final result = await Navigator.push(context, new MaterialPageRoute(
                          builder: (BuildContext context) => new CommandEditPage(
                            title: Command.EDIT,
                            value: value,
                          )));

                      if(result != null){
                        await _getData();
                        setState(() {
                        });
                      }
                    }),
                new FXRightSideButton(name: '删除',
                    backgroundColor: Colors.red,
                    fontColor: Colors.white,
                    onPress: () async {
                      await DB.instance.delete(CommandValueTable.name,
                          where: '${CommandValueTable.title} = ?',
                          whereArgs: [value.title]
                      );

                      _values.removeAt(index);

                      setState((){});
                    })
              ];

              final Decoration decoration = new BoxDecoration(
                border: new Border(
                  bottom: Divider.createBorderSide(context),
                ),
              );
              return new FXLeftSlide(
                key: new Key('$index'),
                onOpen: (Key key,  AutoClose autoClose) => _autoClose[key] = autoClose,
                startTouch: () {
                  _autoClose.forEach((Key key, AutoClose autoClose){
                    autoClose();
                  });

                  _autoClose.clear();
                },
                child: new DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: decoration,
                  child:new ListTile(
                    title: new Text(value.title),
                    subtitle: new Text(_values[index].content),
                    onTap: (){
                      if(widget.result){
                        Navigator.pop(context, value.content);
                      }
                    },
                  ),
                ),
                buttons: buttons,
              );

            }) : null
    );
  }

  @override
  Widget build(BuildContext context) {

    _autoClose.clear();

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('指令管理'),
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.add),
              tooltip: '添加指令',
              onPressed: () async {
                final result = await Navigator.push(context, new MaterialPageRoute(
                    builder: (BuildContext context) => new CommandEditPage(title: Command.NEW))
                );

                if(result != null){
                  await _getData();
                  setState(() {
                  });
                }

              }),
        ],
      ),
      body: _values.length > 0 ? _getList() : new FutureBuilder<Null>(
          future: _getData(),
          builder: (BuildContext context, AsyncSnapshot<List<CommandValue>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Func.loadingWidget(context);
              default:
                return _getList();

            }
          }
      ),

    );
  }
}