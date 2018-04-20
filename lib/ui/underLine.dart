import 'package:flutter/material.dart';

class UnderLine extends StatelessWidget {

  final Widget child;

  const UnderLine({this.child});

  @override
  Widget build(BuildContext context) {
    final Decoration decoration = new BoxDecoration(
      border: new Border(
        bottom: Divider.createBorderSide(context),
      ),
    );

    return new Container(
        color: Colors.white,
        child: new DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: decoration,
        child: child
    )
    );
  }
}