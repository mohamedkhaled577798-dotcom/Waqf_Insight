import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Builds a launcher icon with white background and a golden circular frame.
void main() {
  const inputPath = 'assets/images/logo.png';
  const outputPath = 'assets/images/app_icon.png';
  const canvasSize = 1024;
  const outerPadding = 20;
  const borderWidth = 34;

  final background = img.ColorRgb8(0xFF, 0xFF, 0xFF);
  final gold = img.ColorRgb8(0xD4, 0xAF, 0x37);
  final goldDark = img.ColorRgb8(0xB8, 0x96, 0x0C);

  final bytes = File(inputPath).readAsBytesSync();
  final source = img.decodeImage(bytes);
  if (source == null) {
    stderr.writeln('Could not decode $inputPath');
    exit(1);
  }

  final bounds = _contentBounds(source);
  final cropped = img.copyCrop(
    source,
    x: bounds.left,
    y: bounds.top,
    width: bounds.width,
    height: bounds.height,
  );

  final canvas = img.Image(width: canvasSize, height: canvasSize);
  img.fill(canvas, color: background);

  final center = canvasSize ~/ 2;
  final ringRadius = center - outerPadding - borderWidth ~/ 2;
  final logoDiameter = (ringRadius - borderWidth ~/ 2 - 8) * 2;

  final scale = logoDiameter / math.max(cropped.width, cropped.height);
  final resized = img.copyResize(
    cropped,
    width: (cropped.width * scale).round(),
    height: (cropped.height * scale).round(),
    interpolation: img.Interpolation.cubic,
  );

  final outerRing = ringRadius + borderWidth ~/ 2 + 2;
  final innerRing = ringRadius - borderWidth ~/ 2;
  _drawRing(
    canvas,
    cx: center,
    cy: center,
    outerRadius: outerRing,
    innerRadius: innerRing - 2,
    color: goldDark,
  );
  _drawRing(
    canvas,
    cx: center,
    cy: center,
    outerRadius: ringRadius + borderWidth ~/ 2,
    innerRadius: ringRadius - borderWidth ~/ 2,
    color: gold,
  );

  img.compositeImage(
    canvas,
    resized,
    dstX: ((canvasSize - resized.width) / 2).round(),
    dstY: ((canvasSize - resized.height) / 2).round(),
  );

  File(outputPath).writeAsBytesSync(img.encodePng(canvas));
  stdout.writeln('Generated $outputPath (${canvasSize}x$canvasSize)');
}

void _drawRing(
  img.Image image, {
  required int cx,
  required int cy,
  required int outerRadius,
  required int innerRadius,
  required img.Color color,
}) {
  final outerR2 = outerRadius * outerRadius;
  final innerR2 = innerRadius * innerRadius;

  for (var y = cy - outerRadius; y <= cy + outerRadius; y++) {
    if (y < 0 || y >= image.height) continue;
    for (var x = cx - outerRadius; x <= cx + outerRadius; x++) {
      if (x < 0 || x >= image.width) continue;
      final dx = x - cx;
      final dy = y - cy;
      final dist2 = dx * dx + dy * dy;
      if (dist2 <= outerR2 && dist2 >= innerR2) {
        image.setPixel(x, y, color);
      }
    }
  }
}

class _Bounds {
  const _Bounds({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final int left;
  final int top;
  final int width;
  final int height;
}

_Bounds _contentBounds(img.Image image) {
  var minX = image.width;
  var minY = image.height;
  var maxX = 0;
  var maxY = 0;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (_isContentPixel(image.getPixel(x, y))) {
        minX = math.min(minX, x);
        minY = math.min(minY, y);
        maxX = math.max(maxX, x);
        maxY = math.max(maxY, y);
      }
    }
  }

  if (maxX <= minX || maxY <= minY) {
    final side = math.min(image.width, image.height);
    return _Bounds(
      left: ((image.width - side) / 2).round(),
      top: ((image.height - side) / 2).round(),
      width: side,
      height: side,
    );
  }

  final width = maxX - minX + 1;
  final height = maxY - minY + 1;
  final side = math.max(width, height);
  final centerX = minX + width / 2;
  final centerY = minY + height / 2;

  return _Bounds(
    left: (centerX - side / 2).round().clamp(0, image.width - 1),
    top: (centerY - side / 2).round().clamp(0, image.height - 1),
    width: side.clamp(1, image.width),
    height: side.clamp(1, image.height),
  );
}

bool _isContentPixel(img.Pixel pixel) {
  final r = pixel.r.toInt();
  final g = pixel.g.toInt();
  final b = pixel.b.toInt();
  final luminance = (0.299 * r + 0.587 * g + 0.114 * b).round();
  return luminance > 24;
}
