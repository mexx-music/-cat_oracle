import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

// ── Quality grades ─────────────────────────────────────────────────────────────

enum ScanQualityGrade {
  excellent, // ★★★★★ proceed immediately
  good,      // ★★★★☆ proceed
  acceptable, // ★★★☆☆ proceed with warning
  poor,      // ★★☆☆☆ recommend retake, allow anyway
  retake,    // ★☆☆☆☆ please retake
}

// ── Result model ───────────────────────────────────────────────────────────────

class ScanQualityResult {
  const ScanQualityResult({
    required this.overallGrade,
    required this.backgroundScore,
    required this.lightingScore,
    required this.sharpnessScore,
    required this.handPositionScore,
    required this.palmCoverageScore,
    required this.backgroundVariance,
    required this.backgroundTexture,
    required this.overexposedFraction,
    required this.underexposedFraction,
    required this.shadowScore,
    required this.blurScore,
    required this.handCoverage,
    required this.rotationScore,
    required this.wristVisible,
    required this.fingersVisible,
    required this.overallQuality,
  });

  static const empty = ScanQualityResult(
    overallGrade: ScanQualityGrade.acceptable,
    backgroundScore: 1.0,
    lightingScore: 1.0,
    sharpnessScore: 1.0,
    handPositionScore: 1.0,
    palmCoverageScore: 1.0,
    backgroundVariance: 0.0,
    backgroundTexture: 0.0,
    overexposedFraction: 0.0,
    underexposedFraction: 0.0,
    shadowScore: 0.0,
    blurScore: 1000.0,
    handCoverage: 0.7,
    rotationScore: 1.0,
    wristVisible: true,
    fingersVisible: true,
    overallQuality: 1.0,
  );

  final ScanQualityGrade overallGrade;

  // Per-dimension scores [0, 1] — higher is better
  final double backgroundScore;
  final double lightingScore;
  final double sharpnessScore;
  final double handPositionScore;
  final double palmCoverageScore;

  // Raw debug metrics
  final double backgroundVariance;
  final double backgroundTexture;
  final double overexposedFraction;
  final double underexposedFraction;
  final double shadowScore;
  final double blurScore;
  final double handCoverage;
  final double rotationScore;
  final bool wristVisible;
  final bool fingersVisible;
  final double overallQuality;
}

// ── Assessor ───────────────────────────────────────────────────────────────────

class ScanQualityAssessor {
  ScanQualityAssessor._();

  static Future<ScanQualityResult> assess(Uint8List imageBytes) async {
    if (imageBytes.isEmpty) return ScanQualityResult.empty;
    try {
      final codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: 256,
      );
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;
      final imgW = uiImage.width;
      final imgH = uiImage.height;
      final byteData =
          await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);
      uiImage.dispose();

      if (byteData == null) return ScanQualityResult.empty;

      final raw = await compute(
        _assessQualityPixels,
        QualityInput(
          pixels: byteData.buffer.asUint8List(),
          width: imgW,
          height: imgH,
        ),
      );
      return _fromRaw(raw);
    } catch (_) {
      return ScanQualityResult.empty;
    }
  }

  static ScanQualityResult _fromRaw(Map<String, dynamic> r) {
    final bgScore = (r['backgroundScore'] as num).toDouble();
    final lightScore = (r['lightingScore'] as num).toDouble();
    final sharpScore = (r['sharpnessScore'] as num).toDouble();
    final posScore = (r['handPositionScore'] as num).toDouble();
    final covScore = (r['palmCoverageScore'] as num).toDouble();
    final overall = (r['overallQuality'] as num).toDouble();
    return ScanQualityResult(
      overallGrade: _grade(bgScore, lightScore, sharpScore, posScore, covScore),
      backgroundScore: bgScore,
      lightingScore: lightScore,
      sharpnessScore: sharpScore,
      handPositionScore: posScore,
      palmCoverageScore: covScore,
      backgroundVariance: (r['backgroundVariance'] as num).toDouble(),
      backgroundTexture: (r['backgroundTexture'] as num).toDouble(),
      overexposedFraction: (r['overexposedFraction'] as num).toDouble(),
      underexposedFraction: (r['underexposedFraction'] as num).toDouble(),
      shadowScore: (r['shadowScore'] as num).toDouble(),
      blurScore: (r['blurScore'] as num).toDouble(),
      handCoverage: (r['handCoverage'] as num).toDouble(),
      rotationScore: (r['rotationScore'] as num).toDouble(),
      wristVisible: r['wristVisible'] as bool,
      fingersVisible: r['fingersVisible'] as bool,
      overallQuality: overall,
    );
  }

  static ScanQualityGrade _grade(
    double bg, double light, double sharp, double pos, double cov,
  ) {
    final scores = [bg, light, sharp, pos, cov];
    final minScore = scores.reduce(min);
    final avgScore = scores.fold(0.0, (a, b) => a + b) / scores.length;

    if (minScore >= 0.75) return ScanQualityGrade.excellent;
    if (minScore >= 0.52) return ScanQualityGrade.good;
    if (minScore >= 0.28) return ScanQualityGrade.acceptable;
    if (avgScore >= 0.18) return ScanQualityGrade.poor;
    return ScanQualityGrade.retake;
  }
}

// ── Isolate input ──────────────────────────────────────────────────────────────

class QualityInput {
  const QualityInput({
    required this.pixels,
    required this.width,
    required this.height,
  });

  final Uint8List pixels; // RGBA, 4 bytes per pixel
  final int width;
  final int height;
}

// ── Core assessment (top-level for compute()) ──────────────────────────────────

Map<String, dynamic> _assessQualityPixels(QualityInput input) {
  final pixels = input.pixels;
  final w = input.width;
  final h = input.height;

  Map<String, dynamic> empty() => {
    'backgroundScore': 1.0,
    'lightingScore': 1.0,
    'sharpnessScore': 1.0,
    'handPositionScore': 0.5,
    'palmCoverageScore': 0.5,
    'backgroundVariance': 0.0,
    'backgroundTexture': 0.0,
    'overexposedFraction': 0.0,
    'underexposedFraction': 0.0,
    'shadowScore': 0.0,
    'blurScore': 0.0,
    'handCoverage': 0.0,
    'rotationScore': 1.0,
    'wristVisible': false,
    'fingersVisible': false,
    'overallQuality': 0.5,
  };

  if (w < 8 || h < 8 || pixels.length < w * h * 4) return empty();

  final total = w * h;

  // 1. Grayscale
  final gray = Uint8List(total);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final base = (y * w + x) * 4;
      final r = pixels[base];
      final g = pixels[base + 1];
      final b = pixels[base + 2];
      gray[y * w + x] = (r * 0.299 + g * 0.587 + b * 0.114).round();
    }
  }

  // 2. Skin-like mask: luminance in range typical for human skin/palm
  //    (too dark = shadow/background, too bright = overexposure or white bg)
  final skinMask = List<bool>.filled(total, false);
  for (int i = 0; i < total; i++) {
    final luma = gray[i];
    skinMask[i] = luma >= 40 && luma <= 230;
  }
  final skinCount = skinMask.where((v) => v).length;

  // 3. Background pixels = complement of skinMask
  final bgGray = <int>[];
  for (int i = 0; i < total; i++) {
    if (!skinMask[i]) bgGray.add(gray[i]);
  }

  // 4. Background variance & texture
  double backgroundVariance = 0.0;
  double backgroundTexture = 0.0;
  if (bgGray.length >= 10) {
    final bgMean = bgGray.fold(0.0, (s, v) => s + v) / bgGray.length;
    final bgVar = bgGray.fold(0.0, (s, v) {
          final d = v - bgMean;
          return s + d * d;
        }) /
        bgGray.length;
    backgroundVariance = sqrt(bgVar);
  }

  // Texture = mean |Laplacian| in background region
  double lapSum = 0.0;
  int lapCount = 0;
  for (int y = 1; y < h - 1; y++) {
    for (int x = 1; x < w - 1; x++) {
      final i = y * w + x;
      if (skinMask[i]) continue;
      final lap = (gray[i] * 4 -
              gray[(y - 1) * w + x] -
              gray[(y + 1) * w + x] -
              gray[y * w + (x - 1)] -
              gray[y * w + (x + 1)])
          .abs();
      lapSum += lap;
      lapCount++;
    }
  }
  if (lapCount > 0) backgroundTexture = lapSum / lapCount;

  // 5. Background score
  final varScore = (1.0 - backgroundVariance / 80.0).clamp(0.0, 1.0);
  final texScore = (1.0 - backgroundTexture / 45.0).clamp(0.0, 1.0);
  final backgroundScore = min(varScore, texScore);

  // 6. Lighting metrics
  var overCount = 0;
  var underCount = 0;
  for (int i = 0; i < total; i++) {
    final luma = gray[i];
    if (luma > 248) overCount++;
    if (luma < 12) underCount++;
  }
  final overexposedFraction = overCount / total;
  final underexposedFraction = underCount / total;

  // Shadow: dark pixels within skin region
  var shadowCount = 0;
  for (int i = 0; i < total; i++) {
    if (skinMask[i] && gray[i] < 55) shadowCount++;
  }
  final shadowFrac = skinCount > 0 ? shadowCount / skinCount : 0.0;

  final overScore = (1.0 - overexposedFraction / 0.18).clamp(0.0, 1.0);
  final underScore = (1.0 - underexposedFraction / 0.28).clamp(0.0, 1.0);
  final shadowS = (1.0 - shadowFrac / 0.45).clamp(0.0, 1.0);
  final lightingScore = (overScore + underScore + shadowS) / 3.0;

  // 7. Sharpness: Laplacian variance on full image
  double lapMean = 0.0;
  final lapVals = <double>[];
  for (int y = 1; y < h - 1; y++) {
    for (int x = 1; x < w - 1; x++) {
      final i = y * w + x;
      final lap = (gray[i] * 4 -
              gray[(y - 1) * w + x] -
              gray[(y + 1) * w + x] -
              gray[y * w + (x - 1)] -
              gray[y * w + (x + 1)])
          .abs()
          .toDouble();
      lapVals.add(lap);
      lapMean += lap;
    }
  }
  final lapN = lapVals.length;
  double blurScore = 0.0;
  if (lapN > 0) {
    lapMean /= lapN;
    final lapVar =
        lapVals.fold(0.0, (s, v) {
          final d = v - lapMean;
          return s + d * d;
        }) /
        lapN;
    blurScore = lapVar;
  }
  final sharpnessScore = (blurScore / 900.0).clamp(0.0, 1.0);

  // 8. Hand coverage & position
  final handCoverage = total > 0 ? skinCount / total : 0.0;

  // Wrist: skin pixels in bottom 20% of image
  final wristStart = (h * 0.80).round();
  var wristCount = 0;
  for (int y = wristStart; y < h; y++) {
    for (int x = 0; x < w; x++) {
      if (skinMask[y * w + x]) wristCount++;
    }
  }
  final wristVisible = wristCount > (w * h * 0.20 * 0.05);

  // Fingers: skin pixels in top 15% of image
  final fingerEnd = (h * 0.15).round();
  var fingerCount = 0;
  for (int y = 0; y < fingerEnd; y++) {
    for (int x = 0; x < w; x++) {
      if (skinMask[y * w + x]) fingerCount++;
    }
  }
  final fingersVisible = fingerCount > (w * h * 0.15 * 0.04);

  // Bounding box of skin region for rotation estimation
  var bboxLeft = w, bboxRight = 0, bboxTop = h, bboxBottom = 0;
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      if (skinMask[y * w + x]) {
        if (x < bboxLeft) bboxLeft = x;
        if (x > bboxRight) bboxRight = x;
        if (y < bboxTop) bboxTop = y;
        if (y > bboxBottom) bboxBottom = y;
      }
    }
  }
  double rotationScore = 1.0;
  if (skinCount > 0 && bboxRight > bboxLeft && bboxBottom > bboxTop) {
    final bboxW = (bboxRight - bboxLeft).toDouble();
    final bboxH = (bboxBottom - bboxTop).toDouble();
    final aspectRatio = bboxW / max(1.0, bboxH);
    // Palm should be taller than wide (aspect < 0.9) for upright hand
    rotationScore =
        aspectRatio <= 0.9
            ? 1.0
            : (1.0 - (aspectRatio - 0.9) / 0.8).clamp(0.0, 1.0);
  }

  // Coverage score: target 55–85%
  double palmCoverageScore;
  if (handCoverage >= 0.55 && handCoverage <= 0.85) {
    palmCoverageScore = 1.0;
  } else if (handCoverage < 0.55) {
    palmCoverageScore = (handCoverage / 0.55).clamp(0.0, 1.0);
  } else {
    palmCoverageScore = (1.0 - (handCoverage - 0.85) / 0.15).clamp(0.0, 1.0);
  }

  // Hand position score: coverage + wrist + fingers + rotation
  double coveragePart;
  if (handCoverage >= 0.50 && handCoverage <= 0.88) {
    coveragePart = 1.0;
  } else if (handCoverage < 0.50) {
    coveragePart = (handCoverage / 0.50).clamp(0.0, 1.0);
  } else {
    coveragePart = (1.0 - (handCoverage - 0.88) / 0.12).clamp(0.0, 1.0);
  }
  final wristPart = wristVisible ? 1.0 : 0.35;
  final fingerPart = fingersVisible ? 1.0 : 0.45;
  final handPositionScore =
      (coveragePart * 0.5 + wristPart * 0.25 + fingerPart * 0.15 + rotationScore * 0.10)
          .clamp(0.0, 1.0);

  // 9. Overall quality
  final scores = [
    backgroundScore,
    lightingScore,
    sharpnessScore,
    handPositionScore,
    palmCoverageScore,
  ];
  final overallQuality = scores.fold(0.0, (a, b) => a + b) / scores.length;

  return {
    'backgroundScore': backgroundScore,
    'lightingScore': lightingScore,
    'sharpnessScore': sharpnessScore,
    'handPositionScore': handPositionScore,
    'palmCoverageScore': palmCoverageScore,
    'backgroundVariance': backgroundVariance,
    'backgroundTexture': backgroundTexture,
    'overexposedFraction': overexposedFraction,
    'underexposedFraction': underexposedFraction,
    'shadowScore': shadowFrac,
    'blurScore': blurScore,
    'handCoverage': handCoverage,
    'rotationScore': rotationScore,
    'wristVisible': wristVisible,
    'fingersVisible': fingersVisible,
    'overallQuality': overallQuality,
  };
}

// ── Test helper ───────────────────────────────────────────────────────────────

@visibleForTesting
Map<String, dynamic> assessQualityPixelsForTest(QualityInput input) =>
    _assessQualityPixels(input);
