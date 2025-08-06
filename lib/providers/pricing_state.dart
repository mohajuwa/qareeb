import 'package:flutter/foundation.dart';

class PricingState extends ChangeNotifier {
  double _dropPrice = 0.0;
  double _minimumFare = 0.0;
  double _maximumFare = 0.0;
  String _amountResponse = "";
  String _responseMessage = "";
  String _globalCurrency = "";
  double _priceYourFare = 0.0;
  double _walletAmount = 0.00;

  // Getters
  double get dropPrice => _dropPrice;
  double get minimumFare => _minimumFare;
  double get maximumFare => _maximumFare;
  String get amountResponse => _amountResponse;
  String get responseMessage => _responseMessage;
  String get globalCurrency => _globalCurrency;
  double get priceYourFare => _priceYourFare;
  double get walletAmount => _walletAmount;

  // Setters
  void setDropPrice(double price) {
    _dropPrice = price;
    notifyListeners();
  }

  void setFareRange(double min, double max) {
    _minimumFare = min;
    _maximumFare = max;
    notifyListeners();
  }

  void setAmountResponse(String response) {
    _amountResponse = response;
    notifyListeners();
  }

  void setResponseMessage(String message) {
    _responseMessage = message;
    notifyListeners();
  }

  void setGlobalCurrency(String currency) {
    _globalCurrency = currency;
    notifyListeners();
  }

  void setPriceYourFare(double price) {
    _priceYourFare = price;
    notifyListeners();
  }

  void setWalletAmount(double amount) {
    _walletAmount = amount;
    notifyListeners();
  }

  void clearPricingData() {
    _dropPrice = 0.0;
    _minimumFare = 0.0;
    _maximumFare = 0.0;
    _amountResponse = "";
    _responseMessage = "";
    _priceYourFare = 0.0;
    // Don't clear currency and wallet as they persist
    notifyListeners();
  }
}
