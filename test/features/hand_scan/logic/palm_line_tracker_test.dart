import 'package:cat_oracle/features/hand_scan/logic/palm_line_extractor.dart';
import 'package:cat_oracle/features/hand_scan/logic/palm_line_tracker.dart';
import 'package:flutter/material.dart' show Offset, Rect;
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PalmLineTracker', () {
    test('merges nearby compatible head fragments', () {
      final geometry = _geometry(PalmThumbSide.left);
      final tracked = PalmLineTracker.track(
        geometry: geometry,
        candidatePaths: [
          _path(geometry, const [
            Offset(0.18, 0.50),
            Offset(0.34, 0.50),
            Offset(0.44, 0.51),
          ]),
          _path(geometry, const [
            Offset(0.48, 0.51),
            Offset(0.63, 0.52),
            Offset(0.78, 0.53),
          ]),
        ],
      );

      expect(tracked.head, isNotNull);
      expect(tracked.head!.sourceFragmentIds, containsAll([0, 1]));
      expect(tracked.head!.gapCount, equals(1));
      expect(tracked.gapBridges, isNotEmpty);
    });

    test('bridges only small compatible gaps', () {
      final geometry = _geometry(PalmThumbSide.left);
      final tracked = PalmLineTracker.track(
        geometry: geometry,
        candidatePaths: [
          _path(geometry, const [
            Offset(0.14, 0.54),
            Offset(0.30, 0.53),
            Offset(0.42, 0.52),
          ]),
          _path(geometry, const [
            Offset(0.50, 0.51),
            Offset(0.66, 0.50),
            Offset(0.82, 0.50),
          ]),
        ],
      );

      expect(tracked.head, isNotNull);
      expect(tracked.head!.gapCount, equals(1));
      expect(tracked.head!.continuity, greaterThan(0.70));
      expect(tracked.gapBridges.single.distance, lessThan(0.16));
    });

    test('rejects wrong large merge', () {
      final geometry = _geometry(PalmThumbSide.left);
      final tracked = PalmLineTracker.track(
        geometry: geometry,
        candidatePaths: [
          _path(geometry, const [
            Offset(0.15, 0.50),
            Offset(0.30, 0.50),
            Offset(0.42, 0.50),
          ]),
          _path(geometry, const [
            Offset(0.78, 0.82),
            Offset(0.66, 0.84),
            Offset(0.54, 0.86),
          ]),
        ],
      );

      expect(tracked.gapBridges, isEmpty);
      expect(tracked.head?.sourceFragmentIds.length ?? 0, lessThanOrEqualTo(1));
    });

    test('tracks life line fragments on thumb side', () {
      final geometry = _geometry(PalmThumbSide.left);
      final tracked = PalmLineTracker.track(
        geometry: geometry,
        candidatePaths: [
          _path(geometry, const [
            Offset(0.38, 0.12),
            Offset(0.27, 0.28),
            Offset(0.20, 0.44),
          ]),
          _path(geometry, const [
            Offset(0.19, 0.49),
            Offset(0.23, 0.68),
            Offset(0.31, 0.88),
          ]),
        ],
      );

      expect(tracked.life, isNotNull);
      expect(tracked.life!.sourceFragmentIds, containsAll([0, 1]));
      expect(tracked.life!.arcLength, greaterThan(0.45));
    });

    test('tracks head line in middle palm band', () {
      final geometry = _geometry(PalmThumbSide.left);
      final tracked = PalmLineTracker.track(
        geometry: geometry,
        candidatePaths: [
          _path(geometry, const [
            Offset(0.14, 0.48),
            Offset(0.35, 0.50),
            Offset(0.55, 0.52),
            Offset(0.78, 0.54),
          ]),
        ],
      );

      expect(tracked.head, isNotNull);
      expect(tracked.head!.averageConfidence, greaterThan(0.45));
      expect(tracked.heart, isNull);
    });

    test('tracks heart line in upper palm band', () {
      final geometry = _geometry(PalmThumbSide.left);
      final tracked = PalmLineTracker.track(
        geometry: geometry,
        candidatePaths: [
          _path(geometry, const [
            Offset(0.16, 0.24),
            Offset(0.34, 0.22),
            Offset(0.56, 0.21),
            Offset(0.82, 0.22),
          ]),
        ],
      );

      expect(tracked.heart, isNotNull);
      expect(tracked.heart!.averageConfidence, greaterThan(0.45));
      expect(tracked.head, isNull);
    });

    test('returns empty for empty input', () {
      final tracked = PalmLineTracker.track(
        geometry: _geometry(PalmThumbSide.left),
        candidatePaths: const [],
      );

      expect(tracked.majorLines, isEmpty);
      expect(tracked.unknown, isEmpty);
      expect(tracked.rawFragmentCount, equals(0));
    });

    test('returns empty for invalid geometry', () {
      final tracked = PalmLineTracker.track(
        geometry: null,
        candidatePaths: [
          const [Offset(0.1, 0.1), Offset(0.3, 0.3)],
        ],
      );

      expect(tracked.majorLines, isEmpty);
      expect(tracked.unknown, isEmpty);
    });
  });
}

PalmGeometry _geometry(PalmThumbSide thumbSide) {
  final thenar = thumbSide == PalmThumbSide.right
      ? const Rect.fromLTRB(0.50, 0.43, 0.90, 0.92)
      : const Rect.fromLTRB(0.10, 0.43, 0.50, 0.92);
  return PalmGeometry(
    palmCenter: const Offset(0.50, 0.55),
    wristY: 0.92,
    fingerBaseY: 0.12,
    thumbSide: thumbSide,
    mainAxisAngle: 0.0,
    palmBounds: const Rect.fromLTRB(0.10, 0.08, 0.90, 0.94),
    thenarRegion: thenar,
    interiorMaskCoverage: 0.48,
    confidence: 0.90,
  );
}

List<Offset> _path(PalmGeometry geometry, List<Offset> palmPoints) {
  return palmPoints.map(geometry.palmToImage).toList();
}
