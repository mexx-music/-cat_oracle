import 'dart:typed_data';

import 'package:cat_oracle/features/hand_scan/logic/palm_line_continuation.dart';
import 'package:flutter_test/flutter_test.dart';

// ── helpers ───────────────────────────────────────────────────────────────────

/// Fills a w×h RGBA buffer with a uniform bright colour (simulates palm skin).
Uint8List _bright(int w, int h, {int v = 180}) {
  final px = Uint8List(w * h * 4);
  for (int i = 0; i < px.length; i += 4) {
    px[i] = v;
    px[i + 1] = v;
    px[i + 2] = v;
    px[i + 3] = 255;
  }
  return px;
}

/// Paints a [thick]-pixel wide dark vertical stripe at column [cx] spanning
/// y = [y0]..[y1].  All other pixels remain at [bgV].
Uint8List _withStripe(
  int w,
  int h,
  int cx,
  int y0,
  int y1, {
  int bgV = 180,
  int lineV = 60,
  int thick = 3,
}) {
  final px = _bright(w, h, v: bgV);
  for (int y = y0; y <= y1; y++) {
    for (int dx = -(thick ~/ 2); dx <= thick ~/ 2; dx++) {
      final x = (cx + dx).clamp(0, w - 1);
      final base = (y * w + x) * 4;
      px[base] = lineV;
      px[base + 1] = lineV;
      px[base + 2] = lineV;
      px[base + 3] = 255;
    }
  }
  return px;
}

// ── tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('PalmLineContinuationResult', () {
    test('none sentinel has correct defaults', () {
      const r = PalmLineContinuationResult.none;
      expect(r.wasExtended, isFalse);
      expect(r.extensionPointCount, equals(0));
      expect(r.extendedPath, isEmpty);
      expect(r.extensionArcLength, equals(0.0));
      expect(r.extensionConfidence, equals(0.0));
    });

    test('originalPath returns full path when not extended', () {
      const r = PalmLineContinuationResult(
        extendedPath: [],
        wasExtended: false,
        extensionPointCount: 0,
        oldEndY: 0.5,
        newEndY: 0.5,
        extensionArcLength: 0.0,
        extensionConfidence: 0.0,
      );
      expect(r.originalPath, isEmpty);
      expect(r.extensionPoints, isEmpty);
    });
  });

  group('runContinuationForTest', () {
    test('uniform image → no extension', () {
      // No dark ridges → continuation finds nothing.
      const w = 100, h = 200;
      final pixels = _bright(w, h);
      final path = [
        [0.27, 0.10],
        [0.27, 0.30],
        [0.27, 0.50],
      ];

      final result = runContinuationForTest(pixels, w, h, path);

      expect(result['wasExtended'], isFalse);
      expect(result['extensionPointCount'], equals(0));
    });

    test('dark vertical stripe → extension follows it', () {
      // The "detected" path covers only the top half of a stripe that runs
      // the full height.  Continuation should extend into the lower half.
      const w = 100, h = 200;
      // Stripe at x≈27 (norm 0.27 × 100) spanning y=0..180 (norm 0..0.90)
      final cx = (0.27 * w).round();
      final pixels = _withStripe(w, h, cx, 0, 180, bgV: 180, lineV: 60);

      final path = [
        [0.27, 0.10],
        [0.27, 0.20],
        [0.27, 0.30],
        [0.27, 0.40],
        [0.27, 0.50], // detected end
      ];

      final result = runContinuationForTest(pixels, w, h, path);

      // Extension should have been found
      expect(result['wasExtended'], isTrue,
          reason: 'Dark ridge exists below detected endpoint');
      expect(result['extensionPointCount'], greaterThan(0));
      expect(
        (result['newEndY'] as double),
        greaterThan(result['oldEndY'] as double),
        reason: 'Extension must progress further down the palm',
      );
      expect(result['extensionArcLength'], greaterThan(0.0));
    });

    test('extension points stay within [0, 1] bounds', () {
      // Stripe near the bottom; any extension must stay within image bounds.
      const w = 80, h = 200;
      final cx = (0.30 * w).round();
      final pixels = _withStripe(w, h, cx, 0, 195);

      final path = [
        [0.30, 0.50],
        [0.30, 0.60],
        [0.30, 0.72],
      ];

      final result = runContinuationForTest(pixels, w, h, path);

      final extPath = result['extendedPath'] as List<dynamic>;
      for (final pt in extPath) {
        final l = pt as List;
        final nx = (l[0] as num).toDouble();
        final ny = (l[1] as num).toDouble();
        expect(nx, inInclusiveRange(0.0, 1.0),
            reason: 'X coordinate must be in [0,1]');
        expect(ny, inInclusiveRange(0.0, 1.0),
            reason: 'Y coordinate must be in [0,1]');
      }
    });

    test('extension arc length is positive when extended', () {
      const w = 100, h = 200;
      final cx = (0.27 * w).round();
      final pixels = _withStripe(w, h, cx, 0, 190);

      final path = [
        [0.27, 0.10],
        [0.27, 0.25],
        [0.27, 0.42],
      ];

      final result = runContinuationForTest(pixels, w, h, path);
      if (result['wasExtended'] as bool) {
        expect(result['extensionArcLength'], greaterThan(0.0));
      }
    });

    test('short path (< 3 points) is returned unchanged', () {
      const w = 100, h = 100;
      final pixels = _bright(w, h);
      final path = [
        [0.3, 0.3],
        [0.3, 0.5],
      ];

      final result = runContinuationForTest(pixels, w, h, path);

      expect(result['wasExtended'], isFalse);
      expect(result['skipReason'], isNotNull);
    });

    test('extension points never go above original endpoint Y', () {
      // Ensure continuation only searches forward (downward), not upward.
      const w = 100, h = 200;
      final cx = (0.27 * w).round();
      final pixels = _withStripe(w, h, cx, 0, 180);

      final path = [
        [0.27, 0.10],
        [0.27, 0.30],
        [0.27, 0.50],
      ];

      final result = runContinuationForTest(pixels, w, h, path);

      final extCount = result['extensionPointCount'] as int;
      final extPath = result['extendedPath'] as List<dynamic>;
      final endY = (path.last[1] as num).toDouble();

      // Only the EXTENSION portion (last extCount points) must be below endY.
      final extOnly = extPath.skip(extPath.length - extCount);
      for (final pt in extOnly) {
        final ny = ((pt as List)[1] as num).toDouble();
        expect(ny, greaterThanOrEqualTo(endY - 0.02),
            reason: 'Extension must not go above original end Y');
      }
    });
  });
}
