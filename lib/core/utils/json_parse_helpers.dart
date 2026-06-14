int parseJsonInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}

double parseJsonDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? 0;
}

DateTime? parseJsonDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
