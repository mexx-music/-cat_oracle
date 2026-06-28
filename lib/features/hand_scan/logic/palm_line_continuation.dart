import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Offset;

// ── Result model ──────────────────────────────────────────────────────────────

/// Result of an attempted life line continuation pass.
///
/// [extendedPath] holds the combined original + extension points.
/// When [wasExtended] is false [extendedPath] equals the input path unchanged.
/// The last [extensionPointCount] elements in [extendedPath] are the new
/// extension points; the rest are the original path.
class PalmLineContinuationResult {
  const PalmLineContinuationResult({
    required this.extendedPath,
    required this.wasExtended,
    required this.extensionPointCount,
    required this.oldEndY,
    required this.newEndY,
    required this.extensionArcLength,
    required this.extensionConfidence,
    this.skipReason,
  });

  final List<Offset> extendedPath;
  final bool wasExtended;
  final int extensionPointCount;

  /// Normalised Y of the original path's last point.
  final double oldEndY;

  /// Normalised Y after extension (equals [oldEndY] when not extended).
  final double newEndY;

  /// Additional arc length in [0,1] space contributed by the extension.
  final double extensionArcLength;

  /// Confidence of the extension in [0,1]; 0.0 when not extended.
  final double extensionConfidence;

  /// Why no extension was produced; null when extension succeeded.
  final String? skipReason;

  static const none = PalmLineContinuationResult(
    extendedPath: [],
    wasExtended: false,
    extensionPointCount: 0,
    oldEndY: 0.0,
    newEndY: 0.0,
    extensionArcLength: 0.0,
    extensionConfidence: 0.0,
    skipReason: 'No input',
  );

  List<Offset> get originalPath =>
      wasExtended && extensionPointCount > 0
          ? extendedPath.sublist(
              0, (extendedPath.length - extensionPointCount).clamp(0, extendedPath.length),
            )
          : extendedPath;

  List<Offset> get extensionPoints =>
      wasExtended && extensionPointCount > 0
          ? extendedPath.sublist(
              (extendedPath.length - extensionPointCount).clamp(0, extendedPath.length),
            )
          : const [];
}

// ── Continuation tracker ──────────────────────────────────────────────────────

class PalmLineContinuation {
  PalmLineContinuation._();

  /// Attempts to extend [lifeLinePath] beyond its current endpoint by
  /// following weak dark ridges in a downward corridor (x±0.08, y+0.25).
  ///
  /// Only extends when real image data supports it.  Marks extension with a
  /// lower confidence score so callers can decide whether to trust it.
  static Future<PalmLineContinuationResult> extend(
    Uint8List imageBytes,
    List<Offset> lifeLinePath,
  ) async {
    if (lifeLinePath.length < 3) {
      return PalmLineContinuationResult(
        extendedPath: lifeLinePath,
        wasExtended: false,
        extensionPointCount: 0,
        oldEndY: lifeLinePath.isNotEmpty ? lifeLinePath.last.dy : 0.0,
        newEndY: lifeLinePath.isNotEmpty ? lifeLinePath.last.dy : 0.0,
        extensionArcLength: 0.0,
        extensionConfidence: 0.0,
        skipReason: 'Path too short (< 3 points)',
      );
    }

    try {
      final codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: 512,
      );
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;
      final imgW = uiImage.width;
      final imgH = uiImage.height;
      final byteData = await uiImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      uiImage.dispose();

      if (byteData == null) {
        return PalmLineContinuationResult(
          extendedPath: lifeLinePath,
          wasExtended: false,
          extensionPointCount: 0,
          oldEndY: lifeLinePath.last.dy,
          newEndY: lifeLinePath.last.dy,
          extensionArcLength: 0.0,
          extensionConfidence: 0.0,
          skipReason: 'Could not decode image',
        );
      }

      final raw = await compute(
        _runContinuation,
        _ContInput(
          pixels: byteData.buffer.asUint8List(),
          imgW: imgW,
          imgH: imgH,
          lifeLinePath: lifeLinePath.map((p) => [p.dx, p.dy]).toList(),
        ),
      );

      return _buildResult(raw);
    } catch (e) {
      return PalmLineContinuationResult(
        extendedPath: lifeLinePath,
        wasExtended: false,
        extensionPointCount: 0,
        oldEndY: lifeLinePath.last.dy,
        newEndY: lifeLinePath.last.dy,
        extensionArcLength: 0.0,
        extensionConfidence: 0.0,
        skipReason: 'Error: $e',
      );
    }
  }

  static PalmLineContinuationResult _buildResult(Map<String, dynamic> raw) {
    final rawPath = raw['extendedPath'] as List<dynamic>;
    final pts = rawPath.map((p) {
      final l = p as List;
      return Offset(
        (l[0] as num).toDouble(),
        (l[1] as num).toDouble(),
      );
    }).toList();

    return PalmLineContinuationResult(
      extendedPath: pts,
      wasExtended: raw['wasExtended'] as bool,
      extensionPointCount: raw['extensionPointCount'] as int,
      oldEndY: (raw['oldEndY'] as num).toDouble(),
      newEndY: (raw['newEndY'] as num).toDouble(),
      extensionArcLength: (raw['extensionArcLength'] as num).toDouble(),
      extensionConfidence: (raw['extensionConfidence'] as num).toDouble(),
      skipReason: raw['skipReason'] as String?,
    );
  }
}

// ── Isolate input ─────────────────────────────────────────────────────────────

class _ContInput {
  const _ContInput({
    required this.pixels,
    required this.imgW,
    required this.imgH,
    required this.lifeLinePath,
  });

  final Uint8List pixels;
  final int imgW;
  final int imgH;
  final List<List<double>> lifeLinePath;
}

// ── Core continuation logic (top-level for compute()) ─────────────────────────

Map<String, dynamic> _runContinuation(_ContInput input) {
  final pixels = input.pixels;
  final imgW = input.imgW;
  final imgH = input.imgH;
  final path = input.lifeLinePath;

  // 1. Grayscale
  final gray = Uint8List(imgW * imgH);
  for (int y = 0; y < imgH; y++) {
    for (int x = 0; x < imgW; x++) {
      final base = (y * imgW + x) * 4;
      gray[y * imgW + x] = (
        pixels[base] * 0.299 +
        pixels[base + 1] * 0.587 +
        pixels[base + 2] * 0.114
      ).round();
    }
  }

  // 2. Histogram stretch — same margin as extractor
  final margin = max(2, min(imgW, imgH) ~/ 12);
  int gMin = 255, gMax = 0;
  for (int y = margin; y < imgH - margin; y++) {
    for (int x = margin; x < imgW - margin; x++) {
      final v = gray[y * imgW + x];
      if (v < gMin) gMin = v;
      if (v > gMax) gMax = v;
    }
  }
  final range = (gMax - gMin).clamp(1, 255);
  final enhanced = Uint8List(imgW * imgH);
  for (int i = 0; i < imgW * imgH; i++) {
    enhanced[i] = ((gray[i] - gMin) * 255 ~/ range).clamp(0, 255);
  }

  // 3. Box blur 3×3
  final blurred = Uint8List(imgW * imgH);
  for (int y = 1; y < imgH - 1; y++) {
    for (int x = 1; x < imgW - 1; x++) {
      blurred[y * imgW + x] = (
            enhanced[(y - 1) * imgW + x - 1] +
            enhanced[(y - 1) * imgW + x] +
            enhanced[(y - 1) * imgW + x + 1] +
            enhanced[y * imgW + x - 1] +
            enhanced[y * imgW + x] +
            enhanced[y * imgW + x + 1] +
            enhanced[(y + 1) * imgW + x - 1] +
            enhanced[(y + 1) * imgW + x] +
            enhanced[(y + 1) * imgW + x + 1]
          ) ~/
          9;
    }
  }
  for (int y = 0; y < imgH; y++) {
    blurred[y * imgW] = enhanced[y * imgW];
    blurred[y * imgW + imgW - 1] = enhanced[y * imgW + imgW - 1];
  }
  for (int x = 0; x < imgW; x++) {
    blurred[x] = enhanced[x];
    blurred[(imgH - 1) * imgW + x] = enhanced[(imgH - 1) * imgW + x];
  }

  // 4. End point in pixel space
  final endNorm = path.last;
  final endPxX = endNorm[0] * imgW;
  final endPxY = endNorm[1] * imgH;

  // 5. Direction estimate from last N path points
  final nBack = min(6, path.length - 1);
  final prevNorm = path[path.length - 1 - nBack];
  final ddx = endNorm[0] - prevNorm[0];
  final ddy = endNorm[1] - prevNorm[1];
  final dlen = sqrt(ddx * ddx + ddy * ddy);

  // Default: slightly left + strongly downward (life line arcs to wrist)
  double dirX = dlen > 0.002 ? ddx / dlen : -0.07;
  double dirY = dlen > 0.002 ? ddy / dlen : 0.998;
  final dl0 = sqrt(dirX * dirX + dirY * dirY);
  if (dl0 > 0) {
    dirX /= dl0;
    dirY /= dl0;
  }

  // 6. Corridor bounds (normalised [0,1] original image space)
  const corridorHalfX = 0.08;
  const corridorYSpan = 0.25;
  final corrMinNX = (endNorm[0] - corridorHalfX).clamp(0.0, 1.0);
  final corrMaxNX = (endNorm[0] + corridorHalfX).clamp(0.0, 1.0);
  final corrMaxNY = (endNorm[1] + corridorYSpan).clamp(0.0, 1.0);

  // 7. Ridge following
  //
  // We step forward in the estimated direction and search a local window for
  // the darkest ridge-like pixel (darker than its perpendicular neighbours).
  // Gaps up to [searchR] pixels wide are automatically bridged.
  const stepPx = 6;       // advance per step in pixels
  const searchR = 14;     // search radius in pixels
  const minRidgeness = 7; // minimum perpendicular contrast
  const maxSteps = 22;    // max extension steps

  final extensions = <List<double>>[];
  int strongSteps = 0;
  double curX = endPxX, curY = endPxY;
  String? skipReason;

  for (int step = 0; step < maxSteps; step++) {
    final projX = curX + dirX * stepPx;
    final projY = curY + dirY * stepPx;

    // Corridor boundary check
    final projNX = projX / imgW;
    final projNY = projY / imgH;
    if (projNX < corrMinNX || projNX > corrMaxNX) {
      skipReason ??= 'Left corridor (x)';
      break;
    }
    if (projNY > corrMaxNY) {
      skipReason ??= 'Reached corridor end (y)';
      break;
    }
    if (projX < 0 || projX >= imgW || projY < 0 || projY >= imgH) {
      skipReason ??= 'Out of image bounds';
      break;
    }

    // Search window
    int bestPx = -1, bestPy = -1;
    int bestR = minRidgeness;

    final sx = max(0, (projX - searchR).floor());
    final ex = min(imgW - 1, (projX + searchR).ceil());
    final sy = max(0, (projY - searchR).floor());
    final ey = min(imgH - 1, (projY + searchR).ceil());

    for (int ny = sy; ny <= ey; ny++) {
      for (int nx = sx; nx <= ex; nx++) {
        final nnX = nx / imgW;
        final nnY = ny / imgH;
        if (nnX < corrMinNX || nnX > corrMaxNX) continue;
        // Only accept points below the original endpoint
        if (nnY < endNorm[1] - 0.01 || nnY > corrMaxNY) continue;
        // Must be moving forward, not backward
        if ((nx - curX) * dirX + (ny - curY) * dirY <= 0) continue;

        final r = _ridgeness(blurred, nx, ny, imgW, imgH, dirX, dirY);
        if (r > bestR) {
          bestR = r;
          bestPx = nx;
          bestPy = ny;
        }
      }
    }

    if (bestPx == -1) {
      skipReason ??= 'No ridge at step $step';
      break;
    }

    extensions.add([bestPx / imgW, bestPy / imgH]);
    if (bestR >= minRidgeness * 2) strongSteps++;

    // Smooth direction update (blend old and new)
    final ndx = bestPx - curX;
    final ndy = bestPy - curY;
    final nlen = sqrt(ndx * ndx + ndy * ndy);
    if (nlen > 0) {
      dirX = dirX * 0.6 + (ndx / nlen) * 0.4;
      dirY = dirY * 0.6 + (ndy / nlen) * 0.4;
      final dl2 = sqrt(dirX * dirX + dirY * dirY);
      dirX /= dl2;
      dirY /= dl2;
    }
    curX = bestPx.toDouble();
    curY = bestPy.toDouble();
  }

  // 8. Arc length of extension
  double extArc = 0.0;
  if (extensions.isNotEmpty) {
    double ax = extensions.first[0] - endNorm[0];
    double ay = extensions.first[1] - endNorm[1];
    extArc += sqrt(ax * ax + ay * ay);
    for (int i = 1; i < extensions.length; i++) {
      final bx = extensions[i][0] - extensions[i - 1][0];
      final by = extensions[i][1] - extensions[i - 1][1];
      extArc += sqrt(bx * bx + by * by);
    }
  }

  // 9. Confidence: fraction of steps where ridgeness was strong
  final extConf = extensions.isEmpty
      ? 0.0
      : (strongSteps / extensions.length).clamp(0.0, 1.0);

  // Reject extension if confidence too low (would be fake extension)
  if (extensions.isNotEmpty && extConf < 0.25) {
    return {
      'extendedPath': path,
      'wasExtended': false,
      'extensionPointCount': 0,
      'oldEndY': endNorm[1],
      'newEndY': endNorm[1],
      'extensionArcLength': 0.0,
      'extensionConfidence': extConf,
      'skipReason': 'Low confidence (${(extConf * 100).round()} %)',
    };
  }

  final fullPath = [...path, ...extensions];
  final newEndY =
      extensions.isNotEmpty ? extensions.last[1] : endNorm[1];

  return {
    'extendedPath': fullPath,
    'wasExtended': extensions.isNotEmpty,
    'extensionPointCount': extensions.length,
    'oldEndY': endNorm[1],
    'newEndY': newEndY,
    'extensionArcLength': extArc,
    'extensionConfidence': extConf,
    'skipReason': extensions.isEmpty ? (skipReason ?? 'No ridge found') : null,
  };
}

// ── Ridge detector ────────────────────────────────────────────────────────────

/// Measures how much darker [x,y] is compared to its neighbours perpendicular
/// to the travel direction.  Returns 0..255; higher = stronger ridge.
int _ridgeness(
  Uint8List img,
  int x,
  int y,
  int w,
  int h,
  double dirX,
  double dirY,
) {
  final perpX = -dirY;
  final perpY = dirX;

  final centerVal = img[y * w + x];
  int bgSum = 0, bgCount = 0;

  for (int r = 2; r <= 7; r++) {
    for (final sign in [-1, 1]) {
      final nx = (x + perpX * r * sign).round();
      final ny = (y + perpY * r * sign).round();
      if (nx >= 0 && nx < w && ny >= 0 && ny < h) {
        bgSum += img[ny * w + nx];
        bgCount++;
      }
    }
  }

  if (bgCount == 0) return 0;
  return ((bgSum ~/ bgCount) - centerVal).clamp(0, 255);
}

// ── Test helper ───────────────────────────────────────────────────────────────

@visibleForTesting
Map<String, dynamic> runContinuationForTest(
  Uint8List pixels,
  int imgW,
  int imgH,
  List<List<double>> lifeLinePath,
) =>
    _runContinuation(
      _ContInput(
        pixels: pixels,
        imgW: imgW,
        imgH: imgH,
        lifeLinePath: lifeLinePath,
      ),
    );
