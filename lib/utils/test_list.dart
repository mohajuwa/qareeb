import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qareeb/app_screen/driver_list_screen.dart';
import 'package:qareeb/services/running_ride_monitor.dart';

class RunningRideDebugWidget extends StatefulWidget {
  const RunningRideDebugWidget({super.key});

  @override
  _RunningRideDebugWidgetState createState() => _RunningRideDebugWidgetState();
}

class _RunningRideDebugWidgetState extends State<RunningRideDebugWidget> {
  Map<String, dynamic> _status = {};

  @override
  void initState() {
    super.initState();

    _updateStatus();

    // Update every 2 seconds

    Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _updateStatus();
      } else {
        timer.cancel();
      }
    });
  }

  void _updateStatus() {
    setState(() {
      _status = RunningRideMonitor.instance.currentRideStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Running Ride Monitor",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ..._status.entries.map((entry) => Text(
                "${entry.key}: ${entry.value}",
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              )),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () => RunningRideMonitor.instance.checkNow(),
                child: const Text("Check Now",
                    style: TextStyle(color: Colors.blue)),
              ),
              TextButton(
                onPressed: () {
                  if (RunningRideMonitor.instance.hasActiveBidding) {
                    Get.to(() => const DriverListScreen());
                  }
                },
                child: const Text("Force Display",
                    style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
