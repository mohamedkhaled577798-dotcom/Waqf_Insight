String formatIraqiCurrency(num amount) {
  if (amount >= 1000000000) {
    return '${(amount / 1000000000).toStringAsFixed(1)} مليار';
  }
  if (amount >= 1000000) {
    return '${(amount / 1000000).toStringAsFixed(1)} مليون';
  }
  if (amount >= 1000) {
    return '${(amount / 1000).toStringAsFixed(0)} ألف';
  }
  return amount.toStringAsFixed(0);
}

String formatCount(num value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return value.toStringAsFixed(value is double ? 1 : 0);
}

String formatPercent(double value) => '${value.toStringAsFixed(1)}%';
