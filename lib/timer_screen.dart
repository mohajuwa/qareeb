import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:qareeb/common_code/colore_screen.dart';
import 'package:qareeb/common_code/global_variables.dart';
import 'app_screen/driver_startride_screen.dart';
import 'app_screen/home_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'app_screen/my_ride_screen.dart';
import 'app_screen/ride_complete_payment_screen.dart';
import 'common_code/common_flow_screen.dart';

String extraststus = "";

bool timervarable = false;

class TimerScreen extends StatefulWidget {
  final int hours;
  final int minutes;
  final int secound;
  const TimerScreen({
    super.key,
    required this.hours,
    required this.minutes,
    required this.secound,
  });
  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  void initState() {
    super.initState();
    print("!!!!!!!!!!!!!!!!!!!!!!!otpstatus!!!!!!!!!!!!!!!!!!! $otpstatus");
    socketConnect();
    hours1 = widget.hours;
    minutes1 = widget.minutes;
    seconds = widget.secound;
    sur();
    // _startTimer();

    plusetimer == "0" ? _startTimer1() : _startTimer();

    // _startTimer1();
  }

  socateempt() {
    socket.emit('Vehicle_Time_Request', {
      'uid': useridgloable,
      'd_id': driver_id,
    });
  }

  int? hours1;
  int? minutes1;
  int seconds = 00;
  int countdownStart = 0;

  sur() {
    print("start22222");
    setState(() {
      countdownStart = (hours1! * 3600) + (minutes1! * 60) + seconds;
      // countdownStart = (hours1! * 3600) + (minutes1! * 60);
      _remainingTime = countdownStart;
    });
  }

  // static const int countdownStart = (hours * 3600) + 60; // total time in seconds (2:54 is 174 seconds)
  int _remainingTime = 0;
  Timer? _timer;

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          otpstatus == true ? timer.cancel() : _remainingTime--;
          print("!!!!!otpstatus!!!!!! $otpstatus");
        } else {
          setState(() {
            print("@@@@@@@@@@");
            print("minutes1$minutes1");
            print("@@@@@@@@@@$totaldropmint");
            timer.cancel();
            timeincressstatus == "2" ? timer.cancel() : socateempt();
            timeincressstatus == "2" ? _startTimer1() : timer.cancel();
          });
        }
      });
    });
  }

  bool isloading = false;

  void _startTimer1() {
    extraststus = "";
    setState(() {
      isloading = true;
      extraststus = "Time's up. Extra charges apply";
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime < 1000000000000000000) {
          otpstatus == true ? timer.cancel() : _remainingTime++;
          print("++++++++++:----- $_remainingTime");
          print("+++++---+++++:----- $otpstatus");
          print("+++++---extraststus+++++:----- $extraststus");
        } else {
          timer.cancel();
        }
      });
    });
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  socketConnect() async {
    setState(() {});

    socket = IO.io('https://qareeb.modwir.com', <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
      'extraHeaders': {'Accept': '*/*'},
      'timeout': 30000,
      'forceNew': true,
    });

    socket.connect();

    _connectSocket();
  }

  _connectSocket() async {
    setState(() {
      // midseconde = modual_calculateController.modualCalculateApiModel!.caldriver![0].id!;
    });

    socket.onConnect((data) => print('Connection established Connected'));
    socket.onConnectError((data) => print('Connect Error: $data'));
    socket.onDisconnect((data) => print('Socket.IO server disconnected'));

    socket.on('Vehicle_Time_update$useridgloable', (vehicleTimeUpdate) {
      print("++++++ /Vehicle_Time_update000/ ++++ :---  $vehicleTimeUpdate");
      print(
          "Vehicle_Time_update is of type00: ${vehicleTimeUpdate.runtimeType}");
      print("Vehicle_Time_update keys00: ${vehicleTimeUpdate.keys}");

      hours1 = 0;
      minutes1 = int.parse(vehicleTimeUpdate["time"]);

      if (_remainingTime > 0) {
        print("iopioioioiiooiiooiioioioioioioioioioioioio");
        sur();
        // _startTimer();
      } else {
        print("lklklklklklkklklklklklkllkklklklklklklklkl");
        sur();
        _startTimer();
      }

      // sur();
      // _startTimer();

      print("+++tot_hour00+++:-- $tot_hour");
      print("+++tot_time00+++:-- $tot_time");
    });

    socket.on('Vehicle_Ride_Start_End$useridgloable', (vehicleRideStartEnd) {
      print("++++++ /Vehicle_Ride_Start_End/ ++++ :---  $vehicleRideStartEnd");
      print(
          "Vehicle_Ride_Start_End is of type: ${vehicleRideStartEnd.runtimeType}");
      print("Vehicle_Ride_Start_End keys: ${vehicleRideStartEnd.keys}");
      print("++++Vehicle_Ride_Start_End userid+++++: $useridgloable");
      print(
          "++++Vehicle_Ride_Start_End gggg +++++: ${vehicleRideStartEnd["uid"].toString()}");
      print("++++driver_id gggg +++++: $driver_id");

      statusridestart = "";
      totaldropmint = "";
      plusetimer = "";

      if (driver_id == vehicleRideStartEnd["uid"].toString()) {
        print("SuccessFully1");
        statusridestart = vehicleRideStartEnd["status"];
        totaldropmint = vehicleRideStartEnd["tot_min"].toString();
        totaldrophour = vehicleRideStartEnd["tot_hour"].toString();
        totaldropsecound = vehicleRideStartEnd["tot_second"].toString();
        otpstatus = false;

        timeincressstatus = "2";
        print("+++++++totaldropmint++++:-- $totaldropmint");
        print("+++++++totaldrophour++++:-- $totaldrophour");
        print("++++++++ststus++++:-- $statusridestart");

        if (statusridestart == "5") {
          print("555555555555555555555555");

          timervarable = true;
          droppointstartscreen = [];
          listdrop = [];
          listdrop = vehicleRideStartEnd["drop_list"];
          print("xxxxxxxxx droppointstartscreen xxxxxxxxx$listdrop");
          print("xxxxxxxxx listdrop length:- ${listdrop.length}");

          for (int i = 0; i < listdrop.length; i++) {
            print("objectMMMMMMMMM:-- ($i)");
            droppointstartscreen.add(PointLatLng(
                double.parse(vehicleRideStartEnd["drop_list"][i]["latitude"]),
                double.parse(
                    vehicleRideStartEnd["drop_list"][i]["longitude"])));
            print(
                "vvvvvvvvv droppointstartscreen vvvvvvvvv:-- $droppointstartscreen");
          }
          Get.to(const DriverStartrideScreen());
          // _remainingTime = 0;
          minutes1 = int.parse(totaldropmint);
          hours1 = int.parse(totaldrophour);
          seconds = int.parse(totaldropsecound);
          print("======minutes1======:-  $minutes1");
          print("======hours1======:-  $hours1");

          if (_remainingTime > 0) {
            print("iopioioioiiooiiooiioioioioioioioioioioioio");
            sur();
            // _startTimer();
          } else {
            print("lklklklklklkklklklklklkllkklklklklklklklkl");
            sur();
            _startTimer();
          }

          // sur();
          // _startTimer();
          // Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverStartrideScreen(),));
        } else if (statusridestart == "6") {
          print("6666666666666666");
          timervarable = false;
          droppointstartscreen = [];
          listdrop = [];
          listdrop = vehicleRideStartEnd["drop_list"];
          print("xxxxxxxxx droppointstartscreen xxxxxxxxx$listdrop");
          print("xxxxxxxxx listdrop length${listdrop.length}");
          for (int i = 0; i < listdrop.length; i++) {
            print("objectHHHHH:-- ($i)");
            droppointstartscreen.add(PointLatLng(
                double.parse(vehicleRideStartEnd["drop_list"][i]["latitude"]),
                double.parse(
                    vehicleRideStartEnd["drop_list"][i]["longitude"])));
            print(
                "vvvvvvvvv droppointstartscreen vvvvvvvvv:-- $droppointstartscreen");
          }
          // Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverStartrideScreen(),));
        } else if (statusridestart == "7") {
          print("7777777777777777");
          Get.to(const RideCompletePaymentScreen());
          // Navigator.push(context, MaterialPageRoute(builder: (context) => const RideCompletePaymentScreen(),));
        } else {}
      } else {
        statusridestart = "";
        print("UnSuccessFully1");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // double borderWidth = (_remainingTime / countdownStart) * 3; // Calculate border width based on remaining time
    // if (borderWidth < 1) borderWidth = 1; // Ensure minimum border width of 1

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isloading
                  ? Colors.green
                  : theamcolore), // Dynamic border width
          color: theamcolore.withOpacity(0.1),
        ),
        child: Text(
          _formatTime(_remainingTime),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isloading ? Colors.green : theamcolore,
          ),
        ),
      ),
    );
  }
}
