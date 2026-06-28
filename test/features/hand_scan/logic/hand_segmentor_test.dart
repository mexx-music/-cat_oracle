import 'dart:typed_data';

import 'package:cat_oracle/features/hand_scan/logic/hand_segmentor.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List _whiteImage(int w, int h) {
  final pixels = Uint8List(w * h * 4);
  for (int i = 0; i < pixels.length; i += 4) {
    pixels[i] = 252;
    pixels[i + 1] = 252;
    pixels[i + 2] = 252;
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

  if (withNoiseIsland) {
    _paintRect(pixels, w, h, 56, 82, 62, 90);
  }

  return pixels;
}

Map<String, dynamic> _segment(Uint8List pixels, int w, int h) {
  return segmentPixelsForTest(SegInput(pixels: pixels, width: w, height: h));
}

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
      ]) {
        expect(raw.containsKey(key), isTrue, reason: 'missing key: $key');
      }
      expect(raw['mask'], isA<Uint8List>());
    });
  });
}
