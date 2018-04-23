import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'size_change_notifier.dart';

typedef void AutoClose();
typedef void OnOpen(Key key, AutoClose autoClose);
typedef void StartTouch();

class FXRightSideButton extends Object{
  FXRightSideButton({@required this.name,@required this.onPress, this.backgroundColor:Colors.grey, this.fontColor:Colors.white}){
    assert(name != null);
    assert(onPress != null);
  }

  final String name;
  final VoidCallback onPress;
  final Color backgroundColor;
  final Color fontColor;
}

class FXLeftSlide extends StatefulWidget {
  FXLeftSlide({
    @required Key key,
    this.onOpen,
    this.startTouch,
    @required this.buttons,
    @required this.child,
    this.backgroundColor:Colors.white}):super(key:key){
    assert(buttons.length <= 3);
  }

  final List<FXRightSideButton> buttons;
  final Widget child;
  final Color backgroundColor;
  final OnOpen onOpen;
  final StartTouch startTouch;

  @override
  State<StatefulWidget> createState() {
    return new _LeftSlideState();
  }
}

class _LeftSlideState extends State<FXLeftSlide> {
  ScrollController controller = new ScrollController();
  bool isOpen = false;

  bool needSendTouchEvent = true;
  Size childSize;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller.addListener((){
      if(needSendTouchEvent)  {
//            print('${widget.key} is startTouch');

        needSendTouchEvent = false;
        if(widget.startTouch != null){
          widget.startTouch();
        }
      }

    });

  }

  bool _handleScrollNotification(dynamic notification) {
    if (notification is ScrollEndNotification) {
//          print('_handleScrollNotification : ${notification.metrics.pixels}');


      if(notification.metrics.pixels > 0.0){
        if(widget.onOpen != null){
          widget.onOpen(widget.key, (){
//                print('${widget.key} need autoClose');
            scheduleMicrotask((){
              try {
                controller.animateTo(
                    0.0, duration: new Duration(milliseconds: 200),
                    curve: Curves.decelerate);
              } catch(e){
                print(e);
              }
            });
          });
        }
      } else {
        needSendTouchEvent = true;
      }

      if (notification.metrics.pixels >= (widget.buttons.length * 60.0)/2 && notification.metrics.pixels < widget.buttons.length * 60.0){
        scheduleMicrotask((){
          controller.animateTo(widget.buttons.length * 60.0, duration: new Duration(milliseconds: 500), curve: Curves.decelerate);
        });
      }else if (notification.metrics.pixels > 0.0 && notification.metrics.pixels < (widget.buttons.length * 60.0)/2){
        scheduleMicrotask((){
          controller.animateTo(0.0, duration: new Duration(milliseconds: 500), curve: Curves.decelerate);
        });
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (childSize == null){
      return new NotificationListener(
        child: new FXSizeChangedLayoutNotifier(
          child: widget.child,
        ),
        onNotification: (FXSizeChangedLayoutNotification notification){
          childSize = notification.newSize;
//                    print(notification.newSize);
          scheduleMicrotask((){
            setState((){});
          });
        },

      );
    }

    List<Widget> above = <Widget>[new Container(
      width: childSize.width,
      height: childSize.height,
      color: widget.backgroundColor,
      child: widget.child,
    ),];
    List<Widget> under = <Widget>[];

    for (FXRightSideButton button in widget.buttons){
      under.add(
          new Container(
            alignment: Alignment.center,
            color: button.backgroundColor,
            width: 60.0,
            height: childSize.height,
            child: new Text(button.name, style:new TextStyle(color: button.fontColor, fontSize: 18.0)),
          )
      );

      above.add(
          new InkWell(
              child: new Container(
                alignment: Alignment.center,
                width: 60.0,
                height: childSize.height,
              ),
              onTap: () {
                controller.jumpTo(0.0);
                button.onPress();
              }
          )
      );
    }

    Widget buttons = new Container(
      width: childSize.width,
      height: childSize.height,
      color: widget.backgroundColor,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: under,
      ),
    );

    Widget scrollview = new NotificationListener(
      child: new ListView(
        controller: controller,
        scrollDirection: Axis.horizontal,
        children: above,
      ),
      onNotification: _handleScrollNotification,
    );

    return new Stack(
      children: <Widget>[
        buttons,
        new Positioned(child: scrollview, left: 0.0, bottom: 0.0, right: 0.0, top: 0.0,)
      ],
    );
  }
}

