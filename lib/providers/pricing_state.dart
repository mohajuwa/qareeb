import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PricingState extends ChangeNotifier {
  double _dropPrice = 0.0;
  double _minimumfare = 0.0;
  double _maximumfare = 0.0;
  String _amountresponse = "";
  String _responsemessage = "";
  double _platformFee = 0.0;
  double _weatherPrice = 0.0;
  double _walletPrice = 0.0;
  double _couponAmount = 0.0;
  double _addiTimePrice = 0.0;

  // ✅ ADDED - Flag to prevent build-time updates
  bool _isUpdating = false;

  // Getters
  double get dropPrice => _dropPrice;
  double get minimumfare => _minimumfare;
  double get maximumfare => _maximumfare;
  String get amountresponse => _amountresponse;
  String get responsemessage => _responsemessage;
  double get platformFee => _platformFee;
  double get weatherPrice => _weatherPrice;
  double get walletPrice => _walletPrice;
  double get couponAmount => _couponAmount;
  double get addiTimePrice => _addiTimePrice;

  // ✅ CALCULATED GETTERS
  double get totalFare =>
      _dropPrice + _platformFee + _weatherPrice + _addiTimePrice;
  double get finalAmount => totalFare - _walletPrice - _couponAmount;
  String get finalAmountString => finalAmount.toStringAsFixed(2);

  // ✅ FIXED - Safe notification method
  void _safeNotifyListeners() {
    if (!_isUpdating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isUpdating) {
          notifyListeners();
        }
      });
    }
  }

  // ✅ FIXED - Methods with safe notification
  void updatePricing({
    required double dropPrice,
    required double minimumFare,
    required double maximumFare,
    String amountResponse = "",
    String responseMessage = "",
    double platformFee = 0.0,
    double weatherPrice = 0.0,
    double walletPrice = 0.0,
    double couponAmount = 0.0,
    double addiTimePrice = 0.0,
  }) {
    _isUpdating = true;
    _dropPrice = dropPrice;
    _minimumfare = minimumFare;
    _maximumfare = maximumFare;
    _amountresponse = amountResponse;
    _responsemessage = responseMessage;
    _platformFee = platformFee;
    _weatherPrice = weatherPrice;
    _walletPrice = walletPrice;
    _couponAmount = couponAmount;
    _addiTimePrice = addiTimePrice;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void updateFromCalculateResult(Map<String, dynamic> data) {
    if (data['Result'] == true) {
      _isUpdating = true;
      _dropPrice =
          double.tryParse(data['drop_price']?.toString() ?? '0') ?? 0.0;
      _minimumfare =
          double.tryParse(data['minimum_fare']?.toString() ?? '0') ?? 0.0;
      _maximumfare =
          double.tryParse(data['maximum_fare']?.toString() ?? '0') ?? 0.0;
      _amountresponse = data['amount_response']?.toString() ?? "";
      _responsemessage = data['response_message']?.toString() ?? "";
      _platformFee =
          double.tryParse(data['platform_fee']?.toString() ?? '0') ?? 0.0;
      _weatherPrice =
          double.tryParse(data['weather_price']?.toString() ?? '0') ?? 0.0;
      _walletPrice =
          double.tryParse(data['wallet_price']?.toString() ?? '0') ?? 0.0;
      _couponAmount =
          double.tryParse(data['coupon_amount']?.toString() ?? '0') ?? 0.0;
      _addiTimePrice =
          double.tryParse(data['addi_time_price']?.toString() ?? '0') ?? 0.0;
      _isUpdating = false;
      _safeNotifyListeners();
    }
  }

  void setDropPrice(double price) {
    _isUpdating = true;
    _dropPrice = price;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void setPlatformFee(double fee) {
    _isUpdating = true;
    _platformFee = fee;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void setAmountResponse(String amount) {
    _isUpdating = true;
    _amountresponse = amount;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void setWeatherPrice(double price) {
    _isUpdating = true;
    _weatherPrice = price;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void setWalletPrice(double price) {
    _isUpdating = true;
    _walletPrice = price;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void setCouponAmount(double amount) {
    _isUpdating = true;
    _couponAmount = amount;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void setAddiTimePrice(double price) {
    _isUpdating = true;
    _addiTimePrice = price;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  void clearPricingData() {
    _isUpdating = true;
    _dropPrice = 0.0;
    _minimumfare = 0.0;
    _maximumfare = 0.0;
    _amountresponse = "";
    _responsemessage = "";
    _platformFee = 0.0;
    _weatherPrice = 0.0;
    _walletPrice = 0.0;
    _couponAmount = 0.0;
    _addiTimePrice = 0.0;
    _isUpdating = false;
    _safeNotifyListeners();
  }

  // ✅ ADDED - Batch update for multiple pricing changes
  void updateAllPricing({
    double? dropPrice,
    double? minimumFare,
    double? maximumFare,
    String? amountResponse,
    String? responseMessage,
    double? platformFee,
    double? weatherPrice,
    double? walletPrice,
    double? couponAmount,
    double? addiTimePrice,
  }) {
    _isUpdating = true;

    if (dropPrice != null) _dropPrice = dropPrice;
    if (minimumFare != null) _minimumfare = minimumFare;
    if (maximumFare != null) _maximumfare = maximumFare;
    if (amountResponse != null) _amountresponse = amountResponse;
    if (responseMessage != null) _responsemessage = responseMessage;
    if (platformFee != null) _platformFee = platformFee;
    if (weatherPrice != null) _weatherPrice = weatherPrice;
    if (walletPrice != null) _walletPrice = walletPrice;
    if (couponAmount != null) _couponAmount = couponAmount;
    if (addiTimePrice != null) _addiTimePrice = addiTimePrice;

    _isUpdating = false;
    _safeNotifyListeners();
  }

  // ✅ ADDED - Validation helpers
  bool get hasValidPricing => _dropPrice > 0;
  bool get isWithinFareRange =>
      _dropPrice >= _minimumfare && _dropPrice <= _maximumfare;
  bool get hasPlatformFee => _platformFee > 0;
  bool get hasWeatherCharge => _weatherPrice > 0;
  bool get hasWalletDiscount => _walletPrice > 0;
  bool get hasCouponDiscount => _couponAmount > 0;
  bool get hasAdditionalTimeCharge => _addiTimePrice > 0;

  // ✅ ADDED - Price breakdown for UI display
  Map<String, double> get priceBreakdown => {
        'Trip Fare': _dropPrice,
        'Platform Fee': _platformFee,
        'Weather Charge': _weatherPrice,
        'Additional Time': _addiTimePrice,
        'Wallet Discount': -_walletPrice,
        'Coupon Discount': -_couponAmount,
      };

  // ✅ ADDED - Formatted price strings for UI
  String getFormattedPrice(double price, {String currency = ""}) {
    return "$currency${price.toStringAsFixed(2)}";
  }

  String getFormattedDropPrice({String currency = ""}) {
    return getFormattedPrice(_dropPrice, currency: currency);
  }

  String getFormattedFinalAmount({String currency = ""}) {
    return getFormattedPrice(finalAmount, currency: currency);
  }

  // ✅ ADDED - Debug helper
  void debugPrintPricing() {
    if (kDebugMode) {
      print("💰 PricingState Debug:");
      print("Drop Price: $_dropPrice");
      print("Platform Fee: $_platformFee");
      print("Weather Price: $_weatherPrice");
      print("Additional Time: $_addiTimePrice");
      print("Wallet Discount: $_walletPrice");
      print("Coupon Discount: $_couponAmount");
      print("Total Fare: $totalFare");
      print("Final Amount: $finalAmount");
      print("Amount Response: $_amountresponse");
    }
  }
}
