import 'package:flutter/material.dart';

String formatRelativeTimeAr(DateTime dateTime) {
  final local = dateTime.toLocal();
  final now = DateTime.now();
  final diff = now.difference(local);

  if (diff.inSeconds < 60) return 'الآن';
  if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
  if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
  if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';

  return '${local.day}/${local.month}/${local.year} '
      '${local.hour.toString().padLeft(2, '0')}:'
      '${local.minute.toString().padLeft(2, '0')}';
}

IconData activityActionIcon(String action) {
  final key = action.toLowerCase();
  if (key.contains('create')) return Icons.add_circle_outline_rounded;
  if (key.contains('update')) return Icons.edit_rounded;
  if (key.contains('delete')) return Icons.delete_outline_rounded;
  if (key.contains('login')) return Icons.login_rounded;
  if (key.contains('logout')) return Icons.logout_rounded;
  if (key.contains('approve')) return Icons.check_circle_outline_rounded;
  if (key.contains('reject') || key.contains('cancel')) {
    return Icons.cancel_outlined;
  }
  return Icons.history_rounded;
}

Color activityActionColor(String action, ColorScheme scheme) {
  final key = action.toLowerCase();
  if (key.contains('create')) return scheme.primary;
  if (key.contains('update')) return const Color(0xFF1565C0);
  if (key.contains('delete') || key.contains('reject')) return scheme.error;
  if (key.contains('approve') || key.contains('complete')) {
    return Colors.green.shade700;
  }
  if (key.contains('login')) return const Color(0xFF6A1B9A);
  return scheme.tertiary;
}
