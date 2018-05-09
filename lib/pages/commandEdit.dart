import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../ui/clearTextFieldForm.dart';

import '../utils/db.dart';
import '../utils/func.dart';

enum Command {
  NEW,
  EDIT
}

class CommandEditPage extends StatefulWidget{

  final Command title;
  final CommandValue value;

  const CommandEditPage({
    @required this.title,
    this.value,
  }): assert(title != null);

  @override
  State<StatefulWidget> createState() {
    return new CommandEditState();
  }
}

class CommandEditState extends State<CommandEditPage> {

  GlobalKey<ClearTextFieldFormState> _titleKey = new GlobalKey<ClearTextFieldFormState>();
  GlobalKey<ClearTextFieldFormState> _contentKey = new GlobalKey<ClearTextFieldFormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(widget.title == Command.NEW ? '新建指令' : '编辑指令',),
        actions: <Widget>[
          new IconButton(icon: new Text('保存', style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700)) , onPressed: () async{
              if(_titleKey.currentState.text == '' || _contentKey.currentState.text == ''){
                Func.showMessage('标题或内容不能为空');
                return;
              } else {
                try {

//                  final query = await DB.instance.queryOne(CommandValueTable.name, where: '${CommandValueTable.title} = ?', whereArgs: [_titleKey.currentState.text]);
//                  if(query != null){
//                    Func.showMessage('保存失败, 标题重复');
//                    return;
//                  }


                  if(widget.value != null){
                    CommandValue value = new CommandValue(id:widget.value.id, title: _titleKey.currentState.text, content: _contentKey.currentState.text);

                    await DB.instance.insertOrUpdate(value, where: '${CommandValueTable.id} = ?', whereArgs: [value.id]);
                  } else {
                    CommandValue value = new CommandValue( title: _titleKey.currentState.text, content: _contentKey.currentState.text);
                    await DB.instance.insertOrUpdate(value, where: '${CommandValueTable.title} = ?', whereArgs: [value.title]);
                  }
                  Func.showMessage('保存成功');


                  Future.delayed(new Duration(milliseconds: 400), (){
                    Navigator.pop(context, 'finish');
                  });

                } catch(e){
                  print(e);
                  Func.showMessage('保存失败');

                }
              }
          })
        ],
      ),
      body: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: new Text('指令标题'),
            ),
            new ClearTextFieldForm(
              border: new OutlineInputBorder(),
              key: _titleKey,
              initialValue: widget.value?.title,
              contentPadding: EdgeInsets.all(8.0),
            ),
            new Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: new Text('指令内容'),
            ),
            new ClearTextFieldForm(
              border: new OutlineInputBorder(),
              key: _contentKey,
              maxLine: 10,
              initialValue: widget.value?.content,
              contentPadding: EdgeInsets.all(8.0),
            )
          ],
        ),
      ),
    );
  }
}