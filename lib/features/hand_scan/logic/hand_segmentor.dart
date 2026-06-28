import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

// ── Grade ──────────────────────────────────────────────────────────────────────

enum SegmentationGrade { excellent, good, acceptable, poor }

// ── Result ─────────────────────────────────────────────────────────────────────

class HandSegmentResult {
  const HandSegmentResult({
    required this.mask,
    required this.maskWidth,
    required this.maskHeight,
    required this.cutoutBytes,
    required this.maskCoverage,
    required this.edgeConfidence,
    required this.fingerVisibility,
    required this.thumbVisibility,
    required this.wristVisibility,
    required this.backgroundUniformity,
    required this.grade,
  });

  static HandSegmentResult get empty => HandSegmentResult(
    mask: const [],
    maskWidth: 0,
    maskHeight: 0,
    cutoutBytes: Uint8List(0),
    maskCoverage: 0.5,
    edgeConfidence: 0.5,
    fingerVisibility: 0.5,
    thumbVisibility: 0.5,
    wristVisibility: 0.5,
    backgroundUniformity: 0.5,
    grade: SegmentationGrade.acceptable,
  );

  /// Binary hand mask at [maskWidth] × [maskHeight]. true = hand pixel.
  final List<bool> mask;
  final int maskWidth;
  final int maskHeight;

  /// White-background cutout as PNG bytes, for preview display only.
  final Uint8List cutoutBytes;

  // ── Quality metrics (all [0, 1]) ───────────────────────────────────────────
  final double maskCoverage;
  final double edgeConfidence;
  final double fingerVisibility;
  final double thumbVisibility;
  final double wristVisibility;
  final double backgroundUniformity;
  final SegmentationGrade grade;
}

// ── Segmentor ──────────────────────────────────────────────────────────────────

class HandSegmentor {
  HandSegmentor._();

  static Future<HandSegmentResult> segment(Uint8List imageBytes) async {
    if (imageBytes.isEmpty) return HandSegmentResult.empty;
    try {
      const targetW = 256;
      final codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: targetW,
      );
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;
      final imgW = uiImage.width;
      final imgH = uiImage.height;
      final byteData = await uiImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      uiImage.dispose();
      if (byteData == null) return HandSegmentResult.empty;

      final pixels = byteData.buffer.asUint8List();
      final raw = await compute(
        segmentPixelsIsolate,
        SegInput(pixels: pixels, width: imgW, height: imgH),
      );

      final maskBytes = raw['mask'] as Uint8List;
      final mask = List<bool>.generate(
        maskBytes.length,
        (i) => maskBytes[i] != 0,
        growable: false,
      );

      // Build white-background cutout RGBA for display.
      final cutoutRgba = Uint8List(imgW * imgH * 4);
      for (int i = 0; i < imgW * imgH; i++) {
        if (mask[i]) {
          cutoutRgba[i * 4] = pixels[i * 4];
          cutoutRgba[i * 4 + 1] = pixels[i * 4 + 1];
          cutoutRgba[i * 4 + 2] = pixels[i * 4 + 2];
          cutoutRgba[i * 4 + 3] = 255;
        } else {
          cutoutRgba[i * 4] = 255;
          cutoutRgba[i * 4 + 1] = 255;
          cutoutRgba[i * 4 + 2] = 255;
          cutoutRgba[i * 4 + 3] = 255;
        }
      }

      // Encode to PNG on UI thread.
      var cutoutBytes = Uint8List(0);
      try {
        final completer = Completer<ui.Image>();
        ui.decodeImageFromPixels(
          cutoutRgba,
          imgW,
          imgH,
          ui.PixelFormat.rgba8888,
          (img) => completer.complete(img),
        );
        final cutoutUi = await completer.future;
        final pngData = await cutoutUi.toByteData(
          format: ui.ImageByteFormat.png,
        );
        cutoutUi.dispose();
        if (pngData != null) cutoutBytes = pngData.buffer.asUint8List();
      } catch (_) {}

      final maskCoverage = (raw['maskCoverage'] as num).toDouble();
      final edgeConfidence = (raw['edgeConfidence'] as num).toDouble();
      final fingerVisibility = (raw['fingerVisibility'] as num).toDouble();
      final thumbVisibility = (raw['thumbVisibility'] as num).toDouble();
      final wristVisibility = (raw['wristVisibility'] as num).toDouble();
      final backgroundUniformity = (raw['backgroundUniformity'] as num)
          .toDouble();

      return HandSegmentResult(
        mask: mask,
        maskWidth: imgW,
        maskHeight: imgH,
        cutoutBytes: cutoutBytes,
        maskCoverage: maskCoverage,
        edgeConfidence: edgeConfidence,
        fingerVisibility: fingerVisibility,
        thumbVisibility: thumbVisibility,
        wristVisibility: wristVisibility,
        backgroundUniformity: backgroundUniformity,
        grade: _grade(
          maskCoverage,
          edgeConfidence,
          fingerVisibility,
          wristVisibility,
        ),
      );
    } catch (_) {
      return HandSegmentResult.empty;
    }
  }

  static SegmentationGrade _grade(
    double coverage,
    double edge,
    double finger,
    double wrist,
  ) {
    final scores = [coverage, edge, finger, wrist];
    final minScore = scores.reduce(min);
    final avgScore = scores.fold(0.0, (a, b) => a + b) / scores.length;
    if (minScore >= 0.70) return SegmentationGrade.excellent;
    if (minScore >= 0.45) return SegmentationGrade.good;
    if (avgScore >= 0.28) return SegmentationGrade.acceptable;
    return SegmentationGrade.poor;
  }
}

// ── Isolate input ──────────────────────────────────────────────────────────────

class SegInput {
  const SegInput({
    required this.pixels,
    required this.width,
    required this.height,
  });

  final Uint8List pixels; // RGBA, 4 bytes per pixel
  final int width;
  final int height;
}

// ── Core segmentation (top-level for compute()) ────────────────────────────────

// Named non-private so it can be referenced from test helpers and from
// the _applyHandMask helper in palm_line_extractor.
Map<String, dynamic> segmentPixelsIsolate(SegInput input) {
  final w = input.width;
  final h = input.height;
  final pixels = input.pixels;
  final total = w * h;

  Map<String, dynamic> emptyResult() => {
    'mask': Uint8List(total),
    'maskCoverage': 0.0,
    'edgeConfidence': 0.0,
    'fingerVisibility': 0.0,
    'thumbVisibility': 0.0,
    'wristVisibility': 0.0,
    'backgroundUniformity': 1.0,
  };

  if (w < 8 || h < 8 || pixels.length < total * 4) return emptyResult();

  // 1. Skin detection: multi-criteria (RGB rule + YCrCb approximation).
  final skinRaw = Uint8List(total);
  for (int i = 0; i < total; i++) {
    final base = i * 4;
    final r = pixels[base];
    final g = pixels[base + 1];
    final b = pixels[base + 2];
    if (_isSkin(r, g, b)) skinRaw[i] = 255;
  }

  // 2. BFS connected components → keep largest.
  var mask = _largestComponentMask(skinRaw, w, h);

  // 3. Morphological close (box): fill gaps between fingers.
  final closeR = max(5, (min(w, h) * 0.042).round());
  mask = _dilateBox(mask, w, h, closeR);
  mask = _erodeBox(mask, w, h, closeR);

  // 4. Hole filling: BFS from image borders, mark reachable non-hand pixels;
  //    remaining zero pixels are interior holes → filled.
  mask = _fillHoles(mask, w, h);

  // 5. Dilate slightly to recover excluded skin edges.
  mask = _dilateBox(mask, w, h, 3);

  // 6. Quality metrics.
  final handCount = _countOnes(mask);
  final maskCoverage = total > 0 ? (handCount / total).clamp(0.0, 1.0) : 0.0;

  // Coverage score: target 40–85 % for a proper palm photo.
  final coverageScore = _coverageScore(maskCoverage);

  // Edge confidence: mean gradient magnitude at mask boundary / 80.
  final edgeConfidence = _edgeConfidence(mask, pixels, w, h);

  // Finger visibility: mask reaches top 20 % of image.
  final fingerVisibility = _regionFill(mask, w, 0, (h * 0.20).round(), w, 0.08);

  // Wrist visibility: mask reaches bottom 15 % of image.
  final wristStart = (h * 0.85).round();
  final wristVisibility = _regionFill(mask, w, wristStart, h, w, 0.25);

  // Thumb visibility: mask present in left OR right band of upper half.
  final thumbBandW = max(4, (w * 0.14).round());
  final thumbVisibility = _thumbScore(mask, w, h, thumbBandW);

  // Background uniformity: std-dev of non-mask pixel luminance.
  final backgroundUniformity = _backgroundUniformity(mask, pixels, total);

  return {
    'mask': mask,
    'maskCoverage': coverageScore,
    'edgeConfidence': edgeConfidence,
    'fingerVisibility': fingerVisibility,
    'thumbVisibility': thumbVisibility,
    'wristVisibility': wristVisibility,
    'backgroundUniformity': backgroundUniformity,
  };
}

// ── Private helpers (isolate-safe, no dart:ui) ─────────────────────────────────

bool _isSkin(int r, int g, int b) {
  final luma = (r * 0.299 + g * 0.587 + b * 0.114).round();
  if (luma < 25 || luma > 240) return false;
  // Kovac RGB rule.
  final rule1 =
      r > 95 &&
      g > 40 &&
      b > 20 &&
      r > g &&
      r > b &&
      (r - b) > 15 &&
      (r - g).abs() <= 50;
  // YCrCb approximation.
  final cr = 128 + 0.5 * r - 0.4187 * g - 0.0813 * b;
  final cb = 128 - 0.1687 * r - 0.3313 * g + 0.5 * b;
  final rule2 = cr >= 133 && cr <= 173 && cb >= 77 && cb <= 127;
  return rule1 || rule2;
}

Uint8List _largestComponentMask(Uint8List skin, int w, int h) {
  final total = w * h;
  final labels = List<int>.filled(total, -1);
  final labelSizes = <int, int>{};
  var nextLabel = 0;

  for (int start = 0; start < total; start++) {
    if (skin[start] == 0 || labels[start] >= 0) continue;
    final label = nextLabel++;
    final queue = <int>[start];
    labels[start] = label;
    var qi = 0;
    var size = 0;
    while (qi < queue.length) {
      final i = queue[qi++];
      size++;
      final x = i % w;
      final y = i ~/ w;
      if (x > 0 && skin[i - 1] != 0 && labels[i - 1] < 0) {
        labels[i - 1] = label;
        queue.add(i - 1);
      }
      if (x < w - 1 && skin[i + 1] != 0 && labels[i + 1] < 0) {
        labels[i + 1] = label;
        queue.add(i + 1);
      }
      if (y > 0 && skin[i - w] != 0 && labels[i - w] < 0) {
        labels[i - w] = label;
        queue.add(i - w);
      }
      if (y < h - 1 && skin[i + w] != 0 && labels[i + w] < 0) {
        labels[i + w] = label;
        queue.add(i + w);
      }
    }
    labelSizes[label] = size;
  }

  var largest = -1;
  var largestSz = 0;
  for (final e in labelSizes.entries) {
    if (e.value > largestSz) {
      largestSz = e.value;
      largest = e.key;
    }
  }

  final result = Uint8List(total);
  if (largest >= 0) {
    for (int i = 0; i < total; i++) {
      if (labels[i] == largest) result[i] = 255;
    }
  }
  return result;
}

Uint8List _dilateBox(Uint8List mask, int w, int h, int r) {
  // Separable horizontal pass.
  final temp = Uint8List(mask.length);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final x0 = max(0, x - r);
      final x1 = min(w - 1, x + r);
      var found = false;
      for (int nx = x0; nx <= x1; nx++) {
        if (mask[y * w + nx] != 0) {
          found = true;
          break;
        }
      }
      if (found) temp[y * w + x] = 255;
    }
  }
  // Vertical pass.
  final result = Uint8List(mask.length);
  for (int y = 0; y < h; y++) {
    final y0 = max(0, y - r);
    final y1 = min(h - 1, y + r);
    for (int x = 0; x < w; x++) {
      var found = false;
      for (int ny = y0; ny <= y1; ny++) {
        if (temp[ny * w + x] != 0) {
          found = true;
          break;
        }
      }
      if (found) result[y * w + x] = 255;
    }
  }
  return result;
}

Uint8List _erodeBox(Uint8List mask, int w, int h, int r) {
  // Separable horizontal pass.
  final temp = Uint8List(mask.length);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      if (mask[y * w + x] == 0) continue;
      final x0 = max(0, x - r);
      final x1 = min(w - 1, x + r);
      var allSet = true;
      for (int nx = x0; nx <= x1; nx++) {
        if (mask[y * w + nx] == 0) {
          allSet = false;
          break;
        }
      }
      if (allSet) temp[y * w + x] = 255;
    }
  }
  // Vertical pass.
  final result = Uint8List(mask.length);
  for (int y = 0; y < h; y++) {
    final y0 = max(0, y - r);
    final y1 = min(h - 1, y + r);
    for (int x = 0; x < w; x++) {
      if (temp[y * w + x] == 0) continue;
      var allSet = true;
      for (int ny = y0; ny <= y1; ny++) {
        if (temp[ny * w + x] == 0) {
          allSet = false;
          break;
        }
      }
      if (allSet) result[y * w + x] = 255;
    }
  }
  return result;
}

Uint8List _fillHoles(Uint8List mask, int w, int h) {
  // BFS from image border: mark all zero-pixels reachable from border.
  // Un-marked zero-pixels are holes → set to 255.
  final total = w * h;
  final outside = Uint8List(total);
  final queue = <int>[];

  void tryAdd(int idx) {
    if (mask[idx] == 0 && outside[idx] == 0) {
      outside[idx] = 1;
      queue.add(idx);
    }
  }

  for (int x = 0; x < w; x++) {
    tryAdd(x);
    tryAdd((h - 1) * w + x);
  }
  for (int y = 1; y < h - 1; y++) {
    tryAdd(y * w);
    tryAdd(y * w + w - 1);
  }

  var qi = 0;
  while (qi < queue.length) {
    final i = queue[qi++];
    final x = i % w;
    final y = i ~/ w;
    if (x > 0) tryAdd(i - 1);
    if (x < w - 1) tryAdd(i + 1);
    if (y > 0) tryAdd(i - w);
    if (y < h - 1) tryAdd(i + w);
  }

  final result = Uint8List.fromList(mask);
  for (int i = 0; i < total; i++) {
    if (mask[i] == 0 && outside[i] == 0) result[i] = 255;
  }
  return result;
}

int _countOnes(Uint8List mask) {
  var c = 0;
  for (final v in mask) {
    if (v != 0) c++;
  }
  return c;
}

double _coverageScore(double coverage) {
  if (coverage >= 0.40 && coverage <= 0.85) return 1.0;
  if (coverage < 0.40) return (coverage / 0.40).clamp(0.0, 1.0);
  return (1.0 - (coverage - 0.85) / 0.15).clamp(0.0, 1.0);
}

double _edgeConfidence(Uint8List mask, Uint8List pixels, int w, int h) {
  double magSum = 0.0;
  int count = 0;
  for (int y = 1; y < h - 1; y++) {
    for (int x = 1; x < w - 1; x++) {
      final i = y * w + x;
      if (mask[i] == 0) continue;
      // Boundary pixel: has at least one background neighbour.
      if (mask[i - 1] != 0 &&
          mask[i + 1] != 0 &&
          mask[i - w] != 0 &&
          mask[i + w] != 0) {
        continue;
      }
      final lumaL =
          pixels[(i - 1) * 4] * 0.299 +
          pixels[(i - 1) * 4 + 1] * 0.587 +
          pixels[(i - 1) * 4 + 2] * 0.114;
      final lumaR =
          pixels[(i + 1) * 4] * 0.299 +
          pixels[(i + 1) * 4 + 1] * 0.587 +
          pixels[(i + 1) * 4 + 2] * 0.114;
      final lumaU =
          pixels[(i - w) * 4] * 0.299 +
          pixels[(i - w) * 4 + 1] * 0.587 +
          pixels[(i - w) * 4 + 2] * 0.114;
      final lumaD =
          pixels[(i + w) * 4] * 0.299 +
          pixels[(i + w) * 4 + 1] * 0.587 +
          pixels[(i + w) * 4 + 2] * 0.114;
      final gx = (lumaR - lumaL).abs();
      final gy = (lumaD - lumaU).abs();
      magSum += sqrt(gx * gx + gy * gy);
      count++;
    }
  }
  return count > 0 ? (magSum / count / 80.0).clamp(0.0, 1.0) : 0.0;
}

double _regionFill(
  Uint8List mask,
  int w,
  int yStart,
  int yEnd,
  int totalW,
  double fillTarget,
) {
  var count = 0;
  final area = (yEnd - yStart) * totalW;
  for (int y = yStart; y < yEnd; y++) {
    for (int x = 0; x < totalW; x++) {
      if (mask[y * totalW + x] != 0) count++;
    }
  }
  return area > 0 ? (count / (area * fillTarget)).clamp(0.0, 1.0) : 0.0;
}

double _thumbScore(Uint8List mask, int w, int h, int bandW) {
  var count = 0;
  final halfH = h ~/ 2;
  for (int y = 0; y < halfH; y++) {
    for (int x = 0; x < bandW; x++) {
      if (mask[y * w + x] != 0) count++;
      if (mask[y * w + (w - 1 - x)] != 0) count++;
    }
  }
  final area = halfH * bandW * 2;
  return area > 0 ? (count / (area * 0.10)).clamp(0.0, 1.0) : 0.0;
}

double _backgroundUniformity(Uint8List mask, Uint8List pixels, int total) {
  double sumL = 0;
  double sumL2 = 0;
  int cnt = 0;
  for (int i = 0; i < total; i++) {
    if (mask[i] != 0) continue;
    final luma =
        pixels[i * 4] * 0.299 +
        pixels[i * 4 + 1] * 0.587 +
        pixels[i * 4 + 2] * 0.114;
    sumL += luma;
    sumL2 += luma * luma;
    cnt++;
  }
  if (cnt < 10) return 1.0; // no/few background pixels → assume uniform
  final mean = sumL / cnt;
  final variance = sumL2 / cnt - mean * mean;
  final stddev = sqrt(variance.clamp(0.0, 1e9));
  return (1.0 - stddev / 80.0).clamp(0.0, 1.0);
}

// ── Test helper ────────────────────────────────────────────────────────────────

@visibleForTesting
Map<String, dynamic> segmentPixelsForTest(SegInput input) =>
    segmentPixelsIsolate(input);
