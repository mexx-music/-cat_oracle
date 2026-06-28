import 'dart:typed_data';

import 'package:cat_oracle/features/hand_scan/logic/hand_segmentor.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _whiteImage(int w, int h) {
  return _solidImage(w, h, 252, 252, 252);
}

Uint8List _solidImage(int w, int h, int r, int g, int b) {
  final pixels = Uint8List(w * h * 4);
  for (int i = 0; i < pixels.length; i += 4) {
    pixels[i] = r;
    pixels[i + 1] = g;
    pixels[i + 2] = b;
    pixels[i + 3] = 255;
  }
  return pixels;
}

void _paintRect(
  Uint8List pixels,
  int w,
  int h,
  int left,
  int top,
  int right,
  int bottom, {
  int r = 178,
  int g = 140,
  int b = 108,
}) {
  for (int y = top.clamp(0, h); y < bottom.clamp(0, h); y++) {
    for (int x = left.clamp(0, w); x < right.clamp(0, w); x++) {
      final base = (y * w + x) * 4;
      pixels[base] = r;
      pixels[base + 1] = g;
      pixels[base + 2] = b;
      pixels[base + 3] = 255;
    }
  }
}

Uint8List _uprightHand(int w, int h, {bool withNoiseIsland = false}) {
  final pixels = _whiteImage(w, h);
  _paintUprightHand(pixels, w, h);

  if (withNoiseIsland) {
    _paintRect(pixels, w, h, 56, 82, 62, 90);
  }

  return pixels;
}

Uint8List _uprightHandOn(int w, int h, int r, int g, int b) {
  final pixels = _solidImage(w, h, r, g, b);
  _paintUprightHand(pixels, w, h);
  return pixels;
}

void _paintUprightHand(Uint8List pixels, int w, int h) {
  // Palm.
  _paintRect(pixels, w, h, 20, 30, 46, 80);

  // Four fingers connected to the palm.
  _paintRect(pixels, w, h, 14, 2, 21, 34);
  _paintRect(pixels, w, h, 23, 0, 30, 34);
  _paintRect(pixels, w, h, 32, 1, 39, 34);
  _paintRect(pixels, w, h, 41, 4, 48, 34);

  // Left thumb and wrist.
  _paintRect(pixels, w, h, 0, 36, 23, 61);
  _paintRect(pixels, w, h, 26, 78, 40, 96);
}

Map<String, dynamic> _segment(Uint8List pixels, int w, int h) {
  return segmentPixelsForTest(SegInput(pixels: pixels, width: w, height: h));
}

int _countMask(Uint8List mask) => mask.where((v) => v != 0).length;

void main() {
  const w = 64;
  const h = 96;

  group('HandSegmentor pixels', () {
    test('detects an upright hand on a plain background', () {
      final raw = _segment(_uprightHand(w, h), w, h);
      final mask = raw['mask'] as Uint8List;

      expect(mask, hasLength(w * h));
      expect(mask[52 * w + 32], isNonZero, reason: 'central palm is hand');
      expect(mask[8 * w + 4], equals(0), reason: 'background stays rejected');
      expect((raw['fingerVisibility'] as num).toDouble(), greaterThan(0.75));
      expect((raw['thumbVisibility'] as num).toDouble(), greaterThan(0.75));
      expect((raw['wristVisibility'] as num).toDouble(), greaterThan(0.5));
      expect((raw['maskCoverage'] as num).toDouble(), greaterThan(0.45));
    });

    test(
      'keeps the largest hand component and rejects a small skin island',
      () {
        final raw = _segment(_uprightHand(w, h, withNoiseIsland: true), w, h);
        final mask = raw['mask'] as Uint8List;

        expect(mask[52 * w + 32], isNonZero);
        expect(mask[86 * w + 59], equals(0));
      },
    );

    test('plain background produces an empty mask safely', () {
      final raw = _segment(_whiteImage(w, h), w, h);
      final mask = raw['mask'] as Uint8List;

      expect(mask.where((v) => v != 0), isEmpty);
      expect((raw['maskCoverage'] as num).toDouble(), equals(0.0));
      expect((raw['edgeConfidence'] as num).toDouble(), equals(0.0));
    });

    test('rejects a wood-table patch attached by a narrow bridge', () {
      final pixels = _uprightHand(w, h);
      _paintRect(pixels, w, h, 50, 48, 63, 82, r: 132, g: 94, b: 58);
      _paintRect(pixels, w, h, 45, 58, 52, 62, r: 132, g: 94, b: 58);

      final raw = _segment(pixels, w, h);
      final mask = raw['mask'] as Uint8List;

      expect(mask[54 * w + 32], isNonZero, reason: 'palm is preserved');
      expect(mask[66 * w + 57], equals(0), reason: 'wood patch is removed');
      expect((raw['backgroundLeakageRatio'] as num).toDouble(), lessThan(0.05));
    });

    test('segments the hand on a white background', () {
      final raw = _segment(_uprightHandOn(w, h, 252, 252, 252), w, h);
      final mask = raw['mask'] as Uint8List;

      expect(mask[52 * w + 32], isNonZero);
      expect(mask[8 * w + 4], equals(0));
      expect(_countMask(mask), greaterThan(1200));
    });

    test('segments the hand on a dark background', () {
      final raw = _segment(_uprightHandOn(w, h, 18, 18, 24), w, h);
      final mask = raw['mask'] as Uint8List;

      expect(mask[52 * w + 32], isNonZero);
      expect(mask[8 * w + 4], equals(0));
      expect((raw['edgeConfidence'] as num).toDouble(), greaterThan(0.25));
    });

    test('rejects noisy background speckles', () {
      final pixels = _uprightHand(w, h);
      for (int y = 0; y < h; y += 7) {
        for (int x = 2; x < w; x += 11) {
          if (x > 48 || y > 82) {
            _paintRect(pixels, w, h, x, y, x + 2, y + 2);
          }
        }
      }

      final raw = _segment(pixels, w, h);
      final mask = raw['mask'] as Uint8List;

      expect(mask[52 * w + 32], isNonZero);
      expect(mask[86 * w + 58], equals(0));
      expect(mask[7 * w + 57], equals(0));
    });

    test('keeps the thumb gap clear while preserving the thumb', () {
      final pixels = _uprightHand(w, h);
      _paintRect(pixels, w, h, 18, 34, 27, 46, r: 252, g: 252, b: 252);

      final raw = _segment(pixels, w, h);
      final mask = raw['mask'] as Uint8List;

      expect(mask[48 * w + 8], isNonZero, reason: 'thumb remains');
      expect(mask[40 * w + 24], equals(0), reason: 'thumb gap stays open');
    });

    test('preserves the wrist and palm after refinement', () {
      final raw = _segment(_uprightHand(w, h), w, h);
      final mask = raw['mask'] as Uint8List;

      expect(mask[55 * w + 32], isNonZero, reason: 'palm remains solid');
      expect(mask[88 * w + 32], isNonZero, reason: 'wrist remains connected');
      expect((raw['wristVisibility'] as num).toDouble(), greaterThan(0.5));
    });

    test('invalid input returns all required debug keys', () {
      final raw = _segment(Uint8List(0), 0, 0);

      for (final key in [
        'mask',
        'maskCoverage',
        'edgeConfidence',
        'fingerVisibility',
        'thumbVisibility',
        'wristVisibility',
        'backgroundUniformity',
        'maskArea',
        'boundaryLength',
        'backgroundLeakageRatio',
        'contourSmoothness',
      ]) {
        expect(raw.containsKey(key), isTrue, reason: 'missing key: $key');
      }
      expect(raw['mask'], isA<Uint8List>());
    });
  });
}
