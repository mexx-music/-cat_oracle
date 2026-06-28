import 'dart:math';

import 'package:cat_oracle/features/hand_scan/logic/palm_line_extractor.dart';
import 'package:cat_oracle/features/hand_scan/logic/palm_line_hypothesis_engine.dart';
import 'package:flutter/material.dart' show Offset, Rect;
import 'package:flutter_test/flutter_test.dart';

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

PalmLineTraceEvidence _trace(
  PalmGeometry geometry,
  String id,
  List<Offset> palmPoints, {
  double probability = 0.82,
  double continuity = 0.92,
  double prior = 0.70,
  int gapCount = 0,
  double ridge = 0.74,
  double ridgeMax = 0.88,
  double ridgeConsistency = 0.82,
  double ridgeWidth = 4.0,
  double darkness = 0.62,
  double majorLineScore = 0.72,
  String rejectionReason = 'accepted',
}) {
  return PalmLineTraceEvidence(
    id: id,
    points: palmPoints.map(geometry.palmToImage).toList(),
    averageProbability: probability,
    continuity: continuity,
    anatomicalPriorScore: prior,
    gapCount: gapCount,
    averageRidgeResponse: ridge,
    maximumRidgeResponse: ridgeMax,
    ridgeConsistency: ridgeConsistency,
    ridgeWidthEstimate: ridgeWidth,
    averageDarkness: darkness,
    majorLineScore: majorLineScore,
    rejectionReason: rejectionReason,
  );
}

List<Offset> _lifePalm() => const [
  Offset(0.40, 0.08),
  Offset(0.30, 0.22),
  Offset(0.20, 0.45),
  Offset(0.30, 0.70),
  Offset(0.46, 0.92),
];

List<Offset> _shortThumbWrinklePalm(double y) => [
  for (var i = 0; i <= 5; i++) Offset(0.14 + i * 0.045, y),
];

List<Offset> _lifeFragmentPalm(double y0, double y1) => [
  for (var i = 0; i <= 4; i++)
    Offset(
      0.40 - 0.20 * sin(((y0 + (y1 - y0) * i / 4) * pi).clamp(0.0, pi)),
      y0 + (y1 - y0) * i / 4,
    ),
];

List<Offset> _heartPalm([double y = 0.24]) => [
  for (var i = 0; i <= 10; i++) Offset(0.10 + i * 0.08, y),
];

List<Offset> _headPalm() => [
  for (var i = 0; i <= 10; i++) Offset(0.14 + i * 0.074, 0.40 + i * 0.012),
];

List<Offset> _fatePalm() => [
  for (var i = 0; i <= 10; i++) Offset(0.50, 0.25 + i * 0.058),
];

void main() {
  group('LineHypothesisEngine', () {
    test('generates top five hypotheses per line type', () {
      final geometry = _geometry();
      final traces = [
        for (var i = 0; i < 7; i++)
          _trace(geometry, 'heart_$i', _heartPalm(0.21 + i * 0.018)),
      ];

      final solution = LineHypothesisEngine.solve(
        geometry: geometry,
        traces: traces,
      );
      final heartTop = solution.topHypotheses[PalmLineHypothesisType.heart]!;

      expect(heartTop.length, equals(5));
      for (var i = 1; i < heartTop.length; i++) {
        expect(heartTop[i - 1].score, greaterThanOrEqualTo(heartTop[i].score));
      }
    });

    test('solves global assignment with unique trace ownership', () {
      final geometry = _geometry();
      final solution = LineHypothesisEngine.solve(
        geometry: geometry,
        traces: [
          _trace(geometry, 'life', _lifePalm()),
          _trace(geometry, 'heart', _heartPalm()),
          _trace(geometry, 'head', _headPalm()),
          _trace(geometry, 'fate', _fatePalm()),
        ],
      );

      expect(solution.life, isNotNull);
      expect(solution.heart, isNotNull);
      expect(solution.head, isNotNull);
      expect(solution.fate, isNotNull);
      final assignedTraceIds = {
        solution.life!.traceId,
        solution.heart!.traceId,
        solution.head!.traceId,
        solution.fate!.traceId,
      };
      expect(assignedTraceIds.length, equals(4));
      expect(solution.totalAnatomicalScore, greaterThan(1.0));
    });

    test('does not force a fate assignment from horizontal traces', () {
      final geometry = _geometry();
      final solution = LineHypothesisEngine.solve(
        geometry: geometry,
        traces: [
          _trace(geometry, 'life', _lifePalm()),
          _trace(geometry, 'heart', _heartPalm()),
          _trace(geometry, 'head', _headPalm()),
        ],
      );

      expect(solution.life, isNotNull);
      expect(solution.heart, isNotNull);
      expect(solution.head, isNotNull);
      expect(solution.fate, isNull);
    });

    test('reports uncertainty when alternatives are nearly equal', () {
      final geometry = _geometry();
      final solution = LineHypothesisEngine.solve(
        geometry: geometry,
        traces: [
          _trace(geometry, 'heart_a', _heartPalm(0.235)),
          _trace(geometry, 'heart_b', _heartPalm(0.238)),
        ],
      );

      expect(solution.alternativeScore, greaterThan(0));
      expect(solution.scoreDifference, lessThan(solution.totalAnatomicalScore));
    });

    test('broad life line outranks short thumb wrinkles', () {
      final geometry = _geometry();
      final solution = LineHypothesisEngine.solve(
        geometry: geometry,
        traces: [
          _trace(
            geometry,
            'broad_life',
            _lifePalm(),
            probability: 0.72,
            ridgeWidth: 7.0,
            majorLineScore: 0.88,
          ),
          _trace(
            geometry,
            'thumb_wrinkle',
            _shortThumbWrinklePalm(0.38),
            probability: 0.94,
            continuity: 0.95,
            prior: 0.22,
            ridgeWidth: 2.0,
            majorLineScore: 0.16,
            rejectionReason: 'thumb_mound_wrinkle',
          ),
        ],
      );

      expect(solution.life?.traceId, equals('broad_life'));
    });

    test('faint anatomically correct life line beats dark local wrinkle', () {
      final geometry = _geometry();
      final solution = LineHypothesisEngine.solve(
        geometry: geometry,
        traces: [
          _trace(
            geometry,
            'faint_life',
            _lifePalm(),
            probability: 0.38,
            ridge: 0.42,
            ridgeMax: 0.58,
            darkness: 0.28,
            majorLineScore: 0.74,
          ),
          _trace(
            geometry,
            'dark_short_wrinkle',
            _shortThumbWrinklePalm(0.44),
            probability: 0.96,
            prior: 0.18,
            majorLineScore: 0.14,
            rejectionReason: 'short',
          ),
        ],
      );

      expect(solution.life?.traceId, equals('faint_life'));
    });

    test('fragmented life line stays preferred over short alternatives', () {
      final geometry = _geometry();
      final solution = LineHypothesisEngine.solve(
        geometry: geometry,
        traces: [
          _trace(
            geometry,
            'fragmented_life',
            _lifePalm(),
            probability: 0.62,
            continuity: 0.72,
            gapCount: 2,
            majorLineScore: 0.76,
          ),
          _trace(
            geometry,
            'short_life_like_fragment',
            _lifeFragmentPalm(0.22, 0.38),
            probability: 0.90,
            continuity: 0.92,
            prior: 0.58,
            majorLineScore: 0.24,
            rejectionReason: 'short',
          ),
        ],
      );

      expect(solution.life?.traceId, equals('fragmented_life'));
    });

    test('competing short thumb wrinkles are suppressed for life line', () {
      final geometry = _geometry();
      final traces = [
        _trace(
          geometry,
          'true_life',
          _lifePalm(),
          probability: 0.70,
          majorLineScore: 0.82,
        ),
        for (var i = 0; i < 4; i++)
          _trace(
            geometry,
            'thumb_wrinkle_$i',
            _shortThumbWrinklePalm(0.30 + i * 0.06),
            probability: 0.92,
            prior: 0.20,
            ridgeWidth: 2.0,
            majorLineScore: 0.12,
            rejectionReason: 'thumb_mound_wrinkle',
          ),
      ];

      final solution = LineHypothesisEngine.solve(
        geometry: geometry,
        traces: traces,
      );

      expect(solution.life?.traceId, equals('true_life'));
      expect(
        solution.topHypotheses[PalmLineHypothesisType.life]!.first.traceId,
        equals('true_life'),
      );
    });

    test('long continuous line beats many short segments', () {
      final geometry = _geometry();
      final solution = LineHypothesisEngine.solve(
        geometry: geometry,
        traces: [
          _trace(
            geometry,
            'long_continuous_life',
            _lifePalm(),
            probability: 0.70,
            continuity: 0.96,
            majorLineScore: 0.86,
          ),
          for (var i = 0; i < 7; i++)
            _trace(
              geometry,
              'short_segment_$i',
              _lifeFragmentPalm(0.12 + i * 0.09, 0.17 + i * 0.09),
              probability: 0.94,
              continuity: 0.90,
              prior: 0.60,
              majorLineScore: 0.20,
              rejectionReason: 'short',
            ),
        ],
      );

      expect(solution.life?.traceId, equals('long_continuous_life'));
    });
  });
}
