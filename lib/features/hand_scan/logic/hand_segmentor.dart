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
    required this.currentMaskPreviewBytes,
    required this.refinedMaskPreviewBytes,
    required this.cutoutBytes,
    required this.maskCoverage,
    required this.edgeConfidence,
    required this.fingerVisibility,
    required this.thumbVisibility,
    required this.wristVisibility,
    required this.backgroundUniformity,
    required this.maskArea,
    required this.boundaryLength,
    required this.backgroundLeakageRatio,
    required this.contourSmoothness,
    required this.grade,
  });

  static HandSegmentResult get empty => HandSegmentResult(
    mask: const [],
    maskWidth: 0,
    maskHeight: 0,
    currentMaskPreviewBytes: Uint8List(0),
    refinedMaskPreviewBytes: Uint8List(0),
    cutoutBytes: Uint8List(0),
    maskCoverage: 0.5,
    edgeConfidence: 0.5,
    fingerVisibility: 0.5,
    thumbVisibility: 0.5,
    wristVisibility: 0.5,
    backgroundUniformity: 0.5,
    maskArea: 0,
    boundaryLength: 0,
    backgroundLeakageRatio: 0.0,
    contourSmoothness: 0.0,
    grade: SegmentationGrade.acceptable,
  );

  /// Binary hand mask at [maskWidth] × [maskHeight]. true = hand pixel.
  final List<bool> mask;
  final int maskWidth;
  final int maskHeight;

  /// Preview PNGs for the coarse and first refined binary masks.
  final Uint8List currentMaskPreviewBytes;
  final Uint8List refinedMaskPreviewBytes;

  /// White-background cutout as PNG bytes, for preview display only.
  final Uint8List cutoutBytes;

  // ── Quality metrics (all [0, 1]) ───────────────────────────────────────────
  final double maskCoverage;
  final double edgeConfidence;
  final double fingerVisibility;
  final double thumbVisibility;
  final double wristVisibility;
  final double backgroundUniformity;

  // ── Debug metrics ─────────────────────────────────────────────────────────
  final int maskArea;
  final int boundaryLength;
  final double backgroundLeakageRatio;
  final double contourSmoothness;
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
      final currentMaskBytes = (raw['currentMask'] as Uint8List?) ?? maskBytes;
      final refinedMaskBytes = (raw['refinedMask'] as Uint8List?) ?? maskBytes;

      // Build white-background cutout RGBA for display.
      final cutoutBytes = await _encodeCutoutPreview(
        pixels,
        maskBytes,
        imgW,
        imgH,
      );
      final currentMaskPreviewBytes = await _encodeMaskPreview(
        currentMaskBytes,
        imgW,
        imgH,
      );
      final refinedMaskPreviewBytes = await _encodeMaskPreview(
        refinedMaskBytes,
        imgW,
        imgH,
      );

      final maskCoverage = (raw['maskCoverage'] as num).toDouble();
      final edgeConfidence = (raw['edgeConfidence'] as num).toDouble();
      final fingerVisibility = (raw['fingerVisibility'] as num).toDouble();
      final thumbVisibility = (raw['thumbVisibility'] as num).toDouble();
      final wristVisibility = (raw['wristVisibility'] as num).toDouble();
      final backgroundUniformity = (raw['backgroundUniformity'] as num)
          .toDouble();
      final maskArea = raw['maskArea'] as int;
      final boundaryLength = raw['boundaryLength'] as int;
      final backgroundLeakageRatio = (raw['backgroundLeakageRatio'] as num)
          .toDouble();
      final contourSmoothness = (raw['contourSmoothness'] as num).toDouble();

      return HandSegmentResult(
        mask: mask,
        maskWidth: imgW,
        maskHeight: imgH,
        currentMaskPreviewBytes: currentMaskPreviewBytes,
        refinedMaskPreviewBytes: refinedMaskPreviewBytes,
        cutoutBytes: cutoutBytes,
        maskCoverage: maskCoverage,
        edgeConfidence: edgeConfidence,
        fingerVisibility: fingerVisibility,
        thumbVisibility: thumbVisibility,
        wristVisibility: wristVisibility,
        backgroundUniformity: backgroundUniformity,
        maskArea: maskArea,
        boundaryLength: boundaryLength,
        backgroundLeakageRatio: backgroundLeakageRatio,
        contourSmoothness: contourSmoothness,
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

Future<Uint8List> _encodeCutoutPreview(
  Uint8List pixels,
  Uint8List mask,
  int w,
  int h,
) async {
  final rgba = Uint8List(w * h * 4);
  final feather = _dilateBox(mask, w, h, 1);
  for (int i = 0; i < w * h; i++) {
    final base = i * 4;
    if (mask[i] != 0) {
      final boundary = _isBoundaryPixel(mask, w, h, i);
      final blend = boundary ? 0.88 : 1.0;
      rgba[base] = (pixels[base] * blend + 255 * (1.0 - blend)).round();
      rgba[base + 1] = (pixels[base + 1] * blend + 255 * (1.0 - blend)).round();
      rgba[base + 2] = (pixels[base + 2] * blend + 255 * (1.0 - blend)).round();
      rgba[base + 3] = 255;
    } else if (feather[i] != 0) {
      rgba[base] = 255;
      rgba[base + 1] = 255;
      rgba[base + 2] = 255;
      rgba[base + 3] = 255;
    } else {
      rgba[base] = 255;
      rgba[base + 1] = 255;
      rgba[base + 2] = 255;
      rgba[base + 3] = 255;
    }
  }
  return _encodeRgbaPng(rgba, w, h);
}

Future<Uint8List> _encodeMaskPreview(Uint8List mask, int w, int h) async {
  final rgba = Uint8List(w * h * 4);
  for (int i = 0; i < w * h; i++) {
    final base = i * 4;
    if (mask[i] != 0) {
      final boundary = _isBoundaryPixel(mask, w, h, i);
      rgba[base] = boundary ? 255 : 238;
      rgba[base + 1] = boundary ? 207 : 238;
      rgba[base + 2] = boundary ? 112 : 238;
      rgba[base + 3] = 255;
    } else {
      rgba[base] = 18;
      rgba[base + 1] = 14;
      rgba[base + 2] = 26;
      rgba[base + 3] = 255;
    }
  }
  return _encodeRgbaPng(rgba, w, h);
}

Future<Uint8List> _encodeRgbaPng(Uint8List rgba, int w, int h) async {
  try {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      rgba,
      w,
      h,
      ui.PixelFormat.rgba8888,
      (img) => completer.complete(img),
    );
    final uiImage = await completer.future;
    final pngData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
    uiImage.dispose();
    if (pngData != null) return pngData.buffer.asUint8List();
  } catch (_) {}
  return Uint8List(0);
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
    'currentMask': Uint8List(total),
    'refinedMask': Uint8List(total),
    'maskCoverage': 0.0,
    'edgeConfidence': 0.0,
    'fingerVisibility': 0.0,
    'thumbVisibility': 0.0,
    'wristVisibility': 0.0,
    'backgroundUniformity': 1.0,
    'maskArea': 0,
    'boundaryLength': 0,
    'backgroundLeakageRatio': 0.0,
    'contourSmoothness': 0.0,
  };

  if (w < 8 || h < 8 || pixels.length < total * 4) return emptyResult();

  // 1. Skin detection with border-background suppression.
  final skinRaw = Uint8List(total);
  final skinScore = Uint8List(total);
  final backgroundModel = _borderColorModel(pixels, w, h);
  for (int i = 0; i < total; i++) {
    final base = i * 4;
    final r = pixels[base];
    final g = pixels[base + 1];
    final b = pixels[base + 2];
    final score = _skinScore(r, g, b);
    skinScore[i] = score;
    if (score >= 108 && !_isBorderBackgroundColor(r, g, b, backgroundModel)) {
      skinRaw[i] = 255;
    }
  }

  // 2. BFS connected components → keep largest.
  var mask = _largestComponentMask(skinRaw, w, h);

  // 3. Morphological close (box): fill tiny cracks without sealing finger gaps.
  final closeR = max(1, (min(w, h) * 0.018).round());
  mask = _dilateBox(mask, w, h, closeR);
  mask = _erodeBox(mask, w, h, closeR);

  // 4. Tiny hole filling only; open thumb/finger valleys must stay open.
  mask = _fillSmallHoles(mask, w, h, max(12, total ~/ 900));

  // 5. Dilate slightly to recover excluded skin edges. This is the coarse
  //    "current mask" shown in the debug preview.
  mask = _dilateBox(mask, w, h, max(1, (min(w, h) * 0.012).round()));
  final currentMask = Uint8List.fromList(mask);

  // 6. Boundary refinement, bridge rejection, and leak-driven second pass.
  var refined = _refineMask(
    currentMask,
    pixels,
    skinScore,
    w,
    h,
    aggressive: false,
  );
  final firstRefinedMask = Uint8List.fromList(refined.mask);
  if (refined.backgroundLeakageRatio > 0.035) {
    refined = _refineMask(
      refined.mask,
      pixels,
      skinScore,
      w,
      h,
      aggressive: true,
    );
  }
  mask = refined.mask;

  // 7. Quality metrics.
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
    'currentMask': currentMask,
    'refinedMask': firstRefinedMask,
    'maskCoverage': coverageScore,
    'edgeConfidence': edgeConfidence,
    'fingerVisibility': fingerVisibility,
    'thumbVisibility': thumbVisibility,
    'wristVisibility': wristVisibility,
    'backgroundUniformity': backgroundUniformity,
    'maskArea': handCount,
    'boundaryLength': refined.boundaryLength,
    'backgroundLeakageRatio': refined.backgroundLeakageRatio,
    'contourSmoothness': refined.contourSmoothness,
  };
}

// ── Private helpers (isolate-safe, no dart:ui) ─────────────────────────────────

class _ColorModel {
  const _ColorModel({
    required this.r,
    required this.g,
    required this.b,
    required this.stddev,
  });

  final double r;
  final double g;
  final double b;
  final double stddev;

  double distanceTo(int pr, int pg, int pb) {
    final dr = pr - r;
    final dg = pg - g;
    final db = pb - b;
    return sqrt(dr * dr + dg * dg + db * db);
  }
}

class _RefinementResult {
  const _RefinementResult({
    required this.mask,
    required this.backgroundLeakageRatio,
    required this.boundaryLength,
    required this.contourSmoothness,
  });

  final Uint8List mask;
  final double backgroundLeakageRatio;
  final int boundaryLength;
  final double contourSmoothness;
}

int _skinScore(int r, int g, int b) {
  final luma = (r * 0.299 + g * 0.587 + b * 0.114).round();
  if (luma < 25 || luma > 242) return 0;
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
  final crFit = (1.0 - (cr - 153).abs() / 34.0).clamp(0.0, 1.0);
  final cbFit = (1.0 - (cb - 101).abs() / 30.0).clamp(0.0, 1.0);
  final chromaFit = (crFit * 0.58 + cbFit * 0.42).clamp(0.0, 1.0);
  final rgbFit = rule1 ? 0.72 : 0.0;
  final yFit = luma < 55
      ? (luma / 55.0).clamp(0.0, 1.0)
      : luma > 225
      ? ((242 - luma) / 17.0).clamp(0.0, 1.0)
      : 1.0;
  final score = max(rgbFit, rule2 ? chromaFit : chromaFit * 0.65) * yFit;
  return (score * 255).round().clamp(0, 255);
}

_ColorModel _borderColorModel(Uint8List pixels, int w, int h) {
  final samples = <int>[];
  final patch = max(2, (min(w, h) * 0.08).round());

  void addPatch(int left, int top, int right, int bottom) {
    for (int y = top.clamp(0, h); y < bottom.clamp(0, h); y++) {
      for (int x = left.clamp(0, w); x < right.clamp(0, w); x++) {
        samples.add(y * w + x);
      }
    }
  }

  addPatch(0, 0, patch, patch);
  addPatch(w - patch, 0, w, patch);
  addPatch(0, h - patch, patch, h);
  addPatch(w - patch, h - patch, w, h);
  addPatch(0, h ~/ 3, patch, (h * 2) ~/ 3);
  addPatch(w - patch, h ~/ 3, w, (h * 2) ~/ 3);

  return _colorModelFromSamples(pixels, samples);
}

bool _isBorderBackgroundColor(int r, int g, int b, _ColorModel bg) {
  final tolerance = (bg.stddev * 2.2 + 26.0).clamp(30.0, 68.0);
  return bg.distanceTo(r, g, b) <= tolerance;
}

_RefinementResult _refineMask(
  Uint8List source,
  Uint8List pixels,
  Uint8List skinScore,
  int w,
  int h, {
  required bool aggressive,
}) {
  if (_countOnes(source) == 0) {
    return _RefinementResult(
      mask: Uint8List(source.length),
      backgroundLeakageRatio: 0.0,
      boundaryLength: 0,
      contourSmoothness: 0.0,
    );
  }

  final total = w * h;
  final edgeMap = _edgeMap(pixels, w, h);
  final coreRadius = aggressive ? 3 : 2;
  final rawCore = _erodeBox(source, w, h, coreRadius);
  final modelCore = _countOnes(rawCore) == 0 ? source : rawCore;
  final handModel = _maskedColorModel(pixels, modelCore, skinScore, w, h);
  final bgModel = _backgroundColorModel(pixels, source, w, h);
  final sourceCore = _trustedCoreMask(
    modelCore,
    pixels,
    skinScore,
    handModel,
    bgModel,
  );
  final expanded = _dilateBox(source, w, h, aggressive ? 2 : 1);
  final candidate = Uint8List(total);
  final colorTolerance = (handModel.stddev * 2.4 + (aggressive ? 30 : 36))
      .clamp(38.0, aggressive ? 78.0 : 86.0);

  for (int i = 0; i < total; i++) {
    if (sourceCore[i] != 0) {
      candidate[i] = 255;
      continue;
    }
    if (expanded[i] == 0) continue;

    final base = i * 4;
    final r = pixels[base];
    final g = pixels[base + 1];
    final b = pixels[base + 2];
    final hDist = handModel.distanceTo(r, g, b);
    final bDist = bgModel.distanceTo(r, g, b);
    final skin = skinScore[i];
    final nearEdge = _nearStrongEdge(edgeMap, w, h, i, aggressive ? 2 : 1);
    final handLike =
        skin >= (aggressive ? 120 : 108) &&
        hDist <= colorTolerance &&
        hDist <= bDist * (aggressive ? 0.92 : 1.02) + 18.0;

    if (source[i] != 0) {
      if (handLike ||
          (skin >= 170 && hDist <= colorTolerance + 20) ||
          (nearEdge >= 42 && hDist <= colorTolerance + 10)) {
        candidate[i] = 255;
      }
    } else if (handLike && (skin >= 170 || nearEdge >= 46)) {
      candidate[i] = 255;
    }
  }

  var cleaned = _fillSmallHoles(candidate, w, h, max(12, total ~/ 850));
  cleaned = _keepBestHandComponent(cleaned, sourceCore, w, h);
  cleaned = _breakNarrowBridges(
    cleaned,
    source,
    sourceCore,
    pixels,
    skinScore,
    handModel,
    bgModel,
    w,
    h,
    aggressive: aggressive,
  );
  cleaned = _smoothMask(cleaned, sourceCore, w, h);
  cleaned = _fillSmallHoles(cleaned, w, h, max(10, total ~/ 1000));
  cleaned = _keepBestHandComponent(cleaned, sourceCore, w, h);

  final boundary = _boundaryLength(cleaned, w, h);
  final smoothness = _contourSmoothness(cleaned, w, h, boundary);
  final leakage = _backgroundLeakageRatio(
    cleaned,
    pixels,
    skinScore,
    handModel,
    bgModel,
    w,
    h,
  );
  return _RefinementResult(
    mask: cleaned,
    backgroundLeakageRatio: leakage,
    boundaryLength: boundary,
    contourSmoothness: smoothness,
  );
}

_ColorModel _backgroundColorModel(
  Uint8List pixels,
  Uint8List mask,
  int w,
  int h,
) {
  final samples = <int>[];
  for (int x = 0; x < w; x++) {
    if (mask[x] == 0) samples.add(x);
    final bottom = (h - 1) * w + x;
    if (mask[bottom] == 0) samples.add(bottom);
  }
  for (int y = 1; y < h - 1; y++) {
    final left = y * w;
    final right = y * w + w - 1;
    if (mask[left] == 0) samples.add(left);
    if (mask[right] == 0) samples.add(right);
  }
  if (samples.length < max(12, (w + h) ~/ 4)) {
    return _borderColorModel(pixels, w, h);
  }
  return _colorModelFromSamples(pixels, samples);
}

Uint8List _trustedCoreMask(
  Uint8List core,
  Uint8List pixels,
  Uint8List skinScore,
  _ColorModel handModel,
  _ColorModel bgModel,
) {
  final result = Uint8List(core.length);
  final tolerance = (handModel.stddev * 2.2 + 34).clamp(38.0, 82.0);
  for (int i = 0; i < core.length; i++) {
    if (core[i] == 0 || skinScore[i] < 108) continue;
    final base = i * 4;
    final r = pixels[base];
    final g = pixels[base + 1];
    final b = pixels[base + 2];
    final hDist = handModel.distanceTo(r, g, b);
    final bDist = bgModel.distanceTo(r, g, b);
    if (hDist <= tolerance && hDist <= bDist + 18) {
      result[i] = 255;
    }
  }
  return _countOnes(result) >= 8 ? result : Uint8List.fromList(core);
}

_ColorModel _maskedColorModel(
  Uint8List pixels,
  Uint8List mask,
  Uint8List skinScore,
  int w,
  int h,
) {
  final samples = <int>[];
  var minX = w;
  var maxX = -1;
  var minY = h;
  var maxY = -1;
  for (int i = 0; i < mask.length; i++) {
    if (mask[i] == 0) continue;
    final x = i % w;
    final y = i ~/ w;
    minX = min(minX, x);
    maxX = max(maxX, x);
    minY = min(minY, y);
    maxY = max(maxY, y);
  }
  final hasBounds = maxX >= minX && maxY >= minY;
  final innerLeft = hasBounds ? minX + ((maxX - minX) * 0.22).round() : 0;
  final innerRight = hasBounds ? minX + ((maxX - minX) * 0.78).round() : w - 1;
  final innerTop = hasBounds ? minY + ((maxY - minY) * 0.22).round() : 0;
  final innerBottom = hasBounds ? minY + ((maxY - minY) * 0.86).round() : h - 1;

  for (int i = 0; i < mask.length; i++) {
    if (mask[i] == 0 || skinScore[i] < 120) continue;
    final x = i % w;
    final y = i ~/ w;
    if (x >= innerLeft &&
        x <= innerRight &&
        y >= innerTop &&
        y <= innerBottom) {
      samples.add(i);
    }
  }
  if (samples.length < 8) {
    for (int i = 0; i < mask.length; i++) {
      if (mask[i] != 0) samples.add(i);
    }
  }
  return _colorModelFromSamples(pixels, samples);
}

_ColorModel _colorModelFromSamples(Uint8List pixels, List<int> samples) {
  if (samples.isEmpty) {
    return const _ColorModel(r: 128, g: 128, b: 128, stddev: 48);
  }
  double sr = 0;
  double sg = 0;
  double sb = 0;
  for (final i in samples) {
    final base = i * 4;
    sr += pixels[base];
    sg += pixels[base + 1];
    sb += pixels[base + 2];
  }
  final n = samples.length;
  final mr = sr / n;
  final mg = sg / n;
  final mb = sb / n;
  double variance = 0;
  for (final i in samples) {
    final base = i * 4;
    final dr = pixels[base] - mr;
    final dg = pixels[base + 1] - mg;
    final db = pixels[base + 2] - mb;
    variance += dr * dr + dg * dg + db * db;
  }
  final stddev = sqrt(variance / n);
  return _ColorModel(r: mr, g: mg, b: mb, stddev: stddev);
}

Uint8List _edgeMap(Uint8List pixels, int w, int h) {
  final edges = Uint8List(w * h);
  for (int y = 1; y < h - 1; y++) {
    for (int x = 1; x < w - 1; x++) {
      final i = y * w + x;
      final l = _lumaAt(pixels, i - 1);
      final r = _lumaAt(pixels, i + 1);
      final u = _lumaAt(pixels, i - w);
      final d = _lumaAt(pixels, i + w);
      final mag = sqrt((r - l) * (r - l) + (d - u) * (d - u));
      edges[i] = mag.round().clamp(0, 255);
    }
  }
  return edges;
}

double _lumaAt(Uint8List pixels, int i) {
  final base = i * 4;
  return pixels[base] * 0.299 +
      pixels[base + 1] * 0.587 +
      pixels[base + 2] * 0.114;
}

int _nearStrongEdge(Uint8List edgeMap, int w, int h, int i, int radius) {
  final cx = i % w;
  final cy = i ~/ w;
  var best = 0;
  for (int y = max(1, cy - radius); y <= min(h - 2, cy + radius); y++) {
    for (int x = max(1, cx - radius); x <= min(w - 2, cx + radius); x++) {
      best = max(best, edgeMap[y * w + x]);
    }
  }
  return best;
}

Uint8List _breakNarrowBridges(
  Uint8List mask,
  Uint8List source,
  Uint8List core,
  Uint8List pixels,
  Uint8List skinScore,
  _ColorModel handModel,
  _ColorModel bgModel,
  int w,
  int h, {
  required bool aggressive,
}) {
  final bridgeR = max(
    2,
    min(3, (min(w, h) * (aggressive ? 0.026 : 0.018)).round()),
  );
  final opened = _dilateBox(_erodeBox(mask, w, h, bridgeR), w, h, bridgeR);
  final result = Uint8List.fromList(opened);
  final tolerance = (handModel.stddev * 2.1 + 26).clamp(34.0, 72.0);

  for (int i = 0; i < mask.length; i++) {
    if (core[i] != 0) {
      result[i] = 255;
      continue;
    }
    if (mask[i] == 0 || source[i] == 0) continue;
    final base = i * 4;
    final r = pixels[base];
    final g = pixels[base + 1];
    final b = pixels[base + 2];
    final hDist = handModel.distanceTo(r, g, b);
    final bDist = bgModel.distanceTo(r, g, b);
    if (skinScore[i] >= 142 && hDist <= tolerance && hDist <= bDist + 12) {
      result[i] = 255;
    }
  }

  return _keepBestHandComponent(result, core, w, h);
}

Uint8List _smoothMask(Uint8List mask, Uint8List preserve, int w, int h) {
  final result = Uint8List.fromList(mask);
  for (int y = 1; y < h - 1; y++) {
    for (int x = 1; x < w - 1; x++) {
      final i = y * w + x;
      if (preserve[i] != 0) {
        result[i] = 255;
        continue;
      }
      var count = 0;
      for (int yy = y - 1; yy <= y + 1; yy++) {
        for (int xx = x - 1; xx <= x + 1; xx++) {
          if (mask[yy * w + xx] != 0) count++;
        }
      }
      if (mask[i] != 0 && count <= 2) result[i] = 0;
      if (mask[i] == 0 && count >= 7) result[i] = 255;
    }
  }
  return result;
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

Uint8List _fillSmallHoles(Uint8List mask, int w, int h, int maxHoleSize) {
  final total = w * h;
  final visited = Uint8List(total);
  final result = Uint8List.fromList(mask);

  for (int start = 0; start < total; start++) {
    if (mask[start] != 0 || visited[start] != 0) continue;
    final queue = <int>[start];
    final pixels = <int>[];
    visited[start] = 1;
    var touchesBorder = false;
    var qi = 0;
    while (qi < queue.length) {
      final i = queue[qi++];
      pixels.add(i);
      final x = i % w;
      final y = i ~/ w;
      if (x == 0 || x == w - 1 || y == 0 || y == h - 1) {
        touchesBorder = true;
      }
      void add(int ni) {
        if (mask[ni] == 0 && visited[ni] == 0) {
          visited[ni] = 1;
          queue.add(ni);
        }
      }

      if (x > 0) add(i - 1);
      if (x < w - 1) add(i + 1);
      if (y > 0) add(i - w);
      if (y < h - 1) add(i + w);
    }
    if (!touchesBorder && pixels.length <= maxHoleSize) {
      for (final i in pixels) {
        result[i] = 255;
      }
    }
  }
  return result;
}

Uint8List _keepBestHandComponent(
  Uint8List mask,
  Uint8List anchor,
  int w,
  int h,
) {
  final total = w * h;
  final visited = Uint8List(total);
  List<int> best = const [];
  var bestScore = -1.0;
  final cx = (w - 1) / 2.0;
  final cy = (h - 1) / 2.0;

  for (int start = 0; start < total; start++) {
    if (mask[start] == 0 || visited[start] != 0) continue;
    final queue = <int>[start];
    final comp = <int>[];
    visited[start] = 1;
    var qi = 0;
    var anchorOverlap = 0;
    double sx = 0;
    double sy = 0;

    while (qi < queue.length) {
      final i = queue[qi++];
      comp.add(i);
      if (anchor[i] != 0) anchorOverlap++;
      final x = i % w;
      final y = i ~/ w;
      sx += x;
      sy += y;

      void add(int ni) {
        if (mask[ni] != 0 && visited[ni] == 0) {
          visited[ni] = 1;
          queue.add(ni);
        }
      }

      if (x > 0) add(i - 1);
      if (x < w - 1) add(i + 1);
      if (y > 0) add(i - w);
      if (y < h - 1) add(i + w);
    }

    final area = comp.length;
    final mx = sx / area;
    final my = sy / area;
    final centerDist = sqrt((mx - cx) * (mx - cx) + (my - cy) * (my - cy));
    final centerPenalty = centerDist / max(w, h);
    final score = anchorOverlap * 5.0 + area * 0.35 - centerPenalty * area;
    if (score > bestScore) {
      bestScore = score;
      best = comp;
    }
  }

  final result = Uint8List(total);
  for (final i in best) {
    result[i] = 255;
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

bool _isBoundaryPixel(Uint8List mask, int w, int h, int i) {
  if (mask[i] == 0) return false;
  final x = i % w;
  final y = i ~/ w;
  if (x == 0 || x == w - 1 || y == 0 || y == h - 1) return true;
  return mask[i - 1] == 0 ||
      mask[i + 1] == 0 ||
      mask[i - w] == 0 ||
      mask[i + w] == 0;
}

int _boundaryLength(Uint8List mask, int w, int h) {
  var boundary = 0;
  for (int i = 0; i < mask.length; i++) {
    if (_isBoundaryPixel(mask, w, h, i)) boundary++;
  }
  return boundary;
}

double _contourSmoothness(Uint8List mask, int w, int h, int boundaryLength) {
  if (boundaryLength == 0) return 0.0;
  var roughness = 0;
  for (int y = 1; y < h - 1; y++) {
    for (int x = 1; x < w - 1; x++) {
      final i = y * w + x;
      if (!_isBoundaryPixel(mask, w, h, i)) continue;
      final neighbours = [
        mask[(y - 1) * w + x] != 0,
        mask[(y - 1) * w + x + 1] != 0,
        mask[y * w + x + 1] != 0,
        mask[(y + 1) * w + x + 1] != 0,
        mask[(y + 1) * w + x] != 0,
        mask[(y + 1) * w + x - 1] != 0,
        mask[y * w + x - 1] != 0,
        mask[(y - 1) * w + x - 1] != 0,
      ];
      var transitions = 0;
      for (int n = 0; n < neighbours.length; n++) {
        if (neighbours[n] != neighbours[(n + 1) % neighbours.length]) {
          transitions++;
        }
      }
      roughness += max(0, transitions - 2);
    }
  }
  return (1.0 - roughness / (boundaryLength * 4.0)).clamp(0.0, 1.0);
}

double _backgroundLeakageRatio(
  Uint8List mask,
  Uint8List pixels,
  Uint8List skinScore,
  _ColorModel handModel,
  _ColorModel bgModel,
  int w,
  int h,
) {
  final area = _countOnes(mask);
  if (area == 0) return 0.0;
  final interior = _erodeBox(mask, w, h, 2);
  var leak = 0;
  for (int i = 0; i < mask.length; i++) {
    if (mask[i] == 0 || interior[i] != 0) continue;
    final base = i * 4;
    final r = pixels[base];
    final g = pixels[base + 1];
    final b = pixels[base + 2];
    final hDist = handModel.distanceTo(r, g, b);
    final bDist = bgModel.distanceTo(r, g, b);
    if (skinScore[i] < 92 || (bDist + 8 < hDist && hDist > 34)) {
      leak++;
    }
  }
  return (leak / area).clamp(0.0, 1.0);
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
