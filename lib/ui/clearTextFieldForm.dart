import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/assets.dart';

class ClearTextFieldForm extends StatefulWidget {

  final Widget icon;
  final String hintText;
  final String initialValue;
  final TextStyle style;
  final TextStyle hintStyle;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String> onFieldSubmitted;


  const ClearTextFieldForm({
    Key key,
    this.icon,
    this.hintText,
    this.style,
    this.hintStyle,
    this.initialValue,
    this.obscureText,
    this.keyboardType,
    this.onFieldSubmitted
  }) : super (key: key);

  @override
  State<StatefulWidget> createState() {
    return new ClearTextFieldFormState();
  }
}

class ClearTextFieldFormState extends State<ClearTextFieldForm> {

  bool _showClearIcon = false;
  TextEditingController _controller;


  @override
  void initState() {
    super.initState();

//    print('initValue = ${widget.initialValue}');

    _controller = new TextEditingController(text: widget.initialValue??'');

    if(_controller.text.length > 0){
      _showClearIcon = true;
    }

    _controller.addListener(() {
//      print('_controller.text='+_controller.text);
      if(_controller.text.length > 0 && !_showClearIcon){
        setState(() {
          _showClearIcon = true;
        });
      }

      if( _showClearIcon && _controller.text.length == 0){
        setState(() {
          _showClearIcon = false;
        });
      }
    });

  }


  void clear() {
    _controller.clear();
  }

  get text => _controller.text;

  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      obscureText: widget.obscureText ?? false,
      controller: _controller,
      style: widget.style,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: new InputDecoration(
        prefixIcon: new Padding(
          padding: EdgeInsets.all(12.0),
          child: widget.icon,
        ),
        suffixIcon: _showClearIcon ? GestureDetector(
            onTap: () {
              _controller.clear();
              setState(() {
                _showClearIcon = false;
              });
            },
            child: new Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.0),
              child: new Image.asset(
                ImageAssets.clearfill,
                height: 20.0,
                fit: BoxFit.fill,
                color: Theme.of(context).accentColor,
              ),
            )
        ) : null,
        border: const UnderlineInputBorder(),
        hintText: widget.hintText,
        contentPadding: EdgeInsets.symmetric(vertical: 12.0),
        hintStyle: widget.hintStyle,
      ),
    );
  }
}