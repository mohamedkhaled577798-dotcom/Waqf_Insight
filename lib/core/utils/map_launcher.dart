import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class MapLauncher {
  MapLauncher._();

  static Future<void> openDirections({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final encodedLabel = Uri.encodeComponent(label ?? '$latitude,$longitude');

    if (!kIsWeb && Platform.isIOS) {
      final appleMaps = Uri.parse(
        'http://maps.apple.com/?daddr=$latitude,$longitude&q=$encodedLabel',
      );
      if (await canLaunchUrl(appleMaps)) {
        await launchUrl(appleMaps, mode: LaunchMode.externalApplication);
        return;
      }
    }

    if (!kIsWeb && Platform.isAndroid) {
      final googleNav = Uri.parse('google.navigation:q=$latitude,$longitude');
      if (await canLaunchUrl(googleNav)) {
        await launchUrl(googleNav, mode: LaunchMode.externalApplication);
        return;
      }
    }

    final googleMaps = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );
    await launchUrl(googleMaps, mode: LaunchMode.externalApplication);
  }

  static Future<void> openLocation({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final encodedLabel = Uri.encodeComponent(label ?? '$latitude,$longitude');

    if (!kIsWeb && Platform.isIOS) {
      final appleMaps = Uri.parse(
        'http://maps.apple.com/?ll=$latitude,$longitude&q=$encodedLabel',
      );
      if (await canLaunchUrl(appleMaps)) {
        await launchUrl(appleMaps, mode: LaunchMode.externalApplication);
        return;
      }
    }

    final googleMaps = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    await launchUrl(googleMaps, mode: LaunchMode.externalApplication);
  }
}
