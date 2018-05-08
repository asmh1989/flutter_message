import 'package:flutter/material.dart';

class UnderLine extends StatelessWidget {

  final Widget child;

  const UnderLine({this.child});

  @override
  Widget build(BuildContext context) {
    final Decoration decoration = new BoxDecoration(
      border: new Border(
        bottom: Divider.createBorderSide(context, width: 1.0),
      ),
    );

    return Container(
        color: Colors.white,
        padding: new EdgeInsets.only(top: 4.0),
        child: new DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: decoration,
        child: child
    )
    );
  }
}