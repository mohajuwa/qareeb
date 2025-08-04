// lib/common_code/type_utils.dart
// Create this file to centralize safe type parsing functions

/// Safe parsing functions to prevent type conversion errors
/// These functions handle int, double, string, and null values safely

/// Safely converts any value to int
/// Returns 0 if conversion fails or value is null
int safeParseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

double safeParseDouble(dynamic value) {
  if (value == null) return 0.0;

  if (value is double) return value;

  if (value is int) return value.toDouble();

  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }

  return 0.0;
}

/// Returns empty string if value is null
String safeParseString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

/// Safely converts any value to bool
/// Returns false if conversion fails or value is null
bool safeParseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is String) {
    return value.toLowerCase() == 'true' || value == '1';
  }
  if (value is int) {
    return value == 1;
  }
  return false;
}
