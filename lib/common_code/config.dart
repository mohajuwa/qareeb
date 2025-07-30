// lib/common_code/config.dart
import '../api_code/login_controller.dart';

class Config {
  static String oneSignel = onesignalkey;
  static String mapkey = "AIzaSyB99Z7-KwgRCtvTae9brf7vDeRJBOqnPX8";

  // Use HTTPS with self-signed certificate
  static String baseurl = "https://qareeb.modwir.com";

  // Fixed image and chat URLs
  static String imageurl = '$baseurl/customer/';
  static String chaturl = '$baseurl/chat/';

  // API endpoints - FIXED: Added /customer prefix for mobile APIs
  static String signup = '/customer/signup';
  static String smstypeapi = '/customer/otp_detail'; // FIXED: Was /otp_detail
  static String mobilecheck = '/customer/mobile_check';
  static String msgapi = '/customer/msg91';
  static String twilioapi = '/customer/twilio';
  static String login = '/customer/login';
  static String forgot = '/customer/forgot_password';
  static String home = '/customer/home';
  static String calculate = '/customer/calculate';
  static String modualcalculate = '/customer/module_calculate';
  static String payment = '/customer/coupon_payment';
  static String vehicalcancelreason = '/customer/vehicle_cancel_reason';
  static String walletreportapi = '/customer/wallet';
  static String walletupapi = '/customer/add_wallet';
  static String homemap = '/customer/home_mape';
  static String vihicalcalculate = '/customer/vehicle_calculate';
  static String addvihicalcalculate = '/customer/add_vehicle_request';
  static String vihicaldriverdetail = '/customer/vehicle_driver_detail';
  static String timeoutapi = '/customer/timeout_vehicle_request';
  static String resendrequestapi = '/customer/resend_vehicle_request';
  static String removerequestapi = '/customer/remove_vehicle_request';
  static String vihicalcancelride = '/customer/vehicle_ride_cancel';
  static String allrequest = '/customer/all_service_request';
  static String homewallte = '/customer/home_wallet';
  static String review = '/customer/tbl_review';
  static String vihicalridecomplete = '/customer/vehicle_ride_complete';
  static String myridedetail = '/customer/all_ride_detail';
  static String chatlist = '/chat/chat_list';
  static String reviewdata = '/customer/review_data';
  static String faqapi = '/customer/faq_data';
  static String pagelistapi = '/customer/pages_data';
  static String referearnapi = '/customer/refer_and_earn';
  static String editprofile = '/customer/edit_customer';
  static String driverdetailprofile = '/customer/driver_profile_detail';
  static String vihicalinformation = '/customer/vehicle_information';
  static String notificationurl = '/customer/notification';
  static String delteuseraccount = '/customer/account_deactive';
}
