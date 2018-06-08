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
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String> validator;
  final InputBorder border;
  final int maxLine;
  final EdgeInsets contentPadding;
  final VoidCallback listener;
  final bool filled;
  final Color filledColor;
  final Color clearColor;
  final bool enable;

  const ClearTextFieldForm({
    Key key,
    this.icon,
    this.hintText,
    this.style,
    this.hintStyle,
    this.initialValue,
    this.obscureText,
    this.keyboardType,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.border,
    this.maxLine = 1,
    this.contentPadding,
    this.listener,
    this.filled = false,
    this.filledColor,
    this.clearColor,
    this.enable = true,
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

    if(_controller.text.length > 0 && widget.enable){
      _showClearIcon = true;
    }

    _controller.addListener(() {
//      print('_controller.text='+_controller.text);

      if(widget.listener != null){
        widget.listener();
      }

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

  set text(String value){
    _controller.text = value;
    _controller.selection = new TextSelection.collapsed(offset: value.length);
  }


  @override
  Widget build(BuildContext context) {
    return new TextFormField(
      obscureText: widget.obscureText ?? false,
      controller: _controller,
      style: widget.style,
      keyboardType: widget.keyboardType ?? TextInputType.text,
      onFieldSubmitted: widget.onFieldSubmitted,
      onSaved: widget.onSaved,
      validator: widget.validator,
      maxLines: widget.maxLine,
      enabled: widget.enable,
      decoration: new InputDecoration(
          prefixIcon: widget.icon != null ? new Padding(
            padding: EdgeInsets.all(12.0),
            child: widget.icon,
          ): null,
          suffixIcon: _showClearIcon ? GestureDetector(
              onTap: () {
                _controller.clear();
                setState(() {
                  _showClearIcon = false;
                });
              },
              child: new Image.asset(
                ImageAssets.clearfill,
                height: 20.0,
                fit: BoxFit.fill,
                color: widget.clearColor ?? Theme.of(context).accentColor,
              )
          ) : null,
          border: widget.border??const UnderlineInputBorder(),
          hintText: widget.hintText,
          hintStyle: widget.hintStyle,
          filled: widget.filled,
          fillColor: widget.filledColor,
          contentPadding: widget.contentPadding
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}