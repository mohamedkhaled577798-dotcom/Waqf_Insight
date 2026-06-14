import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactLauncher {
  ContactLauncher._();

  static String _normalizePhoneForWhatsApp(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      throw Exception('رقم الهاتف غير متوفر');
    }
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.startsWith('0')) digits = '964${digits.substring(1)}';
    if (!digits.startsWith('964') && digits.length <= 11) {
      digits = '964$digits';
    }
    return digits;
  }

  static Future<void> _launchWebUri(Uri uri) async {
    if (kIsWeb) {
      final launched = await launchUrl(uri, webOnlyWindowName: '_blank');
      if (!launched) {
        throw Exception('تعذّر فتح الرابط في المتصفح');
      }
      return;
    }

    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    if (await launchUrl(uri, mode: LaunchMode.platformDefault)) return;
    throw Exception('تعذّر فتح الرابط — جرّب نسخه يدوياً: $uri');
  }

  static Future<void> openWhatsApp(
    String phone, {
    String? message,
  }) async {
    final normalized = _normalizePhoneForWhatsApp(phone);
    final query = message != null ? '?text=${Uri.encodeComponent(message)}' : '';
    final uri = Uri.parse('https://wa.me/$normalized$query');
    await _launchWebUri(uri);
  }

  static Future<void> openEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    final params = <String, String>{};
    if (subject != null) params['subject'] = subject;
    if (body != null) params['body'] = body;
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: params.isEmpty ? null : params,
    );

    if (kIsWeb) {
      await _launchWebUri(uri);
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!launched) {
      throw Exception('تعذّر فتح تطبيق البريد');
    }
  }

  static Future<void> callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    throw Exception('تعذّر إجراء المكالمة من هذا الجهاز');
  }
}
