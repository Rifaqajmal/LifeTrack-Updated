/// Number formatting helpers for stat tiles ("1.24B", "58,003").
class NumberFormatter {
  NumberFormatter._();

  /// 58003 -> "58,003"
  static String grouped(int n) {
    final digits = n.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return n < 0 ? '-$buffer' : buffer.toString();
  }

  /// 1243000000 -> "1.24B", 318000000 -> "318M", 24500000 -> "24.5M",
  /// anything below one million is shown grouped ("58,003").
  static String compact(int n) {
    final v = n.abs();
    if (v >= 999500000) return '${_trim(n / 1e9, 2)}B';
    if (v >= 100000000) return '${(n / 1e6).round()}M';
    if (v >= 1000000) return '${_trim(n / 1e6, 1)}M';
    return grouped(n);
  }

  static String _trim(double value, int decimals) {
    var s = value.toStringAsFixed(decimals);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '');
      s = s.replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }
}
