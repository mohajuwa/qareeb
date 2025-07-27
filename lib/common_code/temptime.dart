// import 'package:flutter/animation.dart';
// import 'package:flutter/material.dart';
//
// class TimerBehavior {
//   late AnimationController controller;
//   late Animation<Color?> colorAnimation;
//
//   void startTimer(TickerProvider vsync, int seconds, Function onComplete) {
//     controller = AnimationController(
//       vsync: vsync,
//       duration: Duration(seconds: seconds),
//     );
//
//     colorAnimation = ColorTween(
//       begin: Colors.blue,
//       end: Colors.green,
//     ).animate(controller);
//
//     controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         onComplete();
//       }
//     });
//
//     controller.forward();
//   }
//
//   void dispose() {
//     controller.dispose();
//   }
// }