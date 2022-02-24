import 'dart:math';
import 'package:flutter/material.dart';


class AnimatedConditionalBuilder extends StatelessWidget {
  final bool condition ;
  final WidgetBuilder builder ;
  final WidgetBuilder? fallback ;
  final Duration? duration , reverseDuration ;
  final Curve? switchInCurve , switchOutCurve ;


  const AnimatedConditionalBuilder({
    required this.condition ,
    required this.builder ,
    required this.fallback ,
    this.duration ,
    this.reverseDuration ,
    this.switchOutCurve ,
    this.switchInCurve ,
    Key? key
  }) : super(key : key) ;


  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration ?? const Duration(milliseconds: 400) ,
      switchInCurve: switchInCurve ?? Curves.linear ,
      switchOutCurve: switchOutCurve ?? Curves.linear ,
      reverseDuration: reverseDuration ?? duration ,
      child: condition ?
      builder(context)
          :
      Visibility(
        visible: fallback == null ? false : true ,
        child: fallback!(context) ,
      ),
    );
  }

  // generate random between minimum and maximum
  int generateRandom({required int min, required int max,}) {
    return min + Random.secure().nextInt(max - min);
  }
}