import 'dart:typed_data';

import 'package:cat_oracle/features/hand_scan/logic/scan_quality_assessor.dart';
import 'package:flutter_test/flutter_test.dart';

// ── helpers ───────────────────────────────────────────────────────────────────

/// Solid RGBA image filled with [r,g,b].
Uint8List _solid(int w, int h, {int r = 200, int g = 180, int b = 160}) {
  final pixels = Uint8List(w * h * 4);
  for (int i = 0; i < pixels.length; i += 4) {
    pixels[i] = r;
    pixels[i + 1] = g;
    pixels[i + 2] = b;
    pixels[i + 3] = 255;
  }
  return pixels;
}

/// Creates an image with a central "hand" region (skinColor) and outer
/// background region (bgColor). Useful for coverage/background tests.
Uint8List _handOnBackground(
  int w,
  int h, {
  required int skinR,
  required int skinG,
  required int skinB,
  required int bgR,
  required int bgG,
  required int bgB,
  double handFraction = 0.70, // fraction of image filled by hand
}) {
  final pixels = Uint8List(w * h * 4);
  final margin = ((1.0 - handFraction) / 2.0 * w).round();
  final vMargin = ((1.0 - handFraction) / 2.0 * h).round();
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final isHand = x >= margin &&
          x < w - margin &&
          y >= vMargin &&
          y < h - vMargin;
      final base = (y * w + x) * 4;
      pixels[base] = isHand ? skinR : bgR;
      pixels[base + 1] = isHand ? skinG : bgG;
      pixels[base + 2] = isHand ? skinB : bgB;
      pixels[base + 3] = 255;
    }
  }
  return pixels;
}

/// Creates an image with random noise in the background (simulates clutter).
Uint8List _clutteredBackground(int w, int h) {
  final pixels = Uint8List(w * h * 4);
  var rng = 12345; // simple LCG pseudo-random
  int next() {
    rng = (rng * 1664525 + 1013904223) & 0x7FFFFFFF;
    return rng & 0xFF;
  }

  final margin = (w * 0.25).round();
  final vMargin = (h * 0.25).round();
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final isHand = x >= margin &&
          x < w - margin &&
          y >= vMargin &&
          y < h - vMargin;
      final base = (y * w + x) * 4;
      if (isHand) {
        // Skin-like (medium brightness, warm)
        pixels[base] = 160;
        pixels[base + 1] = 130;
        pixels[base + 2] = 100;
      } else {
        // Noisy clutter background
        pixels[base] = next();
        pixels[base + 1] = next();
        pixels[base + 2] = next();
      }
      pixels[base + 3] = 255;
    }
  }
  return pixels;
}

/// Creates a blurred-looking image by making all pixels the same value (no
/// edges → Laplacian variance ≈ 0).
Uint8List _uniformGray(int w, int h, int luma) {
  final pixels = Uint8List(w * h * 4);
  for (int i = 0; i < pixels.length; i += 4) {
    pixels[i] = luma;
    pixels[i + 1] = luma;
    pixels[i + 2] = luma;
    pixels[i + 3] = 255;
  }
  return pixels;
}

/// Creates an overexposed image (most pixels near 255).
Uint8List _overexposed(int w, int h) => _uniformGray(w, h, 252);

/// Creates a partially-visible hand: skin only in the top half, no wrist area.
Uint8List _partialHand(int w, int h) {
  final pixels = Uint8List(w * h * 4);
  final halfH = h ~/ 2;
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final base = (y * w + x) * 4;
      if (y < halfH) {
        // Skin-like in top half
        pixels[base] = 160;
        pixels[base + 1] = 130;
        pixels[base + 2] = 100;
      } else {
        // Dark background in bottom half
        pixels[base] = 20;
        pixels[base + 1] = 20;
        pixels[base + 2] = 20;
      }
      pixels[base + 3] = 255;
    }
  }
  return pixels;
}

Map<String, dynamic> _assess(Uint8List pixels, int w, int h) =>
    assessQualityPixelsForTest(
      QualityInput(pixels: pixels, width: w, height: h),
    );

// ── tests ─────────────────────────────────────────────────────────────────────

void main() {
  const w = 64, h = 80;

  group('ScanQualityResult', () {
    test('empty has correct defaults', () {
      const r = ScanQualityResult.empty;
      expect(r.overallGrade, equals(ScanQualityGrade.acceptable));
      expect(r.backgroundScore, equals(1.0));
      expect(r.lightingScore, equals(1.0));
      expect(r.sharpnessScore, equals(1.0));
      expect(r.handPositionScore, equals(1.0));
      expect(r.palmCoverageScore, equals(1.0));
      expect(r.overallQuality, equals(1.0));
      expect(r.wristVisible, isTrue);
      expect(r.fingersVisible, isTrue);
    });
  });

  group('ScanQualityAssessor – pixels', () {
    test('plain white background scores excellent background quality', () {
      // White background everywhere, hand is slightly off-white in centre
      final pixels = _handOnBackground(
        w, h,
        skinR: 180, skinG: 150, skinB: 120,
        bgR: 252, bgG: 252, bgB: 252,
      );
      final r = _assess(pixels, w, h);
      // White bg is uniform → low variance, low texture
      final bgScore = (r['backgroundScore'] as num).toDouble();
      // White pixels (>230) are NOT in skinMask, so they form the background.
      // A uniform white background should have near-zero variance.
      expect(bgScore, greaterThan(0.5),
          reason: 'plain white background should score well');
      expect((r['backgroundVariance'] as num).toDouble(), lessThan(30.0));
    });

    test('plain black background scores excellent background quality', () {
      final pixels = _handOnBackground(
        w, h,
        skinR: 150, skinG: 120, skinB: 90,
        bgR: 8, bgG: 8, bgB: 8,
      );
      final r = _assess(pixels, w, h);
      final bgScore = (r['backgroundScore'] as num).toDouble();
      expect(bgScore, greaterThan(0.5),
          reason: 'plain black background should score well');
      expect((r['backgroundVariance'] as num).toDouble(), lessThan(20.0));
    });

    test('cluttered background scores poor background quality', () {
      final pixels = _clutteredBackground(w, h);
      final r = _assess(pixels, w, h);
      final bgScore = (r['backgroundScore'] as num).toDouble();
      // Noisy background → high variance / high texture → low background score
      expect(bgScore, lessThan(0.6),
          reason: 'cluttered background should score poorly');
    });

    test('dark uniform background scores well', () {
      // Dark but uniform background → still low variance
      final pixels = _handOnBackground(
        w, h,
        skinR: 150, skinG: 120, skinB: 90,
        bgR: 25, bgG: 25, bgB: 25,
      );
      final r = _assess(pixels, w, h);
      final bgScore = (r['backgroundScore'] as num).toDouble();
      expect(bgScore, greaterThan(0.5));
    });

    test('blurred image scores low sharpness', () {
      // Uniform gray = Laplacian ≈ 0 → blur score near 0
      final pixels = _uniformGray(w, h, 120);
      final r = _assess(pixels, w, h);
      final sharpScore = (r['sharpnessScore'] as num).toDouble();
      expect(sharpScore, lessThan(0.05),
          reason: 'uniform image has near-zero Laplacian variance');
      expect((r['blurScore'] as num).toDouble(), lessThan(1.0));
    });

    test('partially visible hand has low hand position score', () {
      final pixels = _partialHand(w, h);
      final r = _assess(pixels, w, h);
      // Wrist should not be visible (bottom 20% is dark)
      expect(r['wristVisible'], isFalse,
          reason: 'no skin in bottom 20% → wrist not visible');
      final posScore = (r['handPositionScore'] as num).toDouble();
      expect(posScore, lessThan(0.80),
          reason: 'missing wrist reduces hand position score');
    });

    test('overexposed image scores low lighting', () {
      final pixels = _overexposed(w, h);
      final r = _assess(pixels, w, h);
      final lightScore = (r['lightingScore'] as num).toDouble();
      final overFrac = (r['overexposedFraction'] as num).toDouble();
      // All pixels at luma 252 → well above the 248 overexposure threshold
      expect(overFrac, greaterThan(0.5),
          reason: 'most pixels above 248 threshold');
      // lightingScore averages overScore + underScore + shadowScore;
      // overScore is 0 (fully overexposed), so the average is reduced below 0.75
      expect(lightScore, lessThan(0.75),
          reason: 'heavy overexposure should noticeably reduce lighting score');
    });

    test('result map contains all required debug keys', () {
      final r = _assess(_solid(w, h), w, h);
      for (final key in [
        'backgroundScore',
        'lightingScore',
        'sharpnessScore',
        'handPositionScore',
        'palmCoverageScore',
        'backgroundVariance',
        'backgroundTexture',
        'overexposedFraction',
        'underexposedFraction',
        'shadowScore',
        'blurScore',
        'handCoverage',
        'rotationScore',
        'wristVisible',
        'fingersVisible',
        'overallQuality',
      ]) {
        expect(r.containsKey(key), isTrue, reason: 'missing key: $key');
      }
    });

    test('all scores are clamped to [0, 1]', () {
      for (final pixels in [
        _solid(w, h),
        _uniformGray(w, h, 252),
        _uniformGray(w, h, 5),
        _clutteredBackground(w, h),
        _partialHand(w, h),
      ]) {
        final r = _assess(pixels, w, h);
        for (final key in [
          'backgroundScore',
          'lightingScore',
          'sharpnessScore',
          'handPositionScore',
          'palmCoverageScore',
          'overallQuality',
        ]) {
          final v = (r[key] as num).toDouble();
          expect(v, inInclusiveRange(0.0, 1.0),
              reason: '$key out of range: $v');
        }
      }
    });

    test('too-small image returns empty result without crashing', () {
      final r = _assess(Uint8List(0), 0, 0);
      expect((r['overallQuality'] as num).toDouble(), greaterThanOrEqualTo(0.0));
    });
  });

  group('ScanQualityGrade ordering', () {
    test('grade values are ordered correctly via enum index', () {
      expect(
        ScanQualityGrade.excellent.index <
            ScanQualityGrade.good.index,
        isTrue,
      );
      expect(
        ScanQualityGrade.good.index <
            ScanQualityGrade.acceptable.index,
        isTrue,
      );
      expect(
        ScanQualityGrade.acceptable.index <
            ScanQualityGrade.poor.index,
        isTrue,
      );
      expect(
        ScanQualityGrade.poor.index <
            ScanQualityGrade.retake.index,
        isTrue,
      );
    });
  });
}
