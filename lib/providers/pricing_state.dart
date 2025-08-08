import 'package:flutter/foundation.dart';
class PricingState extends ChangeNotifier {

  double _dropPrice = 0.0; // FIXED: Use dropPrice instead of dropprice

  double _minimumfare = 0.0;

  double _maximumfare = 0.0;

  String _amountresponse = "";

  String _responsemessage = "";



  // Getters - FIXED

  double get dropPrice => _dropPrice; // FIXED NAME

  double get minimumfare => _minimumfare;

  double get maximumfare => _maximumfare;

  String get amountresponse => _amountresponse;

  String get responsemessage => _responsemessage;



  // ADD THESE METHODS:

  void updatePricing({

    required double dropPrice,

    required double minimumFare,

    required double maximumFare,

    String amountResponse = "",

    String responseMessage = "",

  }) {

    _dropPrice = dropPrice;

    _minimumfare = minimumFare;

    _maximumfare = maximumFare;

    _amountresponse = amountResponse;

    _responsemessage = responseMessage;

    notifyListeners();

  }



  void updateFromCalculateResult(Map<String, dynamic> data) {

    if (data['Result'] == true) {

      _dropPrice = double.tryParse(data['drop_price'].toString()) ?? 0.0;

      _minimumfare = double.tryParse(data['minimum_fare'].toString()) ?? 0.0;

      _maximumfare = double.tryParse(data['maximum_fare'].toString()) ?? 0.0;

      _amountresponse = data['amount_response']?.toString() ?? "";

      _responsemessage = data['response_message']?.toString() ?? "";

      notifyListeners();

    }

  }



  void clearPricingData() {

    _dropPrice = 0.0;

    _minimumfare = 0.0;

    _maximumfare = 0.0;

    _amountresponse = "";

    _responsemessage = "";

    notifyListeners();

  }

}



// 5. FIX: Update LocationState - ADD removeDropLocation method

