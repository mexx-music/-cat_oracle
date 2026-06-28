import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Offset, Rect;

// ── Result model ──────────────────────────────────────────────────────────────

enum PalmThumbSide { left, right, unknown }

class PalmGeometry {
  const PalmGeometry({
    required this.palmCenter,
    required this.wristY,
    required this.fingerBaseY,
    required this.thumbSide,
    required this.mainAxisAngle,
    required this.palmBounds,
    required this.thenarRegion,
    required this.interiorMaskCoverage,
    required this.confidence,
  });

  final Offset palmCenter;
  final double wristY;
  final double fingerBaseY;
  final PalmThumbSide thumbSide;
  final double mainAxisAngle;
  final Rect palmBounds;
  final Rect thenarRegion;
  final double interiorMaskCoverage;
  final double confidence;

  Offset imageToPalm(Offset imagePoint) {
    final xDen = max(0.001, palmBounds.width);
    final yDen = max(0.001, wristY - fingerBaseY);
    return Offset(
      ((imagePoint.dx - palmBounds.left) / xDen).clamp(0.0, 1.0),
      ((imagePoint.dy - fingerBaseY) / yDen).clamp(0.0, 1.0),
    );
  }

  Offset palmToImage(Offset palmPoint) {
    return Offset(
      palmBounds.left + palmPoint.dx.clamp(0.0, 1.0) * palmBounds.width,
      fingerBaseY + palmPoint.dy.clamp(0.0, 1.0) * (wristY - fingerBaseY),
    );
  }
}

class PalmLineExtractionResult {
  const PalmLineExtractionResult({
    required this.edgePoints,
    required this.candidatePaths,
    required this.confidence,
    required this.imageWidth,
    required this.imageHeight,
    required this.edgePointCount,
    this.roiLeft,
    this.roiTop,
    this.roiRight,
    this.roiBottom,
    this.normalizedWidth = 0,
    this.normalizedHeight = 0,
    this.rejectedPaths = const [],
    this.palmMaskCoverage = 0.0,
    this.darkLinePixelCount = 0,
    this.sobelPixelCount = 0,
    this.acceptedInteriorRatio = 0.0,
    this.rejectedBoundaryRatio = 0.0,
    this.palmGeometry,
  });

  /// Sampled edge pixels, normalized to [0,1] in both axes (original image space).
  final List<Offset> edgePoints;

  /// Ordered point sequences forming candidate palm lines, normalized [0,1] (original image space).
  final List<List<Offset>> candidatePaths;

  /// Rough confidence estimate in [0,1] based on line count and density.
  final double confidence;

  final int imageWidth;
  final int imageHeight;

  /// Total edge pixels found before component filtering.
  final int edgePointCount;

  /// Detected ROI bounds in original (512 px-resized) image pixel space.
  /// Null when ROI detection failed and the full image was used.
  final int? roiLeft;
  final int? roiTop;
  final int? roiRight;
  final int? roiBottom;

  /// Dimensions of the work image used for Sobel processing (512 if ROI was used).
  final int normalizedWidth;
  final int normalizedHeight;

  /// Paths rejected by the palm-interior filter (mostly finger/hand outer edges).
  final List<List<Offset>> rejectedPaths;

  /// Fraction of the work image covered by the eroded palm-interior mask.
  final double palmMaskCoverage;

  /// Pixels accepted from dark-groove / black-top-hat style evidence.
  final int darkLinePixelCount;

  /// Pixels accepted from Sobel as auxiliary evidence.
  final int sobelPixelCount;

  /// Mean interior-mask fraction across accepted components.
  final double acceptedInteriorRatio;

  /// Mean boundary fraction across rejected components.
  final double rejectedBoundaryRatio;

  /// Estimated palm coordinate system derived from the palm interior mask.
  final PalmGeometry? palmGeometry;

  bool get hasRealData => edgePointCount > 0;
  bool get hasRoi => roiLeft != null;
  int get candidatePathCount => candidatePaths.length;

  static const empty = PalmLineExtractionResult(
    edgePoints: [],
    candidatePaths: [],
    confidence: 0.0,
    imageWidth: 1,
    imageHeight: 1,
    edgePointCount: 0,
    rejectedPaths: [],
    palmMaskCoverage: 0.0,
    darkLinePixelCount: 0,
    sobelPixelCount: 0,
    acceptedInteriorRatio: 0.0,
    rejectedBoundaryRatio: 0.0,
    palmGeometry: null,
  );
}

// ── Extractor ─────────────────────────────────────────────────────────────────

class PalmLineExtractor {
  PalmLineExtractor._();

  static Future<PalmLineExtractionResult> extract(Uint8List imageBytes) async {
    if (imageBytes.isEmpty) return PalmLineExtractionResult.empty;
    try {
      final codec = await ui.instantiateImageCodec(
        imageBytes,
        targetWidth: 512,
      );
      final frame = await codec.getNextFrame();
      final uiImage = frame.image;
      final imgW = uiImage.width;
      final imgH = uiImage.height;
      final byteData = await uiImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      uiImage.dispose();

      if (byteData == null) return PalmLineExtractionResult.empty;

      final raw = await compute(
        _processPixels,
        _PixelInput(
          pixels: byteData.buffer.asUint8List(),
          width: imgW,
          height: imgH,
        ),
      );
      return _buildResult(raw);
    } catch (_) {
      return PalmLineExtractionResult.empty;
    }
  }

  static PalmLineExtractionResult _buildResult(Map<String, dynamic> raw) {
    Offset toOffset(dynamic p) {
      final l = p as List;
      return Offset((l[0] as num).toDouble(), (l[1] as num).toDouble());
    }

    final rawEdge = raw['edgePoints'] as List<dynamic>;
    final rawPaths = raw['candidatePaths'] as List<dynamic>;
    final rawRejected = raw['rejectedPaths'] as List<dynamic>;
    return PalmLineExtractionResult(
      edgePoints: rawEdge.map(toOffset).toList(),
      candidatePaths: rawPaths
          .map((path) => (path as List<dynamic>).map(toOffset).toList())
          .toList(),
      rejectedPaths: rawRejected
          .map((path) => (path as List<dynamic>).map(toOffset).toList())
          .toList(),
      confidence: (raw['confidence'] as num).toDouble(),
      imageWidth: raw['imageWidth'] as int,
      imageHeight: raw['imageHeight'] as int,
      edgePointCount: raw['edgePointCount'] as int,
      roiLeft: raw['roiLeft'] as int?,
      roiTop: raw['roiTop'] as int?,
      roiRight: raw['roiRight'] as int?,
      roiBottom: raw['roiBottom'] as int?,
      normalizedWidth: raw['normalizedWidth'] as int,
      normalizedHeight: raw['normalizedHeight'] as int,
      palmMaskCoverage: (raw['palmMaskCoverage'] as num).toDouble(),
      darkLinePixelCount: raw['darkLinePixelCount'] as int,
      sobelPixelCount: raw['sobelPixelCount'] as int,
      acceptedInteriorRatio: (raw['acceptedInteriorRatio'] as num).toDouble(),
      rejectedBoundaryRatio: (raw['rejectedBoundaryRatio'] as num).toDouble(),
      palmGeometry: _geometryFromRaw(raw['palmGeometry']),
    );
  }
}

PalmGeometry? _geometryFromRaw(dynamic g) {
  if (g == null) return null;
  final m = g as Map;
  Offset offsetFrom(dynamic p) {
    final l = p as List;
    return Offset((l[0] as num).toDouble(), (l[1] as num).toDouble());
  }

  Rect rectFrom(dynamic r) {
    final l = r as List;
    return Rect.fromLTRB(
      (l[0] as num).toDouble(),
      (l[1] as num).toDouble(),
      (l[2] as num).toDouble(),
      (l[3] as num).toDouble(),
    );
  }

  final thumbSide = switch (m['thumbSide'] as String) {
    'left' => PalmThumbSide.left,
    'right' => PalmThumbSide.right,
    _ => PalmThumbSide.unknown,
  };
  return PalmGeometry(
    palmCenter: offsetFrom(m['palmCenter']),
    wristY: (m['wristY'] as num).toDouble(),
    fingerBaseY: (m['fingerBaseY'] as num).toDouble(),
    thumbSide: thumbSide,
    mainAxisAngle: (m['mainAxisAngle'] as num).toDouble(),
    palmBounds: rectFrom(m['palmBounds']),
    thenarRegion: rectFrom(m['thenarRegion']),
    interiorMaskCoverage: (m['interiorMaskCoverage'] as num).toDouble(),
    confidence: (m['confidence'] as num).toDouble(),
  );
}

// ── Isolate input ─────────────────────────────────────────────────────────────

class _PixelInput {
  const _PixelInput({
    required this.pixels,
    required this.width,
    required this.height,
  });

  final Uint8List pixels; // RGBA, 4 bytes per pixel
  final int width;
  final int height;
}

// ── Core processing (top-level for compute()) ─────────────────────────────────

Map<String, dynamic> _processPixels(_PixelInput input) {
  final pixels = input.pixels;
  final w = input.width;
  final h = input.height;

  Map<String, dynamic> emptyResult({
    int? roiL,
    int? roiT,
    int? roiR,
    int? roiB,
    int ww = 0,
    int wh = 0,
    double palmMaskCoverage = 0.0,
    int darkLinePixelCount = 0,
    int sobelPixelCount = 0,
    double acceptedInteriorRatio = 0.0,
    double rejectedBoundaryRatio = 0.0,
    Map<String, dynamic>? palmGeometry,
  }) => {
    'edgePoints': <List<double>>[],
    'candidatePaths': <List<List<double>>>[],
    'rejectedPaths': <List<List<double>>>[],
    'confidence': 0.0,
    'imageWidth': w,
    'imageHeight': h,
    'edgePointCount': 0,
    'roiLeft': roiL,
    'roiTop': roiT,
    'roiRight': roiR,
    'roiBottom': roiB,
    'normalizedWidth': ww,
    'normalizedHeight': wh,
    'palmMaskCoverage': palmMaskCoverage,
    'darkLinePixelCount': darkLinePixelCount,
    'sobelPixelCount': sobelPixelCount,
    'acceptedInteriorRatio': acceptedInteriorRatio,
    'rejectedBoundaryRatio': rejectedBoundaryRatio,
    'palmGeometry': palmGeometry,
  };

  if (w < 8 || h < 8 || pixels.length < w * h * 4) return emptyResult();

  // 1. Grayscale from RGBA
  final gray = Uint8List(w * h);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      final base = (y * w + x) * 4;
      gray[y * w + x] =
          (pixels[base] * 0.299 +
                  pixels[base + 1] * 0.587 +
                  pixels[base + 2] * 0.114)
              .round();
    }
  }

  // 2. Histogram stretch in inner region
  final origMargin = max(2, min(w, h) ~/ 12);
  int gMin = 255, gMax = 0;
  for (int y = origMargin; y < h - origMargin; y++) {
    for (int x = origMargin; x < w - origMargin; x++) {
      final v = gray[y * w + x];
      if (v < gMin) gMin = v;
      if (v > gMax) gMax = v;
    }
  }
  final range = (gMax - gMin).clamp(1, 255);
  final enhanced = Uint8List(w * h);
  for (int i = 0; i < w * h; i++) {
    enhanced[i] = ((gray[i] - gMin) * 255 ~/ range).clamp(0, 255);
  }

  // 3. CLAHE-light local luminance normalisation + box blur.
  final locallyNormalised = _localContrastNormalize(enhanced, w, h);
  final blurred = Uint8List(w * h);
  for (int y = 1; y < h - 1; y++) {
    final yw = y * w;
    for (int x = 1; x < w - 1; x++) {
      blurred[yw + x] =
          (locallyNormalised[(y - 1) * w + x - 1] +
              locallyNormalised[(y - 1) * w + x] +
              locallyNormalised[(y - 1) * w + x + 1] +
              locallyNormalised[yw + x - 1] +
              locallyNormalised[yw + x] +
              locallyNormalised[yw + x + 1] +
              locallyNormalised[(y + 1) * w + x - 1] +
              locallyNormalised[(y + 1) * w + x] +
              locallyNormalised[(y + 1) * w + x + 1]) ~/
          9;
    }
  }
  for (int y = 0; y < h; y++) {
    blurred[y * w] = locallyNormalised[y * w];
    blurred[y * w + w - 1] = locallyNormalised[y * w + w - 1];
  }
  for (int x = 0; x < w; x++) {
    blurred[x] = locallyNormalised[x];
    blurred[(h - 1) * w + x] = locallyNormalised[(h - 1) * w + x];
  }

  // 4. ROI detection: bounding box of palm-brightness pixels
  final roiResult = _detectRoi(blurred, w, h, origMargin);
  final bool useRoi = roiResult != null;

  // 5. Build work image (ROI-cropped + resized to 512², or original blurred)
  const workSize = 512;
  final Uint8List workImg;
  final int workW, workH;
  final int roiL, roiT, roiR, roiB;

  if (useRoi) {
    roiL = roiResult[0];
    roiT = roiResult[1];
    roiR = roiResult[2];
    roiB = roiResult[3];
    workImg = _cropResize(blurred, w, h, roiL, roiT, roiR, roiB, workSize);
    workW = workSize;
    workH = workSize;
  } else {
    roiL = 0;
    roiT = 0;
    roiR = w - 1;
    roiB = h - 1;
    workImg = blurred;
    workW = w;
    workH = h;
  }

  final roiWd = (roiR - roiL).toDouble();
  final roiHd = (roiB - roiT).toDouble();
  final origWd = w.toDouble();
  final origHd = h.toDouble();

  List<double> mapPt(List<double> pt) => [
    (roiL + pt[0] * roiWd) / origWd,
    (roiT + pt[1] * roiHd) / origHd,
  ];

  // 5.5  Palm interior mask: erode the skin region to exclude outer hand/finger
  //      contour. Pixels within ~5.5 % of the hand boundary are excluded so
  //      that strong Sobel edges at finger/hand edges do not become candidatePaths.
  //
  //      We use the ORIGINAL gray values (before histogram stretch) for the skin
  //      mask because the stretch maps skin to 255, which would fall outside any
  //      reasonable upper bound and collapse the mask to all-false.
  final erosionR = max(4, (min(workW, workH) * 0.055).round());
  final Uint8List graySkinWork;
  if (useRoi) {
    // Crop+resize gray to work-image coordinates, same mapping as workImg.
    graySkinWork = _cropResize(gray, w, h, roiL, roiT, roiR, roiB, workSize);
  } else {
    graySkinWork = gray; // no copy needed
  }
  final skinMask = List<bool>.generate(
    workW * workH,
    (i) => graySkinWork[i] >= 35 && graySkinWork[i] <= 235,
  );
  final interiorMask = _erodeMask(skinMask, workW, workH, erosionR);
  final boundarySafeMask = _erodeMask(
    skinMask,
    workW,
    workH,
    max(erosionR, (min(workW, workH) * 0.075).round()),
  );
  final interiorCount = interiorMask.where((v) => v).length;
  final palmMaskCoverage = interiorCount / (workW * workH).toDouble();
  final palmGeometry = _mapPalmGeometry(
    _detectPalmGeometry(interiorMask, workW, workH),
    mapPt,
  );

  // 6. Sobel edge magnitude on work image (L1 norm)
  final edgeMag = Int32List(workW * workH);
  int maxMag = 1;
  for (int y = 1; y < workH - 1; y++) {
    final yw = y * workW;
    for (int x = 1; x < workW - 1; x++) {
      final gx =
          -workImg[(y - 1) * workW + x - 1] -
          2 * workImg[yw + x - 1] -
          workImg[(y + 1) * workW + x - 1] +
          workImg[(y - 1) * workW + x + 1] +
          2 * workImg[yw + x + 1] +
          workImg[(y + 1) * workW + x + 1];
      final gy =
          -workImg[(y - 1) * workW + x - 1] -
          2 * workImg[(y - 1) * workW + x] -
          workImg[(y - 1) * workW + x + 1] +
          workImg[(y + 1) * workW + x - 1] +
          2 * workImg[(y + 1) * workW + x] +
          workImg[(y + 1) * workW + x + 1];
      final mag = gx.abs() + gy.abs();
      edgeMag[yw + x] = mag;
      if (mag > maxMag) maxMag = mag;
    }
  }

  // 7. Threshold + dark-line detection.
  // Upper bound scales with the image's actual contrast range instead of a
  // hard 120 cap, which would collapse the gate on high-contrast images.
  // Guard: ensure upper >= lower (avoids ArgumentError on near-uniform images).
  final thresholdUpper = max(12, maxMag ~/ 3);
  final sobelThreshold = (maxMag * 0.30).round().clamp(12, thresholdUpper);
  final workMargin = max(2, min(workW, workH) ~/ 14);
  final edgeBinary = List<bool>.filled(workW * workH, false);
  int totalEdge = 0;
  int darkLinePixelCount = 0;
  int sobelPixelCount = 0;
  const darkLineThreshold = 8;

  for (int y = workMargin; y < workH - workMargin; y++) {
    final yw = y * workW;
    for (int x = workMargin; x < workW - workMargin; x++) {
      final v = workImg[yw + x];
      if (v < 30 || v > 235) continue;
      final idx = yw + x;
      final darkScore = boundarySafeMask[idx]
          ? _darkLineStrength(workImg, x, y, workW, workH)
          : 0;
      final isDarkLine = darkScore >= darkLineThreshold;
      final isSobelAux =
          interiorMask[idx] && edgeMag[idx] >= sobelThreshold && darkScore >= 4;
      final isBoundaryContour =
          !boundarySafeMask[idx] && edgeMag[idx] >= sobelThreshold;
      if (isDarkLine || isSobelAux || isBoundaryContour) {
        edgeBinary[yw + x] = true;
        totalEdge++;
        if (isDarkLine) {
          darkLinePixelCount++;
        } else {
          sobelPixelCount++;
        }
      }
    }
  }

  if (totalEdge == 0) {
    return emptyResult(
      roiL: useRoi ? roiL : null,
      roiT: useRoi ? roiT : null,
      roiR: useRoi ? roiR : null,
      roiB: useRoi ? roiB : null,
      ww: workW,
      wh: workH,
      palmMaskCoverage: palmMaskCoverage,
      darkLinePixelCount: darkLinePixelCount,
      sobelPixelCount: sobelPixelCount,
      palmGeometry: palmGeometry,
    );
  }

  // 8. Connected components (BFS, 8-connectivity, min 12 px)
  final components = _findComponents(edgeBinary, workW, workH, minSize: 12);

  // 8.5  Filter by interior fraction.
  // Paths that run along the outer hand/finger contour have most pixels
  // outside the eroded interior mask → rejected.
  // Interior palm lines (life, heart, head, fate) sit deep in the palm → accepted.
  const minInteriorFrac = 0.62;
  const minBoundarySafeFrac = 0.42;
  final acceptedComps = <List<int>>[];
  final rejectedComps = <List<int>>[];
  double acceptedInteriorSum = 0.0;
  double rejectedBoundarySum = 0.0;
  for (final comp in components) {
    int inCount = 0;
    int safeCount = 0;
    for (final idx in comp) {
      if (interiorMask[idx]) inCount++;
      if (boundarySafeMask[idx]) safeCount++;
    }
    final interiorFrac = inCount / comp.length;
    final boundarySafeFrac = safeCount / comp.length;
    if (interiorFrac >= minInteriorFrac &&
        boundarySafeFrac >= minBoundarySafeFrac) {
      acceptedComps.add(comp);
      acceptedInteriorSum += interiorFrac;
    } else {
      rejectedComps.add(comp);
      rejectedBoundarySum += 1.0 - boundarySafeFrac;
    }
  }
  final acceptedInteriorRatio = acceptedComps.isEmpty
      ? 0.0
      : acceptedInteriorSum / acceptedComps.length;
  final rejectedBoundaryRatio = rejectedComps.isEmpty
      ? 0.0
      : rejectedBoundarySum / rejectedComps.length;

  // 9. Build ordered paths + collect edge points (in work image [0,1] space)
  final candidatePathsWork = <List<List<double>>>[];
  final rejectedPathsWork = <List<List<double>>>[];
  final allPixels = <int>[];

  for (final comp in acceptedComps) {
    allPixels.addAll(comp);
    final path = _buildOrderedPath(comp, workW, workH);
    if (path.length >= 5) candidatePathsWork.add(path);
  }
  for (final comp in rejectedComps) {
    final path = _buildOrderedPath(comp, workW, workH);
    if (path.length >= 5) rejectedPathsWork.add(path);
  }

  // Subsample edge points (max 280 for display performance)
  final sampledEdgeWork = <List<double>>[];
  if (allPixels.isNotEmpty) {
    final step = (allPixels.length / 280).ceil().clamp(1, allPixels.length);
    for (int i = 0; i < allPixels.length; i += step) {
      final idx = allPixels[i];
      sampledEdgeWork.add([(idx % workW) / workW, (idx ~/ workW) / workH]);
    }
  }

  // 10. Map from work image [0,1] → original image [0,1]
  // If ROI was used, work image coords were extracted from a cropped + resized
  // region; map back so paths align over the original preview image.
  final candidatePaths = candidatePathsWork
      .map((path) => path.map(mapPt).toList())
      .toList();
  final rejectedPaths = rejectedPathsWork
      .map((path) => path.map(mapPt).toList())
      .toList();
  final sampledEdge = sampledEdgeWork.map(mapPt).toList();

  // 11. Confidence
  final pathScore = (candidatePaths.length / 8.0).clamp(0.0, 1.0);
  final darkLineScore = (darkLinePixelCount / (workW * workH * 0.018)).clamp(
    0.0,
    1.0,
  );
  final interiorScore = acceptedInteriorRatio.clamp(0.0, 1.0);
  final confidence =
      (pathScore * 0.45 + darkLineScore * 0.35 + interiorScore * 0.20).clamp(
        0.0,
        1.0,
      );

  return {
    'edgePoints': sampledEdge,
    'candidatePaths': candidatePaths,
    'rejectedPaths': rejectedPaths,
    'confidence': confidence,
    'imageWidth': w,
    'imageHeight': h,
    'edgePointCount': totalEdge,
    'roiLeft': useRoi ? roiL : null,
    'roiTop': useRoi ? roiT : null,
    'roiRight': useRoi ? roiR : null,
    'roiBottom': useRoi ? roiB : null,
    'normalizedWidth': workW,
    'normalizedHeight': workH,
    'palmMaskCoverage': palmMaskCoverage,
    'darkLinePixelCount': darkLinePixelCount,
    'sobelPixelCount': sobelPixelCount,
    'acceptedInteriorRatio': acceptedInteriorRatio,
    'rejectedBoundaryRatio': rejectedBoundaryRatio,
    'palmGeometry': palmGeometry,
  };
}

// ── Local luminance normalisation ─────────────────────────────────────────────

Uint8List _localContrastNormalize(Uint8List src, int w, int h) {
  const tiles = 4;
  final tileW = (w / tiles).ceil();
  final tileH = (h / tiles).ceil();
  final mins = List<int>.filled(tiles * tiles, 255);
  final maxs = List<int>.filled(tiles * tiles, 0);

  for (int ty = 0; ty < tiles; ty++) {
    final y0 = ty * tileH;
    final y1 = min(h, y0 + tileH);
    for (int tx = 0; tx < tiles; tx++) {
      final x0 = tx * tileW;
      final x1 = min(w, x0 + tileW);
      final ti = ty * tiles + tx;
      final hist = List<int>.filled(256, 0);
      var count = 0;
      for (int y = y0; y < y1; y++) {
        final yw = y * w;
        for (int x = x0; x < x1; x++) {
          hist[src[yw + x]]++;
          count++;
        }
      }
      if (count == 0) continue;
      final lowTarget = (count * 0.04).round();
      final highTarget = (count * 0.96).round();
      var acc = 0;
      for (int i = 0; i < 256; i++) {
        acc += hist[i];
        if (acc >= lowTarget) {
          mins[ti] = i;
          break;
        }
      }
      acc = 0;
      for (int i = 0; i < 256; i++) {
        acc += hist[i];
        if (acc >= highTarget) {
          maxs[ti] = i;
          break;
        }
      }
    }
  }

  final dst = Uint8List(w * h);
  for (int y = 0; y < h; y++) {
    final fy = ((y + 0.5) / tileH - 0.5).clamp(0.0, tiles - 1.0);
    final ty0 = fy.floor();
    final ty1 = min(tiles - 1, ty0 + 1);
    final wy = fy - ty0;
    for (int x = 0; x < w; x++) {
      final fx = ((x + 0.5) / tileW - 0.5).clamp(0.0, tiles - 1.0);
      final tx0 = fx.floor();
      final tx1 = min(tiles - 1, tx0 + 1);
      final wx = fx - tx0;

      int stretch(int tx, int ty) {
        final ti = ty * tiles + tx;
        final lo = mins[ti];
        final hi = maxs[ti];
        final range = max(18, hi - lo);
        return ((src[y * w + x] - lo) * 255 ~/ range).clamp(0, 255);
      }

      final top = stretch(tx0, ty0) * (1.0 - wx) + stretch(tx1, ty0) * wx;
      final bottom = stretch(tx0, ty1) * (1.0 - wx) + stretch(tx1, ty1) * wx;
      final local = (top * (1.0 - wy) + bottom * wy).round();
      dst[y * w + x] = ((src[y * w + x] * 0.35) + local * 0.65).round().clamp(
        0,
        255,
      );
    }
  }
  return dst;
}

// ── Palm geometry from interior mask ──────────────────────────────────────────

Map<String, dynamic>? _detectPalmGeometry(List<bool> mask, int w, int h) {
  final comp = _largestMaskComponent(mask, w, h);
  if (comp == null || comp.length < max(16, (w * h * 0.01).round())) {
    return null;
  }

  var minX = w, maxX = -1, minY = h, maxY = -1;
  var sumX = 0.0, sumY = 0.0;
  final rowCount = List<int>.filled(h, 0);
  final rowMin = List<int>.filled(h, w);
  final rowMax = List<int>.filled(h, -1);

  for (final idx in comp) {
    final y = idx ~/ w;
    final x = idx % w;
    sumX += x + 0.5;
    sumY += y + 0.5;
    if (x < minX) minX = x;
    if (x > maxX) maxX = x;
    if (y < minY) minY = y;
    if (y > maxY) maxY = y;
    rowCount[y]++;
    if (x < rowMin[y]) rowMin[y] = x;
    if (x > rowMax[y]) rowMax[y] = x;
  }

  if (maxX <= minX || maxY <= minY) return null;

  final maxRow = rowCount.reduce(max);
  final minRowPixels = max(3, (maxRow * 0.22).round());
  var fingerBaseYPx = minY;
  var wristYPx = maxY;
  for (int y = minY; y <= maxY; y++) {
    if (rowCount[y] >= minRowPixels) {
      fingerBaseYPx = y;
      break;
    }
  }
  for (int y = maxY; y >= minY; y--) {
    if (rowCount[y] >= minRowPixels) {
      wristYPx = y;
      break;
    }
  }

  final centerXPx = sumX / comp.length;
  final centerYPx = sumY / comp.length;
  final palmH = max(1, maxY - minY + 1);
  final palmW = max(1, maxX - minX + 1);

  final thumbBandTop = minY + (palmH * 0.35).round();
  final thumbBandBottom = minY + (palmH * 0.85).round();
  var leftSpanSum = 0.0;
  var rightSpanSum = 0.0;
  var sideRows = 0;
  for (int y = thumbBandTop; y <= thumbBandBottom.clamp(0, h - 1); y++) {
    if (y < 0 || y >= h || rowCount[y] < minRowPixels) continue;
    leftSpanSum += max(0.0, centerXPx - rowMin[y]);
    rightSpanSum += max(0.0, rowMax[y] - centerXPx);
    sideRows++;
  }

  final sideDiff = leftSpanSum - rightSpanSum;
  final sideThreshold = max(2.0, (leftSpanSum + rightSpanSum) * 0.08);
  final thumbSide = sideRows == 0 || sideDiff.abs() < sideThreshold
      ? 'unknown'
      : sideDiff > 0
      ? 'left'
      : 'right';

  double bandCenterX(int y0, int y1) {
    var sum = 0.0;
    var count = 0;
    for (int y = y0.clamp(0, h - 1); y <= y1.clamp(0, h - 1); y++) {
      if (rowCount[y] < minRowPixels) continue;
      sum += (rowMin[y] + rowMax[y]) / 2.0;
      count++;
    }
    return count == 0 ? centerXPx : sum / count;
  }

  final topCenter = bandCenterX(minY, minY + (palmH * 0.20).round());
  final bottomCenter = bandCenterX(maxY - (palmH * 0.20).round(), maxY);
  final mainAxisAngle = atan2(bottomCenter - topCenter, max(1, maxY - minY));

  final bounds = [
    minX / w,
    fingerBaseYPx / h,
    (maxX + 1) / w,
    (wristYPx + 1) / h,
  ];
  final center = [centerXPx / w, centerYPx / h];
  final wristY = ((wristYPx + 0.5) / h).clamp(0.0, 1.0);
  final fingerBaseY = ((fingerBaseYPx + 0.5) / h).clamp(0.0, 1.0);
  final centerX = center[0];
  final thenarTop = ((minY + palmH * 0.42) / h).clamp(0.0, 1.0);
  final thenarBottom = ((wristYPx + 1) / h).clamp(0.0, 1.0);
  final thenar = switch (thumbSide) {
    'left' => [bounds[0], thenarTop, centerX, thenarBottom],
    'right' => [centerX, thenarTop, bounds[2], thenarBottom],
    _ => [centerX, thenarTop, centerX, thenarTop],
  };

  final coverage = comp.length / (w * h).toDouble();
  final extentScore = ((palmH / h) * 1.4).clamp(0.0, 1.0);
  final widthScore = ((palmW / w) * 1.6).clamp(0.0, 1.0);
  final coverageScore = (coverage / 0.18).clamp(0.0, 1.0);
  final sideScore = thumbSide == 'unknown' ? 0.65 : 1.0;
  final confidence =
      (extentScore * 0.30 +
              widthScore * 0.20 +
              coverageScore * 0.30 +
              sideScore * 0.20)
          .clamp(0.0, 1.0);

  return {
    'palmCenter': center,
    'wristY': wristY,
    'fingerBaseY': fingerBaseY,
    'thumbSide': thumbSide,
    'mainAxisAngle': mainAxisAngle,
    'palmBounds': bounds,
    'thenarRegion': thenar,
    'interiorMaskCoverage': coverage,
    'confidence': confidence,
  };
}

List<int>? _largestMaskComponent(List<bool> mask, int w, int h) {
  final visited = List<bool>.filled(w * h, false);
  List<int>? best;
  for (int i = 0; i < mask.length; i++) {
    if (!mask[i] || visited[i]) continue;
    final comp = <int>[];
    final queue = <int>[i];
    var qHead = 0;
    visited[i] = true;
    while (qHead < queue.length) {
      final cur = queue[qHead++];
      comp.add(cur);
      final cy = cur ~/ w;
      final cx = cur % w;
      for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          if (dx == 0 && dy == 0) continue;
          final ny = cy + dy;
          final nx = cx + dx;
          if (ny < 0 || ny >= h || nx < 0 || nx >= w) continue;
          final ni = ny * w + nx;
          if (!mask[ni] || visited[ni]) continue;
          visited[ni] = true;
          queue.add(ni);
        }
      }
    }
    if (best == null || comp.length > best.length) best = comp;
  }
  return best;
}

Map<String, dynamic>? _mapPalmGeometry(
  Map<String, dynamic>? geometry,
  List<double> Function(List<double>) mapPt,
) {
  if (geometry == null) return null;

  List<double> mapRect(dynamic raw) {
    final r = raw as List;
    final tl = mapPt([(r[0] as num).toDouble(), (r[1] as num).toDouble()]);
    final br = mapPt([(r[2] as num).toDouble(), (r[3] as num).toDouble()]);
    return [
      min(tl[0], br[0]),
      min(tl[1], br[1]),
      max(tl[0], br[0]),
      max(tl[1], br[1]),
    ];
  }

  List<double> pointFrom(dynamic raw) {
    final p = raw as List;
    return [(p[0] as num).toDouble(), (p[1] as num).toDouble()];
  }

  final center = mapPt(pointFrom(geometry['palmCenter']));
  final fingerBasePt = mapPt([
    0.0,
    (geometry['fingerBaseY'] as num).toDouble(),
  ]);
  final wristPt = mapPt([0.0, (geometry['wristY'] as num).toDouble()]);
  return {
    ...geometry,
    'palmCenter': center,
    'wristY': wristPt[1],
    'fingerBaseY': fingerBasePt[1],
    'palmBounds': mapRect(geometry['palmBounds']),
    'thenarRegion': mapRect(geometry['thenarRegion']),
  };
}

// ── ROI detection ─────────────────────────────────────────────────────────────

// Returns [left, top, right, bottom] in blurred-image pixel space,
// or null if the palm region is indeterminate (fall back to full image).
List<int>? _detectRoi(Uint8List blurred, int w, int h, int margin) {
  const minBright = 45;
  const maxBright = 222;
  // A row/column "has content" when ≥ 5 % of its inner span is palm-brightness.
  final minRowPx = max(1, (w - 2 * margin) ~/ 20);
  final minColPx = max(1, (h - 2 * margin) ~/ 20);

  final rowHasContent = List<bool>.filled(h, false);
  for (int y = margin; y < h - margin; y++) {
    int cnt = 0;
    for (int x = margin; x < w - margin; x++) {
      final v = blurred[y * w + x];
      if (v >= minBright && v <= maxBright) {
        cnt++;
        if (cnt >= minRowPx) break;
      }
    }
    rowHasContent[y] = cnt >= minRowPx;
  }

  final colHasContent = List<bool>.filled(w, false);
  for (int x = margin; x < w - margin; x++) {
    int cnt = 0;
    for (int y = margin; y < h - margin; y++) {
      final v = blurred[y * w + x];
      if (v >= minBright && v <= maxBright) {
        cnt++;
        if (cnt >= minColPx) break;
      }
    }
    colHasContent[x] = cnt >= minColPx;
  }

  int roiT = h, roiB = -1, roiL = w, roiR = -1;
  for (int y = margin; y < h - margin; y++) {
    if (rowHasContent[y]) {
      if (y < roiT) roiT = y;
      if (y > roiB) roiB = y;
    }
  }
  for (int x = margin; x < w - margin; x++) {
    if (colHasContent[x]) {
      if (x < roiL) roiL = x;
      if (x > roiR) roiR = x;
    }
  }

  if (roiB < roiT || roiR < roiL) return null;

  final roiW = roiR - roiL;
  final roiH = roiB - roiT;

  // Reject if ROI is too small (uncertain) or nearly the whole image (no gain).
  if (roiW < w * 0.25 || roiH < h * 0.25) return null;
  if (roiW > w * 0.92 && roiH > h * 0.92) return null;

  // 5 % padding, clamped to image bounds
  final padX = (roiW * 0.05).round().clamp(2, 20);
  final padY = (roiH * 0.05).round().clamp(2, 20);
  return [
    (roiL - padX).clamp(0, w - 1),
    (roiT - padY).clamp(0, h - 1),
    (roiR + padX).clamp(0, w - 1),
    (roiB + padY).clamp(0, h - 1),
  ];
}

// ── ROI crop + nearest-neighbour resize ───────────────────────────────────────

Uint8List _cropResize(
  Uint8List src,
  int srcW,
  int srcH,
  int roiL,
  int roiT,
  int roiR,
  int roiB,
  int dstSize,
) {
  final roiW = roiR - roiL;
  final roiH = roiB - roiT;
  final dst = Uint8List(dstSize * dstSize);
  for (int y = 0; y < dstSize; y++) {
    final srcY = (roiT + (y * roiH / dstSize).floor()).clamp(0, srcH - 1);
    for (int x = 0; x < dstSize; x++) {
      final srcX = (roiL + (x * roiW / dstSize).floor()).clamp(0, srcW - 1);
      dst[y * dstSize + x] = src[srcY * srcW + srcX];
    }
  }
  return dst;
}

// ── Palm interior mask via box erosion ───────────────────────────────────────

// Erodes [mask] by radius [r] pixels using a separable box kernel.
// O(w*h) via prefix sums — suitable for isolate use.
List<bool> _erodeMask(List<bool> mask, int w, int h, int r) {
  // Row pass: pixel is true iff all pixels in [x-r, x+r] of the same row are true.
  final rowEroded = List<bool>.filled(w * h, false);
  for (int y = 0; y < h; y++) {
    final pref = List<int>.filled(w + 1, 0);
    for (int x = 0; x < w; x++) {
      pref[x + 1] = pref[x] + (mask[y * w + x] ? 0 : 1);
    }
    for (int x = 0; x < w; x++) {
      final l = max(0, x - r);
      final rr = min(w - 1, x + r);
      rowEroded[y * w + x] = (pref[rr + 1] - pref[l]) == 0;
    }
  }
  // Column pass: pixel is true iff all pixels in [y-r, y+r] of the same column
  // (after row erosion) are true.
  final result = List<bool>.filled(w * h, false);
  for (int x = 0; x < w; x++) {
    final pref = List<int>.filled(h + 1, 0);
    for (int y = 0; y < h; y++) {
      pref[y + 1] = pref[y] + (rowEroded[y * w + x] ? 0 : 1);
    }
    for (int y = 0; y < h; y++) {
      final t = max(0, y - r);
      final b = min(h - 1, y + r);
      result[y * w + x] = (pref[b + 1] - pref[t]) == 0;
    }
  }
  return result;
}

// ── Ridge / valley strength ───────────────────────────────────────────────────

// Returns how much darker the center pixel is than its surroundings at radius ~4.
// Palm creases appear as dark grooves → high ridgeness. Uniform skin → near 0.
int _valleyStrength(Uint8List img, int x, int y, int w, int h) {
  if (x < 5 || x >= w - 5 || y < 5 || y >= h - 5) return 0;
  final c = img[y * w + x];
  // 8 sample points at radius ≈ 4 (mix of cardinal and diagonal)
  final bgSum =
      img[(y - 4) * w + x] +
      img[(y + 4) * w + x] +
      img[y * w + (x - 4)] +
      img[y * w + (x + 4)] +
      img[(y - 3) * w + (x - 3)] +
      img[(y - 3) * w + (x + 3)] +
      img[(y + 3) * w + (x - 3)] +
      img[(y + 3) * w + (x + 3)];
  final bgMean = bgSum ~/ 8;
  return (bgMean - c).clamp(0, 255);
}

int _darkLineStrength(Uint8List img, int x, int y, int w, int h) {
  if (x < 8 || x >= w - 8 || y < 8 || y >= h - 8) return 0;
  final c = img[y * w + x];
  var best = 0;
  for (final r in const [3, 5, 7]) {
    final pairHorizontal = (img[y * w + x - r] + img[y * w + x + r]) ~/ 2 - c;
    final pairVertical = (img[(y - r) * w + x] + img[(y + r) * w + x]) ~/ 2 - c;
    final pairDiagA =
        (img[(y - r) * w + x - r] + img[(y + r) * w + x + r]) ~/ 2 - c;
    final pairDiagB =
        (img[(y - r) * w + x + r] + img[(y + r) * w + x - r]) ~/ 2 - c;
    final strongestPair = max(
      max(pairHorizontal, pairVertical),
      max(pairDiagA, pairDiagB),
    );
    final ringMean =
        (img[y * w + x - r] +
            img[y * w + x + r] +
            img[(y - r) * w + x] +
            img[(y + r) * w + x] +
            img[(y - r) * w + x - r] +
            img[(y - r) * w + x + r] +
            img[(y + r) * w + x - r] +
            img[(y + r) * w + x + r]) ~/
        8;
    final score = ((strongestPair * 0.65) + ((ringMean - c) * 0.35)).round();
    if (score > best) best = score;
  }
  return best.clamp(0, 255);
}

// ── Connected-component labeling ──────────────────────────────────────────────

List<List<int>> _findComponents(
  List<bool> binary,
  int w,
  int h, {
  required int minSize,
}) {
  final visited = List<bool>.filled(w * h, false);
  final results = <List<int>>[];

  for (int y = 1; y < h - 1; y++) {
    for (int x = 1; x < w - 1; x++) {
      final idx = y * w + x;
      if (!binary[idx] || visited[idx]) continue;

      final comp = <int>[];
      final queue = <int>[idx];
      int qHead = 0;
      visited[idx] = true;

      while (qHead < queue.length) {
        final cur = queue[qHead++];
        comp.add(cur);
        final cy = cur ~/ w;
        final cx = cur % w;
        if (cy <= 0 || cy >= h - 1 || cx <= 0 || cx >= w - 1) continue;
        for (int dy = -1; dy <= 1; dy++) {
          for (int dx = -1; dx <= 1; dx++) {
            if (dy == 0 && dx == 0) continue;
            final ni = (cy + dy) * w + (cx + dx);
            if (!binary[ni] || visited[ni]) continue;
            visited[ni] = true;
            queue.add(ni);
          }
        }
      }

      if (comp.length >= minSize) results.add(comp);
    }
  }

  results.sort((a, b) => b.length.compareTo(a.length));
  return results.take(10).toList();
}

// ── Path building from component pixels ───────────────────────────────────────

List<List<double>> _buildOrderedPath(List<int> comp, int w, int h) {
  if (comp.length < 2) return [];

  const maxPts = 60;

  // Fast membership look-up for the component pixels.
  final compSet = Set<int>.from(comp);

  // Count 8-connected neighbours that belong to this component.
  int degreeOf(int idx) {
    final cy = idx ~/ w;
    final cx = idx % w;
    var n = 0;
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        if (dy == 0 && dx == 0) continue;
        final ny = cy + dy;
        final nx = cx + dx;
        if (ny < 0 || ny >= h || nx < 0 || nx >= w) continue;
        if (compSet.contains(ny * w + nx)) n++;
      }
    }
    return n;
  }

  // Endpoint = pixel with exactly one component-neighbour.
  // Prefer the topmost (then leftmost) endpoint as the starting pixel.
  // When no endpoint exists (closed contour / blob) use the topmost-leftmost
  // pixel of the whole component.
  int startIdx = -1;
  int bestY = h, bestX = w;
  for (final idx in comp) {
    if (degreeOf(idx) == 1) {
      final iy = idx ~/ w, ix = idx % w;
      if (iy < bestY || (iy == bestY && ix < bestX)) {
        bestY = iy;
        bestX = ix;
        startIdx = idx;
      }
    }
  }
  if (startIdx == -1) {
    for (final idx in comp) {
      final iy = idx ~/ w, ix = idx % w;
      if (iy < bestY || (iy == bestY && ix < bestX)) {
        bestY = iy;
        bestX = ix;
        startIdx = idx;
      }
    }
  }

  // Walk the path: at each step choose the unvisited neighbour that requires
  // the smallest turn relative to the current heading (direction continuity).
  final visited = <int>{startIdx};
  final ordered = <int>[startIdx];
  double dirX = 0.0, dirY = 0.0;

  while (true) {
    final cur = ordered.last;
    final cy = cur ~/ w;
    final cx = cur % w;
    int best = -1;
    double bestScore = double.infinity;

    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        if (dy == 0 && dx == 0) continue;
        final ny = cy + dy;
        final nx = cx + dx;
        if (ny < 0 || ny >= h || nx < 0 || nx >= w) continue;
        final ni = ny * w + nx;
        if (!compSet.contains(ni) || visited.contains(ni)) continue;

        final double score;
        if (dirX == 0.0 && dirY == 0.0) {
          // No heading yet – prefer topmost neighbour.
          score = ny.toDouble();
        } else {
          final len = sqrt((dx * dx + dy * dy).toDouble());
          // Minimise score ↔ maximise alignment with current direction.
          score = -(dx * dirX + dy * dirY) / len;
        }
        if (score < bestScore) {
          bestScore = score;
          best = ni;
        }
      }
    }
    if (best == -1) break;

    final ndx = (best % w) - cx;
    final ndy = (best ~/ w) - cy;
    final len = sqrt((ndx * ndx + ndy * ndy).toDouble());
    dirX = ndx / len;
    dirY = ndy / len;
    visited.add(best);
    ordered.add(best);
  }

  // Uniform downsampling to at most maxPts, always keeping first and last.
  if (ordered.length <= maxPts) {
    return ordered.map((i) => [(i % w) / w, (i ~/ w) / h]).toList();
  }
  final step = ordered.length ~/ maxPts;
  final sampled = <int>[ordered.first];
  for (var i = step; i < ordered.length - 1; i += step) {
    sampled.add(ordered[i]);
  }
  sampled.add(ordered.last);
  return sampled.map((i) => [(i % w) / w, (i ~/ w) / h]).toList();
}

// ── Test helpers ──────────────────────────────────────────────────────────────

@visibleForTesting
Map<String, dynamic> processPixelsForTest(
  Uint8List pixels,
  int width,
  int height,
) => _processPixels(_PixelInput(pixels: pixels, width: width, height: height));

@visibleForTesting
List<bool> erodeMaskForTest(List<bool> mask, int w, int h, int r) =>
    _erodeMask(mask, w, h, r);

@visibleForTesting
int valleyStrengthForTest(Uint8List img, int x, int y, int w, int h) =>
    _valleyStrength(img, x, y, w, h);

@visibleForTesting
int darkLineStrengthForTest(Uint8List img, int x, int y, int w, int h) =>
    _darkLineStrength(img, x, y, w, h);

@visibleForTesting
PalmGeometry? palmGeometryFromMaskForTest(List<bool> mask, int w, int h) =>
    _geometryFromRaw(_detectPalmGeometry(mask, w, h));
