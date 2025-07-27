import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart' as lottie;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// --- Placeholder Imports ---
// Replace these with your actual project imports.
class Config {
  static const String imageurl =
      "http://your_base_url.com/"; // Replace with your actual URL
  static const String mapkey =
      "YOUR_GOOGLE_MAPS_API_KEY"; // Replace with your key
}

class ColorNotifier extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;

  Color get backgroundColor => _isDark ? Colors.grey[900]! : Colors.white;
  Color get containerColor => _isDark ? Colors.grey[850]! : Colors.white;
  Color get textColor => _isDark ? Colors.white70 : Colors.black87;

  void isAvailable(bool value) {
    _isDark = value;
    notifyListeners();
  }
}

// Mock API controllers to make the code runnable
class HomeApiController extends GetxController {
  bool isLoading = false;
  // Mock data structure
  dynamic homeapimodel;
  Future<dynamic> homeApi(
      {required String uid, required String lat, required String lon}) async {}
}

class HomeMapController extends GetxController {
  dynamic homeMapApiModel;
  Future<dynamic> homemapApi(
      {required String mid, required String lat, required String lon}) async {}
}

class CalculateController extends GetxController {
  dynamic calCulateModel;
  Future<dynamic> calculateApi(
      {required BuildContext context,
      required String uid,
      required String mid,
      required String mrole,
      required String pickup_lat_lon,
      required String drop_lat_lon,
      required String drop_lat_lon_list}) async {}
}

class AddVihicalCalculateController extends GetxController {
  dynamic addVihicalCalculateModel;
  Future<dynamic> addvihicalcalculateApi({
    required Map<String, String> pickupadd,
    required Map<String, String> dropadd,
    required List droplistadd,
    required BuildContext context,
    required String uid,
    required String tot_km,
    required String vehicle_id,
    required dynamic tot_minute,
    required dynamic tot_hour,
    required String m_role,
    required String coupon_id,
    required String payment_id,
    required dynamic driverid,
    required String price,
    required String pickup,
    required String drop,
    required String droplist,
    required String bidd_auto_status,
  }) async {}
}

class Modual_CalculateController extends GetxController {
  dynamic modualCalculateApiModel;
  Future<void> modualcalculateApi(
      {required BuildContext context,
      required String uid,
      required String mid,
      required String mrole,
      required String pickup_lat_lon,
      required String drop_lat_lon,
      required String drop_lat_lon_list}) async {}
}

class VihicalInformationApiController extends GetxController {
  dynamic vihicalInFormationApiModel;
  Future<void> vihicalinformationApi({required String vehicle_id}) async {}
}

class HomeWalletApiController extends GetxController {
  Future<dynamic> homwwalleteApi(
      {required String uid, required BuildContext context}) async {
    return {"wallet_amount": "50.00"};
  }
}

class PaymentGetApiController extends GetxController {
  dynamic paymentgetwayapi;
  Future<void> paymentlistApi(BuildContext context) async {}
}

class pagelistApiController extends GetxController {
  dynamic pageListApiiimodel;
  Future<void> pagelistttApi(BuildContext context) async {}
}

class RemoveRequest extends GetxController {
  Future<dynamic> removeApi({required String uid}) async {}
}

class TimeoutRequestApiController extends GetxController {
  Future<void> timeoutrequestApi(
      {required String uid, required String request_id}) async {}
}

class DeleteAccount extends GetxController {
  Future<void> deleteaccountApi({required String id}) async {}
}

class GlobalDriverAcceptClass extends GetxController {
  void driverdetailfunction(
      {required BuildContext context,
      required double lat,
      required double long,
      required String d_id,
      required String request_id}) {}
}

class ResendRequestApiController extends GetxController {}

class VihicalCalculateController extends GetxController {}

// Mock Screens
class OnbordingScreen extends StatelessWidget {
  const OnbordingScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Onboarding Screen")));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Profile Screen")));
}

class MyRideScreen extends StatelessWidget {
  const MyRideScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("My Ride Screen")));
}

class TopUpScreen extends StatelessWidget {
  const TopUpScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Top Up Screen")));
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Language Screen")));
}

class ReferAndEarn extends StatelessWidget {
  const ReferAndEarn({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Refer and Earn Screen")));
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("FAQ Screen")));
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Notification Screen")));
}

class PickupDropPoint extends StatelessWidget {
  const PickupDropPoint(
      {super.key, required bool pagestate, required String bidding});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Pickup/Drop Screen")));
}

class DriverListScreen extends StatelessWidget {
  const DriverListScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Driver List Screen")));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen(
      {super.key,
      required double latpic,
      required double longpic,
      required double latdrop,
      required double longdrop,
      required List destinationlat});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Home Screen")));
}

class Page_List_description extends StatelessWidget {
  const Page_List_description(
      {super.key, required String title, required String description});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text("Page List Description")));
}

// Mock Common Widgets
class CommonButton extends StatelessWidget {
  final Color containcolore;
  final VoidCallback onPressed1;
  final String txt1;
  final BuildContext context;
  const CommonButton(
      {super.key,
      required this.containcolore,
      required this.onPressed1,
      required this.txt1,
      required this.context});
  @override
  Widget build(BuildContext context) =>
      ElevatedButton(onPressed: onPressed1, child: Text(txt1));
}

class CommonOutLineButton extends StatelessWidget {
  final Color bordercolore;
  final VoidCallback onPressed1;
  final String txt1;
  final BuildContext context;
  const CommonOutLineButton(
      {super.key,
      required this.bordercolore,
      required this.onPressed1,
      required this.txt1,
      required this.context});
  @override
  Widget build(BuildContext context) =>
      OutlinedButton(onPressed: onPressed1, child: Text(txt1));
}

// Mock Globals from other files
final Color theamcolore = Colors.blue;
final Color greaycolore = Colors.grey;
String useridgloable = "";
double latitudepick = 0.0;
double longitudepick = 0.0;
double latitudedrop = 0.0;
double longitudedrop = 0.0;
String picktitle = "";
String picksubtitle = "";
String droptitle = "";
String dropsubtitle = "";
List droptitlelist = [];
List<PointLatLng> destinationlat = [];
String onlypass = "";
TextEditingController pickupcontroller = TextEditingController();
TextEditingController dropcontroller = TextEditingController();
var minimumfare;
var maximumfare;
var dropprice;
var totalkm;
var tot_time;
var tot_hour;
String vehicle_id = "";
double vihicalrice = 0.0;
String request_id = "";
String amountresponse = "true";
String responsemessage = "";
List<double> percentValue = [];
int currentStoryIndex = 0;
String midseconde = "";
String vihicalname = "";
String vihicalimage = "";
String tot_secound = "";
var addresspickup;
bool loadertimer = false;
bool offerpluse = false;
var driveridloader;

// --- Globals ---
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
AnimationController? controller;
int durationInSeconds = 0;
// --- End Placeholder Imports ---

class MapScreen extends StatefulWidget {
  final bool selectvihical;
  const MapScreen({super.key, required this.selectvihical});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  late GoogleMapController mapController1;
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  // User and Ride Details
  var decodeUid;
  var userid;
  String username = "";
  var currencyy;

  // Location and Map
  double? lathome;
  double? longhome;
  String? addresshome;
  final Map<MarkerId, Marker> markers = {};
  final Map<PolylineId, Polyline> polylines11 = {};
  String themeForMap = "";
  final List<LatLng> vihicallocations = [];
  final List<String> _iconPaths = [];
  final List<String> _iconPathsbiddingon = [];
  final List<LatLng> vihicallocationsbiddingon = [];
  List<PointLatLng> _dropOffPoints = [];
  Map<MarkerId, Marker> markers11 = {};

  // UI State
  bool isLoad = false;
  bool light = false;
  String biddautostatus = "false";
  bool switchValue = false;
  int toast = 0;
  int payment = 0;
  String paymentname = "";
  String selectedOption = "";
  String selectBoring = "";
  int couponAmt = 0;
  String couponId = "";
  String couponname = "";
  String mainamount = "";
  bool cancelloader = false;
  List<bool> couponadd = [];
  int? couponindex;

  // Controllers
  final TextEditingController amountcontroller = TextEditingController();
  late Animation<Color?> colorAnimation;

  // API and Socket Controllers
  final ResendRequestApiController resendRequestApiController =
      Get.put(ResendRequestApiController());
  final RemoveRequest removeRequest = Get.put(RemoveRequest());
  final TimeoutRequestApiController timeoutRequestApiController =
      Get.put(TimeoutRequestApiController());
  final HomeApiController homeApiController = Get.put(HomeApiController());
  final DeleteAccount deleteAccount = Get.put(DeleteAccount());
  final PaymentGetApiController paymentGetApiController =
      Get.put(PaymentGetApiController());
  final HomeMapController homeMapController = Get.put(HomeMapController());
  final CalculateController calculateController =
      Get.put(CalculateController());
  final Modual_CalculateController modual_calculateController =
      Get.put(Modual_CalculateController());
  final HomeWalletApiController homeWalletApiController =
      Get.put(HomeWalletApiController());
  final AddVihicalCalculateController addVihicalCalculateController =
      Get.put(AddVihicalCalculateController());
  final VihicalInformationApiController vihicalInformationApiController =
      Get.put(VihicalInformationApiController());
  final VihicalCalculateController vihicalCalculateController =
      Get.put(VihicalCalculateController());
  final GlobalDriverAcceptClass globalDriverAcceptClass =
      Get.put(GlobalDriverAcceptClass());
  final pagelistApiController pagelistcontroller =
      Get.put(pagelistApiController());

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  Future<void> _initializeScreen() async {
    await mapThemeStyle(context: context);
    await fun();
    socketConnect();
    _fetchData();

    if (widget.selectvihical) {
      _handleSelectedVehicle();
    }
  }

  void _fetchData() {
    paymentGetApiController.paymentlistApi(context).then((_) {
      // Your logic here
    });
    pagelistcontroller.pagelistttApi(context);
  }

  @override
  void dispose() {
    socket.dispose();
    controller?.dispose();
    amountcontroller.dispose();
    super.dispose();
  }

  // --- Map and Location ---

  Future<void> mapThemeStyle({required BuildContext context}) async {
    if (darkMode == true) {
      final style = await DefaultAssetBundle.of(context)
          .loadString("assets/dark_mode_style.json");
      setState(() {
        themeForMap = style;
      });
    }
  }

  Future<void> fun() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Fluttertoast.showToast(msg: "Location permission denied");
          return;
        }
      }
      var currentLocation = await locateUser();
      await getCurrentLatAndLong(
          currentLocation.latitude, currentLocation.longitude);
      _onAddMarkerButtonPressed(
          currentLocation.latitude, currentLocation.longitude);
    } catch (e) {
      if (kDebugMode) {
        print("Error in fun(): $e");
      }
    }
  }

  Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> getCurrentLatAndLong(double latitude, double longitude) async {
    lathome = latitude;
    longhome = longitude;
    lathomecurrent = latitude;
    longhomecurrent = longitude;

    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      addresshome =
          '${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.country}';
      if (pickupcontroller.text.isEmpty) {
        pickupcontroller.text = addresshome ?? '';
      }
    }
    setState(() {});
  }

  // --- Socket Connection & Listeners ---
  void socketConnect() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var uid = preferences.getString("userLogin");
    if (uid == null) return;

    decodeUid = jsonDecode(uid);
    userid = decodeUid['id'];
    username = decodeUid["name"];
    useridgloable = decodeUid['id'].toString();

    socket = IO.io(Config.imageurl, <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
    });
    socket.connect();

    socket.onConnect((_) {
      if (kDebugMode) print('Connected');
      _connectSocket();
    });
  }

  void _connectSocket() {
    // All your socket.on() listeners go here
    // Example:
    socket.on('acceptvehrequest$useridgloable', (acceptvehrequest) {
      // Your logic here
    });
  }

  // --- Ride Request Logic ---
  void _handleSelectedVehicle() {
    // Your logic for pre-selected vehicle
  }

  void requesttime() {
    // Your timer and animation logic
  }

  void orderfunction() {
    // Your order creation logic
  }

  // --- UI Widgets ---

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    return Scaffold(
      key: _key,
      drawer: draweropen(context),
      body: GetBuilder<HomeApiController>(
        builder: (homeApiController) {
          if (homeApiController.isLoading || lathome == null) {
            return Center(child: CircularProgressIndicator(color: theamcolore));
          }
          return Stack(
            children: [
              GoogleMap(
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer())
                },
                initialCameraPosition:
                    pickupcontroller.text.isEmpty || dropcontroller.text.isEmpty
                        ? CameraPosition(
                            target: LatLng(lathome!, longhome!), zoom: 13)
                        : CameraPosition(
                            target: LatLng(latitudepick, longitudepick),
                            zoom: 13),
                mapType: MapType.normal,
                markers:
                    pickupcontroller.text.isEmpty || dropcontroller.text.isEmpty
                        ? Set<Marker>.of(markers.values)
                        : Set<Marker>.of(markers11.values),
                onTap: (argument) {
                  // Your onTap logic
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
              // ... Your other stacked widgets (Top Bar, Draggable Sheet)
            ],
          );
        },
      ),
    );
  }

  // Placeholder for other methods like draweropen, Buttonpresebottomshhet, etc.
  // You would move the implementation of those methods here.

  Widget draweropen(BuildContext context) {
    // Your full drawer implementation
    return Drawer(child: Center(child: Text("Drawer")));
  }

  void Buttonpresebottomshhet() {
    // Your full bottom sheet implementation
  }

  // --- Helper Methods ---

  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<void> _onAddMarkerButtonPressed(double? lat, double? long) async {
    if (lat == null || long == null) return;
    final Uint8List markIcon = await getImages("assets/pickup.png", 80);
    Marker marker = Marker(
      markerId: const MarkerId("my_1"),
      icon: BitmapDescriptor.fromBytes(markIcon),
      position: LatLng(lat, long),
      onTap: () {
        // Your onTap dialog logic
      },
    );
    setState(() {
      markers[const MarkerId("my_1")] = marker;
    });
  }

  // ... other helper methods like _addMarkers, getDirections11, etc.
  void _addMarkers() {}
  void _addMarkers2() {}
  void _addMarker11(LatLng position, String id, BitmapDescriptor descriptor) {}
  void _addMarker2(LatLng position, String id, BitmapDescriptor descriptor) {}
  void _addMarker3(String id) {}
  void getDirections11(
      {required PointLatLng lat1,
      required PointLatLng lat2,
      required List<PointLatLng> dropOffPoints}) {}
}

class RefreshData {
  final bool shouldRefresh;
  RefreshData(this.shouldRefresh);
}
