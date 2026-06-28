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
}) {
  return PalmLineTraceEvidence(
    id: id,
    points: palmPoints.map(geometry.palmToImage).toList(),
    averageProbability: probability,
    continuity: continuity,
    anatomicalPriorScore: prior,
  );
}

List<Offset> _lifePalm() => const [
  Offset(0.40, 0.08),
  Offset(0.30, 0.22),
  Offset(0.20, 0.45),
  Offset(0.30, 0.70),
  Offset(0.46, 0.92),
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
  });
}
