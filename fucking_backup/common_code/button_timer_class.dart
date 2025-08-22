// import 'package:flutter/material.dart';
// import 'package:qareeb/common_code/temptime.dart';
// import 'timer_behavior.dart'; // Import the TimerBehavior class
//
// // Child Class (BTime) inheriting TimerBehavior
// class BTime extends StatefulWidget {
//   const BTime({Key? key}) : super(key: key);
//
//   @override
//   State<BTime> createState() => _BTimeState();
// }
//
// class _BTimeState extends State<BTime> with TickerProviderStateMixin, TimerBehavior {
//   @override
//   void initState() {
//     super.initState();
//     startTimer(this, 5, onTimerComplete); // Start the timer with a 5-second duration
//   }
//
//   void onTimerComplete() {
//     print("Timer completed in BTime!");
//     // Additional logic can be added here when the timer completes
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder(); // Placeholder UI for BTime
//   }
//
//   @override
//   void dispose() {
//     dispose(); // Dispose of the controller
//     super.dispose();
//   }
// }
