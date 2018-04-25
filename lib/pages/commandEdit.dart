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
  final String titleValue;
  final String contentValue;

  const CommandEditPage({
    @required this.title,
    this.titleValue,
    this.contentValue
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
                CommandValue value = new CommandValue(title: _titleKey.currentState.text, content: _contentKey.currentState.text);
                try {


                  await DB.instance.insertOrUpdate<CommandValue>(value, where: '${CommandValueTable.title} = ?', whereArgs: [value.title]);
                  Func.showMessage('保存成功');

                  if(widget.titleValue != null){
                    await DB.instance.delete<CommandValue>(where: '${CommandValueTable.title} = ?', whereArgs: [widget.titleValue]);
                  }

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
              initialValue: widget.titleValue,
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
              initialValue: widget.contentValue,
              contentPadding: EdgeInsets.all(8.0),
            )
          ],
        ),
      ),
    );
  }
}