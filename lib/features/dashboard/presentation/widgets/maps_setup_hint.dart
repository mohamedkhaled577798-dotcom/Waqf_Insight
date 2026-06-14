import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shown when Google Maps may not render (missing native API key).
class MapsSetupHint extends StatelessWidget {
  const MapsSetupHint({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.errorContainer.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(compact ? 10 : 14),
      child: Padding(
        padding: EdgeInsets.all(compact ? 10 : 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.map_outlined, color: colorScheme.error, size: compact ? 20 : 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الخريطة تحتاج Google Maps API Key',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 12 : 13,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Android: أضف GOOGLE_MAPS_API_KEY في android/local.properties\n'
                      'iOS: عدّل GMSApiKey في ios/Runner/Info.plist\n'
                      'فعّل Maps SDK for Android/iOS في Google Cloud Console',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        height: 1.45,
                        color: colorScheme.onErrorContainer.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
