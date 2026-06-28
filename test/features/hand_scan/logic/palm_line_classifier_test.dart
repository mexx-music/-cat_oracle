import 'package:cat_oracle/features/hand_scan/logic/palm_line_classifier.dart';
import 'package:cat_oracle/features/hand_scan/logic/palm_line_extractor.dart';
import 'package:cat_oracle/features/hand_scan/models/scanned_hand.dart';
import 'package:cat_oracle/features/palmistry/logic/palmistry_reading_engine.dart';
import 'package:cat_oracle/features/palmistry/models/palmistry_analysis_profile.dart';
import 'package:flutter/material.dart' show Rect;
import 'package:flutter_test/flutter_test.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Builds a [List<Offset>] from bare [x, y] pairs.
List<Offset> _path(List<List<double>> pts) =>
    pts.map((p) => Offset(p[0], p[1])).toList();

/// Life-line candidate: left palm (x ~0.18), arcs vertically to wrist.
List<Offset> get _lifeLine => _path([
  for (var i = 0; i <= 12; i++) [0.18 + i * 0.005, 0.15 + i * 0.055],
]);

/// Heart-line candidate: upper palm (y ~0.25), full-width horizontal.
List<Offset> get _heartLine => _path([
  for (var i = 0; i <= 12; i++) [0.10 + i * 0.065, 0.25],
]);

/// Head-line candidate: middle area (y ~0.45), mostly horizontal.
List<Offset> get _headLine => _path([
  for (var i = 0; i <= 12; i++) [0.12 + i * 0.062, 0.45 + i * 0.008],
]);

/// Fate-line candidate: central (x ~0.50), vertical.
List<Offset> get _fateLine => _path([
  for (var i = 0; i <= 12; i++) [0.49 + i * 0.001, 0.20 + i * 0.052],
]);

/// Wraps paths into a minimal [PalmLineExtractionResult] with enough data to
/// bypass the confidence gate in [profileFromExtraction].
PalmLineExtractionResult _extraction(List<List<Offset>> paths) =>
    PalmLineExtractionResult(
      edgePoints: const [],
      candidatePaths: paths,
      confidence: 0.8,
      imageWidth: 512,
      imageHeight: 512,
      edgePointCount: 500,
    );

PalmGeometry _geometry() {
  return const PalmGeometry(
    palmCenter: Offset(0.50, 0.55),
    wristY: 0.92,
    fingerBaseY: 0.12,
    thumbSide: PalmThumbSide.left,
    mainAxisAngle: 0.0,
    palmBounds: Rect.fromLTRB(0.10, 0.08, 0.90, 0.94),
    thenarRegion: Rect.fromLTRB(0.10, 0.43, 0.50, 0.92),
    interiorMaskCoverage: 0.48,
    confidence: 0.90,
  );
}

List<Offset> _palmPath(PalmGeometry geometry, List<Offset> palmPoints) {
  return palmPoints.map(geometry.palmToImage).toList();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // ── PalmLineClassifier ───────────────────────────────────────────────────

  group('PalmLineClassifier', () {
    test('empty extraction returns empty result', () {
      final r = PalmLineClassifier.classify(PalmLineExtractionResult.empty);
      expect(r.lifeLinePath, isNull);
      expect(r.heartLinePath, isNull);
      expect(r.headLinePath, isNull);
      expect(r.fateLinePath, isNull);
      expect(r.lifeLineConfidence, equals(0.0));
    });

    test('left-arcing vertical path is classified as life line', () {
      final r = PalmLineClassifier.classify(_extraction([_lifeLine]));
      expect(
        r.lifeLinePath,
        isNotNull,
        reason: 'left vertical path should be the life line',
      );
      expect(r.lifeLineConfidence, greaterThan(0.25));
    });

    test('horizontal upper path is classified as heart line', () {
      final r = PalmLineClassifier.classify(_extraction([_heartLine]));
      expect(
        r.heartLinePath,
        isNotNull,
        reason: 'horizontal upper path should be the heart line',
      );
      expect(r.heartLineConfidence, greaterThan(0.25));
    });

    test('horizontal middle path is classified as head line', () {
      final r = PalmLineClassifier.classify(_extraction([_headLine]));
      expect(
        r.headLinePath,
        isNotNull,
        reason: 'horizontal middle path should be the head line',
      );
      expect(r.headLineConfidence, greaterThan(0.25));
    });

    test('central vertical path is classified as fate line', () {
      final r = PalmLineClassifier.classify(_extraction([_fateLine]));
      expect(
        r.fateLinePath,
        isNotNull,
        reason: 'central vertical path should be the fate line',
      );
      expect(r.fateLineConfidence, greaterThan(0.25));
    });

    test('four distinct paths are each assigned to a unique line type', () {
      final r = PalmLineClassifier.classify(
        _extraction([_lifeLine, _heartLine, _headLine, _fateLine]),
      );
      expect(r.lifeLinePath, isNotNull);
      expect(r.heartLinePath, isNotNull);
      expect(r.headLinePath, isNotNull);
      expect(r.fateLinePath, isNotNull);
    });

    test('no two line types reference the same path object', () {
      final r = PalmLineClassifier.classify(
        _extraction([_lifeLine, _heartLine, _headLine, _fateLine]),
      );
      final assigned = [
        r.lifeLinePath,
        r.heartLinePath,
        r.headLinePath,
        r.fateLinePath,
      ].whereType<List<Offset>>().toList();
      final identities = assigned.map((p) => identityHashCode(p)).toSet();
      expect(
        identities.length,
        equals(assigned.length),
        reason: 'each line type must hold a distinct path',
      );
    });

    test('lifeLineLengthRatio is positive when a life line is found', () {
      final r = PalmLineClassifier.classify(_extraction([_lifeLine]));
      expect(r.lifeLineLengthRatio, greaterThan(0.0));
    });

    test('headLineCurvature is near 1.0 for a perfectly straight path', () {
      final straight = _path([
        for (var i = 0; i <= 10; i++) [0.1 + i * 0.07, 0.45],
      ]);
      final r = PalmLineClassifier.classify(_extraction([straight]));
      expect(r.headLineCurvature, closeTo(1.0, 0.05));
    });

    test(
      'uses tracker to merge geometry-backed fragments before assignment',
      () {
        final geometry = _geometry();
        final extraction = PalmLineExtractionResult(
          edgePoints: const [],
          candidatePaths: [
            _palmPath(geometry, const [
              Offset(0.16, 0.50),
              Offset(0.32, 0.50),
              Offset(0.44, 0.51),
            ]),
            _palmPath(geometry, const [
              Offset(0.48, 0.51),
              Offset(0.64, 0.52),
              Offset(0.80, 0.53),
            ]),
          ],
          rejectedPaths: const [],
          confidence: 0.8,
          imageWidth: 512,
          imageHeight: 512,
          edgePointCount: 500,
          palmGeometry: geometry,
        );

        final r = PalmLineClassifier.classify(extraction);

        expect(r.headLinePath, isNotNull);
        expect(r.headLinePath!.length, equals(6));
        expect(r.headLineConfidence, greaterThan(0.45));
      },
    );
  });

  // ── profileFromExtraction ────────────────────────────────────────────────

  group('profileFromExtraction', () {
    test(
      'empty extraction falls back to seed-based profile without throwing',
      () {
        final p = profileFromExtraction(
          PalmLineExtractionResult.empty,
          fallbackSeed: 'test_seed',
        );
        expect(p, isA<PalmistryAnalysisProfile>());
      },
    );

    test('low-confidence extraction falls back to seed-based profile', () {
      const lowConf = PalmLineExtractionResult(
        edgePoints: [],
        candidatePaths: [],
        confidence: 0.05,
        imageWidth: 512,
        imageHeight: 512,
        edgePointCount: 10,
      );
      final p = profileFromExtraction(lowConf, fallbackSeed: 'low_conf');
      expect(p, isA<PalmistryAnalysisProfile>());
    });

    test('analysis still runs with unknown hand fallback', () {
      final p = profileFromImagePath(
        'unknown_hand_seed',
        scannedHand: ScannedHand.unknown,
      );
      expect(p, isA<PalmistryAnalysisProfile>());
      expect(p.scannedHand, equals(ScannedHand.unknown));
    });

    test('same fallback seed produces a stable profile across calls', () {
      final a = profileFromExtraction(
        PalmLineExtractionResult.empty,
        fallbackSeed: 'stable_seed',
      );
      final b = profileFromExtraction(
        PalmLineExtractionResult.empty,
        fallbackSeed: 'stable_seed',
      );
      expect(a.lifeLine, equals(b.lifeLine));
      expect(a.heartLine, equals(b.heartLine));
      expect(a.headLine, equals(b.headLine));
      expect(a.fateLine, equals(b.fateLine));
    });

    test('real extraction returns a valid PalmistryAnalysisProfile', () {
      // A long life line: ySpan ≈ 0.66, so arcLength should exceed 0.62 → long.
      final longLife = _path([
        for (var i = 0; i <= 20; i++) [0.20 + i * 0.003, 0.15 + i * 0.033],
      ]);
      final extraction = PalmLineExtractionResult(
        edgePoints: const [],
        candidatePaths: [longLife],
        confidence: 0.75,
        imageWidth: 512,
        imageHeight: 512,
        edgePointCount: 800,
      );
      final p = profileFromExtraction(extraction, fallbackSeed: 'long_life');
      expect(p, isA<PalmistryAnalysisProfile>());
      expect(LifeLine.values.contains(p.lifeLine), isTrue);
    });

    test('no central vertical path produces FateLine.faint', () {
      // Only a horizontal upper path → no fate line candidate passes threshold.
      final p = profileFromExtraction(
        _extraction([_heartLine]),
        fallbackSeed: 'no_fate',
      );
      expect(p.fateLine, equals(FateLine.faint));
    });
  });
}
