import 'dart:typed_data';

import 'package:cat_oracle/features/hand_scan/logic/palm_line_classifier.dart';
import 'package:cat_oracle/features/hand_scan/logic/palm_line_extractor.dart';
import 'package:cat_oracle/features/hand_scan/models/scanned_hand.dart';
import 'package:flutter_test/flutter_test.dart';

// ── helpers ───────────────────────────────────────────────────────────────────

/// Creates a w×h RGBA image filled with [r,g,b] (fully opaque).
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

/// Paints a 2-px-wide dark horizontal band at [lineY] spanning x = [x0..x1].
void _darkLine(Uint8List pixels, int w, int lineY, int x0, int x1) {
  for (int x = x0; x <= x1; x++) {
    for (int dy = 0; dy <= 1; dy++) {
      final base = ((lineY + dy) * w + x) * 4;
      pixels[base] = 50;
      pixels[base + 1] = 40;
      pixels[base + 2] = 35;
      pixels[base + 3] = 255;
    }
  }
}

// ── tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('PalmLineExtractionResult', () {
    test('empty has correct defaults', () {
      const r = PalmLineExtractionResult.empty;
      expect(r.edgePointCount, equals(0));
      expect(r.candidatePaths, isEmpty);
      expect(r.edgePoints, isEmpty);
      expect(r.confidence, equals(0.0));
      expect(r.hasRealData, isFalse);
      expect(r.hasRoi, isFalse);
      expect(r.candidatePathCount, equals(0));
    });

    test('hasRealData is true when edgePointCount > 0', () {
      const r = PalmLineExtractionResult(
        edgePoints: [],
        candidatePaths: [],
        confidence: 0.5,
        imageWidth: 100,
        imageHeight: 100,
        edgePointCount: 42,
      );
      expect(r.hasRealData, isTrue);
    });

    test('hasRoi reflects whether ROI fields are set', () {
      const noRoi = PalmLineExtractionResult(
        edgePoints: [],
        candidatePaths: [],
        confidence: 0.0,
        imageWidth: 100,
        imageHeight: 100,
        edgePointCount: 0,
      );
      expect(noRoi.hasRoi, isFalse);

      const withRoi = PalmLineExtractionResult(
        edgePoints: [],
        candidatePaths: [],
        confidence: 0.0,
        imageWidth: 100,
        imageHeight: 100,
        edgePointCount: 0,
        roiLeft: 10,
        roiTop: 10,
        roiRight: 90,
        roiBottom: 90,
        normalizedWidth: 512,
        normalizedHeight: 512,
      );
      expect(withRoi.hasRoi, isTrue);
    });

    test('candidatePathCount mirrors candidatePaths.length', () {
      const r = PalmLineExtractionResult(
        edgePoints: [],
        candidatePaths: [[], []],
        confidence: 0.0,
        imageWidth: 100,
        imageHeight: 100,
        edgePointCount: 5,
      );
      expect(r.candidatePathCount, equals(2));
    });

    test('debug quality metrics have safe defaults', () {
      const r = PalmLineExtractionResult.empty;
      expect(r.palmMaskCoverage, equals(0.0));
      expect(r.darkLinePixelCount, equals(0));
      expect(r.sobelPixelCount, equals(0));
      expect(r.acceptedInteriorRatio, equals(0.0));
      expect(r.rejectedBoundaryRatio, equals(0.0));
      expect(r.palmGeometry, isNull);
      expect(r.creasePixelCount, equals(0));
      expect(r.skeletonLength, equals(0));
      expect(r.averageCreaseProbability, equals(0.0));
      expect(r.largestCreasePixelCount, equals(0));
      expect(r.processingTimeMs, equals(0));
      expect(r.debugPalmMask, isEmpty);
      expect(r.debugClahe, isEmpty);
      expect(r.debugDarkLineResponse, isEmpty);
      expect(r.debugCreaseProbability, isEmpty);
      expect(r.debugSkeleton, isEmpty);
      expect(r.tracedCreases, isEmpty);
      expect(r.traceCount, equals(0));
      expect(r.averageTraceLength, equals(0.0));
      expect(r.longestTraceLength, equals(0.0));
      expect(r.recoveredGapCount, equals(0));
      expect(r.averageTraceContinuity, equals(0.0));
      expect(r.averageTraceProbability, equals(0.0));
      expect(r.tracingTimeMs, equals(0));
      expect(r.debugTraceSeeds, isEmpty);
      expect(r.debugTraceDirections, isEmpty);
      expect(r.debugGapRecoveries, isEmpty);
      expect(r.averageAnatomicalScore, equals(0.0));
      expect(r.lifePriorScore, equals(0.0));
      expect(r.heartPriorScore, equals(0.0));
      expect(r.headPriorScore, equals(0.0));
      expect(r.fatePriorScore, equals(0.0));
      expect(r.trackerConfidenceBeforeAnatomical, equals(0.0));
      expect(r.trackerConfidenceAfterAnatomical, equals(0.0));
      expect(r.debugLifePrior, isEmpty);
      expect(r.debugHeartPrior, isEmpty);
      expect(r.debugHeadPrior, isEmpty);
      expect(r.debugFatePrior, isEmpty);
    });
  });

  group('processPixelsForTest', () {
    test('uniform image produces no edges', () {
      const w = 24, h = 24;
      final result = processPixelsForTest(_solid(w, h), w, h);
      expect(result['edgePointCount'], equals(0));
      expect(result['candidatePaths'], isEmpty);
    });

    test('image with dark horizontal line produces edge points', () {
      const w = 60, h = 60;
      final pixels = _solid(w, h);
      _darkLine(pixels, w, 30, 8, 52);
      final result = processPixelsForTest(pixels, w, h);
      expect(result['edgePointCount'], greaterThan(0));
      expect(result['imageWidth'], equals(w));
      expect(result['imageHeight'], equals(h));
    });

    test('image with multiple dark lines detects candidate paths', () {
      const w = 80, h = 80;
      final pixels = _solid(w, h, r: 210, g: 190, b: 170);
      for (final lineY in [20, 40, 60]) {
        _darkLine(pixels, w, lineY, 10, 70);
      }
      final result = processPixelsForTest(pixels, w, h);
      expect(result['edgePointCount'], greaterThan(0));
      final paths = result['candidatePaths'] as List;
      expect(paths, isNotEmpty);
    });

    test('too-small image returns empty result', () {
      final pixels = Uint8List(4 * 4 * 4);
      final result = processPixelsForTest(pixels, 4, 4);
      expect(result['edgePointCount'], equals(0));
    });

    test('mismatched pixel buffer returns empty result', () {
      final pixels = Uint8List(10);
      final result = processPixelsForTest(pixels, 100, 100);
      expect(result['edgePointCount'], equals(0));
    });

    test('confidence is between 0 and 1', () {
      const w = 60, h = 60;
      final pixels = _solid(w, h);
      _darkLine(pixels, w, 30, 8, 52);
      final result = processPixelsForTest(pixels, w, h);
      final conf = (result['confidence'] as num).toDouble();
      expect(conf, greaterThanOrEqualTo(0.0));
      expect(conf, lessThanOrEqualTo(1.0));
    });

    test('result always contains ROI and normalizedWidth keys', () {
      const w = 60, h = 60;
      final result = processPixelsForTest(_solid(w, h), w, h);
      expect(result.containsKey('roiLeft'), isTrue);
      expect(result.containsKey('normalizedWidth'), isTrue);
      expect(result.containsKey('normalizedHeight'), isTrue);
      expect(result.containsKey('palmMaskCoverage'), isTrue);
      expect(result.containsKey('darkLinePixelCount'), isTrue);
      expect(result.containsKey('sobelPixelCount'), isTrue);
      expect(result.containsKey('acceptedInteriorRatio'), isTrue);
      expect(result.containsKey('rejectedBoundaryRatio'), isTrue);
      expect(result.containsKey('palmGeometry'), isTrue);
      expect(result.containsKey('creasePixelCount'), isTrue);
      expect(result.containsKey('skeletonLength'), isTrue);
      expect(result.containsKey('averageCreaseProbability'), isTrue);
      expect(result.containsKey('largestCreasePixelCount'), isTrue);
      expect(result.containsKey('processingTimeMs'), isTrue);
      expect(result.containsKey('debugPalmMask'), isTrue);
      expect(result.containsKey('debugClahe'), isTrue);
      expect(result.containsKey('debugDarkLineResponse'), isTrue);
      expect(result.containsKey('multiScaleRidgeMap'), isTrue);
      expect(result.containsKey('debugMultiScaleRidgeMap'), isTrue);
      expect(result.containsKey('debugRidgeStrengthHeatmap'), isTrue);
      expect(result.containsKey('debugCreaseProbability'), isTrue);
      expect(result.containsKey('debugSkeleton'), isTrue);
      expect(result.containsKey('tracedCreases'), isTrue);
      expect(result.containsKey('traceCount'), isTrue);
      expect(result.containsKey('averageTraceLength'), isTrue);
      expect(result.containsKey('longestTraceLength'), isTrue);
      expect(result.containsKey('recoveredGapCount'), isTrue);
      expect(result.containsKey('averageTraceContinuity'), isTrue);
      expect(result.containsKey('averageTraceProbability'), isTrue);
      expect(result.containsKey('tracingTimeMs'), isTrue);
      expect(result.containsKey('debugTraceSeeds'), isTrue);
      expect(result.containsKey('debugTraceDirections'), isTrue);
      expect(result.containsKey('debugGapRecoveries'), isTrue);
      expect(result.containsKey('debugMajorLineScores'), isTrue);
      expect(result.containsKey('debugTopLifeLineCandidates'), isTrue);
      expect(result.containsKey('debugTraceRejectionReasons'), isTrue);
      expect(result.containsKey('averageAnatomicalScore'), isTrue);
      expect(result.containsKey('lifePriorScore'), isTrue);
      expect(result.containsKey('heartPriorScore'), isTrue);
      expect(result.containsKey('headPriorScore'), isTrue);
      expect(result.containsKey('fatePriorScore'), isTrue);
      expect(result.containsKey('trackerConfidenceBeforeAnatomical'), isTrue);
      expect(result.containsKey('trackerConfidenceAfterAnatomical'), isTrue);
      expect(result.containsKey('debugLifePrior'), isTrue);
      expect(result.containsKey('debugHeartPrior'), isTrue);
      expect(result.containsKey('debugHeadPrior'), isTrue);
      expect(result.containsKey('debugFatePrior'), isTrue);
      expect(result.containsKey('anatomyWeighted'), isTrue);
      expect(result.containsKey('outsideMaskProbabilityPixels'), isTrue);
      expect(result.containsKey('outsideMaskSkeletonPixels'), isTrue);
      expect(result.containsKey('rejectedOutsideMaskTraces'), isTrue);
      expect(
        result.containsKey('minInsidePalmRatioOfAcceptedCandidates'),
        isTrue,
      );
      expect(result.containsKey('rejectedOutsideMaskPaths'), isTrue);
      expect(result.containsKey('debugPalmOutline'), isTrue);
    });

    // ── ROI normalization tests ────────────────────────────────────────────────

    test('off-center line is found after ROI normalization', () {
      // 120×100 image: top-left quadrant is white (background),
      // palm region occupies the right 60 % with a dark line at x=90.
      const w = 120, h = 100;
      // Light palm skin in inner right portion
      final pixels = Uint8List(w * h * 4);
      for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
          final base = (y * w + x) * 4;
          // Left strip: very bright (background)
          if (x < 30) {
            pixels[base] = 250;
            pixels[base + 1] = 250;
            pixels[base + 2] = 250;
          } else {
            // Palm-tone skin
            pixels[base] = 190;
            pixels[base + 1] = 170;
            pixels[base + 2] = 150;
          }
          pixels[base + 3] = 255;
        }
      }
      // Dark line at x=90 spanning y=20..80
      for (int y = 20; y <= 80; y++) {
        for (int dx = 0; dx <= 1; dx++) {
          final base = (y * w + 90 + dx) * 4;
          pixels[base] = 50;
          pixels[base + 1] = 40;
          pixels[base + 2] = 35;
          pixels[base + 3] = 255;
        }
      }
      final result = processPixelsForTest(pixels, w, h);
      // With ROI normalization the palm-only crop is processed; edge count > 0.
      expect(result['edgePointCount'], greaterThan(0));
      // Edge point x-coordinates must be in original image [0,1] space (> 0.3).
      final edgePts = result['edgePoints'] as List;
      if (edgePts.isNotEmpty) {
        final firstX = (edgePts.first as List)[0] as double;
        expect(
          firstX,
          greaterThan(0.2),
          reason: 'edge mapped back to original image space',
        );
      }
    });

    test(
      'near-uniform (background-only) image stays empty regardless of ROI',
      () {
        // Nearly white image — no palm, no lines.
        const w = 80, h = 80;
        final pixels = Uint8List(w * h * 4);
        for (int i = 0; i < pixels.length; i += 4) {
          pixels[i] = 248;
          pixels[i + 1] = 248;
          pixels[i + 2] = 248;
          pixels[i + 3] = 255;
        }
        final result = processPixelsForTest(pixels, w, h);
        expect(result['edgePointCount'], equals(0));
        expect((result['candidatePaths'] as List), isEmpty);
      },
    );

    test('ROI fallback on near-uniform dark image does not crash', () {
      // Very dark image — ROI detection will yield no palm-brightness pixels,
      // falling back to full-image processing without throwing.
      const w = 60, h = 60;
      final pixels = Uint8List(w * h * 4);
      for (int i = 0; i < pixels.length; i += 4) {
        pixels[i] = 10;
        pixels[i + 1] = 10;
        pixels[i + 2] = 10;
        pixels[i + 3] = 255;
      }
      // Must not throw; result shape must be valid.
      Map<String, dynamic>? result;
      expect(
        () => result = processPixelsForTest(pixels, w, h),
        returnsNormally,
      );
      expect(result, isNotNull);
      expect(result!['imageWidth'], equals(w));
      expect(result!['imageHeight'], equals(h));
      // ROI should be null since no palm-brightness pixels were found.
      expect(result!['roiLeft'], isNull);
    });
  });

  group('PalmLineExtractor.extract', () {
    test('returns empty for zero-length bytes', () async {
      final result = await PalmLineExtractor.extract(Uint8List(0));
      expect(result.hasRealData, isFalse);
      expect(result.candidatePaths, isEmpty);
    });

    test('returns empty for garbage bytes', () async {
      final result = await PalmLineExtractor.extract(
        Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]),
      );
      expect(result.hasRealData, isFalse);
    });
  });

  // ── Interior mask (erodeMaskForTest) ─────────────────────────────────────────

  group('erodeMaskForTest', () {
    test('all-true mask eroded stays true in centre for small radius', () {
      const w = 20, h = 20;
      final mask = List<bool>.filled(w * h, true);
      final result = erodeMaskForTest(mask, w, h, 2);
      // Pixels far from the border stay true after erosion with r=2.
      expect(result[5 * w + 5], isTrue);
      expect(result[10 * w + 10], isTrue);
    });

    test('all-false mask eroded stays all-false', () {
      const w = 10, h = 10;
      final mask = List<bool>.filled(w * h, false);
      final result = erodeMaskForTest(mask, w, h, 2);
      expect(result.every((v) => !v), isTrue);
    });

    test('single false pixel erodes a radius-r neighbourhood to false', () {
      const w = 20, h = 20, r = 3;
      final mask = List<bool>.filled(w * h, true);
      mask[10 * w + 10] = false; // hole at (10,10)
      final result = erodeMaskForTest(mask, w, h, r);
      // Every pixel within r of (10,10) in both axes must be false.
      for (int dy = -r; dy <= r; dy++) {
        for (int dx = -r; dx <= r; dx++) {
          final y = 10 + dy, x = 10 + dx;
          if (y < 0 || y >= h || x < 0 || x >= w) continue;
          expect(
            result[y * w + x],
            isFalse,
            reason: 'pixel ($x,$y) should be eroded',
          );
        }
      }
    });

    test('erosion with r=0 is identity', () {
      const w = 8, h = 8;
      final mask = List<bool>.filled(w * h, false);
      mask[3 * w + 3] = true;
      final result = erodeMaskForTest(mask, w, h, 0);
      expect(result[3 * w + 3], isTrue);
    });
  });

  // ── Valley strength (valleyStrengthForTest) ───────────────────────────────────

  group('valleyStrengthForTest', () {
    test('uniform image returns 0 ridgeness', () {
      const w = 20, h = 20;
      final img = Uint8List(w * h);
      img.fillRange(0, img.length, 150);
      expect(valleyStrengthForTest(img, 10, 10, w, h), equals(0));
    });

    test('dark centre on bright background returns high ridgeness', () {
      const w = 20, h = 20;
      final img = Uint8List(w * h);
      img.fillRange(0, img.length, 180);
      img[10 * w + 10] = 60; // dark pit
      final strength = valleyStrengthForTest(img, 10, 10, w, h);
      expect(strength, greaterThan(0));
    });

    test('bright centre on dark background returns 0 (not a groove)', () {
      const w = 20, h = 20;
      final img = Uint8List(w * h);
      img.fillRange(0, img.length, 60);
      img[10 * w + 10] = 200; // bright bump, not a groove
      final strength = valleyStrengthForTest(img, 10, 10, w, h);
      // bgMean - center will be negative, clamped to 0.
      expect(strength, equals(0));
    });

    test('pixels near border return 0 (guard)', () {
      const w = 20, h = 20;
      final img = Uint8List(w * h);
      img.fillRange(0, img.length, 150);
      img[2 * w + 2] = 30;
      // x=2 < 5 → guard triggers
      expect(valleyStrengthForTest(img, 2, 2, w, h), equals(0));
    });
  });

  // ── Dark-line map ───────────────────────────────────────────────────────────

  group('darkLineStrengthForTest', () {
    test('shallow dark groove produces evidence without Sobel input', () {
      const w = 24, h = 24;
      final img = Uint8List(w * h)..fillRange(0, w * h, 150);
      for (int x = 5; x < 19; x++) {
        img[12 * w + x] = 138;
      }
      expect(darkLineStrengthForTest(img, 12, 12, w, h), greaterThan(7));
    });
  });

  // ── Multi-scale Hessian ridge map ──────────────────────────────────────────

  group('multiScaleRidgeMapForTest', () {
    test('broad dark crease produces a strong ridge response', () {
      const w = 48, h = 48;
      final img = Uint8List(w * h)..fillRange(0, w * h, 180);
      for (int y = 21; y <= 27; y++) {
        for (int x = 8; x < 40; x++) {
          img[y * w + x] = 120;
        }
      }

      final ridge = multiScaleRidgeMapForTest(img, w, h);

      expect(ridge[24 * w + 24], greaterThan(0));
      expect(ridge[24 * w + 24], greaterThan(ridge[8 * w + 8]));
    });

    test('faint broad crease remains visible at a larger scale', () {
      const w = 56, h = 56;
      final img = Uint8List(w * h)..fillRange(0, w * h, 180);
      for (int y = 25; y <= 31; y++) {
        for (int x = 9; x < 47; x++) {
          img[y * w + x] = 166;
        }
      }

      final ridge = multiScaleRidgeMapForTest(img, w, h);

      expect(ridge[28 * w + 28], greaterThan(0));
      expect(ridge[28 * w + 28], greaterThan(ridge[14 * w + 14]));
    });
  });

  // ── Palm geometry ───────────────────────────────────────────────────────────

  group('palmGeometryFromMaskForTest', () {
    List<bool> emptyMask(int w, int h) => List<bool>.filled(w * h, false);

    void fillRect(List<bool> mask, int w, int x0, int y0, int x1, int y1) {
      for (int y = y0; y <= y1; y++) {
        for (int x = x0; x <= x1; x++) {
          mask[y * w + x] = true;
        }
      }
    }

    test('simple palm-like mask gives center near expected', () {
      const w = 100, h = 100;
      final mask = emptyMask(w, h);
      fillRect(mask, w, 30, 20, 70, 90);
      final geometry = palmGeometryFromMaskForTest(mask, w, h);
      expect(geometry, isNotNull);
      expect(geometry!.palmCenter.dx, closeTo(0.505, 0.02));
      expect(geometry.palmCenter.dy, closeTo(0.555, 0.02));
      expect(geometry.fingerBaseY, closeTo(0.205, 0.02));
      expect(geometry.wristY, closeTo(0.905, 0.02));
      expect(geometry.confidence, greaterThan(0.5));
      expect(geometry.palmWidth, greaterThan(0.35));
      expect(geometry.palmHeight, greaterThan(0.65));
      expect(geometry.wristWidth, greaterThan(0.35));
      expect(geometry.wristCenter.dx, closeTo(0.505, 0.04));
      expect(geometry.fingerBaseArc.length, equals(4));
      expect(geometry.fingerArcConfidence, greaterThan(0.5));
      expect(geometry.wristConfidence, greaterThan(0.5));
      expect(geometry.canonicalTransformQuality, greaterThan(0.25));
    });

    test('wider left lower region detects left thumb side', () {
      const w = 100, h = 100;
      final mask = emptyMask(w, h);
      fillRect(mask, w, 35, 20, 65, 90);
      fillRect(mask, w, 18, 45, 35, 85);
      final geometry = palmGeometryFromMaskForTest(mask, w, h);
      expect(geometry, isNotNull);
      expect(geometry!.thumbSide, equals(PalmThumbSide.left));
      expect(geometry.handedness, equals(PalmHandedness.unknown));
      expect(geometry.thumbSideConfidence, greaterThan(0.16));
      expect(geometry.thenarRegion.left, lessThan(geometry.palmCenter.dx));
      expect(geometry.thumbBase.dx, lessThan(geometry.palmCenter.dx));
      expect(geometry.thenarCenter.dx, lessThan(geometry.palmCenter.dx));
    });

    test('wider right lower region detects right thumb side', () {
      const w = 100, h = 100;
      final mask = emptyMask(w, h);
      fillRect(mask, w, 35, 20, 65, 90);
      fillRect(mask, w, 65, 45, 82, 85);
      final geometry = palmGeometryFromMaskForTest(mask, w, h);
      expect(geometry, isNotNull);
      expect(geometry!.thumbSide, equals(PalmThumbSide.right));
      expect(geometry.handedness, equals(PalmHandedness.unknown));
      expect(geometry.thumbSideConfidence, greaterThan(0.16));
      expect(geometry.thenarRegion.right, greaterThan(geometry.palmCenter.dx));
      expect(geometry.thumbBase.dx, greaterThan(geometry.palmCenter.dx));
      expect(geometry.thenarCenter.dx, greaterThan(geometry.palmCenter.dx));
    });

    test('thumb-index web lands above thumb base on asymmetric mask', () {
      const w = 100, h = 100;
      final mask = emptyMask(w, h);
      fillRect(mask, w, 35, 20, 65, 90);
      fillRect(mask, w, 18, 48, 35, 84);
      fillRect(mask, w, 30, 28, 35, 42);
      final geometry = palmGeometryFromMaskForTest(mask, w, h);
      expect(geometry, isNotNull);
      expect(geometry!.thumbSide, equals(PalmThumbSide.left));
      expect(geometry.thumbIndexWeb.dy, lessThan(geometry.thumbBase.dy));
      expect(geometry.thumbIndexWeb.dx, lessThan(geometry.palmCenter.dx));
    });

    test('wrist line exposes left edge, right edge and width', () {
      const w = 120, h = 120;
      final mask = emptyMask(w, h);
      fillRect(mask, w, 38, 20, 82, 94);
      fillRect(mask, w, 45, 95, 75, 110);
      final geometry = palmGeometryFromMaskForTest(mask, w, h);
      expect(geometry, isNotNull);
      expect(geometry!.wristLeft.dx, lessThan(geometry.wristCenter.dx));
      expect(geometry.wristRight.dx, greaterThan(geometry.wristCenter.dx));
      expect(geometry.wristWidth, greaterThan(0.20));
      expect(geometry.wristConfidence, greaterThan(0.35));
    });

    test('canonical y maps finger base near 0 and wrist near 1', () {
      const w = 100, h = 100;
      final mask = emptyMask(w, h);
      fillRect(mask, w, 28, 18, 72, 88);
      final geometry = palmGeometryFromMaskForTest(mask, w, h)!;
      final finger = geometry.imageToPalm(
        Offset(geometry.palmCenter.dx, geometry.fingerBaseY),
      );
      final wrist = geometry.imageToPalm(
        Offset(geometry.palmCenter.dx, geometry.wristY),
      );
      expect(finger.dy, closeTo(0.0, 0.01));
      expect(wrist.dy, closeTo(1.0, 0.01));
      final backToImage = geometry.palmToImage(const Offset(0.5, 1.0));
      expect(backToImage.dy, closeTo(geometry.wristY, 0.001));
    });

    test('invalid empty mask returns null geometry', () {
      final geometry = palmGeometryFromMaskForTest(emptyMask(40, 40), 40, 40);
      expect(geometry, isNull);
    });

    test('image thumb side right does not automatically mean left hand', () {
      const w = 100, h = 100;
      final mask = emptyMask(w, h);
      fillRect(mask, w, 35, 20, 65, 90);
      fillRect(mask, w, 65, 45, 82, 85);
      final geometry = palmGeometryFromMaskForTest(mask, w, h);
      final extraction = PalmLineExtractionResult(
        edgePoints: const [],
        candidatePaths: const [],
        confidence: 0.5,
        imageWidth: w,
        imageHeight: h,
        edgePointCount: 1,
        palmGeometry: geometry,
      );

      expect(extraction.imageThumbSide, equals(PalmThumbSide.right));
      expect(extraction.semanticHandedness, equals(ScannedHand.unknown));
    });

    test('analysis result can carry unknown hand fallback', () {
      const extraction = PalmLineExtractionResult(
        edgePoints: [],
        candidatePaths: [],
        confidence: 0.5,
        imageWidth: 100,
        imageHeight: 100,
        edgePointCount: 1,
      );

      expect(extraction.scannedHand, equals(ScannedHand.unknown));
      expect(extraction.copyWith().scannedHand, equals(ScannedHand.unknown));
    });
  });

  // ── Interior filtering: accepted vs rejected paths ────────────────────────────

  group('interior filtering (processPixelsForTest)', () {
    test('result contains rejectedPaths key', () {
      const w = 60, h = 60;
      final result = processPixelsForTest(_solid(w, h), w, h);
      expect(result.containsKey('rejectedPaths'), isTrue);
    });

    // Builds a 120×120 skin image with a dark ring at y=12,13 (inside the
    // workMargin boundary of 8 px) so Sobel detects it, but the grayscale
    // skin-mask erosion places it outside the interior mask → rejected.
    Uint8List boundaryOnlyImage() {
      const w = 120, h = 120;
      final px = Uint8List(w * h * 4);
      for (int i = 0; i < px.length; i += 4) {
        px[i] = 200;
        px[i + 1] = 180;
        px[i + 2] = 160;
        px[i + 3] = 255;
      }
      // Dark ring at y=12,13 and y=h-14,h-13 (gray≈20, which is <50 → skinMask=FALSE)
      for (int x = 0; x < w; x++) {
        for (final y in [12, 13, h - 14, h - 13]) {
          final b = (y * w + x) * 4;
          px[b] = 20;
          px[b + 1] = 20;
          px[b + 2] = 20;
          px[b + 3] = 255;
        }
      }
      for (int y = 0; y < h; y++) {
        for (final x in [12, 13, w - 14, w - 13]) {
          final b = (y * w + x) * 4;
          px[b] = 20;
          px[b + 1] = 20;
          px[b + 2] = 20;
          px[b + 3] = 255;
        }
      }
      return px;
    }

    test('boundary-only image: outer-edge component is rejected', () {
      // The 120×120 image has a dark ring at y=12 (inside the loop range
      // workMargin=8) but the interior mask erosion (radius=7) erodes the
      // skin mask outward from the dark ring, so ring components are rejected.
      final result = processPixelsForTest(boundaryOnlyImage(), 120, 120);
      final rejected = result['rejectedPaths'] as List;
      final accepted = result['candidatePaths'] as List;
      expect(
        rejected.length,
        greaterThanOrEqualTo(accepted.length),
        reason: 'boundary ring component should dominate rejectedPaths',
      );
      expect(
        (result['rejectedBoundaryRatio'] as num).toDouble(),
        greaterThan(0),
      );
    });

    test('strong outer boundary is rejected instead of accepted', () {
      final result = processPixelsForTest(boundaryOnlyImage(), 120, 120);
      final accepted = result['candidatePaths'] as List;
      final rejected = result['rejectedPaths'] as List;
      expect(rejected, isNotEmpty);
      expect(
        accepted.length,
        lessThanOrEqualTo(1),
        reason: 'outer contour evidence should not become main palm lines',
      );
    });

    test('interior line preferred: ends up in candidatePaths', () {
      // 80×80 bright skin image with a single dark horizontal interior line.
      // No dark background → graySkin=TRUE everywhere → interior mask covers
      // the whole image → line component interiorFrac=1.0 → accepted.
      const w = 80, h = 80;
      final px = Uint8List(w * h * 4);
      for (int i = 0; i < px.length; i += 4) {
        px[i] = 200;
        px[i + 1] = 180;
        px[i + 2] = 160;
        px[i + 3] = 255;
      }
      // Dark horizontal crease at y=40 spanning x=10..69 (gray≈72, in [50,235])
      for (int x = 10; x < 70; x++) {
        for (int dy = 0; dy <= 1; dy++) {
          final b = ((40 + dy) * w + x) * 4;
          px[b] = 80;
          px[b + 1] = 70;
          px[b + 2] = 65;
          px[b + 3] = 255;
        }
      }
      final result = processPixelsForTest(px, w, h);
      final accepted = result['candidatePaths'] as List;
      expect(
        accepted,
        isNotEmpty,
        reason: 'interior palm crease must survive interior filter',
      );
      expect(
        (result['acceptedInteriorRatio'] as num).toDouble(),
        greaterThan(0.6),
      );
    });

    test('weak dark interior line is detected by dark-line evidence', () {
      const w = 96, h = 96;
      final px = _solid(w, h, r: 190, g: 172, b: 154);
      for (int x = 18; x < 78; x++) {
        final b = (48 * w + x) * 4;
        px[b] = 174;
        px[b + 1] = 158;
        px[b + 2] = 143;
      }
      final result = processPixelsForTest(px, w, h);
      expect(result['edgePointCount'], greaterThan(0));
      expect(result['darkLinePixelCount'], greaterThan(0));
      expect(result['candidatePaths'], isNotEmpty);
    });

    test('crease probability map produces skeleton tracker input', () {
      const w = 96, h = 96;
      final px = _solid(w, h, r: 192, g: 174, b: 156);
      for (int x = 18; x < 78; x++) {
        for (int dy = -1; dy <= 1; dy++) {
          final b = ((48 + dy) * w + x) * 4;
          final shade = dy == 0 ? 150 : 170;
          px[b] = shade;
          px[b + 1] = shade - 12;
          px[b + 2] = shade - 24;
        }
      }

      final result = processPixelsForTest(px, w, h);

      expect(result['creasePixelCount'], greaterThan(0));
      expect(result['skeletonLength'], greaterThan(0));
      expect(
        (result['averageCreaseProbability'] as num).toDouble(),
        greaterThan(0),
      );
      expect(result['largestCreasePixelCount'], greaterThan(0));
      expect(result['debugCreaseProbability'], isNotEmpty);
      expect(result['debugSkeleton'], isNotEmpty);
      expect(result['debugMultiScaleRidgeMap'], isNotEmpty);
      expect(result['debugRidgeStrengthHeatmap'], isNotEmpty);
      expect(result['candidatePaths'], isNotEmpty);
      expect(result['tracedCreases'], isNotEmpty);
      expect(result['traceCount'], greaterThan(0));
      expect(result['averageTraceLength'], greaterThan(0));
      expect(result['longestTraceLength'], greaterThan(0));
      expect(result['averageTraceContinuity'], greaterThan(0));
      expect(result['averageTraceProbability'], greaterThan(0));
      expect(result['averageAnatomicalScore'], greaterThan(0));
      expect(result['trackerConfidenceBeforeAnatomical'], greaterThan(0));
      expect(result['trackerConfidenceAfterAnatomical'], greaterThan(0));
      expect(result['debugLifePrior'], isNotEmpty);
      expect(result['debugHeartPrior'], isNotEmpty);
      expect(result['debugHeadPrior'], isNotEmpty);
      expect(result['debugFatePrior'], isNotEmpty);
      final traces = result['tracedCreases'] as List<dynamic>;
      final firstTrace = traces.first as Map<dynamic, dynamic>;
      expect(firstTrace.containsKey('anatomicalScore'), isTrue);
      expect(firstTrace.containsKey('weightedProbability'), isTrue);
      expect(firstTrace.containsKey('averageRidgeResponse'), isTrue);
      expect(firstTrace.containsKey('maximumRidgeResponse'), isTrue);
      expect(firstTrace.containsKey('ridgeConsistency'), isTrue);
      expect(firstTrace.containsKey('ridgeWidthEstimate'), isTrue);
      expect(firstTrace.containsKey('majorLineScore'), isTrue);
      expect(firstTrace.containsKey('rejectionReason'), isTrue);
      expect((firstTrace['anatomicalScore'] as num).toDouble(), greaterThan(0));
      expect(
        (firstTrace['weightedProbability'] as num).toDouble(),
        greaterThan(0),
      );
      expect(
        (firstTrace['averageRidgeResponse'] as num).toDouble(),
        greaterThanOrEqualTo(0),
      );
      expect((firstTrace['majorLineScore'] as num).toDouble(), greaterThan(0));
      expect(result['debugMajorLineScores'], isNotEmpty);
      expect(result.containsKey('debugTopLifeLineCandidates'), isTrue);
      expect(result['debugTraceRejectionReasons'], isNotEmpty);
      expect(result['debugTraceSeeds'], isNotEmpty);
    });

    test(
      'anatomical priors score an upper horizontal crease as heart-like',
      () {
        const w = 112, h = 112;
        final px = _solid(w, h, r: 194, g: 176, b: 158);
        for (int x = 16; x < 96; x++) {
          for (int dy = -1; dy <= 1; dy++) {
            final b = ((32 + dy) * w + x) * 4;
            final shade = dy == 0 ? 145 : 169;
            px[b] = shade;
            px[b + 1] = shade - 12;
            px[b + 2] = shade - 24;
          }
        }

        final result = processPixelsForTest(px, w, h);

        expect(result['tracedCreases'], isNotEmpty);
        expect(
          (result['heartPriorScore'] as num).toDouble(),
          greaterThan((result['fatePriorScore'] as num).toDouble()),
        );
        expect(
          (result['trackerConfidenceAfterAnatomical'] as num).toDouble(),
          greaterThan(0),
        );
      },
    );

    test('crease tracer reconnects a small interrupted palm crease', () {
      const w = 112, h = 112;
      final px = _solid(w, h, r: 194, g: 176, b: 158);
      for (int x = 18; x < 94; x++) {
        if (x >= 53 && x <= 58) continue;
        for (int dy = -1; dy <= 1; dy++) {
          final b = ((56 + dy) * w + x) * 4;
          final shade = dy == 0 ? 145 : 169;
          px[b] = shade;
          px[b + 1] = shade - 12;
          px[b + 2] = shade - 24;
        }
      }

      final result = processPixelsForTest(px, w, h);
      final traces = result['tracedCreases'] as List<dynamic>;
      final paths = result['candidatePaths'] as List<dynamic>;

      expect(traces, isNotEmpty);
      expect(paths, isNotEmpty);
      expect(result['recoveredGapCount'], greaterThan(0));
      expect(
        (result['longestTraceLength'] as num).toDouble(),
        greaterThan(0.45),
      );
    });

    test('dark-line map is the primary extraction evidence', () {
      const w = 96, h = 96;
      final px = _solid(w, h, r: 188, g: 170, b: 152);
      for (int x = 18; x < 78; x++) {
        for (int dy = -1; dy <= 1; dy++) {
          final b = ((48 + dy) * w + x) * 4;
          final shade = dy == 0 ? 166 : 174;
          px[b] = shade;
          px[b + 1] = shade - 14;
          px[b + 2] = shade - 26;
        }
      }
      final result = processPixelsForTest(px, w, h);
      expect(result['darkLinePixelCount'], greaterThan(0));
      expect(
        result['darkLinePixelCount'],
        greaterThan(result['sobelPixelCount'] as int),
        reason: 'dark-line pixels should dominate auxiliary Sobel evidence',
      );
    });

    test('fallback guide lines are not treated as detected candidates', () {
      const extraction = PalmLineExtractionResult(
        edgePoints: [Offset(0.5, 0.5)],
        candidatePaths: [],
        confidence: 0.2,
        imageWidth: 100,
        imageHeight: 100,
        edgePointCount: 1,
      );
      expect(extraction.hasRealData, isTrue);
      expect(extraction.candidatePathCount, equals(0));
      expect(extraction.candidatePaths, isEmpty);
    });

    test('candidatePath points are within [0,1]', () {
      const w = 60, h = 60;
      final pixels = _solid(w, h);
      _darkLine(pixels, w, 30, 8, 52);
      final result = processPixelsForTest(pixels, w, h);
      final paths = result['candidatePaths'] as List<dynamic>;
      for (final path in paths) {
        for (final pt in path as List<dynamic>) {
          final l = pt as List;
          expect((l[0] as num).toDouble(), inInclusiveRange(0.0, 1.0));
          expect((l[1] as num).toDouble(), inInclusiveRange(0.0, 1.0));
        }
      }
    });

    test('rejectedPath points are within [0,1]', () {
      final result = processPixelsForTest(boundaryOnlyImage(), 120, 120);
      final paths = result['rejectedPaths'] as List<dynamic>;
      for (final path in paths) {
        for (final pt in path as List<dynamic>) {
          final l = pt as List;
          expect((l[0] as num).toDouble(), inInclusiveRange(0.0, 1.0));
          expect((l[1] as num).toDouble(), inInclusiveRange(0.0, 1.0));
        }
      }
    });
  });

  // ── anatomy-weighted probability maps ─────────────────────────────────────────

  group('anatomy-weighted probability maps', () {
    test('prior alone without base signal creates no line', () {
      // base = 0 everywhere → weighted must be 0 regardless of prior value
      final base = Float32List(4);
      final prior = Float32List.fromList([1.0, 1.0, 1.0, 1.0]);
      final weighted = anatomyWeightedMapForTest(base, prior);
      expect(
        weighted,
        everyElement(equals(0.0)),
        reason: 'prior alone must not create signal where base is zero',
      );
    });

    test('weak line in prior zone is amplified', () {
      // base=0.3, prior=1.0 → 0.3 * (0.45 + 0.75*1.0) = 0.3 * 1.20 = 0.36
      final base = Float32List.fromList([0.3]);
      final prior = Float32List.fromList([1.0]);
      final weighted = anatomyWeightedMapForTest(base, prior);
      expect(
        weighted[0],
        greaterThan(base[0]),
        reason: 'high prior should amplify a weak base signal',
      );
      expect(weighted[0], closeTo(0.36, 0.001));
    });

    test('strong line outside prior zone is downweighted', () {
      // base=0.8, prior=0.0 → 0.8 * (0.45 + 0.75*0.0) = 0.8 * 0.45 = 0.36
      final base = Float32List.fromList([0.8]);
      final prior = Float32List.fromList([0.0]);
      final weighted = anatomyWeightedMapForTest(base, prior);
      expect(
        weighted[0],
        lessThan(base[0]),
        reason: 'zero prior should reduce signal outside the anatomical zone',
      );
      expect(weighted[0], closeTo(0.36, 0.001));
    });

    test('anatomy-weighted result contains all required sub-keys', () {
      const w = 60, h = 60;
      final pixels = _solid(w, h);
      _darkLine(pixels, w, 30, 8, 52);
      final result = processPixelsForTest(pixels, w, h);
      expect(result.containsKey('anatomyWeighted'), isTrue);
      final aw = result['anatomyWeighted'] as Map<String, dynamic>;
      for (final key in const [
        'lifeCandidates',
        'heartCandidates',
        'headCandidates',
        'fateCandidates',
        'lifeTracedCreases',
        'heartTracedCreases',
        'headTracedCreases',
        'fateTracedCreases',
        'baseCreasePixels',
        'lifeCreasePixels',
        'heartCreasePixels',
        'headCreasePixels',
        'fateCreasePixels',
        'lifeSkeletonLength',
        'heartSkeletonLength',
        'headSkeletonLength',
        'fateSkeletonLength',
        'debugLifeWeightedProb',
        'debugHeartWeightedProb',
        'debugHeadWeightedProb',
        'debugFateWeightedProb',
        'debugLifeSkeleton',
        'debugHeartSkeleton',
        'debugHeadSkeleton',
        'debugFateSkeleton',
      ]) {
        expect(
          aw.containsKey(key),
          isTrue,
          reason: 'missing anatomy key: $key',
        );
      }
    });

    test('fallback is stable: empty result has valid anatomy defaults', () {
      const r = PalmLineExtractionResult.empty;
      expect(r.anatomyWeighted, isNotNull);
      expect(r.anatomyWeighted.lifeCandidates, isEmpty);
      expect(r.anatomyWeighted.lifeTracedCreases, isEmpty);
      expect(r.anatomyWeighted.baseCreasePixels, equals(0));
      expect(r.anatomyWeighted.lifeSkeletonLength, equals(0));
      expect(r.anatomyWeighted.debugLifeWeightedProb, isEmpty);
    });
  });

  // ── palm mask gating ──────────────────────────────────────────────────────────

  group('palm mask gating', () {
    test('outsideMaskProbabilityPixels is always 0 after safety gate', () {
      const w = 60, h = 60;
      final pixels = _solid(w, h);
      _darkLine(pixels, w, 30, 8, 52);
      final result = processPixelsForTest(pixels, w, h);
      expect(
        result['outsideMaskProbabilityPixels'],
        equals(0),
        reason:
            'hard masking gate must leave no residual outside-palm probability',
      );
    });

    test('outsideMaskSkeletonPixels is 0 for well-formed input', () {
      const w = 60, h = 60;
      final pixels = _solid(w, h);
      _darkLine(pixels, w, 30, 8, 52);
      final result = processPixelsForTest(pixels, w, h);
      expect(
        result['outsideMaskSkeletonPixels'],
        equals(0),
        reason: 'skeleton should have no pixels outside boundarySafeMask',
      );
    });

    test(
      'minInsidePalmRatioOfAcceptedCandidates is >= 0.98 when candidates exist',
      () {
        const w = 60, h = 60;
        final pixels = _solid(w, h);
        _darkLine(pixels, w, 30, 8, 52);
        final result = processPixelsForTest(pixels, w, h);
        final candidates = result['candidatePaths'] as List;
        if (candidates.isNotEmpty) {
          final ratio =
              (result['minInsidePalmRatioOfAcceptedCandidates'] as num)
                  .toDouble();
          expect(
            ratio,
            greaterThanOrEqualTo(0.98),
            reason: 'every accepted candidate must be >= 98 % inside palm mask',
          );
        }
      },
    );

    test(
      'outside-palm trace (insidePalmRatio < 0.98) cannot win as life line',
      () {
        const outsideCrease = PalmTracedCrease(
          points: [Offset(0.1, 0.8), Offset(0.15, 0.5), Offset(0.1, 0.2)],
          totalLength: 0.6,
          averageProbability: 0.85,
          continuityScore: 0.95,
          averageCurvature: 1.0,
          interruptionCount: 0,
          branchCount: 0,
          anatomicalScore: 0.9,
          insidePalmRatio: 0.40, // clearly outside palm
        );
        const extraction = PalmLineExtractionResult(
          edgePoints: [Offset(0.1, 0.5)],
          candidatePaths: [
            [Offset(0.1, 0.8), Offset(0.15, 0.5), Offset(0.1, 0.2)],
          ],
          confidence: 0.8,
          imageWidth: 100,
          imageHeight: 100,
          edgePointCount: 10,
          tracedCreases: [outsideCrease],
        );
        final result = PalmLineClassifier.classify(extraction);
        expect(
          result.lifeLinePath,
          isNull,
          reason:
              'an outside-palm trace must never be assigned as the life line',
        );
      },
    );

    test('empty result has correct defaults for all palm-gating fields', () {
      const r = PalmLineExtractionResult.empty;
      expect(r.outsideMaskProbabilityPixels, equals(0));
      expect(r.outsideMaskSkeletonPixels, equals(0));
      expect(r.rejectedOutsideMaskTraces, equals(0));
      expect(r.minInsidePalmRatioOfAcceptedCandidates, equals(1.0));
      expect(r.rejectedOutsideMaskPaths, isEmpty);
      expect(r.debugPalmOutline, isEmpty);
    });
  });
}
