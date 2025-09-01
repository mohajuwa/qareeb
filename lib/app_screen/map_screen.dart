import 'package:qareeb/common_code/custom_notification.dart';
import 'package:qareeb/common_code/custom_loading_widget.dart';
// ignore_for_file: avoid_print
// ignore_for_file: unused_field, unused_element, depend_on_referenced_packages, camel_case_types, non_constant_identifier_names, prefer_typing_uninitialized_variables, avoid_init_to_null, use_build_context_synchronously, unnecessary_brace_in_string_interps, prefer_final_fields
// ignore_for_file: unused_import, must_be_immutable, use_super_parameters,
// ignore_for_file: use_key_in_widget_constructors, prefer_interpolation_to_compose_strings, unnecessary_string_interpolations, await_only_futures, prefer_const_constructors, avoid_unnecessary_containers, file_names, void_checks, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:provider/provider.dart';
import 'package:qareeb/common_code/status_helper.dart';
import 'package:qareeb/common_code/status_page.dart';
import 'package:qareeb/services/running_ride_monitor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../api_code/coupon_payment_api_contoller.dart';
import '../api_code/home_controller.dart';
import 'home_screen.dart';
import 'pagelist_description.dart';
import 'pickup_drop_point.dart';
import 'profile_screen.dart';
import 'refer_and_earn.dart';
import 'top_up_screen.dart';
import 'dart:ui' as ui;
import '../common_code/colore_screen.dart';
import '../common_code/common_button.dart';
import '../common_code/common_flow_screen.dart';
import '../common_code/config.dart';
import '../api_code/add_vehical_api_controller.dart';
import '../api_code/calculate_api_controller.dart';
import '../api_code/delete_api_controller.dart';
import '../api_code/home_map_api_controller.dart';
import '../api_code/home_wallet_api_controller.dart';
import '../api_code/login_controller.dart';
import '../api_code/modual_calculate_api_controller.dart';
import '../api_code/pagelist_api_controller.dart';
import '../api_code/remove_request.dart';
import '../api_code/resend_request_api_controller.dart';
import '../api_code/timeout_request_api_controller.dart';
import '../api_code/vihical_calculate_api_controller.dart';
import '../api_code/vihical_information.dart';
import '../auth_screen/onbording_screen.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../common_code/push_notification.dart';
import 'counter_bottom_sheet.dart';
import 'driver_list_screen.dart';
import 'driver_startride_screen.dart';
import 'faq_screen.dart';
import 'language_screen.dart';
import 'my_ride_screen.dart';
import 'notification_screen.dart';

// bool bottomshhetopen = false;

bool buttontimer = false;

bool darkMode = false;
num priceyourfare = 0;
bool isControllerDisposed = false;
bool isanimation = false;
String mid = "";
String mroal = "";
int select1 = 0;
String globalcurrency = "";
List vehicle_bidding_driver = [];
List vehicle_bidding_secounde = [];
num walleteamount = 0.00;
late IO.Socket socket;
var lathomecurrent;
var longhomecurrent;
String biddautostatus = "false";

AnimationController? controller;

late Animation<Color?> colorAnimation;

Timer? timer;

bool _isDisposed = false;

int durationInSeconds = 0;

class MapScreen extends StatefulWidget {
  final bool selectvihical;
  const MapScreen({super.key, required this.selectvihical});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final List<LatLng> vihicallocations = [];
  final List<String> _iconPaths = [];
  final List<String> _iconPathsbiddingon = [];
  final List<LatLng> vihicallocationsbiddingon = [];
  List<PointLatLng> _dropOffPoints = [];
  List<bool> couponadd = [];

  // bool timeout = false;
  bool get isAutomaticBookingEnabled => switchValue && biddautostatus == "true";
  String get currentBookingModeDescription => isAutomaticBookingEnabled
      ? "Automatic booking is ON - nearest driver will be auto-accepted"
      : "Manual selection is ON - you'll choose from available drivers";
  String themeForMap = "";

  bool isLoad = false;

  bool light = false;
  bool switchValue = false;
  // int pricecounr = 0;
  int toast = 0;
  int payment = 0;
  String paymentname = "";
  String selectedOption = "";
  String selectBoring = "";
  int couponAmt = 0;
  String couponId = "";
  String couponname = "";
  String mainamount = "";

  var lathome;
  var longhome;
  var addresshome;
  var decodeUid;
  var userid;
  var currencyy;
  String username = "";

  final DraggableScrollableController sheetController =
      DraggableScrollableController();
  ResendRequestApiController resendRequestApiController =
      Get.put(ResendRequestApiController());
  RemoveRequest removeRequest = Get.put(RemoveRequest());
  TimeoutRequestApiController timeoutRequestApiController =
      Get.put(TimeoutRequestApiController());

  HomeApiController homeApiController = Get.put(HomeApiController());
  DeleteAccount deleteAccount = Get.put(DeleteAccount());
  PaymentGetApiController paymentGetApiController =
      Get.put(PaymentGetApiController());
  HomeMapController homeMapController = Get.put(HomeMapController());
  CalculateController calculateController = Get.put(CalculateController());
  Modual_CalculateController modual_calculateController =
      Get.put(Modual_CalculateController());
  HomeWalletApiController homeWalletApiController =
      Get.put(HomeWalletApiController());
  AddVihicalCalculateController addVihicalCalculateController =
      Get.put(AddVihicalCalculateController());
  VihicalInformationApiController vihicalInformationApiController =
      Get.put(VihicalInformationApiController());
  VihicalCalculateController vihicalCalculateController =
      Get.put(VihicalCalculateController());
  GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());
  TextEditingController amountcontroller = TextEditingController();

  // late AnimationController controller;
  // late Animation<Color?> colorAnimation;
  Timer? _mainTimer;
  Timer? _socketTimer;
  Timer? _animationTimer;
  bool _isDisposed = false;

  bool _showingLogoPlaceholders = false;
  Timer? _logoPlaceholderTimer;

  void resetMapScreenState() {
    if (kDebugMode) print("🔄 Resetting map screen state...");

    if (mounted) {
      setState(() {
        isanimation = false;

        isControllerDisposed = true;

        buttontimer = false;

        loadertimer = false;

        vehicle_bidding_driver.clear();

        vehicle_bidding_secounde.clear();

        driveridloader = false;
      });
    }

    _mainTimer?.cancel();

    _mainTimer = null;

    _animationTimer?.cancel();

    _animationTimer = null;

    if (controller != null && !isControllerDisposed) {
      try {
        if (controller!.isAnimating) {
          controller!.stop();
        }

        controller!.dispose();

        controller = null;

        isControllerDisposed = true;
      } catch (e) {
        if (kDebugMode) print("Error disposing controller in reset: $e");
      }
    }

    _reconnectSocketIfNeeded();

    if (kDebugMode) print("✅ Map screen state reset completed");
  }

  // ✅ NEW: Method to safely reconnect socket

  void _reconnectSocketIfNeeded() {
    try {
      if (!socket.connected) {
        if (kDebugMode) print("🔌 Reconnecting socket...");

        socket.connect();

        _connectSocket();
      }
    } catch (e) {
      if (kDebugMode) print("Socket reconnection error: $e");
    }
  }
  // socate code

  socketConnect() async {
    if (_isDisposed) return;

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      var uid = preferences.getString("userLogin");

      if (uid == null || _isDisposed) return;

      decodeUid = jsonDecode(uid);
      userid = decodeUid['id'];
      username = decodeUid["name"];
      useridgloable = decodeUid['id'];

      if (kDebugMode) {
        print("++++:---  $userid");
        print("++ currencyy ++:---  $currencyy");
      }

      if (_isDisposed) return;

      setState(() {});

      socket = IO.io(Config.imageurl, <String, dynamic>{
        'autoConnect': false,
        'transports': ['websocket'],
      });
      socket.connect();

      socket.onConnect((_) {
        if (kDebugMode) print('Connected');
        if (!_isDisposed) {
          socket.emit('message', 'Hello from Flutter');
        }
      });

      _connectSocket();
    } catch (e) {
      if (kDebugMode) print("Socket connection error: $e");
    }
  }

  _connectSocket() async {
    if (_isDisposed) return;

    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();

      socket.onConnect((data) {
        if (kDebugMode) print('Connection established Connected map screen');
      });
      socket.onConnectError((data) {
        if (kDebugMode) print('Connect Error map screen: $data');
      });
      socket.onDisconnect((data) {
        if (kDebugMode) print('Socket.IO server disconnected map screen');
      });

      // 1. Fetch Wallet Data

      if (!_isDisposed && userid != null) {
        homeWalletApiController
            .homwwalleteApi(uid: userid.toString(), context: context)
            .then((value) {
          if (!_isDisposed && mounted && value != null) {
            walleteamount = double.parse(value["wallet_amount"]);
          }
        }).catchError((error) {
          if (kDebugMode) print("Wallet API error: $error");
        });
      }

      // 2. Fetch Home API Data and Handle Ride State

      if (!_isDisposed &&
          userid != null &&
          lathome != null &&
          longhome != null) {
        homeApiController
            .homeApi(
                uid: userid.toString(),
                lat: lathome.toString(),
                lon: longhome.toString())
            .then((value) {
          if (_isDisposed || !mounted) return;

          mid = homeApiController.homeapimodel!.categoryList![select1].id
              .toString();
          mroal = homeApiController.homeapimodel!.categoryList![select1].role
              .toString();
          var currency = preferences.getString("currenci");
          if (currency != null) {
            currencyy = jsonDecode(currency);
          }
          globalcurrency = currencyy;

          // ✅ CRITICAL FIX: Restore the "Running Ride" Logic

          if (homeApiController.homeapimodel!.runnigRide!.isNotEmpty) {
            if (kDebugMode) {
              print("🏃‍♂️ Found a running ride. Restoring state...");
            }

            final runningRide = homeApiController.homeapimodel!.runnigRide![0];

            // ✅ THIS WAS THE MISSING PIECE: Assign the request_id

            request_id = runningRide.id.toString();
            if (kDebugMode) print("✅ Restored request_id: $request_id");

            pickupcontroller.text = runningRide.pickAdd!.title.toString();
            dropcontroller.text = runningRide.dropAdd!.title.toString();

            latitudepick = double.parse(homeApiController
                .homeapimodel!.runnigRide![0].pickLatlon!.latitude
                .toString());
            longitudepick = double.parse(homeApiController
                .homeapimodel!.runnigRide![0].pickLatlon!.longitude
                .toString());
            latitudedrop = double.parse(homeApiController
                .homeapimodel!.runnigRide![0].dropLatlon!.latitude
                .toString());
            longitudedrop = double.parse(homeApiController
                .homeapimodel!.runnigRide![0].dropLatlon!.longitude
                .toString());

            calculateController
                .calculateApi(
                    context: context,
                    uid: useridgloable.toString(),
                    mid: mid,
                    mrole: mroal,
                    pickup_lat_lon: "$latitudepick,$longitudepick",
                    drop_lat_lon: "$latitudedrop,$longitudedrop",
                    drop_lat_lon_list: onlypass)
                .then((value) {
              if (_isDisposed || !mounted) return;

              calculateController.calCulateModel!.offerExpireTime =
                  int.parse(runningRide.increasedTime.toString());
              calculateController.calCulateModel!.driverId = runningRide.dId;

              setState(() {
                isanimation = true;
                loadertimer = true;
                offerpluse = false;
              });
              RunningRideMonitor.instance.checkNow();
              if (!_isDisposed) {
                requesttime();
              }
            }).catchError((error) {
              if (kDebugMode) {
                print("Calculate API error during ride restore: $error");
              }
            });
          } else {
            RunningRideMonitor.instance.checkNow();
            if (kDebugMode) {
              print("🚗 No running ride found. Ready for new booking.");
            }

            if (pickupcontroller.text.isEmpty || dropcontroller.text.isEmpty) {
              homeMapController
                  .homemapApi(
                      mid: mid,
                      lat: lathome.toString(),
                      lon: longhome.toString())
                  .then((value) {
                if (_isDisposed || !mounted) return;
                setState(() {
                  if (value["Result"] == false) {
                    vihicallocations.clear();
                    markers.clear();
                  } else {
                    vihicallocations.clear();
                    _iconPaths.clear();
                    for (int i = 0;
                        i < homeMapController.homeMapApiModel!.list!.length;
                        i++) {
                      vihicallocations.add(LatLng(
                          double.parse(homeMapController
                              .homeMapApiModel!.list![i].latitude
                              .toString()),
                          double.parse(homeMapController
                              .homeMapApiModel!.list![i].longitude
                              .toString())));
                      _iconPaths.add(
                          "${Config.imageurl}${homeMapController.homeMapApiModel!.list![i].image}");
                    }
                  }
                  _addMarkersOptimized();
                });
              }).catchError((error) {
                if (kDebugMode) print("Home map API error: $error");
              });
            }
          }
        }).catchError((error) {
          if (kDebugMode) print("Home API error: $error");
        });
      }
      // Socket event listeners with safety checks
      socket.on('home', (messaj) {
        if (_isDisposed || !mounted) return;
        if (kDebugMode) print("++++++++++ :---  $messaj");

        homeApiController
            .homeApi(
                uid: messaj['uid'].toString(),
                lat: messaj['lat'].toString(),
                lon: messaj['lon'].toString())
            .then((value) {
          if (_isDisposed || !mounted) return;

          mid = homeApiController.homeapimodel!.categoryList![0].id.toString();
          mroal =
              homeApiController.homeapimodel!.categoryList![0].role.toString();
          RunningRideMonitor.instance.checkNow();
        }).catchError((error) {
          if (kDebugMode) print("Socket home event error: $error");
        });
      });

      socket.on("Driver_location_On", (Driver_location_On) async {
        if (_isDisposed || !mounted) return;

        try {
          if (kDebugMode) {
            print("++++++ Driver_location_On ++++ :---  $Driver_location_On");
          }

          List zonelist = Driver_location_On["zone_list"];

          if (zonelist.contains(homeMapController.homeMapApiModel!.zoneId)) {
            LatLng postion = LatLng(
                double.parse(Driver_location_On["latitude"]),
                double.parse(Driver_location_On["longitude"]));
            final Uint8List markIcon = await getNetworkImage(
                "${Config.imageurl}${Driver_location_On["image"]}");
            MarkerId markerId = MarkerId(Driver_location_On["id"].toString());
            Marker marker = Marker(
              markerId: markerId,
              icon: BitmapDescriptor.fromBytes(markIcon),
              position: postion,
            );

            if (!_isDisposed && mounted) {
              markers[markerId] = marker;
              markers11[markerId] = marker;
              setState(() {});
            }
          }
        } catch (e) {
          if (kDebugMode) print("Driver location on error: $e");
        }
      });

      socket.on("Driver_location_Update", (Driver_location_Update) async {
        if (_isDisposed || !mounted) return;

        try {
          if (kDebugMode) {
            print(
                "++++++ Driver_location_Update ++++ :---  $Driver_location_Update");
          }

          LatLng postion = LatLng(
              double.parse(Driver_location_Update["latitude"]),
              double.parse(Driver_location_Update["longitude"]));
          final Uint8List markIcon = await getNetworkImage(
              "${Config.imageurl}${Driver_location_Update["image"]}");

          MarkerId markerId = MarkerId(Driver_location_Update["id"].toString());
          Marker marker = Marker(
            markerId: markerId,
            icon: BitmapDescriptor.fromBytes(markIcon),
            position: postion,
          );

          if (!_isDisposed && mounted) {
            markers[markerId] = marker;
            if (markers.containsKey(markerId)) {
              final Marker oldMarker = markers[markerId]!;
              final Marker updatedMarker = oldMarker.copyWith(
                positionParam: postion,
              );
              markers[markerId] = updatedMarker;
            }

            // Update markers11 as well
            markers11[markerId] = marker;
            if (markers11.containsKey(markerId)) {
              final Marker oldMarker = markers11[markerId]!;
              final Marker updatedMarker = oldMarker.copyWith(
                positionParam: postion,
              );
              markers11[markerId] = updatedMarker;
            }

            setState(() {});
          }
        } catch (e) {
          if (kDebugMode) print("Driver location update error: $e");
        }
      });

      socket.on("Vehicle_Bidding$userid", (Vehicle_Bidding) {
        if (_isDisposed || !mounted) return;

        if (kDebugMode) {
          print("++++++ Vehicle_Bidding ++++ :---  $Vehicle_Bidding");
        }

        setState(() {
          vehicle_bidding_driver = Vehicle_Bidding["bidding_list"];
          vehicle_bidding_secounde = [];

          for (int i = 0; i < vehicle_bidding_driver.length; i++) {
            vehicle_bidding_secounde
                .add(Vehicle_Bidding["bidding_list"][i]["diff_second"]);
          }
        });

        Get.back();
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const DriverListScreen()));
      });

      socket.on('acceptvehrequest$useridgloable', (acceptvehrequest) {
        if (_isDisposed || !mounted) return;

        socket.close();

        if (kDebugMode) {
          print("++++++ /acceptvehrequest map/ ++++ :---  $acceptvehrequest");
          print(
              "acceptvehrequest is of type map: ${acceptvehrequest.runtimeType}");
        }

        setState(() {
          isanimation = false;
          isControllerDisposed = true;
          loadertimer = true;
        });

        // Safely dispose controller
        if (controller != null && controller!.isAnimating) {
          try {
            controller!.dispose();
            controller = null;
          } catch (e) {
            if (kDebugMode) print("Error disposing controller in socket: $e");
          }
        }

        try {
          vihicalrice = double.parse(amountcontroller.text);
        } catch (a) {
          if (kDebugMode) print("Price parsing error:-- $a");
        }

        if (acceptvehrequest["c_id"]
            .toString()
            .contains(useridgloable.toString())) {
          if (kDebugMode) print("condition done");
          driveridloader = false;

          if (!_isDisposed && mounted) {
            globalDriverAcceptClass.driverdetailfunction(
                context: context,
                lat: latitudepick,
                long: longitudepick,
                d_id: acceptvehrequest["uid"].toString(),
                request_id: acceptvehrequest["request_id"].toString());
          }
        } else {
          if (kDebugMode) print("condition not done");
        }
      });
    } catch (e) {
      if (kDebugMode) print("_connectSocket error: $e");
    }
  }

  Timer? timer;

  bool isTimerRunning = false;

  void startTimer() {
    if (isTimerRunning || _isDisposed) return;

    isTimerRunning = true;

    _mainTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed || !mounted) {
        timer.cancel();

        isTimerRunning = false;

        return;
      }

      setState(() {});
    });
  }

  void cancelTimer() {
    if (kDebugMode) print("Canceling timer");

    _mainTimer?.cancel();

    _mainTimer = null;

    if (controller != null && !isControllerDisposed) {
      try {
        if (controller!.isAnimating) {
          controller!.stop();
        }

        controller!.dispose();

        controller = null;

        isControllerDisposed = true;
      } catch (e) {
        if (kDebugMode) print("Error in cancelTimer: $e");
      }
    }

    if (isTimerRunning) {
      isTimerRunning = false;

      if (kDebugMode) print("Timer canceled");
    }
  }

  pagelistApiController pagelistcontroller = Get.put(pagelistApiController());

  Future<Uint8List> getNetworkImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        final ByteData data = await rootBundle.load('assets/logo.png');
        return data.buffer.asUint8List();
      }
    } catch (e) {
      if (kDebugMode) print("Error loading network image: $e");

      final ByteData data = await rootBundle.load('assets/logo.png');
      return data.buffer.asUint8List();
    }
  }

  void updateBiddingMode(bool isAutomatic) {
    // Don't call setState here since it's already called in the switch onChanged
    biddautostatus = isAutomatic ? "true" : "false";

    if (kDebugMode) {
      print("🔧 Bidding mode updated:");
      print("   Switch Value: $switchValue");
      print("   Bidding Status: $biddautostatus");
      print("   Mode: ${isAutomatic ? 'Automatic' : 'Manual'}");
      print(
          "   Next Action: ${isAutomatic ? 'Auto-accept nearest driver' : 'Show DriverListScreen for manual selection'}");
    }
  }

  Future<void> _saveAutomaticBookingPreference(bool isAutomatic) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setBool("automaticBooking", isAutomatic);

      if (kDebugMode) {
        print("💾 Saved automatic booking preference: $isAutomatic");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error saving automatic booking preference: $e");
      }
    }
  }

  // Load automatic booking preference from SharedPreferences

  Future<void> _loadAutomaticBookingPreference() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      bool? savedPreference = prefs.getBool("automaticBooking");

      if (savedPreference != null) {
        setState(() {
          switchValue = savedPreference;

          biddautostatus = savedPreference ? "true" : "false";
        });

        if (kDebugMode) {
          print("📱 Loaded automatic booking preference: $savedPreference");

          print("🔧 Updated switchValue: $switchValue");

          print("🚗 Updated biddautostatus: $biddautostatus");
        }
      } else {
        setState(() {
          switchValue = false;

          biddautostatus = "false";
        });

        if (kDebugMode) {
          print("🏠 No saved preference found, defaulting to manual mode");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error loading automatic booking preference: $e");
      }

      setState(() {
        switchValue = false;

        biddautostatus = "false";
      });
    }
  }

  Future<void> _refreshVehiclesForLocation(double lat, double lon) async {
    if (_isDisposed || !mounted) return;

    try {
      lathome = lat;

      longhome = lon;

      if (kDebugMode) {
        print("📍 Location changed: lat=$lat, lon=$lon - refreshing vehicles");
      }

      // Use the optimized vehicle loading

      await _loadVehiclesOptimized();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error refreshing vehicles for location: $e");
      }
    }
  }

  void _debugVehicleState() {
    if (kDebugMode) {
      print("🐛 DEBUG Vehicle State:");

      print("   Total vehicles: ${vihicallocations.length}");

      print("   Total icons: ${_iconPaths.length}");

      print("   Total markers: ${markers.length}");

      print("   Selected category: $select1");

      print("   Category ID: $mid");

      print("   Category role: $mroal");

      print("   Current location: lat=$lathome, lon=$longhome");

      if (homeMapController.homeMapApiModel?.list != null) {
        print(
            "   Available in API: ${homeMapController.homeMapApiModel!.list!.length}");
      } else {
        print("   API Model: null");
      }
    }
  }

  Future<void> _initializeParallelOperations() async {
    if (_isDisposed || !mounted) return;

    try {
      // Start all non-blocking operations in parallel

      List<Future> parallelOperations = [
        _loadPaymentMethods(),
        _loadPageList(),
      ];

      // Start location loading but don't wait for it

      _loadLocation();

      // Only add calculate API if in vehicle selection mode

      if (widget.selectvihical == true) {
        parallelOperations.add(_loadCalculateAPI());
      }

      // Don't await - let them run in background

      Future.wait(parallelOperations).catchError((error) {
        if (kDebugMode) print("❌ Parallel operations error: $error");
      });

      if (kDebugMode) {
        print("✅ Started ${parallelOperations.length} parallel operations");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Error starting parallel operations: $e");
    }
  }

  Future<void> _loadCalculateAPI() async {
    if (widget.selectvihical != true) return;

    try {
      // Wait for home API data first

      int attempts = 0;

      while (homeApiController.homeapimodel?.categoryList == null &&
          attempts < 10) {
        await Future.delayed(Duration(milliseconds: 100));

        attempts++;

        if (_isDisposed || !mounted) return;
      }

      if (homeApiController.homeapimodel?.categoryList == null) {
        if (kDebugMode) {
          print("❌ Home API data not available for calculate API");
        }

        return;
      }

      // ✅ KEY FIX: Use select1 instead of [select1]

      if (select1 < homeApiController.homeapimodel!.categoryList!.length) {
        mid = homeApiController.homeapimodel!.categoryList![select1].id
            .toString();

        mroal = homeApiController.homeapimodel!.categoryList![select1].role
            .toString();
      } else {
        // Fallback to first category if select1 is out of bounds

        mid = homeApiController.homeapimodel!.categoryList![select1].id
            .toString();

        mroal = homeApiController.homeapimodel!.categoryList![select1].role
            .toString();
      }

      if (kDebugMode) {
        print("🧮 Loading Calculate API for selected vehicle");

        print("   Selected index: $select1");

        print("   Category ID: $mid");

        print("   Role: $mroal");
      }

      // Continue with existing calculation code...

      if (pickupcontroller.text.isNotEmpty && dropcontroller.text.isNotEmpty) {
        final value = await calculateController.calculateApi(
            context: context,
            uid: userid.toString(),
            mid: mid,
            mrole: mroal,
            pickup_lat_lon: "$latitudepick,$longitudepick",
            drop_lat_lon: "$latitudedrop,$longitudedrop",
            drop_lat_lon_list: convertDroplist());

        if (_isDisposed || !mounted) return;

        if (value["Result"] == true) {
          amountresponse = "true";

          dropprice = value["drop_price"];

          minimumfare = value["vehicle"]["minimum_fare"];

          maximumfare = value["vehicle"]["maximum_fare"];

          responsemessage = value["message"];

          tot_hour = value["tot_hour"].toString();

          tot_time = value["tot_minute"].toString();

          vehicle_id = value["vehicle"]["id"].toString();

          vihicalrice = double.parse(value["drop_price"].toString());

          totalkm = double.parse(value["tot_km"].toString());

          tot_secound = "0";

          vihicalimage = value["vehicle"]["map_img"].toString();

          vihicalname = value["vehicle"]["name"].toString();

          setState(() {});

          if (kDebugMode) {
            print("✅ Calculate API completed for selected vehicle");

            print("   Vehicle: $vihicalname");

            print("   Price: $dropprice");
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print("❌ Calculate API loading error: $e");
    }
  }

  Future<void> _fastVehicleLoad() async {
    try {
      if (kDebugMode) print("🚀 Starting fast vehicle load...");

      // Load location first...

      if (lathomecurrent != null && longhomecurrent != null) {
        lathome = lathomecurrent;

        longhome = longhomecurrent;

        if (kDebugMode) {
          print("📍 Using cached location: lat=$lathome, lon=$longhome");
        }

        await _loadVehiclesQuick();
      } else if (lathome != null && longhome != null) {
        if (kDebugMode) {
          print("📍 Using available location: lat=$lathome, lon=$longhome");
        }

        await _loadVehiclesQuick();
      } else {
        if (kDebugMode) print("📍 Using default location for initial load");

        lathome = 13.9673941;

        longhome = 44.1545032;

        await _loadVehiclesQuick();

        _updateLocationAndRefreshVehicles();
      }
    } catch (e) {
      if (kDebugMode) print("❌ Fast vehicle load error: $e");
    }
  }

  Future<void> _loadVehiclesQuick() async {
    if (_isDisposed || !mounted) return;

    try {
      // Load home API data if not available

      if (homeApiController.homeapimodel?.categoryList == null) {
        final homeData = await homeApiController.homeApi(
          uid: userid.toString(),
          lat: lathome.toString(),
          lon: longhome.toString(),
        );
        RunningRideMonitor.instance.checkNow();

        if (homeData == null || homeData["Result"] != true) {
          if (kDebugMode) print("❌ Home API failed");

          return;
        }
      }

      // Set category data using selected index

      if (homeApiController.homeapimodel?.categoryList?.isNotEmpty == true) {
        // ✅ KEY FIX: Use select1 instead of [select1]

        if (select1 < homeApiController.homeapimodel!.categoryList!.length) {
          mid = homeApiController.homeapimodel!.categoryList![select1].id
              .toString();

          mroal = homeApiController.homeapimodel!.categoryList![select1].role
              .toString();
        } else {
          // Fallback to first category if select1 is out of bounds

          mid = homeApiController.homeapimodel!.categoryList![select1].id
              .toString();

          mroal = homeApiController.homeapimodel!.categoryList![select1].role
              .toString();
        }

        if (kDebugMode) {
          print("✅ Set category for selected vehicle");

          print("   Selected index: $select1");

          print("   Category ID: $mid");

          print(
              "   Category name: ${homeApiController.homeapimodel!.categoryList![select1 < homeApiController.homeapimodel!.categoryList!.length ? select1 : 0].name}");
        }
      }

      // Load vehicles with selected category

      await _loadVehiclesOptimized();
    } catch (e) {
      if (kDebugMode) print("❌ Quick vehicle load error: $e");
    }
  }

  // ✅ OPTIMIZED: Load vehicles with performance improvements
  Future<void> _loadVehiclesOptimized() async {
    if (_isDisposed || !mounted) return;

    try {
      if (kDebugMode) {
        final stopwatch = Stopwatch()..start();
        print("🚗 Loading vehicles optimized - category: $mid");
      }

      // Validate data
      if (mid.isEmpty || lathome == null || longhome == null) {
        if (kDebugMode) print("⚠️ Missing required data for vehicle loading");
        return;
      }

      // Call home map API
      final value = await homeMapController.homemapApi(
        mid: mid,
        lat: lathome.toString(),
        lon: longhome.toString(),
      );

      if (!_isDisposed && mounted && value != null && value["Result"] == true) {
        // Clear existing vehicles
        setState(() {
          vihicallocations.clear();
          _iconPaths.clear();
          // Don't clear all markers, just vehicle markers
          markers.removeWhere((key, value) => key.value.startsWith('vehicle_'));
        });

        // Process vehicle data
        if (homeMapController.homeMapApiModel?.list != null &&
            homeMapController.homeMapApiModel!.list!.isNotEmpty) {
          final vehicleList = homeMapController.homeMapApiModel!.list!;

          // Add vehicle locations
          for (int i = 0; i < vehicleList.length; i++) {
            vihicallocations.add(LatLng(
                double.parse(vehicleList[i].latitude.toString()),
                double.parse(vehicleList[i].longitude.toString())));
            _iconPaths.add("${Config.imageurl}${vehicleList[i].image}");
          }

          // ✅ FAST: Add markers with optimized loading
          _addMarkersOptimized();

          if (kDebugMode) {
            print("✅ Loaded ${vihicallocations.length} vehicles optimized");
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Optimized vehicle loading error: $e");
      }
    }
  }

  // ✅ OPTIMIZED: Fast marker loading with async image handling
  void _addMarkersOptimized() async {
    // ADDED async KEYWORD

    if (_isDisposed || !mounted) return;
    try {
      if (vihicallocations.isEmpty) {
        if (kDebugMode) print("⚠️ No vehicles to display");
        return;
      }
      if (kDebugMode) {
        print(
            "🔄 Adding ${vihicallocations.length} markers with logo placeholders...");
      }

      // Await the placeholder creation to ensure it's ready

      final BitmapDescriptor placeholderIcon = await _createLogoMarker();

      setState(() {
        _showingLogoPlaceholders = true;

        // Add vehicles with logo placeholders first (instant)

        for (var i = 0; i < vihicallocations.length; i++) {
          if (i < homeMapController.homeMapApiModel!.list!.length) {
            MarkerId markerId = MarkerId(
                "vehicle_${homeMapController.homeMapApiModel!.list![i].id}");

            // ✅ CORRECTED: Use the awaited BitmapDescriptor

            Marker marker = Marker(
              markerId: markerId,
              icon: placeholderIcon,
              position: vihicallocations[i],
              infoWindow: InfoWindow(
                title: "Loading Vehicle...",
                snippet: "Please wait",
              ),
            );
            markers[markerId] = marker;
          }
        }
      });

      if (kDebugMode) {
        print("✅ Added ${markers.length} logo placeholder markers");
      }

      // Start timer to show logo for 5 seconds, then transition to vehicle icons

      _startLogoPlaceholderTimer();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Logo placeholder marker adding error: $e");
      }
    }
  }
  // ✅ NEW: Timer for logo placeholder transition

  void _startLogoPlaceholderTimer() {
    // Cancel any existing timer

    _logoPlaceholderTimer?.cancel();

    if (kDebugMode) {
      print("⏰ Starting 5-second logo placeholder timer...");
    }

    _logoPlaceholderTimer = Timer(Duration(seconds: 5), () {
      if (_isDisposed || !mounted) return;

      if (kDebugMode) {
        print(
            "🔄 Logo placeholder timer completed - transitioning to vehicle icons");
      }

      // Transition to actual vehicle icons

      _transitionToVehicleIcons();
    });
  }

  // ✅ NEW: Smooth transition from logo to vehicle icons

  void _transitionToVehicleIcons() async {
    if (_isDisposed || !mounted || _iconPaths.isEmpty) return;

    try {
      setState(() {
        _showingLogoPlaceholders = false;
      });

      if (kDebugMode) {
        print("🎨 Transitioning to vehicle icons...");
      }

      // Load vehicle icons one by one with smooth updates

      for (int i = 0;
          i < _iconPaths.length && i < vihicallocations.length;
          i++) {
        if (_isDisposed || !mounted) break;

        try {
          final icon = await _loadSingleIcon(_iconPaths[i]);

          if (_isDisposed || !mounted) break;

          // Update specific marker with vehicle icon

          if (i < homeMapController.homeMapApiModel!.list!.length) {
            MarkerId markerId = MarkerId(
                "vehicle_${homeMapController.homeMapApiModel!.list![i].id}");

            if (markers.containsKey(markerId)) {
              setState(() {
                Marker existingMarker = markers[markerId]!;

                Marker updatedMarker = existingMarker.copyWith(
                  iconParam: icon,
                  infoWindowParam: InfoWindow(
                    title: "Available Vehicle",
                    snippet: homeMapController.homeMapApiModel!.list![i].name ??
                        "Vehicle",
                  ),
                );

                markers[markerId] = updatedMarker;
              });

              if (kDebugMode) {
                print("✅ Updated marker $i with vehicle icon");
              }
            }
          }

          // Small delay for smooth transition effect

          await Future.delayed(Duration(milliseconds: 200));
        } catch (e) {
          if (kDebugMode) print("❌ Icon transition error for index $i: $e");
        }
      }

      if (kDebugMode) {
        print("🎉 Vehicle icon transition completed!");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Vehicle icon transition error: $e");
      }
    }
  }

  // ✅ NEW: Load custom icons in background without blocking UI
  void _loadCustomIconsAsync() async {
    if (_isDisposed || !mounted || _iconPaths.isEmpty) return;

    try {
      if (kDebugMode) {
        print("🎨 Loading custom icons in background...");
      }

      // Load icons one by one to avoid blocking
      for (int i = 0;
          i < _iconPaths.length && i < vihicallocations.length;
          i++) {
        if (_isDisposed || !mounted) break;

        try {
          final icon = await _loadSingleIcon(_iconPaths[i]);

          if (_isDisposed || !mounted) break;

          // Update specific marker with custom icon
          if (i < homeMapController.homeMapApiModel!.list!.length) {
            MarkerId markerId = MarkerId(
                "vehicle_${homeMapController.homeMapApiModel!.list![i].id}");

            if (markers.containsKey(markerId)) {
              setState(() {
                Marker existingMarker = markers[markerId]!;
                Marker updatedMarker = existingMarker.copyWith(
                  iconParam: icon,
                );
                markers[markerId] = updatedMarker;
              });
            }
          }

          // Small delay to prevent blocking UI
          await Future.delayed(Duration(milliseconds: 50));
        } catch (e) {
          if (kDebugMode) print("❌ Icon loading error for index $i: $e");
          // Continue with next icon
        }
      }

      if (kDebugMode) {
        print("✅ Custom icons loaded in background");
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Background icon loading error: $e");
      }
    }
  }

  // ✅ OPTIMIZED: Load single icon with caching
  Future<BitmapDescriptor> _loadSingleIcon(String url) async {
    try {
      if (url.isEmpty || url.contains("undefined")) {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      }

      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Uint8List bytes = response.bodyBytes;
        final ui.Codec codec = await ui.instantiateImageCodec(bytes,
            targetWidth: 40, // Slightly larger for better visibility
            targetHeight: 60);
        final ui.FrameInfo frameInfo = await codec.getNextFrame();
        final ByteData? byteData =
            await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);
        return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
      } else {
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
      }
    } catch (e) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
  }

  // ✅ BACKGROUND: Load location and update vehicles
  Future<void> _updateLocationAndRefreshVehicles() async {
    try {
      // Get accurate location in background
      final location = await fun();

      if (_isDisposed || !mounted) return;

      // Update vehicles with accurate location
      if (lathome != null && longhome != null) {
        if (kDebugMode) {
          print(
              "📍 Updated location: lat=$lathome, lon=$longhome - refreshing vehicles");
        }
        await _loadVehiclesOptimized();
      }
    } catch (e) {
      if (kDebugMode) {
        print("❌ Location update error: $e");
      }
    }
  }

  // ✅ BACKGROUND: Load payment methods
  Future<void> _loadPaymentMethods() async {
    try {
      final value = await paymentGetApiController.paymentlistApi(context);
      if (_isDisposed || !mounted) return;

      for (int i = 1;
          i < paymentGetApiController.paymentgetwayapi!.paymentList!.length;
          i++) {
        if (int.parse(paymentGetApiController.paymentgetwayapi!.defaultPayment
                .toString()) ==
            paymentGetApiController.paymentgetwayapi!.paymentList![i].id) {
          setState(() {
            payment =
                paymentGetApiController.paymentgetwayapi!.paymentList![i].id!;
            paymentname =
                paymentGetApiController.paymentgetwayapi!.paymentList![i].name!;
            if (kDebugMode) {
              print("💳 Default payment: $payment ($paymentname)");
            }
          });
          break;
        }
      }
    } catch (e) {
      if (kDebugMode) print("❌ Payment loading error: $e");
    }
  }

  // ✅ BACKGROUND: Load page list
  Future<void> _loadPageList() async {
    try {
      await pagelistcontroller.pagelistttApi(context);
    } catch (e) {
      if (kDebugMode) print("❌ Page list loading error: $e");
    }
  }

  Future<void> _loadLocation() async {
    try {
      // Don't block on location - get it in background

      final position = await fun().timeout(Duration(seconds: 10));

      if (_isDisposed || !mounted) return;

      getCurrentLatAndLong(lathome, longhome);

      // Only refresh vehicles if we got a significantly different location

      if (lathome != null && longhome != null) {
        await _loadVehiclesOptimized();
      }

      // Connect socket after location is ready

      socketConnect();

      if (kDebugMode) {
        print("✅ Location and socket initialized");
      }
    } catch (e) {
      if (kDebugMode) print("❌ Location loading error: $e");

      // Even if location fails, try to connect socket

      try {
        socketConnect();
      } catch (socketError) {
        if (kDebugMode) print("❌ Socket connection error: $socketError");
      }
    }
  }
  // ✅ PERFORMANCE FIX: Simplified initState (replace your current one)

  void _handleRequestTimeout() async {
    if (!mounted || _isDisposed) return;

    try {
      if (kDebugMode) print("⏰ Handling request timeout...");

      // Cancel animation

      if (controller != null && controller!.isAnimating) {
        controller!.stop();
      }

      setState(() {
        isanimation = false;

        loadertimer = true;
      });

      // Close any open bottom sheets

      if (Get.isBottomSheetOpen == true) {
        Get.back();
      }

      // ✅ CALL TIMEOUT API WITH RETRY

      try {
        await timeoutRequestApiController
            .timeoutrequestApi(
                uid: userid.toString(), request_id: request_id.toString())
            .timeout(Duration(seconds: 15), onTimeout: () {
          throw TimeoutException('Timeout API call timed out');
        });

        if (kDebugMode) print("✅ Timeout API call successful");
      } catch (timeoutApiError) {
        if (kDebugMode) print("❌ Timeout API error: $timeoutApiError");

        // Show user-friendly message

        CustomNotification.show(
            message: "Request expired. Please try booking again.".tr,
            type: NotificationType.warning);
      }

      // ✅ SHOW TIMEOUT BOTTOM SHEET

      _showTimeoutBottomSheet();
    } catch (timeoutHandlerError) {
      if (kDebugMode) print("💥 Timeout handler error: $timeoutHandlerError");

      // Fallback: simple state reset

      setState(() {
        isanimation = false;

        loadertimer = true;
      });
    }
  }

  // ✅ TIMEOUT BOTTOM SHEET

  void _showTimeoutBottomSheet() {
    if (!mounted) return;

    Get.bottomSheet(
      isDismissible: false,
      enableDrag: false,
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time,
                size: 48,
                color: Colors.orange,
              ),
              SizedBox(height: 16),
              Text(
                "Request Timeout".tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "No drivers responded to your request. Would you like to try again?"
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();

                        // Reset to initial state

                        setState(() {
                          isanimation = false;

                          loadertimer = true;
                        });
                      },
                      child: Text("Cancel".tr),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();

                        // Retry the order

                        orderfunction();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theamcolore,
                      ),
                      child: Text("Try Again".tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ========================================
  // FIXED: Replace your requesttime() method with this
  // ========================================

  void requesttime() {
    try {
      if (kDebugMode) print("⏰ Starting request timer...");

      // Safety check
      if (!mounted || _isDisposed) {
        if (kDebugMode) print("❌ Widget not ready for timer");
        return;
      }

      // Clear any existing timer
      if (timer != null && timer!.isActive) {
        timer!.cancel();
      }

      // Get duration from API or use default
      int duration = durationInSeconds > 0 ? durationInSeconds : 180;
      if (kDebugMode) print("⏰ Timer duration: ${duration} seconds");

      // ✅ ALWAYS RECREATE CONTROLLER TO AVOID DISPOSAL ISSUES
      if (controller != null) {
        try {
          controller!.dispose();
        } catch (e) {
          if (kDebugMode) print("⚠️ Old controller disposal: $e");
        }
      }

      // Create fresh controller
      if (mounted && !_isDisposed) {
        try {
          controller = AnimationController(
            duration: Duration(seconds: duration),
            vsync: this,
          );

          colorAnimation = ColorTween(
            begin: Colors.blue,
            end: Colors.red,
          ).animate(controller!);

          // Start animation
          controller!.forward();
          if (kDebugMode) print("✅ Animation started successfully");
        } catch (controllerError) {
          if (kDebugMode) {
            print("❌ Controller creation error: $controllerError");
          }
          // Continue without animation
        }
      }

      // Set up timeout handling
      timer = Timer(Duration(seconds: duration), () {
        if (!mounted || _isDisposed) return;

        if (kDebugMode) print("⏰ Request timer expired - handling timeout");
        _handleRequestTimeout();
      });

      if (kDebugMode) print("✅ Request timer started successfully");
    } catch (timerError) {
      if (kDebugMode) print("❌ Request timer error: $timerError");

      // Fallback: set a basic timer
      timer = Timer(Duration(seconds: 180), () {
        if (mounted) _handleRequestTimeout();
      });
    }
  }

  // ========================================
  // ALSO UPDATE: Your initState() method - REMOVE the controller creation
  // ========================================

  @override
  void initState() {
    super.initState();
    if (widget.selectvihical == true) {
      if (kDebugMode) {
        print("TRUETRUETRUTRUETRUETRUETRUETRUETRUEWTRUWEUETEWUETRUETR");
      }
    }

    _isDisposed = false;
    WidgetsBinding.instance.addObserver(this);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isDisposed) {
        RunningRideMonitor.instance.startMonitoring();
      }
    });
    // Load automatic booking preference
    _loadAutomaticBookingPreference();

    if (kDebugMode) {
      print("🚀 MapScreen initialized - Fast loading mode");
      print("🔧 selectvihical parameter: ${widget.selectvihical}");
    }

    // ✅ PERFORMANCE: Start all operations in parallel immediately
    Future.microtask(() {
      _initializeParallelOperations();
      _fastVehicleLoad();
    });

    // ✅ REMOVED: Don't initialize controller here - let requesttime() handle it
    if (kDebugMode) print("⏱️ DURATION SECONDS: $durationInSeconds");

    // Initialize theme and other settings
    mapThemeStyle(context: context);
    isControllerDisposed = false;
    plusetimer = "";

    // Initialize drop off points and markers
    _dropOffPoints = [];
    _dropOffPoints = destinationlat;

    if (kDebugMode) print("📍 Drop off points: $_dropOffPoints");

    // Add route markers
    _addMarker11(LatLng(latitudepick, longitudepick), "origin",
        BitmapDescriptor.defaultMarker);

    _addMarker2(LatLng(latitudedrop, longitudedrop), "destination",
        BitmapDescriptor.defaultMarkerWithHue(90));

    for (int a = 0; a < _dropOffPoints.length; a++) {
      _addMarker3("destination");
    }

    // Get directions
    getDirections11(
        lat1: PointLatLng(latitudepick, longitudepick),
        lat2: PointLatLng(latitudedrop, longitudedrop),
        dropOffPoints: _dropOffPoints);

    // Reset state after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      resetMapScreenState();
    });
  }

  // ========================================
  // UPDATED: Enhanced dispose method
  // ========================================

  @override
  void dispose() {
    if (kDebugMode) print("🧹 Disposing MapScreen resources...");

    _isDisposed = true;

    // Cancel timer
    if (timer != null && timer!.isActive) {
      timer!.cancel();
      timer = null;
    }

    // Dispose animation controller safely
    if (controller != null) {
      try {
        controller!.dispose();
        if (kDebugMode) print("✅ Controller disposed successfully");
      } catch (e) {
        if (kDebugMode) print("⚠️ Controller disposal error: $e");
      }
      controller = null;
    }

    // Close socket connection
    try {
      if (socket.connected) {
        socket.disconnect();
        if (kDebugMode) print("✅ Socket disconnected");
      }
    } catch (e) {
      if (kDebugMode) print("⚠️ Socket disposal error: $e");
    }

    // Remove observer
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    if (kDebugMode) print("✅ MapScreen disposed successfully");
  }

  Future<BitmapDescriptor> _createLogoMarker() async {
    try {
      // Select logo path
      String logoPath = notifier.isDark
          ? 'assets/app_logo_dark.png'
          : 'assets/app_logo_light.png';

      // Load the logo as bytes
      final ByteData byteData = await rootBundle.load(logoPath);
      final Uint8List imageBytes = byteData.buffer.asUint8List();

      // Decode original image
      final ui.Codec codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: 80,
        targetHeight: 80,
      );
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image logoImage = frameInfo.image;

      // Canvas size
      const int size = 80; // marker size
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(recorder);

      // Draw circular background
      final ui.Paint backgroundPaint = ui.Paint()
        ..color = notifier.isDark
            ? const ui.Color(0xFFFFFFFF).withOpacity(0.8)
            : const ui.Color(0xFF000000).withOpacity(0.7)
        ..style = ui.PaintingStyle.fill;

      canvas.drawCircle(
        const ui.Offset(size / 2, size / 2),
        size / 2,
        backgroundPaint,
      );

      // Draw logo in center
      const double logoSize = 60;
      const double offset = (size - logoSize) / 2;
      canvas.drawImageRect(
        logoImage,
        ui.Rect.fromLTWH(
            0, 0, logoImage.width.toDouble(), logoImage.height.toDouble()),
        ui.Rect.fromLTWH(offset, offset, logoSize, logoSize),
        ui.Paint(),
      );

      // Convert to PNG
      final ui.Image finalImage =
          await recorder.endRecording().toImage(size, size);
      final ByteData? byteDataMarker =
          await finalImage.toByteData(format: ui.ImageByteFormat.png);

      return BitmapDescriptor.fromBytes(byteDataMarker!.buffer.asUint8List());
    } catch (e) {
      if (kDebugMode) print("❌ Error creating marker with background: $e");
      return BitmapDescriptor.defaultMarkerWithHue(
        notifier.isDark ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueAzure,
      );
    }
  }

  // ✅ UPDATE: Replace _createLogoPlaceholder() with themed version
  _createLogoPlaceholder() {
    // return _createThemedLogoPlaceholder();
    return _createLogoMarker();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (kDebugMode) print("🔄 App resumed, checking map state");

        resetMapScreenState();

        break;

      case AppLifecycleState.paused:
        if (kDebugMode) print("⏸️ App paused");

        break;

      case AppLifecycleState.detached:
        if (kDebugMode) print("🔚 App detached");

        break;

      case AppLifecycleState.inactive:
        if (kDebugMode) print("😴 App inactive");

        break;

      case AppLifecycleState.hidden:
        if (kDebugMode) print("🙈 App hidden");

        break;
    }
  }

  // Replace your existing mapThemeStyle method:
  mapThemeStyle({required BuildContext context}) {
    if (_isDisposed) return;

    final stylePath = darkMode == true
        ? "assets/map_styles/dark_style.json"
        : "assets/map_styles/light_style.json";

    DefaultAssetBundle.of(context).loadString(stylePath).then((value) {
      if (!_isDisposed && mounted) {
        setState(() {
          themeForMap = value;
        });
      }
    }).catchError((error) {
      if (kDebugMode) print("Map theme loading error: $error");
    });
  }

  // Poliline Map Code

  //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  late GoogleMapController mapController11;

  Map<MarkerId, Marker> markers11 = {};
  Map<PolylineId, Polyline> polylines11 = {};
  List<LatLng> polylineCoordinates11 = [];
  PolylinePoints polylinePoints11 = PolylinePoints();

  void _onMapCreated11(GoogleMapController controller) async {
    mapController11 = controller;
  }

  Future<Uint8List> getImages11(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  // Multiple pin function

  _addMarker11(LatLng position, String id, BitmapDescriptor descriptor) async {
    final Uint8List markIcon = await getImages("assets/pickup_marker.png", 80);
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: BitmapDescriptor.fromBytes(markIcon),
      position: position,
      onTap: () {
        showDialog(
          barrierColor: Colors.transparent,
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  alignment: const Alignment(0, -0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                  child: Container(
                    width: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          picktitle == "" ? pickupcontroller.text : picktitle,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        picksubtitle == ""
                            ? const SizedBox()
                            : Text(
                                picksubtitle,
                                maxLines: 3,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
    markers11[markerId] = marker;
  }

  Future _addMarker2(
      LatLng position, String id, BitmapDescriptor descriptor) async {
    final Uint8List markIcon = await getImages("assets/drop_marker.png", 80);
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(
      markerId: markerId,
      icon: BitmapDescriptor.fromBytes(markIcon),
      position: position,
      onTap: () {
        showDialog(
          barrierColor: Colors.transparent,
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  alignment: const Alignment(0, -0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                  child: Container(
                    width: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          droptitle,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          dropsubtitle,
                          maxLines: 3,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
    markers11[markerId] = marker;
  }

  _addMarker3(String id) async {
    for (int a = 0; a < _dropOffPoints.length; a++) {
      final Uint8List markIcon = await getImages("assets/drop_marker.png", 80);
      MarkerId markerId = MarkerId(id[a]);

      LatLng position =
          LatLng(_dropOffPoints[a].latitude, _dropOffPoints[a].longitude);

      Marker marker = Marker(
        markerId: markerId,
        icon: BitmapDescriptor.fromBytes(markIcon),
        position: position,
        onTap: () {
          showDialog(
            barrierColor: Colors.transparent,
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return Dialog(
                    alignment: const Alignment(0, -0.25),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                    child: Container(
                      width: 50,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${droptitlelist[a]["title"]}",
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            "${droptitlelist[a]["subt"]}",
                            maxLines: 3,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      );

      markers11[markerId] = marker;
    }
  }
// ✅ COMPLETE FIXED getDirections11 function in map_screen.dart

  Future getDirections11(
      {required PointLatLng lat1,
      required PointLatLng lat2,
      required List<PointLatLng> dropOffPoints}) async {
    // Remove location marker but preserve vehicle markers
    markers.remove(const MarkerId("my_1"));

    // ✅ CRITICAL FIX: Copy vehicle markers to markers11 before route calculation
    // This ensures vehicles remain visible after route is drawn
    Map<MarkerId, Marker> vehicleMarkers = {};
    markers.forEach((key, marker) {
      if (key.value.startsWith('vehicle_')) {
        vehicleMarkers[key] = marker;
      }
    });

    // Clear existing polylines
    polylines11.clear();

    // Calculate route
    List<LatLng> polylineCoordinates = [];
    List<PointLatLng> allPoints = [lat1, lat2, ...dropOffPoints];

    for (int i = 0; i < allPoints.length - 1; i++) {
      PointLatLng point1 = allPoints[i];
      PointLatLng point2 = allPoints[i + 1];

      PolylineResult result = await polylinePoints11.getRouteBetweenCoordinates(
        Config.mapkey,
        point1,
        point2,
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        // Handle the case where no route is found
        if (kDebugMode) {
          print("⚠️ No route found between points $i and ${i + 1}");
        }
      }
    }

    // Add the polyline
    addPolyLine11(polylineCoordinates);

    // ✅ CRITICAL: Add vehicle markers to markers11 after route calculation
    setState(() {
      // Add all vehicle markers to markers11 so they show with the route
      markers11.addAll(vehicleMarkers);
    });

    if (kDebugMode) {
      print(
          "✅ Route calculated with ${vehicleMarkers.length} vehicle markers preserved");
    }
  }

// Supporting function - keep existing
  addPolyLine11(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: theamcolore,
      points: polylineCoordinates,
      width: 3,
    );
    polylines11[id] = polyline;
    setState(() {});
  }

  void _addMarkers2() async {
    Future<BitmapDescriptor> loadIcon(String url) async {
      try {
        if (url.isEmpty || url.contains("undefined")) {
          return BitmapDescriptor.defaultMarker;
        }

        final http.Response response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final Uint8List bytes = response.bodyBytes;

          final ui.Codec codec = await ui.instantiateImageCodec(bytes,
              targetWidth: 30, targetHeight: 50);
          final ui.FrameInfo frameInfo = await codec.getNextFrame();
          final ByteData? byteData =
              await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

          return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
        } else {
          throw Exception('Failed to load image from $url');
        }
      } catch (e) {
        print("Error loading icon from $url: $e");
        return BitmapDescriptor.defaultMarker;
      }
    }

    final List<BitmapDescriptor> icons = await Future.wait(
      _iconPathsbiddingon.map((path) => loadIcon(path)),
    );

    setState(() {
      markers11.clear();

      _addMarker11(LatLng(latitudepick, longitudepick), "origin",
          BitmapDescriptor.defaultMarker);

      _addMarker2(LatLng(latitudedrop, longitudedrop), "destination",
          BitmapDescriptor.defaultMarkerWithHue(90));

      for (int a = 0; a < _dropOffPoints.length; a++) {
        _addMarker3("destination");
      }

      getDirections11(
          lat1: PointLatLng(latitudepick, longitudepick),
          lat2: PointLatLng(latitudedrop, longitudedrop),
          dropOffPoints: _dropOffPoints);

      for (var i = 0; i < vihicallocationsbiddingon.length; i++) {
        final markerId =
            MarkerId('${homeMapController.homeMapApiModel!.list![i].id}');
        final marker = Marker(
          markerId: markerId,
          position: LatLng(
              double.parse(homeMapController.homeMapApiModel!.list![i].latitude
                  .toString()),
              double.parse(homeMapController.homeMapApiModel!.list![i].longitude
                  .toString())),
          icon: icons[i],
        );
        markers11[markerId] = marker; // Add marker to the map
      }
    });
  }

  Map<MarkerId, Marker> markers = {};

  late GoogleMapController mapController1;

  Future fun() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {}
    var currentLocation = await locateUser();
    debugPrint('location: ${currentLocation.latitude}');
    _onAddMarkerButtonPressed(
        currentLocation.latitude, currentLocation.longitude);
    getCurrentLatAndLong(
      currentLocation.latitude,
      currentLocation.longitude,
    );
    print("????????????${currentLocation.longitude}");
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  // Optimized version with offline fallback

  Future getCurrentLatAndLong(double latitude, double longitude) async {
    if (_isDisposed) return;

    lathome = latitude;

    longhome = longitude;

    lathomecurrent = latitude;

    longhomecurrent = longitude;

    String fallbackAddress =
        "Location ${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}";

    if (pickupcontroller.text.isEmpty && !_isDisposed) {
      pickupcontroller.text = fallbackAddress;

      if (!_isDisposed && mounted) {
        setState(() {}); // Update UI immediately with coordinates
      }
    }

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(lathome, longhome)
              .timeout(const Duration(seconds: 6));

      if (placemarks.isNotEmpty && !_isDisposed) {
        final placemark = placemarks.first;

        String detailedAddress =
            '${placemark.name ?? "Unknown Location"}, ${placemark.locality ?? "Unknown Area"}, ${placemark.country ?? "Unknown Country"}';

        addresshome = detailedAddress;

        if (pickupcontroller.text == fallbackAddress && !_isDisposed) {
          pickupcontroller.text = addresshome;

          if (!_isDisposed && mounted) {
            setState(() {}); // Update UI with detailed address
          }
        }

        if (kDebugMode) print("Detailed address loaded: $addresshome");
      }
    } catch (e) {
      if (kDebugMode) print("Geocoding failed, keeping fallback: $e");

      addresshome = fallbackAddress; // Keep the coordinate-based fallback
    }
  }

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _onAddMarkerButtonPressed(double? lat, long) async {
    final Uint8List markIcon = await getImages("assets/pickup_marker.png", 80);

    Marker marker = Marker(
      markerId: const MarkerId("my_1"),
      icon: BitmapDescriptor.fromBytes(markIcon),
      position:
          LatLng(double.parse(lat.toString()), double.parse(long.toString())),
      onTap: () {
        showDialog(
          barrierColor: Colors.transparent,
          context: context,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) {
                return Dialog(
                  alignment: const Alignment(0, -0.22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$addresshome",
                          maxLines: 1,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
    markers[const MarkerId("my_1")] = marker;

    setState(() {});
  }

  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  void _navigateAndRefresh() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PickupDropPoint(
                  pagestate: false,
                  bidding: homeApiController
                      .homeapimodel!.categoryList![select1].bidding
                      .toString(),
                )));
    if (result != null && result.shouldRefresh) {
      _refreshPage();
    }
  }

  void _refreshPage() {
    setState(() {});
  }

  // ✅ ENHANCED SOCKET EMIT METHOD

  void socateempt() {
    try {
      if (socket.connected) {
        socket.emit('vehiclerequest', {
          'requestid': request_id,
          'driverid': homeMapController.homeMapApiModel!.driverid!,
          'c_id': userid
        });

        if (kDebugMode) {
          print("📡 Socket event 'vehiclerequest' emitted successfully");
        }
      } else {
        if (kDebugMode) {
          print("⚠️ Socket not connected - attempting to reconnect");
        }

        socket.connect();

        // Retry emit after connection

        Future.delayed(Duration(milliseconds: 500), () {
          if (socket.connected) {
            socket.emit('vehiclerequest', {
              'requestid':
                  addVihicalCalculateController.addVihicalCalculateModel!.id,
              'driverid': homeMapController.homeMapApiModel!.driverid!,
              'c_id': userid
            });

            if (kDebugMode) print("📡 Socket event emitted after reconnection");
          }
        });
      }
    } catch (socketError) {
      if (kDebugMode) print("❌ Socket emit error: $socketError");

      // Don't fail the entire operation for socket errors
    }
  }

  socatloadbidinfdata() {
    socket.emit('load_bidding_data', {
      'uid': useridgloable,
      'request_id': request_id,
      'd_id': homeMapController.homeMapApiModel!.driverid!
    });
  }

  void refreshAnimation() {
    controller!.reset();
    controller!.repeat(reverse: false);
  }

  bool offerpluse = false;

  bool cancelloader = false;

  List drowertitle = [
    "Home".tr,
    "My Ride".tr,
    "Wallet".tr,
    "Profile".tr,
    "Language".tr,
    "Refer and earn".tr,
    "Faq".tr,
    "Notifications".tr,
    "Dark Mode".tr,
  ];

  List drowerimage = [
    "assets/svgpicture/myride.svg",
    "assets/svgpicture/routing-2.svg",
    "assets/svgpicture/wallet.svg",
    "assets/svgpicture/profile.svg",
    "assets/svgpicture/languge.svg",
    "assets/svgpicture/share.svg",
    "assets/svgpicture/faq.svg",
    "assets/svgpicture/notification.svg",
    "assets/svgpicture/moon_regulare.svg",
  ];

  ColorNotifier notifier = ColorNotifier();
  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      key: _key,
      drawer: draweropen(context),
      body: GetBuilder<HomeApiController>(
        builder: (homeApiController) {
          return homeApiController.isLoading
              ? Center(child: CustomLoadingWidget())
              : Stack(
                  children: [
                    GoogleMap(
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer())
                      },
                      initialCameraPosition: pickupcontroller.text.isEmpty ||
                              dropcontroller.text.isEmpty
                          ? CameraPosition(
                              target: LatLng(lathome, longhome), zoom: 13)
                          : CameraPosition(
                              target: LatLng(latitudepick, longitudepick),
                              zoom: 13),
                      mapType: MapType.normal,
                      markers: {
                        ...Set<Marker>.of(markers.values),
                        ...Set<Marker>.of(markers11.values),
                      },
                      onTap: (argument) async {
                        setState(() {
                          _onAddMarkerButtonPressed(
                              argument.latitude, argument.longitude);
                        });

                        await _refreshVehiclesForLocation(
                            argument.latitude, argument.longitude);
                      },
                      myLocationEnabled: false,
                      zoomGesturesEnabled: true,
                      tiltGesturesEnabled: true,
                      zoomControlsEnabled: true,
                      onMapCreated: (controller) {
                        setState(() {
                          controller.setMapStyle(themeForMap);
                          mapController1 = controller;
                        });
                      },
                      polylines: Set<Polyline>.of(polylines11.values),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 60, left: 10, right: 10),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _key.currentState!.openDrawer();
                                });
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    color: notifier.containercolore,
                                    shape: BoxShape.circle),
                                child: Center(
                                    child: Image(
                                  image: const AssetImage("assets/menu.png"),
                                  height: 20,
                                  color: notifier.textColor,
                                )),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: notifier.containercolore,
                                  borderRadius: BorderRadius.circular(25)),
                              child: TextField(
                                onTap: () {
                                  _addMarkersOptimized();
                                  fun().then((value) {
                                    setState(() {});
                                    getCurrentLatAndLong(lathome, longhome)
                                        .then(
                                      (value) {
                                        mapController1.animateCamera(
                                          CameraUpdate.newCameraPosition(
                                            CameraPosition(
                                              target: LatLng(lathome, longhome),
                                              zoom: 14.0,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  });
                                },
                                readOnly: true,
                                style: const TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15, horizontal: 15),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        borderSide: BorderSide(
                                            color: notifier.background)),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        borderSide: BorderSide(
                                            color: notifier.background)),
                                    hintText: "Your Current Location".tr,
                                    hintStyle: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(25)),
                                        borderSide: BorderSide(
                                            color: notifier.containercolore)),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.green, width: 6),
                                        ),
                                      ),
                                    ),
                                    suffixIcon: InkWell(
                                        onTap: () {
                                          _addMarkersOptimized();
                                          fun().then((value) {
                                            setState(() {});
                                            getCurrentLatAndLong(
                                                    lathome, longhome)
                                                .then(
                                              (value) {
                                                mapController1.animateCamera(
                                                  CameraUpdate
                                                      .newCameraPosition(
                                                    CameraPosition(
                                                      target: LatLng(
                                                          lathome, longhome),
                                                      zoom: 14.0,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          });
                                        },
                                        child: SvgPicture.asset(
                                          "assets/svgpicture/gpsicon.svg",
                                        ))),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    DraggableScrollableSheet(
                      initialChildSize:
                          0.45, // Set the default height to 50% of the screen
                      minChildSize: 0.2, // Minimum height
                      maxChildSize: 1.0,
                      controller: sheetController,
                      builder: (BuildContext context, scrollController) {
                        return Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                            color: notifier.containercolore,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25),
                            ),
                          ),
                          child: CustomScrollView(
                            controller: scrollController,
                            slivers: [
                              SliverToBoxAdapter(
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: notifier.textColor,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    height: 4,
                                    width: 40,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                ),
                              ),
                              SliverList.list(children: [
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10),
                                  child: SizedBox(
                                    height:
                                        101, // THIS FIXED HEIGHT IS CAUSING OVERFLOW
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        clipBehavior: Clip.none,
                                        itemCount: homeApiController
                                            .homeapimodel!.categoryList!.length,
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) {
                                          return // Replace the existing vehicle selection ListView.builder onTap in the improved map screen with this:

                                              InkWell(
                                            onTap: () async {
                                              if (_isDisposed || !mounted) {
                                                return;
                                              }

                                              // Update selected vehicle index and category

                                              setState(() {
                                                select1 = index;

                                                mid = homeApiController
                                                    .homeapimodel!
                                                    .categoryList![index]
                                                    .id
                                                    .toString();

                                                mroal = homeApiController
                                                    .homeapimodel!
                                                    .categoryList![index]
                                                    .role
                                                    .toString();
                                              });

                                              if (kDebugMode) {
                                                print(
                                                    "🚗 Selected category $index: ${homeApiController.homeapimodel!.categoryList![index].name}");

                                                print(
                                                    "📋 Category ID: $mid, Role: $mroal");
                                              }

                                              try {
                                                // ✅ CRITICAL: Load vehicles for selected category

                                                await _loadVehiclesOptimized();

                                                // ✅ CRITICAL: Recalculate price if pickup and drop locations exist

                                                if (pickupcontroller
                                                        .text.isNotEmpty &&
                                                    dropcontroller
                                                        .text.isNotEmpty) {
                                                  if (kDebugMode) {
                                                    print(
                                                        "🧮 Recalculating price for selected vehicle...");
                                                  }

                                                  StatusHelper.showStatusDialog(
                                                    context,
                                                    statusType:
                                                        StatusType.loading,
                                                    customTitle:
                                                        "Calculation Loading",
                                                    customSubtitle:
                                                        "Calculating fare for this vehicle...",
                                                    barrierDismissible: true,
                                                  );

                                                  final value =
                                                      await calculateController
                                                          .calculateApi(
                                                    context: context,
                                                    uid: userid.toString(),
                                                    mid: mid,
                                                    mrole: mroal,
                                                    pickup_lat_lon:
                                                        "$latitudepick,$longitudepick",
                                                    drop_lat_lon:
                                                        "$latitudedrop,$longitudedrop",
                                                    drop_lat_lon_list:
                                                        convertDroplist(),
                                                  );

                                                  // Hide loading dialog

                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop();

                                                  if (_isDisposed || !mounted) {
                                                    return;
                                                  }

                                                  if (value["Result"] == true) {
                                                    setState(() {
                                                      amountresponse = "true";

                                                      dropprice =
                                                          value["drop_price"];

                                                      minimumfare =
                                                          value["vehicle"]
                                                              ["minimum_fare"];

                                                      maximumfare =
                                                          value["vehicle"]
                                                              ["maximum_fare"];

                                                      responsemessage =
                                                          value["message"];

                                                      tot_hour =
                                                          value["tot_hour"]
                                                              .toString();

                                                      tot_time =
                                                          value["tot_minute"]
                                                              .toString();

                                                      vehicle_id =
                                                          value["vehicle"]["id"]
                                                              .toString();

                                                      vihicalrice =
                                                          double.parse(value[
                                                                  "drop_price"]
                                                              .toString());

                                                      totalkm = double.parse(
                                                          value["tot_km"]
                                                              .toString());

                                                      tot_secound = "0";

                                                      vihicalimage =
                                                          value["vehicle"]
                                                                  ["map_img"]
                                                              .toString();

                                                      vihicalname =
                                                          value["vehicle"]
                                                                  ["name"]
                                                              .toString();
                                                    });

                                                    if (kDebugMode) {
                                                      print(
                                                          "✅ Recalculation completed successfully");

                                                      print(
                                                          "   Vehicle: $vihicalname");

                                                      print(
                                                          "   Price: $dropprice");
                                                    }
                                                  } else {
                                                    amountresponse = "false";

                                                    if (kDebugMode) {
                                                      print(
                                                          "❌ Recalculation failed");
                                                    }

                                                    StatusHelper
                                                        .showStatusDialog(
                                                      context,
                                                      statusType:
                                                          StatusType.error,
                                                      customTitle:
                                                          "Calculation Failed",
                                                      customSubtitle:
                                                          "Unable to calculate fare for this vehicle",
                                                      barrierDismissible: true,
                                                      onRetry: () {
                                                        Navigator.of(context)
                                                            .pop();

                                                        // Optionally retry the calculation
                                                      },
                                                    );
                                                  }
                                                }
                                              } catch (e) {
                                                if (kDebugMode) {
                                                  print(
                                                      "❌ Vehicle selection error: $e");
                                                }

                                                // Hide loading dialog if showing

                                                if (Navigator.of(context)
                                                    .canPop()) {
                                                  Navigator.of(context,
                                                          rootNavigator: true)
                                                      .pop();
                                                }

                                                StatusHelper.showStatusDialog(
                                                  context,
                                                  statusType: StatusType.error,
                                                  customTitle:
                                                      "Selection Failed",
                                                  customSubtitle:
                                                      "Unable to load vehicles for selected type",
                                                  barrierDismissible: true,
                                                  onRetry: () {
                                                    Navigator.of(context).pop();

                                                    // Optionally retry the vehicle selection
                                                  },
                                                );
                                              }
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Container(
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  color: select1 == index
                                                      ? theamcolore
                                                          .withOpacity(0.08)
                                                      : notifier
                                                          .containercolore,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        select1 == index
                                                            ? CrossAxisAlignment
                                                                .center
                                                            : CrossAxisAlignment
                                                                .start,
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(
                                                            height: 40,
                                                            width: 40,
                                                            child: Image(
                                                              image: NetworkImage(
                                                                  "${Config.imageurl}${homeApiController.homeapimodel!.categoryList![index].image}"),
                                                              height: 40,
                                                            ),
                                                          ),
                                                          select1 == index
                                                              ? const SizedBox(
                                                                  width: 5)
                                                              : const SizedBox(),
                                                          select1 == index
                                                              ? InkWell(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      vihicalInformationApiController
                                                                          .vihicalinformationApi(
                                                                              vehicle_id: homeApiController.homeapimodel!.categoryList![index].id.toString())
                                                                          .then((value) {
                                                                        Get.bottomSheet(
                                                                          StatefulBuilder(
                                                                            builder:
                                                                                (context, setState) {
                                                                              return Container(
                                                                                clipBehavior: Clip.hardEdge,
                                                                                width: Get.width,
                                                                                decoration: BoxDecoration(
                                                                                  color: notifier.containercolore,
                                                                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                                                                                ),
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.all(15),
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    children: [
                                                                                      Image.network(
                                                                                        "${Config.imageurl}${vihicalInformationApiController.vihicalInFormationApiModel!.vehicle!.image}",
                                                                                        height: 60,
                                                                                      ),
                                                                                      Text(
                                                                                        "${vihicalInformationApiController.vihicalInFormationApiModel!.vehicle!.name}",
                                                                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: notifier.textColor),
                                                                                      ),
                                                                                      const SizedBox(height: 10),
                                                                                      Text(
                                                                                        "${vihicalInformationApiController.vihicalInFormationApiModel!.vehicle!.description}",
                                                                                        style: TextStyle(fontSize: 16, color: notifier.textColor),
                                                                                      ),
                                                                                      const SizedBox(height: 20),
                                                                                      CommonOutLineButton(
                                                                                          bordercolore: theamcolore,
                                                                                          onPressed1: () {
                                                                                            Get.back();
                                                                                          },
                                                                                          txt1: "Close".tr,
                                                                                          context: context)
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        );
                                                                      });
                                                                    });
                                                                  },
                                                                  child: Image(
                                                                    image: const AssetImage(
                                                                        "assets/info-circle.png"),
                                                                    height: 20,
                                                                    color:
                                                                        theamcolore,
                                                                  ))
                                                              : const SizedBox(),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      Text(
                                                        "${homeApiController.homeapimodel!.categoryList![index].name}",
                                                        style: TextStyle(
                                                            color: notifier
                                                                .textColor),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(15),
                                            topLeft: Radius.circular(15)),
                                      ),
                                      context: context,
                                      builder: (context) {
                                        return Container(
                                          height: 750,
                                          decoration: const BoxDecoration(
                                              color: Colors.pinkAccent,
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(15),
                                                topLeft: Radius.circular(15),
                                              )),
                                          child: Column(
                                            children: [
                                              Expanded(
                                                  child: PickupDropPoint(
                                                pagestate: false,
                                                bidding: homeApiController
                                                    .homeapimodel!
                                                    .categoryList![select1]
                                                    .bidding
                                                    .toString(),
                                              )),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.only(left: 10),
                                        leading: Container(
                                          height: 20,
                                          width: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.green, width: 4),
                                          ),
                                        ),
                                        title: pickupcontroller.text.isEmpty
                                            ? Transform.translate(
                                                offset: const Offset(-20, 0),
                                                child: Text(
                                                  "${addresshome ?? "Searching for you on the map...".tr}",
                                                  style: TextStyle(
                                                      color:
                                                          notifier.textColor),
                                                ))
                                            : Transform.translate(
                                                offset: const Offset(-20, 0),
                                                child: Text(
                                                  pickupcontroller.text,
                                                  style: TextStyle(
                                                      color:
                                                          notifier.textColor),
                                                )),
                                      ),
                                    ),
                                  ),
                                ),
                                textfieldlist.isNotEmpty
                                    ? const SizedBox(height: 0)
                                    : const SizedBox(height: 10),
                                textfieldlist.isNotEmpty
                                    ? InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                            isScrollControlled: true,
                                            shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(15),
                                                  topLeft: Radius.circular(15)),
                                            ),
                                            context: context,
                                            builder: (context) {
                                              return SizedBox(
                                                height: 750,
                                                child: Column(
                                                  children: [
                                                    Expanded(
                                                        child: PickupDropPoint(
                                                      pagestate: false,
                                                      bidding: homeApiController
                                                          .homeapimodel!
                                                          .categoryList![
                                                              select1]
                                                          .bidding
                                                          .toString(),
                                                    )),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20, right: 20, top: 10),
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.05),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: ListTile(
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 10, right: 10),
                                              leading: Container(
                                                height: 20,
                                                width: 20,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.red,
                                                      width: 4),
                                                ),
                                              ),
                                              title: Transform.translate(
                                                  offset: const Offset(-20, 0),
                                                  child: Text(
                                                    "${textfieldlist.length + 1} route stops",
                                                    style: TextStyle(
                                                        color:
                                                            notifier.textColor),
                                                  )),
                                              trailing: Icon(
                                                Icons.add,
                                                color: notifier.textColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                              isScrollControlled: true,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(15),
                                                    topLeft:
                                                        Radius.circular(15)),
                                              ),
                                              context: context,
                                              builder: (context) {
                                                return SizedBox(
                                                  height: 750,
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                          child:
                                                              PickupDropPoint(
                                                        pagestate: false,
                                                        bidding:
                                                            homeApiController
                                                                .homeapimodel!
                                                                .categoryList![
                                                                    select1]
                                                                .bidding
                                                                .toString(),
                                                      )),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.05),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Row(
                                                children: [
                                                  Image(
                                                    image: const AssetImage(
                                                        "assets/search.png"),
                                                    height: 20,
                                                    color: notifier.textColor,
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Flexible(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 2),
                                                      child: dropcontroller
                                                              .text.isEmpty
                                                          ? Text(
                                                              "To",
                                                              style: TextStyle(
                                                                  color: notifier
                                                                      .textColor,
                                                                  fontSize: 16),
                                                            )
                                                          : Text(
                                                              dropcontroller
                                                                  .text,
                                                              style: TextStyle(
                                                                  color: notifier
                                                                      .textColor,
                                                                  fontSize: 16),
                                                              maxLines: 2,
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                homeApiController.homeapimodel!
                                            .categoryList![select1].bidding ==
                                        "1"
                                    ? const SizedBox(
                                        height: 10,
                                      )
                                    : const SizedBox(),
                                homeApiController.homeapimodel!
                                            .categoryList![select1].bidding ==
                                        "1"
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20),
                                        child: InkWell(
                                          onTap: () {
                                            Buttonpresebottomshhet();
                                          },
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.05),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10, right: 10),
                                              child: Row(
                                                children: [
                                                  (pickupcontroller
                                                              .text.isEmpty ||
                                                          dropcontroller
                                                              .text.isEmpty)
                                                      ? Text(
                                                          "${currencyy ?? globalcurrency}",
                                                          style: TextStyle(
                                                              color: notifier
                                                                  .textColor,
                                                              fontSize: 16),
                                                        )
                                                      : Text(
                                                          "${currencyy ?? globalcurrency} ${dropprice ?? ""}",
                                                          style: TextStyle(
                                                              color: notifier
                                                                  .textColor,
                                                              fontSize: 16),
                                                        ),
                                                  const SizedBox(
                                                    width: 8,
                                                  ),
                                                  Text(
                                                    "Offer your fare".tr,
                                                    style: TextStyle(
                                                        color:
                                                            notifier.textColor,
                                                        fontSize: 16),
                                                  ),
                                                  const Spacer(),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                pickupcontroller.text.isEmpty ||
                                        dropcontroller.text.isEmpty
                                    ? Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: CommonButton(
                                            containcolore:
                                                theamcolore.withOpacity(0.2),
                                            onPressed1: () {},
                                            context: context,
                                            txt1: "Find a driver".tr),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: CommonButton(
                                            containcolore: theamcolore,
                                            onPressed1: homeApiController
                                                        .homeapimodel!
                                                        .categoryList![select1]
                                                        .bidding ==
                                                    "1"
                                                ? () {
                                                    // This is the bidding flow, which is correct and unchanged.
                                                    Buttonpresebottomshhet();
                                                  }
                                                : () async {
                                                    // ✅ Make the function async
                                                    if (kDebugMode) {
                                                      print(
                                                          "Requesting non-bidding ride...");
                                                    }

                                                    // 1. Show a loading indicator to the user.
                                                    StatusHelper.showStatusDialog(
                                                        context,
                                                        statusType:
                                                            StatusType.loading,
                                                        customSubtitle:
                                                            "Finding drivers...");

                                                    try {
                                                      // 2. AWAIT the API call to finish first. This is the critical fix.
                                                      await modual_calculateController
                                                          .modualcalculateApi(
                                                        context: context,
                                                        uid: userid.toString(),
                                                        mid: mid,
                                                        mrole: mroal,
                                                        pickup_lat_lon:
                                                            "$latitudepick,$longitudepick",
                                                        drop_lat_lon:
                                                            "$latitudedrop,$longitudedrop",
                                                        drop_lat_lon_list:
                                                            convertDroplist(),
                                                      );

                                                      // 3. Hide the loading indicator.
                                                      if (mounted) {
                                                        Navigator.pop(context);
                                                      }

                                                      // 4. Check if the API call was successful and returned drivers.
                                                      if (modual_calculateController
                                                                  .modualCalculateApiModel
                                                                  ?.caldriver !=
                                                              null &&
                                                          modual_calculateController
                                                              .modualCalculateApiModel!
                                                              .caldriver!
                                                              .isNotEmpty) {
                                                        // Data is now ready. Set the variables.
                                                        midseconde =
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![
                                                                    select1]
                                                                .id!;
                                                        vihicalrice = double.parse(
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![
                                                                    select1]
                                                                .dropPrice!
                                                                .toString());
                                                        totalkm = double.parse(
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![
                                                                    select1]
                                                                .dropKm!
                                                                .toString());
                                                        tot_time =
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![
                                                                    select1]
                                                                .dropTime!
                                                                .toString();
                                                        tot_hour =
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![
                                                                    select1]
                                                                .dropHour!
                                                                .toString();
                                                        vihicalname =
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![
                                                                    select1]
                                                                .name!
                                                                .toString();
                                                        vihicalimage =
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![
                                                                    select1]
                                                                .image!
                                                                .toString();
                                                        vehicle_id =
                                                            modual_calculateController
                                                                .modualCalculateApiModel!
                                                                .caldriver![
                                                                    select1]
                                                                .id!
                                                                .toString();

                                                        // 5. NOW it is safe to navigate to the HomeScreen with all the data.
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    HomeScreen(
                                                              latpic:
                                                                  latitudepick,
                                                              longpic:
                                                                  longitudepick,
                                                              latdrop:
                                                                  latitudedrop,
                                                              longdrop:
                                                                  longitudedrop,
                                                              destinationlat:
                                                                  destinationlat,
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        // Handle the case where no drivers are found.
                                                        CustomNotification.show(
                                                          message:
                                                              "No drivers are currently available for this route."
                                                                  .tr,
                                                          type: NotificationType
                                                              .info,
                                                        );
                                                      }
                                                    } catch (e) {
                                                      // Hide loading indicator on error.
                                                      if (mounted) {
                                                        Navigator.pop(context);
                                                      }

                                                      CustomNotification.show(
                                                        message:
                                                            "An error occurred while finding drivers. Please try again."
                                                                .tr,
                                                        type: NotificationType
                                                            .error,
                                                      );
                                                      if (kDebugMode) {
                                                        print(
                                                            "Error during non-bidding ride request: $e");
                                                      }
                                                    }
                                                  },
                                            context: context,
                                            txt1: "Find a driver".tr),
                                      ),
                              ])
                            ],
                          ),
                        );
                      },
                    )
                  ],
                );
        },
      ),
    );
  }

  Widget draweropen(context) {
    return Drawer(
      width: 280,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      backgroundColor: notifier.containercolore,
      child: GetBuilder<HomeApiController>(
        builder: (homeApiController) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 60,
                ),
                Row(
                  children: [
                    Spacer(),
                    Text(
                      "V 1.3",
                      style: TextStyle(
                          color: Colors.grey.withOpacity(0.8),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
                homeApiController.isLoading
                    ? Center(child: CustomLoadingWidget())
                    : InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ));
                        },
                        child: Stack(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                  color: greaycolore, shape: BoxShape.circle),
                              child: decodeUid["profile_image"] == ""
                                  ? Center(
                                      child: Text("${decodeUid["name"][0]}",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 25)))
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(65),
                                      child: Image.network(
                                        "${Config.imageurl}${decodeUid["profile_image"]}",
                                        fit: BoxFit.cover,
                                      )),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                    color: theamcolore,
                                    border: Border.all(color: Colors.white),
                                    shape: BoxShape.circle),
                                child: const Center(
                                  child: Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Container(
                    height: 25,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: theamcolore)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            "${homeApiController.homeapimodel!.cusRating!.avgStar}",
                            style: TextStyle(
                                fontSize: 14, color: notifier.textColor),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        SvgPicture.asset(
                          "assets/svgpicture/star-fill.svg",
                          height: 12,
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  username == "" ? "" : username,
                  style: TextStyle(
                      color: notifier.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                const SizedBox(
                  height: 5,
                ),
                InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ProfileScreen(),
                      ));
                    },
                    child: Text(
                      "View profile",
                      style: TextStyle(color: theamcolore),
                    )),
                const SizedBox(
                  height: 5,
                ),
                Divider(
                  color: Colors.grey.withOpacity(0.4),
                ),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: drowertitle.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        switch (index) {
                          case 0:
                            pickupcontroller.text = "";
                            dropcontroller.text = "";
                            latitudepick = 0.00;
                            longitudepick = 0.00;
                            latitudedrop = 0.00;
                            longitudedrop = 0.00;
                            picktitle = "";
                            picksubtitle = "";
                            droptitle = "";
                            dropsubtitle = "";
                            droptitlelist = [];
                            Get.offAll(const MapScreen(
                              selectvihical: false,
                            ));
                          case 1:
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const MyRideScreen(),
                            ));
                          case 2:
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const TopUpScreen(),
                            ));
                          case 3:
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ));
                          case 4:
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const LanguageScreen(),
                            ));
                          case 5:
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const ReferAndEarn(),
                            ));
                          case 6:
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const FaqScreen(),
                            ));
                          case 7:
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const NotificationScreen(),
                            ));
                          case 8:
                            return;
                          case 9:
                            return;
                        }
                      },
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  "${drowerimage[index]}",
                                  height: 25,
                                  color: notifier.textColor,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "${drowertitle[index]}".tr,
                                  style: TextStyle(
                                      fontSize: 16, color: notifier.textColor),
                                ),
                                const Spacer(),
                                index == 8
                                    ? // Replace the existing dark mode switch with this code:

                                    SizedBox(
                                        height: 20,
                                        width: 30,
                                        child: Transform.scale(
                                          scale: 0.8,
                                          child: CupertinoSwitch(
                                            value: notifier.isDark,
                                            activeColor: theamcolore,
                                            onChanged: (bool value) async {
                                              if (!mounted || _isDisposed) {
                                                return;
                                              }

                                              try {
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();

                                                await prefs.setBool(
                                                    "isDark", value);

                                                notifier.isAvailable(value);

                                                if (!mounted || _isDisposed) {
                                                  return;
                                                }

                                                setState(() {
                                                  darkMode = value;
                                                });

                                                Get.offAll(MapScreen(
                                                    selectvihical: false));
                                              } catch (e) {
                                                if (kDebugMode) {
                                                  print(
                                                      "Dark mode switch error: $e");
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                const SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                GetBuilder<pagelistApiController>(
                  builder: (pagelistcontroller) {
                    return pagelistcontroller.isLoading
                        ? const SizedBox()
                        : ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            separatorBuilder: (context, index) {
                              return const SizedBox(width: 5);
                            },
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: pagelistcontroller
                                .pageListApiiimodel!.pagesList!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            Page_List_description(
                                                title:
                                                    pagelistcontroller
                                                        .pageListApiiimodel!
                                                        .pagesList![index]
                                                        .title
                                                        .toString(),
                                                description: pagelistcontroller
                                                    .pageListApiiimodel!
                                                    .pagesList![index]
                                                    .description
                                                    .toString()),
                                      ));
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, right: 10, top: 20),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/svgpicture/pagelist.svg",
                                            height: 25,
                                            color: notifier.textColor,
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            "${pagelistcontroller.pageListApiiimodel!.pagesList![index].title}",
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: notifier.textColor),
                                          ),
                                          const Spacer(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            });
                  },
                ),
                InkWell(
                  onTap: () {
                    loginSharedPreferencesSet(true);
                    Get.offAll(const OnbordingScreen());
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              "assets/svgpicture/logout.svg",
                              height: 25,
                              color: Colors.red,
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              "Log Out".tr,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.red),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    Get.back();
                    showModalBottomSheet<void>(
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(15),
                              topLeft: Radius.circular(15))),
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          height: 200,
                          decoration: BoxDecoration(
                              color: notifier.containercolore,
                              borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  topLeft: Radius.circular(15))),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15, right: 15),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const SizedBox(
                                  height: 25,
                                ),
                                Text('Delete Account'.tr,
                                    style: TextStyle(
                                        color: theamcolore,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                const SizedBox(height: 12.5),
                                const Divider(
                                  color: Colors.grey,
                                ),
                                const SizedBox(
                                  height: 12.5,
                                ),
                                Text(
                                    'Are you sure you want to delete account?'
                                        .tr,
                                    style: TextStyle(
                                        color: notifier.textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(
                                  height: 25,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ButtonStyle(
                                          fixedSize:
                                              const WidgetStatePropertyAll(
                                                  Size(130, 40)),
                                          elevation:
                                              const WidgetStatePropertyAll(0),
                                          shape: WidgetStatePropertyAll(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          backgroundColor:
                                              const WidgetStatePropertyAll(
                                                  Colors.white)),
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel'.tr.tr,
                                          style: const TextStyle(
                                              color: Colors.black)),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                          fixedSize:
                                              const WidgetStatePropertyAll(
                                                  Size(130, 40)),
                                          elevation:
                                              const WidgetStatePropertyAll(0),
                                          shape: WidgetStatePropertyAll(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  theamcolore)),
                                      onPressed: () => {
                                        loginSharedPreferencesSet(true),
                                        deleteAccount
                                            .deleteaccountApi(
                                                id: useridgloable.toString())
                                            .then(
                                          (value) {
                                            Get.offAll(OnbordingScreen());
                                          },
                                        ),
                                      },
                                      child: Text('Yes,Remove'.tr,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(15)),
                      child: Center(
                        child: Text(
                          "Delete account",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  final FocusNode _focusNode = FocusNode();

  int? couponindex;

  Buttonpresebottomshhet() {
    if (pickupcontroller.text.isEmpty || dropcontroller.text.isEmpty) {
      CustomNotification.show(
          message: "Select Pickup and Drop", type: NotificationType.info);
    } else if (amountresponse == "false") {
      CustomNotification.show(
          message: "Address is not in the zone!", type: NotificationType.info);
    } else if (dropprice == 0) {
      CustomNotification.show(
          message: responsemessage, type: NotificationType.info);
    } else {
      toast = 0;
      amountcontroller.text = dropprice.toString();

      int maxprice = int.parse(maximumfare);
      int minprice = int.parse(minimumfare);
      print("**maxprice**:-- $maxprice");
      print("**maxprice**:-- $minprice");

      Get.bottomSheet(
        enableDrag: false,
        isDismissible: false,
        isScrollControlled: true,
        StatefulBuilder(
          builder: (context, setState) {
            return Container(
              width: Get.width,
              decoration: BoxDecoration(
                color: notifier.containercolore,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Column(
                      children: [
                        isanimation == false
                            ? const SizedBox()
                            : lottie.Lottie.asset("assets/lottie/loading.json",
                                height: 30),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Spacer(),
                            SizedBox(
                              width: 40,
                            ),
                            Text(
                              "Set your price".tr,
                              style: TextStyle(
                                  color: notifier.textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                            ),
                            Spacer(),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (controller != null &&
                                      controller!.isAnimating) {
                                    CustomNotification.show(
                                        message:
                                            "Your current request is in progress. You can either wait for it to complete or cancel to perform this action."
                                                .tr,
                                        type: NotificationType.info);
                                  } else {
                                    Get.back();
                                  }
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Image(
                                    image: AssetImage("assets/close.png"),
                                    color: notifier.textColor,
                                    height: 20,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text("💡Raise the fare, increase your chances.".tr,
                            style: const TextStyle(color: Colors.grey)),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (controller != null &&
                                      controller!.isAnimating) {
                                    CustomNotification.show(
                                        message:
                                            "Your current request is in progress. You can either wait for it to complete or cancel to perform this action."
                                                .tr,
                                        type: NotificationType.info);
                                  } else {
                                    if (double.parse(dropprice.toString()) >
                                        minprice) {
                                      dropprice -= 1;
                                      amountcontroller.text =
                                          dropprice.toString();
                                      mainamount = dropprice.toString();
                                      offerpluse = true;

                                      if (couponindex != null) {
                                        if (couponadd[couponindex!] == true) {
                                          couponadd[couponindex!] = false;
                                        }
                                      }

                                      couponname = "";
                                      couponId = "";
                                    }
                                  }
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Image(
                                    image: AssetImage("assets/minus.png"),
                                    color: notifier.textColor,
                                    height: 20,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Center(
                              child: SizedBox(
                                width: 150,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  controller: amountcontroller,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 30, color: notifier.textColor),
                                  readOnly: controller != null &&
                                          controller!.isAnimating
                                      ? true
                                      : false,
                                  onTap: () {
                                    controller != null &&
                                            controller!.isAnimating
                                        ? CustomNotification.show(
                                            message:
                                                "Your current request is in progress. You can either wait for it to complete or cancel to perform this action."
                                                    .tr,
                                            type: NotificationType.info)
                                        : "";
                                  },
                                  onSubmitted: (value) {
                                    setState(() {
                                      if (int.parse(amountcontroller.text) >
                                          maxprice) {
                                        amountcontroller.clear();
                                        toast = 1;
                                        print("fffff");
                                      } else if (int.parse(
                                              amountcontroller.text) <
                                          minprice) {
                                        amountcontroller.clear();
                                        toast = 2;
                                        print("hhhhh");
                                      } else {
                                        toast = 0;
                                        dropprice =
                                            int.parse(amountcontroller.text);
                                        mainamount = amountcontroller.text;
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (controller != null &&
                                      controller!.isAnimating) {
                                    CustomNotification.show(
                                        message:
                                            "Your current request is in progress. You can either wait for it to complete or cancel to perform this action."
                                                .tr,
                                        type: NotificationType.info);
                                  } else {
                                    if (double.parse(dropprice.toString()) <
                                        maxprice) {
                                      dropprice += 1;
                                      amountcontroller.text =
                                          dropprice.toString();
                                      mainamount = dropprice.toString();
                                      offerpluse = true;
                                      if (couponindex != null) {
                                        if (couponadd[couponindex!] == true) {
                                          couponadd[couponindex!] = false;
                                        }
                                      }

                                      couponname = "";
                                      couponId = "";
                                    }
                                  }

                                  print("////:--- $dropprice");
                                });
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    shape: BoxShape.circle),
                                child: Center(
                                  child: Image(
                                    image: AssetImage("assets/plus.png"),
                                    color: notifier.textColor,
                                    height: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        toast == 1
                            ? Text(
                                "Maximum fare is $currencyy$maxprice",
                                style: const TextStyle(color: Colors.red),
                              )
                            : toast == 2
                                ? Text(
                                    "Minimum fare is $currencyy$minprice",
                                    style: const TextStyle(color: Colors.red),
                                  )
                                : const SizedBox(),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Image(
                            image: AssetImage("assets/automatically.png"),
                            height: 30,
                            width: 30,
                          ),
                          title: Text(
                            "Automatically book the nearest driver for (${globalcurrency}${amountcontroller.text})"
                                .tr,
                            style: TextStyle(
                                color: notifier.textColor, fontSize: 16),
                          ),
                          trailing: SizedBox(
                            height: 30,
                            width: 40,
                            child: Transform.scale(
                              scale: 0.9,
                              child: CupertinoSwitch(
                                value: switchValue,
                                activeColor: theamcolore,
                                onChanged: controller != null &&
                                        controller!.isAnimating
                                    ? (bool value) {
                                        CustomNotification.show(
                                          message:
                                              "Your current request is in progress. You can either wait for it to complete or cancel to perform this action."
                                                  .tr,
                                        );
                                      }
                                    : (bool value) async {
                                        // Check if widget is still mounted to avoid setState on disposed widget
                                        if (!mounted) return;

                                        try {
                                          // Update UI immediately
                                          setState(() {
                                            switchValue = value;
                                          });

                                          // Update the bidding mode
                                          updateBiddingMode(value);

                                          // Save preference
                                          await _saveAutomaticBookingPreference(
                                              value);

                                          // Show notification
                                          CustomNotification.show(
                                            message: value
                                                ? "Automatic booking enabled".tr
                                                : "Manual driver selection".tr,
                                          );

                                          offerpluse = true;

                                          if (kDebugMode) {
                                            print(
                                                "🔄 Auto-booking toggled: ${value ? 'ON' : 'OFF'}");
                                            print(
                                                "📱 UI State - switchValue: $switchValue");
                                            print(
                                                "🚗 Backend State - biddautostatus: $biddautostatus");
                                          }
                                        } catch (e) {
                                          if (kDebugMode) {
                                            print(
                                                "❌ Error updating switch: $e");
                                          }
                                          // Revert the switch if there was an error
                                          if (mounted) {
                                            setState(() {
                                              switchValue = !value;
                                            });
                                          }
                                        }
                                      },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: notifier.containercolore,
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0, -0.4),
                              blurRadius: 5),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15)),
                                      ),
                                      context: context,
                                      builder: (BuildContext context) {
                                        return StatefulBuilder(
                                            builder: (context, setState) {
                                          return ClipRRect(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(15),
                                                    topRight:
                                                        Radius.circular(15)),
                                            child: Scaffold(
                                              backgroundColor:
                                                  notifier.containercolore,
                                              floatingActionButtonLocation:
                                                  FloatingActionButtonLocation
                                                      .centerDocked,
                                              floatingActionButton: Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 10,
                                                    left: 10,
                                                    right: 10),
                                                child: CommonButton(
                                                    containcolore: theamcolore,
                                                    onPressed1: () {
                                                      Get.back();
                                                      Get.back();
                                                      Buttonpresebottomshhet();
                                                    },
                                                    txt1: "CONTINUE".tr,
                                                    context: context),
                                              ),
                                              body: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      notifier.containercolore,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  15),
                                                          topRight:
                                                              Radius.circular(
                                                                  15)),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          bottom: 50),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      const SizedBox(
                                                        height: 13,
                                                      ),
                                                      Text(
                                                          'Payment Getway Method'
                                                              .tr,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  "SofiaProBold",
                                                              fontSize: 18,
                                                              color: notifier
                                                                  .textColor)),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      walleteamount == 0
                                                          ? const SizedBox()
                                                          : Row(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  "assets/svgpicture/wallet.svg",
                                                                  height: 30,
                                                                  color:
                                                                      theamcolore,
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Text(
                                                                  "My Wallet (${globalcurrency}${walleteamount})",
                                                                  style: TextStyle(
                                                                      color: notifier
                                                                          .textColor),
                                                                ),
                                                                const Spacer(),
                                                                Transform.scale(
                                                                  scale: 0.8,
                                                                  child:
                                                                      CupertinoSwitch(
                                                                    value:
                                                                        switchValue,
                                                                    activeColor:
                                                                        theamcolore,
                                                                    onChanged: (bool
                                                                        value) {
                                                                      setState(
                                                                          () {
                                                                        switchValue =
                                                                            value;
                                                                      });
                                                                    },
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      Expanded(
                                                        child:
                                                            ListView.separated(
                                                                separatorBuilder:
                                                                    (context,
                                                                        index) {
                                                                  return const SizedBox(
                                                                      width: 0);
                                                                },
                                                                shrinkWrap:
                                                                    true,
                                                                scrollDirection:
                                                                    Axis
                                                                        .vertical,
                                                                itemCount: paymentGetApiController
                                                                    .paymentgetwayapi!
                                                                    .paymentList!
                                                                    .length,
                                                                itemBuilder:
                                                                    (BuildContext
                                                                            context,
                                                                        int index) {
                                                                  return InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        payment = paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![index]
                                                                            .id!;
                                                                        paymentname = paymentGetApiController
                                                                            .paymentgetwayapi!
                                                                            .paymentList![index]
                                                                            .name!;
                                                                      });
                                                                    },
                                                                    child: paymentGetApiController.paymentgetwayapi!.paymentList![index].status ==
                                                                            "0"
                                                                        ? const SizedBox()
                                                                        : Container(
                                                                            height:
                                                                                90,
                                                                            margin: const EdgeInsets.only(
                                                                                left: 10,
                                                                                right: 10,
                                                                                top: 6,
                                                                                bottom: 6),
                                                                            padding:
                                                                                const EdgeInsets.all(5),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              border: Border.all(color: payment == paymentGetApiController.paymentgetwayapi!.paymentList![index].id! ? theamcolore : Colors.grey.withOpacity(0.4)),
                                                                              borderRadius: BorderRadius.circular(15),
                                                                            ),
                                                                            child:
                                                                                Center(
                                                                              child: ListTile(
                                                                                leading: Transform.translate(
                                                                                  offset: const Offset(-5, 0),
                                                                                  child: Container(
                                                                                    height: 100,
                                                                                    width: 60,
                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.4)), image: DecorationImage(image: NetworkImage('${Config.imageurl}${paymentGetApiController.paymentgetwayapi!.paymentList![index].image}'))),
                                                                                  ),
                                                                                ),
                                                                                title: Padding(
                                                                                  padding: const EdgeInsets.only(bottom: 4),
                                                                                  child: Text(
                                                                                    paymentGetApiController.paymentgetwayapi!.paymentList![index].name.toString(),
                                                                                    style: TextStyle(fontSize: 16, fontFamily: "SofiaProBold", color: notifier.textColor),
                                                                                    maxLines: 2,
                                                                                  ),
                                                                                ),
                                                                                subtitle: Padding(
                                                                                  padding: const EdgeInsets.only(bottom: 4),
                                                                                  child: Text(
                                                                                    paymentGetApiController.paymentgetwayapi!.paymentList![index].subTitle.toString(),
                                                                                    style: TextStyle(fontSize: 12, fontFamily: "SofiaProBold", color: notifier.textColor),
                                                                                    maxLines: 2,
                                                                                  ),
                                                                                ),
                                                                                trailing: Radio(
                                                                                  value: payment == paymentGetApiController.paymentgetwayapi!.paymentList![index].id! ? true : false,
                                                                                  fillColor: MaterialStatePropertyAll(theamcolore),
                                                                                  groupValue: true,
                                                                                  onChanged: (value) {
                                                                                    print(value);
                                                                                    setState(() {
                                                                                      selectedOption = value.toString();
                                                                                      selectBoring = paymentGetApiController.paymentgetwayapi!.paymentList![index].image.toString();
                                                                                    });
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                  );
                                                                }),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                      },
                                    );
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Image(
                                      image: AssetImage("assets/payment.png"),
                                      height: 30,
                                      width: 30,
                                    ),
                                    title: Transform.translate(
                                        offset: const Offset(-15, 0),
                                        child: Text(
                                          paymentname,
                                          style: TextStyle(
                                              color: notifier.textColor),
                                        )),
                                    trailing: Image(
                                      image: AssetImage(
                                          "assets/angle-right-small.png"),
                                      height: 30,
                                      color: notifier.textColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    {
                                      if (controller != null &&
                                          controller!.isAnimating) {
                                        CustomNotification.show(
                                            message:
                                                "Your current request is in progress."
                                                    .tr,
                                            type: NotificationType.info);
                                        return; // Prevents the rest of the function from running
                                      }
                                      setState(() {
                                        mainamount = dropprice.toString();
                                        if (couponadd.isEmpty) {
                                          for (int i = 0;
                                              i <
                                                  paymentGetApiController
                                                      .paymentgetwayapi!
                                                      .couponList!
                                                      .length;
                                              i++) {
                                            couponadd.add(false);
                                          }
                                        }
                                      });

                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15)),
                                        ),
                                        context: context,
                                        builder: (BuildContext context) {
                                          return StatefulBuilder(
                                              builder: (context, setState) {
                                            return Scaffold(
                                              backgroundColor:
                                                  notifier.containercolore,
                                              appBar: AppBar(
                                                elevation: 0,
                                                toolbarHeight: 90,
                                                backgroundColor:
                                                    notifier.containercolore,
                                                automaticallyImplyLeading:
                                                    false,
                                                leading: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 40,
                                                          left: 18,
                                                          right: 18),
                                                  child: InkWell(
                                                      onTap: () {
                                                        Get.back();
                                                      },
                                                      child: Image(
                                                        image: AssetImage(
                                                            "assets/arrow-left.png"),
                                                        color:
                                                            notifier.textColor,
                                                      )),
                                                ),
                                                title: Transform.translate(
                                                    offset:
                                                        const Offset(-10, 0),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 40),
                                                      child: Text(
                                                        "All coupons".tr,
                                                        style: TextStyle(
                                                            color: notifier
                                                                .textColor,
                                                            fontSize: 18),
                                                      ),
                                                    )),
                                              ),
                                              body: Padding(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Text(
                                                      "Best Coupon".tr,
                                                      style: TextStyle(
                                                          color: notifier
                                                              .textColor,
                                                          fontSize: 20),
                                                    ),
                                                    const SizedBox(
                                                      height: 20,
                                                    ),
                                                    Expanded(
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            paymentGetApiController
                                                                .paymentgetwayapi!
                                                                .couponList!
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 10),
                                                            decoration: BoxDecoration(
                                                                color: notifier
                                                                    .containercolore,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            15)),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.4))),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(15),
                                                              child: Row(
                                                                children: [
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        "${paymentGetApiController.paymentgetwayapi!.couponList![index].title}",
                                                                        style: TextStyle(
                                                                            color:
                                                                                notifier.textColor,
                                                                            fontWeight: FontWeight.bold,
                                                                            fontSize: 18),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Text(
                                                                        "${paymentGetApiController.paymentgetwayapi!.couponList![index].subTitle}",
                                                                        style: const TextStyle(
                                                                            color:
                                                                                Colors.grey),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            10,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                            "Coupon Code: ".tr,
                                                                            style:
                                                                                TextStyle(color: notifier.textColor),
                                                                          ),
                                                                          Text(
                                                                            "${paymentGetApiController.paymentgetwayapi!.couponList![index].code}",
                                                                            style:
                                                                                TextStyle(color: theamcolore, fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                            "Coupon Amount: ".tr,
                                                                            style:
                                                                                TextStyle(color: notifier.textColor),
                                                                          ),
                                                                          Text(
                                                                            "${globalcurrency}${paymentGetApiController.paymentgetwayapi!.couponList![index].discountAmount}",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, color: notifier.textColor),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                            "Minimum Amount: ".tr,
                                                                            style:
                                                                                TextStyle(color: notifier.textColor),
                                                                          ),
                                                                          Text(
                                                                            "${globalcurrency}${paymentGetApiController.paymentgetwayapi!.couponList![index].minAmount}",
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, color: notifier.textColor),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            5,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Text(
                                                                            "Ex Date: ".tr,
                                                                            style:
                                                                                TextStyle(color: notifier.textColor),
                                                                          ),
                                                                          Text(
                                                                            paymentGetApiController.paymentgetwayapi!.couponList![index].endDate.toString().split(" ").first,
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold, color: notifier.textColor),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              15),
                                                                      couponadd[index] ==
                                                                              true
                                                                          ? InkWell(
                                                                              onTap: () {
                                                                                if (controller != null && controller!.isAnimating) {
                                                                                  CustomNotification.show(message: "Your current request is in progress.".tr, type: NotificationType.info);
                                                                                  return; // Prevents the rest of the function from running
                                                                                }
                                                                                setState(() {
                                                                                  couponadd[index] = false;
                                                                                  dropprice = mainamount;
                                                                                  amountcontroller.text = mainamount;
                                                                                  couponname = "";
                                                                                  couponId = "";
                                                                                  Get.back(result: {
                                                                                    "coupAdded": "",
                                                                                    "couponid": "",
                                                                                  });
                                                                                  Get.back(result: {
                                                                                    "coupAdded": "",
                                                                                    "couponid": "",
                                                                                  });
                                                                                  Buttonpresebottomshhet();
                                                                                });
                                                                              },
                                                                              child: Container(
                                                                                  height: 45,
                                                                                  width: 130,
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border.all(color: Colors.red),
                                                                                    borderRadius: BorderRadius.circular(30),
                                                                                  ),
                                                                                  child: const Center(
                                                                                      child: Text(
                                                                                    "Remove",
                                                                                    style: TextStyle(color: Colors.red),
                                                                                  ))))
                                                                          : InkWell(
                                                                              onTap: () {
                                                                                if (double.parse(amountcontroller.text.toString()) >= double.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].minAmount.toString())) {
                                                                                  setState(() {
                                                                                    couponAmt = int.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].discountAmount.toString());

                                                                                    couponindex = index;
                                                                                    if (couponadd[index] == false) {
                                                                                      for (int i = 0; i < couponadd.length; i++) {
                                                                                        if (couponadd.contains(true)) {
                                                                                          couponadd[i] = false;
                                                                                        }
                                                                                      }
                                                                                      couponadd[index] = true;
                                                                                    } else {
                                                                                      couponadd[index] = false;
                                                                                    }
                                                                                  });

                                                                                  print("----------------------------------------${double.parse(amountcontroller.text.toString())}");
                                                                                  couponname = paymentGetApiController.paymentgetwayapi!.couponList![index].title.toString();
                                                                                  couponId = paymentGetApiController.paymentgetwayapi!.couponList![index].id.toString();

                                                                                  print("xjsbchjscvsgchsvcscsc  $couponId");

                                                                                  Get.back(result: {
                                                                                    "coupAdded": paymentGetApiController.paymentgetwayapi!.couponList![index].title,
                                                                                    "couponid": paymentGetApiController.paymentgetwayapi!.couponList![index].id.toString(),
                                                                                  });
                                                                                  Get.back(result: {
                                                                                    "coupAdded": paymentGetApiController.paymentgetwayapi!.couponList![index].title,
                                                                                    "couponid": paymentGetApiController.paymentgetwayapi!.couponList![index].id.toString(),
                                                                                  });
                                                                                  Buttonpresebottomshhet();
                                                                                }
                                                                              },
                                                                              child: Container(
                                                                                  height: 45,
                                                                                  width: 130,
                                                                                  decoration: BoxDecoration(
                                                                                    border: Border.all(color: int.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].minAmount!) < int.parse(mainamount) ? theamcolore : Colors.grey.withOpacity(0.2)),
                                                                                    borderRadius: BorderRadius.circular(30),
                                                                                  ),
                                                                                  child: Center(
                                                                                      child: Text(
                                                                                    "Apply coupons".tr,
                                                                                    style: TextStyle(color: int.parse(paymentGetApiController.paymentgetwayapi!.couponList![index].minAmount!) < int.parse(mainamount) ? theamcolore : Colors.grey),
                                                                                  ))),
                                                                            ),
                                                                    ],
                                                                  ),
                                                                  const Spacer(),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      SvgPicture
                                                                          .asset(
                                                                        "assets/svgpicture/offerIcon.svg",
                                                                        height:
                                                                            50,
                                                                      )
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            );
                                          });
                                        },
                                      );
                                    }
                                  },
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: Image(
                                        image: AssetImage("assets/coupon.png"),
                                        height: 30,
                                        width: 30,
                                      ),
                                    ),
                                    title: couponname == ""
                                        ? Transform.translate(
                                            offset: const Offset(-15, 10),
                                            child: Text(
                                              "Coupon".tr,
                                              style: TextStyle(
                                                  color: notifier.textColor),
                                            ))
                                        : Transform.translate(
                                            offset: const Offset(-15, 0),
                                            child: Text(
                                              couponname,
                                              style: TextStyle(
                                                  color: notifier.textColor),
                                            )),
                                    subtitle: couponname == ""
                                        ? const Text("")
                                        : Transform.translate(
                                            offset: const Offset(-15, 0),
                                            child: Text(
                                              "Coupon applied".tr,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: notifier.textColor),
                                            )),
                                    trailing: Image(
                                      image: AssetImage(
                                          "assets/angle-right-small.png"),
                                      height: 30,
                                      color: notifier.textColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          isanimation == false
                              ? CommonButton(
                                  containcolore: theamcolore,
                                  onPressed1: () {
                                    setState(() {
                                      if (double.parse(amountcontroller.text) >
                                          maxprice) {
                                        amountcontroller.clear();
                                        toast = 1;
                                        print("fffff");
                                      } else if (double.parse(
                                              amountcontroller.text) <
                                          minprice) {
                                        amountcontroller.clear();
                                        toast = 2;
                                        print("hhhhh");
                                      } else {
                                        isanimation = true;
                                        loadertimer = true;
                                        offerpluse = false;
                                        requesttime();
                                        orderfunction();
                                      }
                                    });
                                  },
                                  context: context,
                                  txt1:
                                      "Book for ${currencyy ?? globalcurrency}${amountcontroller.text}")
                              : AnimatedBuilder(
                                  animation: controller!,
                                  builder: (context, child) {
                                    return SizedBox(
                                      height: 49,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          padding: const WidgetStatePropertyAll(
                                              EdgeInsets.zero),
                                          elevation:
                                              const WidgetStatePropertyAll(0),
                                          overlayColor:
                                              const WidgetStatePropertyAll(
                                                  Colors.transparent),
                                          backgroundColor:
                                              WidgetStatePropertyAll(
                                                  theamcolore.withOpacity(0.4)),
                                          shape: WidgetStatePropertyAll(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            setState(() {
                                              if (double.parse(
                                                      amountcontroller.text) >
                                                  maxprice) {
                                                amountcontroller.clear();
                                                toast = 1;
                                                print("fffff");
                                              } else if (double.parse(
                                                      amountcontroller.text) <
                                                  minprice) {
                                                amountcontroller.clear();
                                                toast = 2;
                                                print("hhhhh");
                                              } else {
                                                if (offerpluse == true) {
                                                  if (controller != null &&
                                                      controller!.isAnimating) {
                                                    controller!.dispose();
                                                  }
                                                  print(
                                                      "fgvjgfsvjhsgfvjhbfgvjhafgbvhjkafgv");
                                                  requesttime();
                                                  orderfunction();

                                                  offerpluse = false;
                                                } else {}
                                              }

                                              if (double.parse(
                                                      amountcontroller.text) >
                                                  maxprice) {
                                                amountcontroller.clear();
                                                amountcontroller.text =
                                                    maxprice.toString();
                                                toast = 1;
                                                print("fffff");
                                              } else if (double.parse(
                                                      amountcontroller.text) <
                                                  minprice) {
                                                amountcontroller.clear();
                                                amountcontroller.text =
                                                    minprice.toString();
                                                toast = 2;
                                                print("hhhhh");
                                              } else {
                                                toast = 0;

                                                dropprice = double.parse(
                                                    amountcontroller.text);
                                                mainamount =
                                                    amountcontroller.text;
                                              }
                                            });
                                          });
                                        },
                                        child: Stack(
                                          alignment: Alignment.center,
                                          clipBehavior: Clip.none,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: LinearProgressIndicator(
                                                minHeight: 49,
                                                value: 1.0 - controller!.value,
                                                backgroundColor: theamcolore
                                                    .withOpacity(0.1),
                                                color: theamcolore,
                                              ),
                                            ),
                                            offerpluse == true
                                                ? Text(
                                                    "Raise fare to $currencyy${amountcontroller.text}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                      letterSpacing: 0.4,
                                                    ),
                                                  )
                                                : Text(
                                                    "Book for $currencyy${amountcontroller.text}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.white,
                                                      letterSpacing: 0.4,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                          homeApiController.homeapimodel!.runnigRide!.isEmpty
                              ? SizedBox()
                              : homeApiController.homeapimodel!.runnigRide![0]
                                          .biddingRunStatus ==
                                      0
                                  ? SizedBox()
                                  : const SizedBox(
                                      height: 10,
                                    ),
                          homeApiController.homeapimodel!.runnigRide!.isEmpty
                              ? SizedBox()
                              : homeApiController.homeapimodel!.runnigRide![0]
                                          .biddingRunStatus ==
                                      0
                                  ? SizedBox()
                                  : CommonOutLineButton(
                                      bordercolore: theamcolore,
                                      onPressed1: () {
                                        setState(() {
                                          homeApiController
                                              .homeapimodel!
                                              .runnigRide![0]
                                              .biddingRunStatus = 0;
                                          print(
                                              "+++++ biddingRunStatus +++++ :- ${homeApiController.homeapimodel!.runnigRide![0].biddingRunStatus}");
                                          socatloadbidinfdata();
                                        });
                                      },
                                      context: context,
                                      txt1: "Driver Offers"),
                          const SizedBox(
                            height: 10,
                          ),
                          StatefulBuilder(
                            builder: (context, setState) {
                              return cancelloader
                                  ? Center(
                                      child: CustomLoadingWidget(),
                                    )
                                  : CommonOutLineButton(
                                      bordercolore: theamcolore,
                                      onPressed1: () {
                                        setState(() {
                                          isanimation = false;

                                          cancelloader = true;
                                          print(
                                              "++CANCEL LOADER++:- ${cancelloader}");
                                          removeRequest
                                              .removeApi(
                                                  uid: useridgloable.toString())
                                              .then(
                                            (value) {
                                              socket.emit('AcceRemoveOther', {
                                                'requestid': request_id,
                                                'driverid': calculateController
                                                    .calCulateModel!.driverId!,
                                              });

                                              Future.delayed(
                                                  Duration(microseconds: 500),
                                                  () {
                                                setState(() {
                                                  setState(() {});
                                                });
                                              });
                                              Get.back();
                                              cancelloader = false;
                                            },
                                          );
                                          if (controller != null &&
                                              controller!.isAnimating) {
                                            print("vgvgvgvgvgvgvgvgvgvgv");
                                            controller!.dispose();
                                          }
                                          cancelTimer();
                                        });
                                      },
                                      context: context,
                                      txt1: "Cancel Request".tr);
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
  }

// =================== 👇 PASTE THIS ENTIRE FUNCTION 👇 ===================

  orderfunction() {
    print("DRIVER ID:- ${homeMapController.homeMapApiModel!.driverid}");
    print("PICK LOCATION:- ${pickupcontroller.text}");
    print("DROP LOCATION:- ${dropcontroller.text}");
    socket.connect();

    homeWalletApiController
        .homwwalleteApi(uid: userid.toString(), context: context)
        .then(
      (value) {
        print("{{{{{[wallete}}}}}]:-- ${value["wallet_amount"]}");
        walleteamount = double.parse(value["wallet_amount"]);
        print("[[[[[[[[[[[[[walleteamount]]]]]]]]]]]]]:-- ($walleteamount)");
      },
    );
    // refreshAnimation();

    // print("111111111dd111111111 ${calculateController.calCulateModel!.driverId}");
    print("111111111 amountcontroller.text 111111111 ${amountcontroller.text}");

    percentValue.clear();
    percentValue = [];
    for (int i = 0; i < 4; i++) {
      percentValue.add(0);
    }
    setState(() {
      currentStoryIndex = 0;
      // loadertimer = false;
    });

    priceyourfare = double.parse(amountcontroller.text);
    print("***price***::-(${priceyourfare})");

    addVihicalCalculateController.addvihicalcalculateApi(
      pickupadd: {
        "title": "${picktitle == "" ? addresspickup : picktitle}",
        "subt": picksubtitle
      },
      dropadd: {"title": droptitle, "subt": dropsubtitle},
      droplistadd: droptitlelist,
      context: context,
      uid: useridgloable.toString(),
      tot_km: "$totalkm",
      vehicle_id: vehicle_id,
      tot_minute: tot_time,
      tot_hour: tot_hour,
      m_role: mroal,
      coupon_id: couponId,
      payment_id: "$payment",
      driverid: homeMapController.homeMapApiModel!.driverid!,
      // driverid: [29,14],
      price: amountcontroller.text,
      pickup: "$latitudepick,$longitudepick",
      drop: "$latitudedrop,$longitudedrop",
      droplist: onlypass,
      bidd_auto_status: biddautostatus,
    ).then(
      (value) {
        print("+++++${value!["id"]}");
        setState(() {});
        request_id = value["id"].toString();
        socateempt();
      },
    );

    calculateController
        .calculateApi(
            context: context,
            uid: userid.toString(),
            mid: mid,
            mrole: mroal,
            pickup_lat_lon: "$latitudepick,$longitudepick",
            drop_lat_lon: "$latitudedrop,$longitudedrop",
            drop_lat_lon_list: onlypass)
        .then(
      (value) {
        // print("********** value **********:----- ${value}");
        // print("********** value **********:----- ${value["drop_price"]}");
        // print("********** value **********:----- ${value["vehicle"]["minimum_fare"]}");
        // print("********** value **********:----- ${value["vehicle"]["maximum_fare"]}");

        dropprice = 0;
        minimumfare = 0;
        maximumfare = 0;

        if (value["Result"] == true) {
          amountresponse = "true";
          dropprice = value["drop_price"];
          minimumfare = value["vehicle"]["minimum_fare"];
          maximumfare = value["vehicle"]["maximum_fare"];
          responsemessage = value["message"];
        } else {
          amountresponse = "false";
          print("jojojojojojojojojojojojojojojojojojojojojojojojo");
        }

        print("********** dropprice **********:----- $dropprice");
        print("********** minimumfare **********:----- $minimumfare");
        print("********** maximumfare **********:----- $maximumfare");
      },
    );
  }

// =================== 👆 END OF THE FUNCTION TO PASTE 👆 ===================
  List<String> convertDroplist() {
    if (onlypass.isEmpty) {
      return [];
    }

    return onlypass
        .map((point) => "${point.latitude},${point.longitude}")
        .toList();
  }

  void _showRetryDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Connection Error".tr),
          content: Text(
              "Failed to create ride request. Would you like to try again?".tr),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Reset UI state

                setState(() {
                  isanimation = false;

                  loadertimer = true;
                });
              },
              child: Text("Cancel".tr),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Retry the order

                orderfunction();
              },
              child: Text("Retry".tr),
            ),
          ],
        );
      },
    );
  }
}

class RefreshData {
  final bool shouldRefresh;
  RefreshData(this.shouldRefresh);
}
