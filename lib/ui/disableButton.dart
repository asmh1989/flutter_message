import 'package:flutter/material.dart';

class DisableButton extends StatefulWidget{

  final VoidCallback onPressed;

  const DisableButton({Key key, this.onPressed}): super(key: key);

  @override
  State<StatefulWidget> createState() {
    return new DisableButtonState();
  }
}

class DisableButtonState extends State<DisableButton>{

  bool _disabled = true;

  void setDisabled(bool disable){
    if(_disabled == disable) return;
    setState(() {
      _disabled = disable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Theme(data: new ThemeData(
      buttonTheme: new ButtonThemeData(
          minWidth: 40.0,
        height: 40.0
      )
    ), child: RaisedButton(
      padding: EdgeInsets.all(4.0),
      color: const Color(0xFF029de0),
      highlightColor: const Color(0xFF029de0),
      child: new Text('发送', style: new TextStyle(color: Colors.white),),
      onPressed: _disabled ? null : widget.onPressed,
    ));
  }
}