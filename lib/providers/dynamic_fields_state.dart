import 'package:flutter/foundation.dart';
import 'package:qareeb/app_screen/pickup_drop_point.dart'; // For DynamicWidget

class DynamicFieldsState extends ChangeNotifier {
  List<DynamicWidget> _textFieldList = [];

  List<DynamicWidget> get textFieldList => _textFieldList;

  void addTextField() {
    _textFieldList.add(DynamicWidget());
    notifyListeners();
  }

  void removeTextField(int index) {
    if (index < _textFieldList.length) {
      _textFieldList[index].destinationcontroller.dispose();
      _textFieldList.removeAt(index);
      notifyListeners();
    }
  }

  void clearAllFields() {
    for (var field in _textFieldList) {
      field.destinationcontroller.dispose();
    }
    _textFieldList.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    clearAllFields();
    super.dispose();
  }
}
