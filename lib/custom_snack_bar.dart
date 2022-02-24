

import 'package:flutter/material.dart';

ScaffoldMessengerState customSnackBar({
  required String text,
  required BuildContext context ,
  final BorderRadius? borderRadius ,
  final EdgeInsets? padding ,
  final Duration? duration ,
  final SnackBarAction? snackBarAction
}) {
  return ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(
      SnackBar(
          content: Text(text),
          shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(0.0)),
          padding: padding ,
          duration: duration ?? const Duration(seconds: 1) ,
          action: snackBarAction
      ));
}


// Future<bool> customExitApp({required DateTime dateTime}) async {
//   final Duration varDifference = DateTime.now().difference(dateTime);
//   final isExitWarning = varDifference >= const Duration(seconds: 2);
//   dateTime = DateTime.now();
//
//   if(isExitWarning){
//     await Fluttertoast.showToast(msg: 'Press back again to exit',fontSize: 17.0);
//     return false;
//   }else{
//     await Fluttertoast.cancel();
//     return true;
//   }
// }