import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Offset, Rect;

import '../models/scanned_hand.dart';
import 'hand_segmentor.dart';

// ── Result model ──────────────────────────────────────────────────────────────

enum PalmThumbSide { left, right, unknown }

enum PalmHandedness { left, right, unknown }

class PalmDebugSample {
  const PalmDebugSample({required this.point, required this.value});

  final Offset point;
  final double value;
}

class PalmDebugVector {
  const PalmDebugVector({
    required this.from,
    required this.to,
    required this.value,
  });

  final Offset from;
  final Offset to;
  final double value;
}

class PalmTracedCrease {
  const PalmTracedCrease({
    required this.points,
    required this.totalLength,
    required this.averageProbability,
    required this.continuityScore,
    required this.averageCurvature,
    required this.interruptionCount,
    required this.branchCount,
    this.anatomicalScore = 0.0,
    this.weightedProbability = 0.0,
    this.averageRidgeResponse = 0.0,
    this.maximumRidgeResponse = 0.0,
    this.ridgeConsistency = 0.0,
    this.ridgeWidthEstimate = 0.0,
    this.averageDarkness = 0.0,
    this.majorLineScore = 0.0,
    this.rejectionReason = '',
    this.insidePalmRatio = 1.0,
  });

  final List<Offset> points;
  final double totalLength;
  final double averageProbability;
  final double continuityScore;
  final double averageCurvature;
  final int interruptionCount;
  final int branchCount;
  final double anatomicalScore;
  final double weightedProbability;
  final double averageRidgeResponse;
  final double maximumRidgeResponse;
  final double ridgeConsistency;
  final double ridgeWidthEstimate;
  final double averageDarkness;
  final double majorLineScore;
  final String rejectionReason;
  // Fraction of trace pixels inside boundarySafeMask [0,1].
  // Candidates with insidePalmRatio < 0.98 are rejected before classification.
  final double insidePalmRatio;
}

class PalmLineAnatomyResult {
  const PalmLineAnatomyResult({
    this.lifeCandidates = const [],
    this.heartCandidates = const [],
    this.headCandidates = const [],
    this.fateCandidates = const [],
    this.lifeTracedCreases = const [],
    this.heartTracedCreases = const [],
    this.headTracedCreases = const [],
    this.fateTracedCreases = const [],
    this.baseCreasePixels = 0,
    this.lifeCreasePixels = 0,
    this.heartCreasePixels = 0,
    this.headCreasePixels = 0,
    this.fateCreasePixels = 0,
    this.lifeSkeletonLength = 0,
    this.heartSkeletonLength = 0,
    this.headSkeletonLength = 0,
    this.fateSkeletonLength = 0,
    this.debugLifeWeightedProb = const [],
    this.debugHeartWeightedProb = const [],
    this.debugHeadWeightedProb = const [],
    this.debugFateWeightedProb = const [],
    this.debugLifeSkeleton = const [],
    this.debugHeartSkeleton = const [],
    this.debugHeadSkeleton = const [],
    this.debugFateSkeleton = const [],
  });

  static const empty = PalmLineAnatomyResult();

  final List<List<Offset>> lifeCandidates;
  final List<List<Offset>> heartCandidates;
  final List<List<Offset>> headCandidates;
  final List<List<Offset>> fateCandidates;
  final List<PalmTracedCrease> lifeTracedCreases;
  final List<PalmTracedCrease> heartTracedCreases;
  final List<PalmTracedCrease> headTracedCreases;
  final List<PalmTracedCrease> fateTracedCreases;
  final int baseCreasePixels;
  final int lifeCreasePixels;
  final int heartCreasePixels;
  final int headCreasePixels;
  final int fateCreasePixels;
  final int lifeSkeletonLength;
  final int heartSkeletonLength;
  final int headSkeletonLength;
  final int fateSkeletonLength;
  final List<PalmDebugSample> debugLifeWeightedProb;
  final List<PalmDebugSample> debugHeartWeightedProb;
  final List<PalmDebugSample> debugHeadWeightedProb;
  final List<PalmDebugSample> debugFateWeightedProb;
  final List<PalmDebugSample> debugLifeSkeleton;
  final List<PalmDebugSample> debugHeartSkeleton;
  final List<PalmDebugSample> debugHeadSkeleton;
  final List<PalmDebugSample> debugFateSkeleton;
}

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
    this.thumbBase = Offset.zero,
    this.thumbIndexWeb = Offset.zero,
    this.thenarCenter = Offset.zero,
    this.fingerBaseArc = const [],
    this.wristCenter = Offset.zero,
    this.wristLeft = Offset.zero,
    this.wristRight = Offset.zero,
    this.wristWidth = 0.0,
    this.palmWidth = 0.0,
    this.palmHeight = 0.0,
    this.majorAxisAngle = 0.0,
    this.minorAxisAngle = 0.0,
    this.handedness = PalmHandedness.unknown,
    this.thumbSideConfidence = 0.0,
    this.palmCenterConfidence = 0.0,
    this.fingerArcConfidence = 0.0,
    this.wristConfidence = 0.0,
    this.canonicalTransformQuality = 0.0,
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
  final Offset thumbBase;
  final Offset thumbIndexWeb;
  final Offset thenarCenter;
  final List<Offset> fingerBaseArc;
  final Offset wristCenter;
  final Offset wristLeft;
  final Offset wristRight;
  final double wristWidth;
  final double palmWidth;
  final double palmHeight;
  final double majorAxisAngle;
  final double minorAxisAngle;
  final PalmHandedness handedness;
  final double thumbSideConfidence;
  final double palmCenterConfidence;
  final double fingerArcConfidence;
  final double wristConfidence;
  final double canonicalTransformQuality;

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
    this.creasePixelCount = 0,
    this.skeletonLength = 0,
    this.averageCreaseProbability = 0.0,
    this.largestCreasePixelCount = 0,
    this.processingTimeMs = 0,
    this.debugPalmMask = const [],
    this.debugClahe = const [],
    this.debugDarkLineResponse = const [],
    this.multiScaleRidgeMap = const [],
    this.debugMultiScaleRidgeMap = const [],
    this.debugRidgeStrengthHeatmap = const [],
    this.debugCreaseProbability = const [],
    this.debugSkeleton = const [],
    this.tracedCreases = const [],
    this.traceCount = 0,
    this.averageTraceLength = 0.0,
    this.longestTraceLength = 0.0,
    this.recoveredGapCount = 0,
    this.averageTraceContinuity = 0.0,
    this.averageTraceProbability = 0.0,
    this.tracingTimeMs = 0,
    this.debugTraceSeeds = const [],
    this.debugTraceDirections = const [],
    this.debugGapRecoveries = const [],
    this.debugMajorLineScores = const [],
    this.debugTopLifeLineCandidates = const [],
    this.debugTraceRejectionReasons = const [],
    this.averageAnatomicalScore = 0.0,
    this.lifePriorScore = 0.0,
    this.heartPriorScore = 0.0,
    this.headPriorScore = 0.0,
    this.fatePriorScore = 0.0,
    this.trackerConfidenceBeforeAnatomical = 0.0,
    this.trackerConfidenceAfterAnatomical = 0.0,
    this.debugLifePrior = const [],
    this.debugHeartPrior = const [],
    this.debugHeadPrior = const [],
    this.debugFatePrior = const [],
    this.scannedHand = ScannedHand.unknown,
    this.anatomyWeighted = const PalmLineAnatomyResult(),
    this.outsideMaskProbabilityPixels = 0,
    this.outsideMaskSkeletonPixels = 0,
    this.rejectedOutsideMaskTraces = 0,
    this.minInsidePalmRatioOfAcceptedCandidates = 1.0,
    this.rejectedOutsideMaskPaths = const [],
    this.debugPalmOutline = const [],
    this.handSegmentation,
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
  PalmThumbSide get imageThumbSide =>
      palmGeometry?.thumbSide ?? PalmThumbSide.unknown;
  ScannedHand get semanticHandedness => scannedHand;

  /// Pixels above the crease-probability threshold before skeletonization.
  final int creasePixelCount;

  /// Number of skeleton pixels passed to path extraction.
  final int skeletonLength;

  /// Mean probability across crease pixels.
  final double averageCreaseProbability;

  /// Largest connected high-probability crease region before skeletonization.
  final int largestCreasePixelCount;

  /// End-to-end isolate processing time in milliseconds.
  final int processingTimeMs;

  /// Debug samples in normalized original image space.
  final List<PalmDebugSample> debugPalmMask;
  final List<PalmDebugSample> debugClahe;
  final List<PalmDebugSample> debugDarkLineResponse;
  final List<PalmDebugSample> multiScaleRidgeMap;
  final List<PalmDebugSample> debugMultiScaleRidgeMap;
  final List<PalmDebugSample> debugRidgeStrengthHeatmap;
  final List<PalmDebugSample> debugCreaseProbability;
  final List<PalmDebugSample> debugSkeleton;

  /// Complete traced palm creases reconstructed from skeleton + probability.
  final List<PalmTracedCrease> tracedCreases;
  final int traceCount;
  final double averageTraceLength;
  final double longestTraceLength;
  final int recoveredGapCount;
  final double averageTraceContinuity;
  final double averageTraceProbability;
  final int tracingTimeMs;

  /// Debug data for the crease tracer.
  final List<PalmDebugSample> debugTraceSeeds;
  final List<PalmDebugVector> debugTraceDirections;
  final List<PalmDebugVector> debugGapRecoveries;
  final List<PalmDebugSample> debugMajorLineScores;
  final List<PalmDebugSample> debugTopLifeLineCandidates;
  final List<String> debugTraceRejectionReasons;

  /// Anatomical prior scores sampled from life/heart/head/fate heatmaps.
  final double averageAnatomicalScore;
  final double lifePriorScore;
  final double heartPriorScore;
  final double headPriorScore;
  final double fatePriorScore;
  final double trackerConfidenceBeforeAnatomical;
  final double trackerConfidenceAfterAnatomical;
  final List<PalmDebugSample> debugLifePrior;
  final List<PalmDebugSample> debugHeartPrior;
  final List<PalmDebugSample> debugHeadPrior;
  final List<PalmDebugSample> debugFatePrior;
  final ScannedHand scannedHand;
  final PalmLineAnatomyResult anatomyWeighted;

  /// Pixels that had residual probability > 0 outside boundarySafeMask (safety net; should be 0).
  final int outsideMaskProbabilityPixels;

  /// Skeleton pixels outside boundarySafeMask that were explicitly zeroed.
  final int outsideMaskSkeletonPixels;

  /// Number of traces rejected because insidePalmRatio < 0.98.
  final int rejectedOutsideMaskTraces;

  /// Minimum inside-palm ratio across all accepted candidate paths (should be >= 0.98).
  final double minInsidePalmRatioOfAcceptedCandidates;

  /// Candidate paths rejected because < 98 % of their pixels were inside the palm mask.
  final List<List<Offset>> rejectedOutsideMaskPaths;

  /// Boundary outline of boundarySafeMask for debug visualisation.
  final List<PalmDebugSample> debugPalmOutline;

  /// Hand segmentation result from Phase 8 (null when segmentation was skipped).
  final HandSegmentResult? handSegmentation;

  bool get hasRealData => edgePointCount > 0;
  bool get hasRoi => roiLeft != null;
  int get candidatePathCount => candidatePaths.length;

  PalmLineExtractionResult copyWith({
    ScannedHand? scannedHand,
    HandSegmentResult? handSegmentation,
  }) {
    return PalmLineExtractionResult(
      edgePoints: edgePoints,
      candidatePaths: candidatePaths,
      confidence: confidence,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      edgePointCount: edgePointCount,
      roiLeft: roiLeft,
      roiTop: roiTop,
      roiRight: roiRight,
      roiBottom: roiBottom,
      normalizedWidth: normalizedWidth,
      normalizedHeight: normalizedHeight,
      rejectedPaths: rejectedPaths,
      palmMaskCoverage: palmMaskCoverage,
      darkLinePixelCount: darkLinePixelCount,
      sobelPixelCount: sobelPixelCount,
      acceptedInteriorRatio: acceptedInteriorRatio,
      rejectedBoundaryRatio: rejectedBoundaryRatio,
      palmGeometry: palmGeometry,
      creasePixelCount: creasePixelCount,
      skeletonLength: skeletonLength,
      averageCreaseProbability: averageCreaseProbability,
      largestCreasePixelCount: largestCreasePixelCount,
      processingTimeMs: processingTimeMs,
      debugPalmMask: debugPalmMask,
      debugClahe: debugClahe,
      debugDarkLineResponse: debugDarkLineResponse,
      multiScaleRidgeMap: multiScaleRidgeMap,
      debugMultiScaleRidgeMap: debugMultiScaleRidgeMap,
      debugRidgeStrengthHeatmap: debugRidgeStrengthHeatmap,
      debugCreaseProbability: debugCreaseProbability,
      debugSkeleton: debugSkeleton,
      tracedCreases: tracedCreases,
      traceCount: traceCount,
      averageTraceLength: averageTraceLength,
      longestTraceLength: longestTraceLength,
      recoveredGapCount: recoveredGapCount,
      averageTraceContinuity: averageTraceContinuity,
      averageTraceProbability: averageTraceProbability,
      tracingTimeMs: tracingTimeMs,
      debugTraceSeeds: debugTraceSeeds,
      debugTraceDirections: debugTraceDirections,
      debugGapRecoveries: debugGapRecoveries,
      debugMajorLineScores: debugMajorLineScores,
      debugTopLifeLineCandidates: debugTopLifeLineCandidates,
      debugTraceRejectionReasons: debugTraceRejectionReasons,
      averageAnatomicalScore: averageAnatomicalScore,
      lifePriorScore: lifePriorScore,
      heartPriorScore: heartPriorScore,
      headPriorScore: headPriorScore,
      fatePriorScore: fatePriorScore,
      trackerConfidenceBeforeAnatomical: trackerConfidenceBeforeAnatomical,
      trackerConfidenceAfterAnatomical: trackerConfidenceAfterAnatomical,
      debugLifePrior: debugLifePrior,
      debugHeartPrior: debugHeartPrior,
      debugHeadPrior: debugHeadPrior,
      debugFatePrior: debugFatePrior,
      scannedHand: scannedHand ?? this.scannedHand,
      anatomyWeighted: anatomyWeighted,
      outsideMaskProbabilityPixels: outsideMaskProbabilityPixels,
      outsideMaskSkeletonPixels: outsideMaskSkeletonPixels,
      rejectedOutsideMaskTraces: rejectedOutsideMaskTraces,
      minInsidePalmRatioOfAcceptedCandidates:
          minInsidePalmRatioOfAcceptedCandidates,
      rejectedOutsideMaskPaths: rejectedOutsideMaskPaths,
      debugPalmOutline: debugPalmOutline,
      handSegmentation: handSegmentation ?? this.handSegmentation,
    );
  }

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
    creasePixelCount: 0,
    skeletonLength: 0,
    averageCreaseProbability: 0.0,
    largestCreasePixelCount: 0,
    processingTimeMs: 0,
    debugPalmMask: [],
    debugClahe: [],
    debugDarkLineResponse: [],
    multiScaleRidgeMap: [],
    debugMultiScaleRidgeMap: [],
    debugRidgeStrengthHeatmap: [],
    debugCreaseProbability: [],
    debugSkeleton: [],
    tracedCreases: [],
    traceCount: 0,
    averageTraceLength: 0.0,
    longestTraceLength: 0.0,
    recoveredGapCount: 0,
    averageTraceContinuity: 0.0,
    averageTraceProbability: 0.0,
    tracingTimeMs: 0,
    debugTraceSeeds: [],
    debugTraceDirections: [],
    debugGapRecoveries: [],
    debugMajorLineScores: [],
    debugTopLifeLineCandidates: [],
    debugTraceRejectionReasons: [],
    averageAnatomicalScore: 0.0,
    lifePriorScore: 0.0,
    heartPriorScore: 0.0,
    headPriorScore: 0.0,
    fatePriorScore: 0.0,
    trackerConfidenceBeforeAnatomical: 0.0,
    trackerConfidenceAfterAnatomical: 0.0,
    debugLifePrior: [],
    debugHeartPrior: [],
    debugHeadPrior: [],
    debugFatePrior: [],
    scannedHand: ScannedHand.unknown,
    anatomyWeighted: PalmLineAnatomyResult.empty,
    outsideMaskProbabilityPixels: 0,
    outsideMaskSkeletonPixels: 0,
    rejectedOutsideMaskTraces: 0,
    minInsidePalmRatioOfAcceptedCandidates: 1.0,
    rejectedOutsideMaskPaths: [],
    debugPalmOutline: [],
  );
}

// ── Extractor ─────────────────────────────────────────────────────────────────

class PalmLineExtractor {
  PalmLineExtractor._();

  static Future<PalmLineExtractionResult> extract(
    Uint8List imageBytes, {
    HandSegmentResult? segmentation,
  }) async {
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

      // Phase 8: apply hand mask — replace background with black (gray 0 < 35,
      // excluded from both the skin mask and ROI brightness range).
      var pixels = byteData.buffer.asUint8List();
      if (segmentation != null && segmentation.mask.isNotEmpty) {
        pixels = _applyHandMask(
          pixels,
          imgW,
          imgH,
          segmentation.mask,
          segmentation.maskWidth,
          segmentation.maskHeight,
        );
      }

      final raw = await compute(
        _processPixels,
        _PixelInput(pixels: pixels, width: imgW, height: imgH),
      );
      return _buildResult(raw).copyWith(handSegmentation: segmentation);
    } catch (_) {
      return PalmLineExtractionResult.empty;
    }
  }

  static PalmLineExtractionResult _buildResult(Map<String, dynamic> raw) {
    Offset toOffset(dynamic p) {
      final l = p as List;
      return Offset((l[0] as num).toDouble(), (l[1] as num).toDouble());
    }

    PalmDebugSample toSample(dynamic p) {
      final l = p as List;
      return PalmDebugSample(
        point: Offset((l[0] as num).toDouble(), (l[1] as num).toDouble()),
        value: (l[2] as num).toDouble(),
      );
    }

    PalmDebugVector toVector(dynamic p) {
      final l = p as List;
      return PalmDebugVector(
        from: Offset((l[0] as num).toDouble(), (l[1] as num).toDouble()),
        to: Offset((l[2] as num).toDouble(), (l[3] as num).toDouble()),
        value: (l[4] as num).toDouble(),
      );
    }

    PalmTracedCrease toTrace(dynamic raw) {
      final m = raw as Map;
      final rawPoints = m['points'] as List<dynamic>;
      return PalmTracedCrease(
        points: rawPoints.map(toOffset).toList(),
        totalLength: (m['totalLength'] as num).toDouble(),
        averageProbability: (m['averageProbability'] as num).toDouble(),
        continuityScore: (m['continuityScore'] as num).toDouble(),
        averageCurvature: (m['averageCurvature'] as num).toDouble(),
        interruptionCount: m['interruptionCount'] as int,
        branchCount: m['branchCount'] as int,
        anatomicalScore: (m['anatomicalScore'] as num?)?.toDouble() ?? 0.0,
        weightedProbability:
            (m['weightedProbability'] as num?)?.toDouble() ?? 0.0,
        averageRidgeResponse:
            (m['averageRidgeResponse'] as num?)?.toDouble() ?? 0.0,
        maximumRidgeResponse:
            (m['maximumRidgeResponse'] as num?)?.toDouble() ?? 0.0,
        ridgeConsistency: (m['ridgeConsistency'] as num?)?.toDouble() ?? 0.0,
        ridgeWidthEstimate:
            (m['ridgeWidthEstimate'] as num?)?.toDouble() ?? 0.0,
        averageDarkness: (m['averageDarkness'] as num?)?.toDouble() ?? 0.0,
        majorLineScore: (m['majorLineScore'] as num?)?.toDouble() ?? 0.0,
        rejectionReason: m['rejectionReason'] as String? ?? '',
        insidePalmRatio: (m['insidePalmRatio'] as num?)?.toDouble() ?? 1.0,
      );
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
      creasePixelCount: raw['creasePixelCount'] as int? ?? 0,
      skeletonLength: raw['skeletonLength'] as int? ?? 0,
      averageCreaseProbability:
          (raw['averageCreaseProbability'] as num?)?.toDouble() ?? 0.0,
      largestCreasePixelCount: raw['largestCreasePixelCount'] as int? ?? 0,
      processingTimeMs: raw['processingTimeMs'] as int? ?? 0,
      debugPalmMask: (raw['debugPalmMask'] as List<dynamic>? ?? const [])
          .map(toSample)
          .toList(),
      debugClahe: (raw['debugClahe'] as List<dynamic>? ?? const [])
          .map(toSample)
          .toList(),
      debugDarkLineResponse:
          (raw['debugDarkLineResponse'] as List<dynamic>? ?? const [])
              .map(toSample)
              .toList(),
      multiScaleRidgeMap:
          (raw['multiScaleRidgeMap'] as List<dynamic>? ?? const [])
              .map(toSample)
              .toList(),
      debugMultiScaleRidgeMap:
          (raw['debugMultiScaleRidgeMap'] as List<dynamic>? ?? const [])
              .map(toSample)
              .toList(),
      debugRidgeStrengthHeatmap:
          (raw['debugRidgeStrengthHeatmap'] as List<dynamic>? ?? const [])
              .map(toSample)
              .toList(),
      debugCreaseProbability:
          (raw['debugCreaseProbability'] as List<dynamic>? ?? const [])
              .map(toSample)
              .toList(),
      debugSkeleton: (raw['debugSkeleton'] as List<dynamic>? ?? const [])
          .map(toSample)
          .toList(),
      tracedCreases: (raw['tracedCreases'] as List<dynamic>? ?? const [])
          .map(toTrace)
          .toList(),
      traceCount: raw['traceCount'] as int? ?? 0,
      averageTraceLength:
          (raw['averageTraceLength'] as num?)?.toDouble() ?? 0.0,
      longestTraceLength:
          (raw['longestTraceLength'] as num?)?.toDouble() ?? 0.0,
      recoveredGapCount: raw['recoveredGapCount'] as int? ?? 0,
      averageTraceContinuity:
          (raw['averageTraceContinuity'] as num?)?.toDouble() ?? 0.0,
      averageTraceProbability:
          (raw['averageTraceProbability'] as num?)?.toDouble() ?? 0.0,
      tracingTimeMs: raw['tracingTimeMs'] as int? ?? 0,
      debugTraceSeeds: (raw['debugTraceSeeds'] as List<dynamic>? ?? const [])
          .map(toSample)
          .toList(),
      debugTraceDirections:
          (raw['debugTraceDirections'] as List<dynamic>? ?? const [])
              .map(toVector)
              .toList(),
      debugGapRecoveries:
          (raw['debugGapRecoveries'] as List<dynamic>? ?? const [])
              .map(toVector)
              .toList(),
      debugMajorLineScores:
          (raw['debugMajorLineScores'] as List<dynamic>? ?? const [])
              .map(toSample)
              .toList(),
      debugTopLifeLineCandidates:
          (raw['debugTopLifeLineCandidates'] as List<dynamic>? ?? const [])
              .map(toSample)
              .toList(),
      debugTraceRejectionReasons:
          (raw['debugTraceRejectionReasons'] as List<dynamic>? ?? const [])
              .map((v) => v.toString())
              .toList(),
      averageAnatomicalScore:
          (raw['averageAnatomicalScore'] as num?)?.toDouble() ?? 0.0,
      lifePriorScore: (raw['lifePriorScore'] as num?)?.toDouble() ?? 0.0,
      heartPriorScore: (raw['heartPriorScore'] as num?)?.toDouble() ?? 0.0,
      headPriorScore: (raw['headPriorScore'] as num?)?.toDouble() ?? 0.0,
      fatePriorScore: (raw['fatePriorScore'] as num?)?.toDouble() ?? 0.0,
      trackerConfidenceBeforeAnatomical:
          (raw['trackerConfidenceBeforeAnatomical'] as num?)?.toDouble() ?? 0.0,
      trackerConfidenceAfterAnatomical:
          (raw['trackerConfidenceAfterAnatomical'] as num?)?.toDouble() ?? 0.0,
      debugLifePrior: (raw['debugLifePrior'] as List<dynamic>? ?? const [])
          .map(toSample)
          .toList(),
      debugHeartPrior: (raw['debugHeartPrior'] as List<dynamic>? ?? const [])
          .map(toSample)
          .toList(),
      debugHeadPrior: (raw['debugHeadPrior'] as List<dynamic>? ?? const [])
          .map(toSample)
          .toList(),
      debugFatePrior: (raw['debugFatePrior'] as List<dynamic>? ?? const [])
          .map(toSample)
          .toList(),
      anatomyWeighted: _anatomyFromRaw(
        raw['anatomyWeighted'],
        toOffset,
        toSample,
        toTrace,
      ),
      outsideMaskProbabilityPixels:
          raw['outsideMaskProbabilityPixels'] as int? ?? 0,
      outsideMaskSkeletonPixels: raw['outsideMaskSkeletonPixels'] as int? ?? 0,
      rejectedOutsideMaskTraces: raw['rejectedOutsideMaskTraces'] as int? ?? 0,
      minInsidePalmRatioOfAcceptedCandidates:
          (raw['minInsidePalmRatioOfAcceptedCandidates'] as num?)?.toDouble() ??
          1.0,
      rejectedOutsideMaskPaths:
          (raw['rejectedOutsideMaskPaths'] as List<dynamic>? ?? const [])
              .map((path) => (path as List<dynamic>).map(toOffset).toList())
              .toList(),
      debugPalmOutline: (raw['debugPalmOutline'] as List<dynamic>? ?? const [])
          .map(toSample)
          .toList(),
    );
  }

  static PalmLineAnatomyResult _anatomyFromRaw(
    dynamic rawAnatomy,
    Offset Function(dynamic) toOffset,
    PalmDebugSample Function(dynamic) toSample,
    PalmTracedCrease Function(dynamic) toTrace,
  ) {
    if (rawAnatomy == null) return PalmLineAnatomyResult.empty;
    final m = rawAnatomy as Map<String, dynamic>;
    List<List<Offset>> parsePaths(String key) =>
        (m[key] as List<dynamic>? ?? const [])
            .map((path) => (path as List<dynamic>).map(toOffset).toList())
            .toList();
    List<PalmTracedCrease> parseCreases(String key) =>
        (m[key] as List<dynamic>? ?? const []).map(toTrace).toList();
    List<PalmDebugSample> parseSamples(String key) =>
        (m[key] as List<dynamic>? ?? const []).map(toSample).toList();
    return PalmLineAnatomyResult(
      lifeCandidates: parsePaths('lifeCandidates'),
      heartCandidates: parsePaths('heartCandidates'),
      headCandidates: parsePaths('headCandidates'),
      fateCandidates: parsePaths('fateCandidates'),
      lifeTracedCreases: parseCreases('lifeTracedCreases'),
      heartTracedCreases: parseCreases('heartTracedCreases'),
      headTracedCreases: parseCreases('headTracedCreases'),
      fateTracedCreases: parseCreases('fateTracedCreases'),
      baseCreasePixels: m['baseCreasePixels'] as int? ?? 0,
      lifeCreasePixels: m['lifeCreasePixels'] as int? ?? 0,
      heartCreasePixels: m['heartCreasePixels'] as int? ?? 0,
      headCreasePixels: m['headCreasePixels'] as int? ?? 0,
      fateCreasePixels: m['fateCreasePixels'] as int? ?? 0,
      lifeSkeletonLength: m['lifeSkeletonLength'] as int? ?? 0,
      heartSkeletonLength: m['heartSkeletonLength'] as int? ?? 0,
      headSkeletonLength: m['headSkeletonLength'] as int? ?? 0,
      fateSkeletonLength: m['fateSkeletonLength'] as int? ?? 0,
      debugLifeWeightedProb: parseSamples('debugLifeWeightedProb'),
      debugHeartWeightedProb: parseSamples('debugHeartWeightedProb'),
      debugHeadWeightedProb: parseSamples('debugHeadWeightedProb'),
      debugFateWeightedProb: parseSamples('debugFateWeightedProb'),
      debugLifeSkeleton: parseSamples('debugLifeSkeleton'),
      debugHeartSkeleton: parseSamples('debugHeartSkeleton'),
      debugHeadSkeleton: parseSamples('debugHeadSkeleton'),
      debugFateSkeleton: parseSamples('debugFateSkeleton'),
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
  final handedness = switch (m['handedness'] as String?) {
    'left' => PalmHandedness.left,
    'right' => PalmHandedness.right,
    _ => PalmHandedness.unknown,
  };
  List<Offset> arcFrom(dynamic raw) {
    final points = raw as List<dynamic>? ?? const [];
    return points.map(offsetFrom).toList();
  }

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
    thumbBase: m['thumbBase'] == null
        ? Offset.zero
        : offsetFrom(m['thumbBase']),
    thumbIndexWeb: m['thumbIndexWeb'] == null
        ? Offset.zero
        : offsetFrom(m['thumbIndexWeb']),
    thenarCenter: m['thenarCenter'] == null
        ? Offset.zero
        : offsetFrom(m['thenarCenter']),
    fingerBaseArc: arcFrom(m['fingerBaseArc']),
    wristCenter: m['wristCenter'] == null
        ? Offset.zero
        : offsetFrom(m['wristCenter']),
    wristLeft: m['wristLeft'] == null
        ? Offset.zero
        : offsetFrom(m['wristLeft']),
    wristRight: m['wristRight'] == null
        ? Offset.zero
        : offsetFrom(m['wristRight']),
    wristWidth: (m['wristWidth'] as num?)?.toDouble() ?? 0.0,
    palmWidth: (m['palmWidth'] as num?)?.toDouble() ?? 0.0,
    palmHeight: (m['palmHeight'] as num?)?.toDouble() ?? 0.0,
    majorAxisAngle:
        (m['majorAxisAngle'] as num?)?.toDouble() ??
        (m['mainAxisAngle'] as num).toDouble(),
    minorAxisAngle: (m['minorAxisAngle'] as num?)?.toDouble() ?? 0.0,
    handedness: handedness,
    thumbSideConfidence: (m['thumbSideConfidence'] as num?)?.toDouble() ?? 0.0,
    palmCenterConfidence:
        (m['palmCenterConfidence'] as num?)?.toDouble() ?? 0.0,
    fingerArcConfidence: (m['fingerArcConfidence'] as num?)?.toDouble() ?? 0.0,
    wristConfidence: (m['wristConfidence'] as num?)?.toDouble() ?? 0.0,
    canonicalTransformQuality:
        (m['canonicalTransformQuality'] as num?)?.toDouble() ?? 0.0,
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

// ── Phase 8: apply hand mask to work pixels ───────────────────────────────────

/// Nearest-neighbor resize of [mask] (mw×mh) to (imgW×imgH), then set
/// non-hand pixels to black (0,0,0) so the existing pipeline's skin-mask
/// check (graySkinWork[i] >= 35) naturally excludes them.
Uint8List _applyHandMask(
  Uint8List pixels,
  int imgW,
  int imgH,
  List<bool> mask,
  int mw,
  int mh,
) {
  if (mw == 0 || mh == 0) return pixels;
  final result = Uint8List.fromList(pixels);
  for (int y = 0; y < imgH; y++) {
    final my = ((y * mh) ~/ imgH).clamp(0, mh - 1);
    for (int x = 0; x < imgW; x++) {
      final mx = ((x * mw) ~/ imgW).clamp(0, mw - 1);
      if (!mask[my * mw + mx]) {
        final base = (y * imgW + x) * 4;
        result[base] = 0;
        result[base + 1] = 0;
        result[base + 2] = 0;
        result[base + 3] = 255;
      }
    }
  }
  return result;
}

// ── Anatomy-weighted map constants ────────────────────────────────────────────

const double _anatomyAlpha = 0.45;
const double _anatomyBeta = 0.75;

// ── Core processing (top-level for compute()) ─────────────────────────────────

Map<String, dynamic> _processPixels(_PixelInput input) {
  final stopwatch = Stopwatch()..start();
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
    int creasePixelCount = 0,
    int skeletonLength = 0,
    double averageCreaseProbability = 0.0,
    int largestCreasePixelCount = 0,
    List<List<List<double>>> rejectedPaths = const [],
    List<Map<String, dynamic>> tracedCreases = const [],
    int traceCount = 0,
    double averageTraceLength = 0.0,
    double longestTraceLength = 0.0,
    int recoveredGapCount = 0,
    double averageTraceContinuity = 0.0,
    double averageTraceProbability = 0.0,
    int tracingTimeMs = 0,
    double averageAnatomicalScore = 0.0,
    double lifePriorScore = 0.0,
    double heartPriorScore = 0.0,
    double headPriorScore = 0.0,
    double fatePriorScore = 0.0,
    double trackerConfidenceBeforeAnatomical = 0.0,
    double trackerConfidenceAfterAnatomical = 0.0,
    List<List<double>> debugPalmMask = const [],
    List<List<double>> debugClahe = const [],
    List<List<double>> debugDarkLineResponse = const [],
    List<List<double>> multiScaleRidgeMap = const [],
    List<List<double>> debugMultiScaleRidgeMap = const [],
    List<List<double>> debugRidgeStrengthHeatmap = const [],
    List<List<double>> debugCreaseProbability = const [],
    List<List<double>> debugSkeleton = const [],
    List<List<double>> debugTraceSeeds = const [],
    List<List<double>> debugTraceDirections = const [],
    List<List<double>> debugGapRecoveries = const [],
    List<List<double>> debugMajorLineScores = const [],
    List<List<double>> debugTopLifeLineCandidates = const [],
    List<String> debugTraceRejectionReasons = const [],
    List<List<double>> debugLifePrior = const [],
    List<List<double>> debugHeartPrior = const [],
    List<List<double>> debugHeadPrior = const [],
    List<List<double>> debugFatePrior = const [],
    Map<String, dynamic> anatomyWeighted = const {},
    int outsideMaskProbabilityPixels = 0,
    int outsideMaskSkeletonPixels = 0,
    int rejectedOutsideMaskTraces = 0,
    double minInsidePalmRatioOfAcceptedCandidates = 1.0,
    List<List<List<double>>> rejectedOutsideMaskPaths = const [],
    List<List<double>> debugPalmOutline = const [],
  }) => {
    'edgePoints': <List<double>>[],
    'candidatePaths': <List<List<double>>>[],
    'rejectedPaths': rejectedPaths,
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
    'creasePixelCount': creasePixelCount,
    'skeletonLength': skeletonLength,
    'averageCreaseProbability': averageCreaseProbability,
    'largestCreasePixelCount': largestCreasePixelCount,
    'processingTimeMs': stopwatch.elapsedMilliseconds,
    'tracedCreases': tracedCreases,
    'traceCount': traceCount,
    'averageTraceLength': averageTraceLength,
    'longestTraceLength': longestTraceLength,
    'recoveredGapCount': recoveredGapCount,
    'averageTraceContinuity': averageTraceContinuity,
    'averageTraceProbability': averageTraceProbability,
    'tracingTimeMs': tracingTimeMs,
    'averageAnatomicalScore': averageAnatomicalScore,
    'lifePriorScore': lifePriorScore,
    'heartPriorScore': heartPriorScore,
    'headPriorScore': headPriorScore,
    'fatePriorScore': fatePriorScore,
    'trackerConfidenceBeforeAnatomical': trackerConfidenceBeforeAnatomical,
    'trackerConfidenceAfterAnatomical': trackerConfidenceAfterAnatomical,
    'debugPalmMask': debugPalmMask,
    'debugClahe': debugClahe,
    'debugDarkLineResponse': debugDarkLineResponse,
    'multiScaleRidgeMap': multiScaleRidgeMap,
    'debugMultiScaleRidgeMap': debugMultiScaleRidgeMap,
    'debugRidgeStrengthHeatmap': debugRidgeStrengthHeatmap,
    'debugCreaseProbability': debugCreaseProbability,
    'debugSkeleton': debugSkeleton,
    'debugTraceSeeds': debugTraceSeeds,
    'debugTraceDirections': debugTraceDirections,
    'debugGapRecoveries': debugGapRecoveries,
    'debugMajorLineScores': debugMajorLineScores,
    'debugTopLifeLineCandidates': debugTopLifeLineCandidates,
    'debugTraceRejectionReasons': debugTraceRejectionReasons,
    'debugLifePrior': debugLifePrior,
    'debugHeartPrior': debugHeartPrior,
    'debugHeadPrior': debugHeadPrior,
    'debugFatePrior': debugFatePrior,
    'anatomyWeighted': anatomyWeighted,
    'outsideMaskProbabilityPixels': outsideMaskProbabilityPixels,
    'outsideMaskSkeletonPixels': outsideMaskSkeletonPixels,
    'rejectedOutsideMaskTraces': rejectedOutsideMaskTraces,
    'minInsidePalmRatioOfAcceptedCandidates':
        minInsidePalmRatioOfAcceptedCandidates,
    'rejectedOutsideMaskPaths': rejectedOutsideMaskPaths,
    'debugPalmOutline': debugPalmOutline,
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
  final palmGeometryWork = _detectPalmGeometry(interiorMask, workW, workH);
  final palmGeometry = _mapPalmGeometry(palmGeometryWork, mapPt);

  // 6. Palm-crease probability map.
  // From here on the primary signal is dark-valley probability, not edge
  // magnitude. Sobel is retained only for boundary rejection and diagnostics.
  final claheWork = _localContrastNormalizeMasked(
    workImg,
    workW,
    workH,
    interiorMask,
  );
  final topHat = _multiScaleBlackTopHat(claheWork, workW, workH, const [
    3,
    5,
    7,
    9,
  ]);
  final dog = _differenceOfGaussiansDark(claheWork, workW, workH);
  final multiScaleRidgeMap = _multiScaleHessianRidgeResponse(
    claheWork,
    workW,
    workH,
  );
  final edgeMag = _sobelMagnitude(claheWork, workW, workH);
  final probability = Float32List(workW * workH);

  var maxSobel = 1;
  for (final v in edgeMag) {
    if (v > maxSobel) maxSobel = v;
  }
  final sobelBoundaryThreshold = max(24, (maxSobel * 0.34).round());
  final workMargin = max(10, min(workW, workH) ~/ 18);
  int darkLinePixelCount = 0;
  int sobelPixelCount = 0;

  for (int y = workMargin; y < workH - workMargin; y++) {
    final yw = y * workW;
    for (int x = workMargin; x < workW - workMargin; x++) {
      final idx = yw + x;
      final inPalm = boundarySafeMask[idx];
      final dark = topHat[idx] / 255.0;
      final dogScore = dog[idx] / 255.0;
      final valley = multiScaleRidgeMap[idx] / 255.0;
      final localValley =
          _valleyStrength(claheWork, x, y, workW, workH) / 255.0;
      if (dark > 0.08) darkLinePixelCount++;
      if (inPalm && edgeMag[idx] >= sobelBoundaryThreshold && dark > 0.06) {
        sobelPixelCount++;
      }
      if (!inPalm) {
        probability[idx] = 0.0;
        continue;
      }

      final crease =
          dark * 0.38 + dogScore * 0.24 + valley * 0.28 + localValley * 0.10;
      final texturePenalty =
          edgeMag[idx] > sobelBoundaryThreshold && dark < 0.08 ? 0.42 : 1.0;
      final wristPenalty = _wristBorderPenalty(y / workH, palmGeometryWork);
      probability[idx] = (crease * texturePenalty * wristPenalty).clamp(
        0.0,
        1.0,
      );
    }
  }

  // Hard gate: zero any residual probability outside the palm mask.
  // This is a safety net; the loop above already sets outside pixels to 0.
  var outsideMaskProbabilityPixels = 0;
  for (int i = 0; i < probability.length; i++) {
    if (!boundarySafeMask[i] && probability[i] > 0.0) {
      outsideMaskProbabilityPixels++;
      probability[i] = 0.0;
    }
  }

  final threshold = _adaptiveCreaseThreshold(probability, boundarySafeMask);
  final creaseBinary = List<bool>.filled(workW * workH, false);
  var creasePixelCount = 0;
  var probabilitySum = 0.0;
  for (int i = 0; i < probability.length; i++) {
    if (!boundarySafeMask[i]) continue;
    if (probability[i] >= threshold) {
      creaseBinary[i] = true;
      creasePixelCount++;
      probabilitySum += probability[i];
    }
  }
  final averageCreaseProbability = creasePixelCount == 0
      ? 0.0
      : probabilitySum / creasePixelCount;
  final anatomicalPriors = _buildAnatomicalPriors(
    palmGeometryWork,
    boundarySafeMask,
    workW,
    workH,
  );

  final rejectedBinary = List<bool>.filled(workW * workH, false);
  for (int y = workMargin; y < workH - workMargin; y++) {
    final yw = y * workW;
    for (int x = workMargin; x < workW - workMargin; x++) {
      final idx = yw + x;
      if (boundarySafeMask[idx]) continue;
      final dark = max(topHat[idx], dog[idx]);
      final rawDarkBoundary = graySkinWork[idx] < 45 || workImg[idx] < 45;
      if (rawDarkBoundary ||
          dark >= 14 ||
          edgeMag[idx] >= sobelBoundaryThreshold) {
        rejectedBinary[idx] = true;
      }
    }
  }

  final rejectedComps = _findComponents(
    rejectedBinary,
    workW,
    workH,
    minSize: 18,
    maxComponents: 10,
  );
  var rejectedBoundarySum = 0.0;
  for (final comp in rejectedComps) {
    var unsafeCount = 0;
    for (final idx in comp) {
      if (!boundarySafeMask[idx]) unsafeCount++;
    }
    rejectedBoundarySum += unsafeCount / comp.length;
  }
  final rejectedBoundaryRatio = rejectedComps.isEmpty
      ? 0.0
      : rejectedBoundarySum / rejectedComps.length;

  if (creasePixelCount == 0) {
    final rejectedPaths = <List<List<double>>>[];
    for (final comp in rejectedComps) {
      final path = _buildOrderedPath(comp, workW, workH);
      if (path.length >= 5) {
        rejectedPaths.add(path.map(mapPt).toList());
      }
    }
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
      rejectedBoundaryRatio: rejectedBoundaryRatio,
      palmGeometry: palmGeometry,
      rejectedPaths: rejectedPaths,
      debugPalmMask: _sampleMask(interiorMask, workW, workH, mapPt),
      debugClahe: _sampleByteMap(
        claheWork,
        workW,
        workH,
        mapPt,
        maxSamples: 900,
      ),
      debugDarkLineResponse: _sampleByteMap(
        topHat,
        workW,
        workH,
        mapPt,
        maxSamples: 900,
      ),
      multiScaleRidgeMap: _sampleByteMap(
        multiScaleRidgeMap,
        workW,
        workH,
        mapPt,
        maxSamples: 900,
      ),
      debugMultiScaleRidgeMap: _sampleByteMap(
        multiScaleRidgeMap,
        workW,
        workH,
        mapPt,
        maxSamples: 900,
      ),
      debugRidgeStrengthHeatmap: _sampleByteMap(
        multiScaleRidgeMap,
        workW,
        workH,
        mapPt,
        maxSamples: 1200,
      ),
      debugCreaseProbability: _sampleProbabilityMap(
        probability,
        workW,
        workH,
        mapPt,
      ),
      debugLifePrior: _sampleProbabilityMap(
        anatomicalPriors.life,
        workW,
        workH,
        mapPt,
      ),
      debugHeartPrior: _sampleProbabilityMap(
        anatomicalPriors.heart,
        workW,
        workH,
        mapPt,
      ),
      debugHeadPrior: _sampleProbabilityMap(
        anatomicalPriors.head,
        workW,
        workH,
        mapPt,
      ),
      debugFatePrior: _sampleProbabilityMap(
        anatomicalPriors.fate,
        workW,
        workH,
        mapPt,
      ),
    );
  }

  final creaseComponents = _findComponents(
    creaseBinary,
    workW,
    workH,
    minSize: 18,
    maxComponents: 18,
  );
  final largestCreasePixelCount = creaseComponents.isEmpty
      ? 0
      : creaseComponents.first.length;
  final skeletonBinary = _zhangSuenThin(creaseBinary, workW, workH);

  // Hard gate: explicitly zero skeleton pixels outside palm mask.
  // Zhang-Suen should not create new pixels, but this guarantees it.
  var outsideMaskSkeletonPixels = 0;
  for (int i = 0; i < workW * workH; i++) {
    if (skeletonBinary[i] && !boundarySafeMask[i]) {
      skeletonBinary[i] = false;
      outsideMaskSkeletonPixels++;
    }
  }

  // State for outside-mask rejection (shared by anatomy + base tracing).
  var rejectedOutsideMaskTraces = 0;
  var minInsidePalmRatioOfAcceptedCandidates = 1.0;
  final rejectedOutsideMaskPathsWork = <List<List<double>>>[];

  // Helper: filter a scored-trace list, reject traces with insidePalmRatio < 0.98.
  double palmInsideRatio(List<int> indices) {
    if (indices.isEmpty) return 0.0;
    var inside = 0;
    for (final i in indices) {
      if (boundarySafeMask[i]) inside++;
    }
    return inside / indices.length;
  }

  List<_ScoredTrace> filterByPalmRatio(
    List<_ScoredTrace> traces, {
    bool trackMin = false,
  }) {
    final accepted = <_ScoredTrace>[];
    for (final s in traces) {
      final ratio = palmInsideRatio(s.trace.indices);
      if (ratio < 0.98) {
        rejectedOutsideMaskTraces++;
        final p = _pathFromTrace(s.trace.indices, workW, workH);
        if (p.length >= 5) rejectedOutsideMaskPathsWork.add(p);
      } else {
        if (trackMin && ratio < minInsidePalmRatioOfAcceptedCandidates) {
          minInsidePalmRatioOfAcceptedCandidates = ratio;
        }
        accepted.add(s);
      }
    }
    return accepted;
  }

  // ── Anatomy-weighted probability maps ───────────────────────────────────────
  // weightedProb = baseProbability * (alpha + beta * prior)
  // Safety: base=0 → weighted=0; prior alone cannot create a line.
  final lifeWeightedProb = Float32List(workW * workH);
  final heartWeightedProb = Float32List(workW * workH);
  final headWeightedProb = Float32List(workW * workH);
  final fateWeightedProb = Float32List(workW * workH);
  for (int i = 0; i < workW * workH; i++) {
    final base = probability[i];
    if (base <= 0.0) continue;
    lifeWeightedProb[i] =
        (base * (_anatomyAlpha + _anatomyBeta * anatomicalPriors.life[i]))
            .clamp(0.0, 1.0);
    heartWeightedProb[i] =
        (base * (_anatomyAlpha + _anatomyBeta * anatomicalPriors.heart[i]))
            .clamp(0.0, 1.0);
    headWeightedProb[i] =
        (base * (_anatomyAlpha + _anatomyBeta * anatomicalPriors.head[i]))
            .clamp(0.0, 1.0);
    fateWeightedProb[i] =
        (base * (_anatomyAlpha + _anatomyBeta * anatomicalPriors.fate[i]))
            .clamp(0.0, 1.0);
  }
  final lifeThr = _adaptiveCreaseThreshold(lifeWeightedProb, boundarySafeMask);
  final heartThr = _adaptiveCreaseThreshold(
    heartWeightedProb,
    boundarySafeMask,
  );
  final headThr = _adaptiveCreaseThreshold(headWeightedProb, boundarySafeMask);
  final fateThr = _adaptiveCreaseThreshold(fateWeightedProb, boundarySafeMask);
  var lifeCreasePixels = 0;
  var heartCreasePixels = 0;
  var headCreasePixels = 0;
  var fateCreasePixels = 0;
  final lifeSkeleton = List<bool>.filled(workW * workH, false);
  final heartSkeleton = List<bool>.filled(workW * workH, false);
  final headSkeleton = List<bool>.filled(workW * workH, false);
  final fateSkeleton = List<bool>.filled(workW * workH, false);
  for (int i = 0; i < workW * workH; i++) {
    if (!skeletonBinary[i]) continue;
    if (lifeWeightedProb[i] >= lifeThr) {
      lifeSkeleton[i] = true;
      lifeCreasePixels++;
    }
    if (heartWeightedProb[i] >= heartThr) {
      heartSkeleton[i] = true;
      heartCreasePixels++;
    }
    if (headWeightedProb[i] >= headThr) {
      headSkeleton[i] = true;
      headCreasePixels++;
    }
    if (fateWeightedProb[i] >= fateThr) {
      fateSkeleton[i] = true;
      fateCreasePixels++;
    }
  }
  final lifeTraceResult = _traceCreases(
    probability: lifeWeightedProb,
    skeleton: lifeSkeleton,
    creaseMask: creaseBinary,
    palmMask: boundarySafeMask,
    topHat: topHat,
    valley: multiScaleRidgeMap,
    w: workW,
    h: workH,
    threshold: lifeThr,
  );
  final heartTraceResult = _traceCreases(
    probability: heartWeightedProb,
    skeleton: heartSkeleton,
    creaseMask: creaseBinary,
    palmMask: boundarySafeMask,
    topHat: topHat,
    valley: multiScaleRidgeMap,
    w: workW,
    h: workH,
    threshold: heartThr,
  );
  final headTraceResult = _traceCreases(
    probability: headWeightedProb,
    skeleton: headSkeleton,
    creaseMask: creaseBinary,
    palmMask: boundarySafeMask,
    topHat: topHat,
    valley: multiScaleRidgeMap,
    w: workW,
    h: workH,
    threshold: headThr,
  );
  final fateTraceResult = _traceCreases(
    probability: fateWeightedProb,
    skeleton: fateSkeleton,
    creaseMask: creaseBinary,
    palmMask: boundarySafeMask,
    topHat: topHat,
    valley: multiScaleRidgeMap,
    w: workW,
    h: workH,
    threshold: fateThr,
  );
  List<_ScoredTrace> scoreAndSort(
    _CreaseTraceResult tr, {
    bool lifeMode = false,
  }) =>
      tr.traces.map((trace) {
        final ps = _scoreTraceAnatomy(trace.indices, anatomicalPriors);
        final major = _majorLineScore(
          trace,
          ps,
          workW,
          workH,
          palmGeometryWork,
          lifeMode: lifeMode,
        );
        return _ScoredTrace(
          trace: trace,
          priorScore: ps,
          weightedProbability: _weightedTraceProbability(
            trace.averageProbability,
            ps.average,
          ),
          majorLineScore: major.score,
          rejectionReason: major.rejectionReason,
        );
      }).toList()..sort((a, b) {
        final c = b.majorLineScore.compareTo(a.majorLineScore);
        if (c != 0) return c;
        return b.weightedProbability.compareTo(a.weightedProbability);
      });
  // Filter anatomy traced creases: reject any with insidePalmRatio < 0.98.
  final lifeScoredTraces = filterByPalmRatio(
    scoreAndSort(lifeTraceResult, lifeMode: true),
  );
  final heartScoredTraces = filterByPalmRatio(scoreAndSort(heartTraceResult));
  final headScoredTraces = filterByPalmRatio(scoreAndSort(headTraceResult));
  final fateScoredTraces = filterByPalmRatio(scoreAndSort(fateTraceResult));

  List<List<List<double>>> buildTypePaths(List<_ScoredTrace> scored) {
    final paths = <List<List<double>>>[];
    for (final s in scored) {
      final path = _pathFromTrace(s.trace.indices, workW, workH);
      if (path.length >= 5) paths.add(path);
    }
    return paths;
  }

  final anatomyRaw = <String, dynamic>{
    'lifeCandidates': buildTypePaths(
      lifeScoredTraces,
    ).map((p) => p.map(mapPt).toList()).toList(),
    'heartCandidates': buildTypePaths(
      heartScoredTraces,
    ).map((p) => p.map(mapPt).toList()).toList(),
    'headCandidates': buildTypePaths(
      headScoredTraces,
    ).map((p) => p.map(mapPt).toList()).toList(),
    'fateCandidates': buildTypePaths(
      fateScoredTraces,
    ).map((p) => p.map(mapPt).toList()).toList(),
    'lifeTracedCreases': lifeScoredTraces
        .map(
          (s) => _traceToRaw(
            s,
            workW,
            workH,
            mapPt,
            insidePalmRatio: palmInsideRatio(s.trace.indices),
          ),
        )
        .toList(),
    'heartTracedCreases': heartScoredTraces
        .map(
          (s) => _traceToRaw(
            s,
            workW,
            workH,
            mapPt,
            insidePalmRatio: palmInsideRatio(s.trace.indices),
          ),
        )
        .toList(),
    'headTracedCreases': headScoredTraces
        .map(
          (s) => _traceToRaw(
            s,
            workW,
            workH,
            mapPt,
            insidePalmRatio: palmInsideRatio(s.trace.indices),
          ),
        )
        .toList(),
    'fateTracedCreases': fateScoredTraces
        .map(
          (s) => _traceToRaw(
            s,
            workW,
            workH,
            mapPt,
            insidePalmRatio: palmInsideRatio(s.trace.indices),
          ),
        )
        .toList(),
    'baseCreasePixels': creasePixelCount,
    'lifeCreasePixels': lifeCreasePixels,
    'heartCreasePixels': heartCreasePixels,
    'headCreasePixels': headCreasePixels,
    'fateCreasePixels': fateCreasePixels,
    'lifeSkeletonLength': lifeScoredTraces.fold<int>(
      0,
      (s, t) => s + t.trace.indices.length,
    ),
    'heartSkeletonLength': heartScoredTraces.fold<int>(
      0,
      (s, t) => s + t.trace.indices.length,
    ),
    'headSkeletonLength': headScoredTraces.fold<int>(
      0,
      (s, t) => s + t.trace.indices.length,
    ),
    'fateSkeletonLength': fateScoredTraces.fold<int>(
      0,
      (s, t) => s + t.trace.indices.length,
    ),
    'debugLifeWeightedProb': _sampleProbabilityMap(
      lifeWeightedProb,
      workW,
      workH,
      mapPt,
    ),
    'debugHeartWeightedProb': _sampleProbabilityMap(
      heartWeightedProb,
      workW,
      workH,
      mapPt,
    ),
    'debugHeadWeightedProb': _sampleProbabilityMap(
      headWeightedProb,
      workW,
      workH,
      mapPt,
    ),
    'debugFateWeightedProb': _sampleProbabilityMap(
      fateWeightedProb,
      workW,
      workH,
      mapPt,
    ),
    'debugLifeSkeleton': _sampleMask(lifeSkeleton, workW, workH, mapPt),
    'debugHeartSkeleton': _sampleMask(heartSkeleton, workW, workH, mapPt),
    'debugHeadSkeleton': _sampleMask(headSkeleton, workW, workH, mapPt),
    'debugFateSkeleton': _sampleMask(fateSkeleton, workW, workH, mapPt),
  };

  final traceStopwatch = Stopwatch()..start();
  final traceResult = _traceCreases(
    probability: probability,
    skeleton: skeletonBinary,
    creaseMask: creaseBinary,
    palmMask: boundarySafeMask,
    topHat: topHat,
    valley: multiScaleRidgeMap,
    w: workW,
    h: workH,
    threshold: threshold,
  );
  traceStopwatch.stop();

  double acceptedInteriorSum = 0.0;
  for (final trace in traceResult.traces) {
    var inCount = 0;
    for (final idx in trace.indices) {
      if (interiorMask[idx]) inCount++;
    }
    acceptedInteriorSum += inCount / trace.indices.length;
  }
  final acceptedInteriorRatio = traceResult.traces.isEmpty
      ? 0.0
      : acceptedInteriorSum / traceResult.traces.length;
  final scoredTraces =
      traceResult.traces.map((trace) {
        final priorScore = _scoreTraceAnatomy(trace.indices, anatomicalPriors);
        final major = _majorLineScore(
          trace,
          priorScore,
          workW,
          workH,
          palmGeometryWork,
          lifeMode: false,
        );
        return _ScoredTrace(
          trace: trace,
          priorScore: priorScore,
          weightedProbability: _weightedTraceProbability(
            trace.averageProbability,
            priorScore.average,
          ),
          majorLineScore: major.score,
          rejectionReason: major.rejectionReason,
        );
      }).toList()..sort((a, b) {
        final c = b.majorLineScore.compareTo(a.majorLineScore);
        if (c != 0) return c;
        return b.weightedProbability.compareTo(a.weightedProbability);
      });

  // Hard gate: reject base traced creases with < 98 % pixels inside palm mask.
  final filteredScoredTraces = filterByPalmRatio(scoredTraces, trackMin: true);

  // 7. Build ordered paths from traced creases. These are the final tracker input.
  final candidatePathsWork = <List<List<double>>>[];
  final rejectedPathsWork = <List<List<double>>>[];
  final allPixels = <int>[];
  var skeletonLength = 0;

  for (final scored in filteredScoredTraces) {
    final trace = scored.trace;
    allPixels.addAll(trace.indices);
    skeletonLength += trace.indices.length;
    final path = _pathFromTrace(trace.indices, workW, workH);
    if (path.length >= 5) candidatePathsWork.add(path);
  }
  for (final comp in rejectedComps) {
    final path = _buildOrderedPath(comp, workW, workH);
    if (path.length >= 5) rejectedPathsWork.add(path);
  }

  // Subsample skeleton points for display performance.
  final sampledEdgeWork = <List<double>>[];
  if (allPixels.isNotEmpty) {
    final step = (allPixels.length / 280).ceil().clamp(1, allPixels.length);
    for (int i = 0; i < allPixels.length; i += step) {
      final idx = allPixels[i];
      sampledEdgeWork.add([(idx % workW) / workW, (idx ~/ workW) / workH]);
    }
  }

  // 8. Map from work image [0,1] → original image [0,1]
  // If ROI was used, work image coords were extracted from a cropped + resized
  // region; map back so paths align over the original preview image.
  final candidatePaths = candidatePathsWork
      .map((path) => path.map(mapPt).toList())
      .toList();
  final rejectedPaths = rejectedPathsWork
      .map((path) => path.map(mapPt).toList())
      .toList();
  final sampledEdge = sampledEdgeWork.map(mapPt).toList();
  final tracedCreases = filteredScoredTraces
      .map(
        (scored) => _traceToRaw(
          scored,
          workW,
          workH,
          mapPt,
          insidePalmRatio: palmInsideRatio(scored.trace.indices),
        ),
      )
      .toList();
  final debugMajorLineScores = _scoreDebugSamples(
    filteredScoredTraces,
    workW,
    workH,
    mapPt,
  );
  final debugTopLifeLineCandidates = _scoreDebugSamples(
    lifeScoredTraces.take(5).toList(),
    workW,
    workH,
    mapPt,
  );
  final debugTraceRejectionReasons = <String>[
    for (var i = 0; i < filteredScoredTraces.length; i++)
      'trace_$i:${filteredScoredTraces[i].rejectionReason}',
    for (var i = 0; i < lifeScoredTraces.take(5).length; i++)
      'life_$i:${lifeScoredTraces[i].rejectionReason}',
  ];
  final traceCount = filteredScoredTraces.length;
  var traceLengthSum = 0.0;
  var longestTraceLength = 0.0;
  var continuitySum = 0.0;
  var traceProbabilitySum = 0.0;
  var weightedTraceProbabilitySum = 0.0;
  var anatomicalTraceSum = 0.0;
  var lifePriorTraceSum = 0.0;
  var heartPriorTraceSum = 0.0;
  var headPriorTraceSum = 0.0;
  var fatePriorTraceSum = 0.0;
  var recoveredGapCount = 0;
  for (final scored in filteredScoredTraces) {
    final trace = scored.trace;
    final priorScore = scored.priorScore;
    traceLengthSum += trace.totalLength;
    if (trace.totalLength > longestTraceLength) {
      longestTraceLength = trace.totalLength;
    }
    continuitySum += trace.continuityScore;
    traceProbabilitySum += trace.averageProbability;
    weightedTraceProbabilitySum += scored.weightedProbability;
    anatomicalTraceSum += priorScore.average;
    lifePriorTraceSum += priorScore.life;
    heartPriorTraceSum += priorScore.heart;
    headPriorTraceSum += priorScore.head;
    fatePriorTraceSum += priorScore.fate;
    recoveredGapCount += trace.interruptionCount;
  }
  final averageTraceLength = traceCount == 0
      ? 0.0
      : traceLengthSum / traceCount;
  final averageTraceContinuity = traceCount == 0
      ? 0.0
      : continuitySum / traceCount;
  final averageTraceProbability = traceCount == 0
      ? 0.0
      : traceProbabilitySum / traceCount;
  final averageWeightedTraceProbability = traceCount == 0
      ? 0.0
      : weightedTraceProbabilitySum / traceCount;
  final averageAnatomicalScore = traceCount == 0
      ? 0.0
      : anatomicalTraceSum / traceCount;
  final lifePriorScore = traceCount == 0 ? 0.0 : lifePriorTraceSum / traceCount;
  final heartPriorScore = traceCount == 0
      ? 0.0
      : heartPriorTraceSum / traceCount;
  final headPriorScore = traceCount == 0 ? 0.0 : headPriorTraceSum / traceCount;
  final fatePriorScore = traceCount == 0 ? 0.0 : fatePriorTraceSum / traceCount;

  // 9. Confidence is crease-probability based, then anatomically weighted.
  final pathScore = (candidatePaths.length / 7.0).clamp(0.0, 1.0);
  final darkLineScore = (creasePixelCount / (workW * workH * 0.012)).clamp(
    0.0,
    1.0,
  );
  final interiorScore = acceptedInteriorRatio.clamp(0.0, 1.0);
  final trackerConfidenceBeforeAnatomical =
      (pathScore * 0.32 +
              darkLineScore * 0.28 +
              averageCreaseProbability * 0.24 +
              interiorScore * 0.16)
          .clamp(0.0, 1.0);
  final trackerConfidenceAfterAnatomical =
      (trackerConfidenceBeforeAnatomical * 0.62 +
              averageWeightedTraceProbability * 0.24 +
              averageAnatomicalScore * 0.14)
          .clamp(0.0, 1.0);
  final confidence = trackerConfidenceAfterAnatomical;

  return {
    'edgePoints': sampledEdge,
    'candidatePaths': candidatePaths,
    'rejectedPaths': rejectedPaths,
    'confidence': confidence,
    'imageWidth': w,
    'imageHeight': h,
    'edgePointCount': creasePixelCount,
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
    'creasePixelCount': creasePixelCount,
    'skeletonLength': skeletonLength,
    'averageCreaseProbability': averageCreaseProbability,
    'largestCreasePixelCount': largestCreasePixelCount,
    'processingTimeMs': stopwatch.elapsedMilliseconds,
    'tracedCreases': tracedCreases,
    'traceCount': traceCount,
    'averageTraceLength': averageTraceLength,
    'longestTraceLength': longestTraceLength,
    'recoveredGapCount': recoveredGapCount,
    'averageTraceContinuity': averageTraceContinuity,
    'averageTraceProbability': averageTraceProbability,
    'tracingTimeMs': traceStopwatch.elapsedMilliseconds,
    'averageAnatomicalScore': averageAnatomicalScore,
    'lifePriorScore': lifePriorScore,
    'heartPriorScore': heartPriorScore,
    'headPriorScore': headPriorScore,
    'fatePriorScore': fatePriorScore,
    'trackerConfidenceBeforeAnatomical': trackerConfidenceBeforeAnatomical,
    'trackerConfidenceAfterAnatomical': trackerConfidenceAfterAnatomical,
    'debugPalmMask': _sampleMask(boundarySafeMask, workW, workH, mapPt),
    'debugClahe': _sampleByteMap(
      claheWork,
      workW,
      workH,
      mapPt,
      maxSamples: 900,
    ),
    'debugDarkLineResponse': _sampleByteMap(
      topHat,
      workW,
      workH,
      mapPt,
      maxSamples: 900,
    ),
    'multiScaleRidgeMap': _sampleByteMap(
      multiScaleRidgeMap,
      workW,
      workH,
      mapPt,
      maxSamples: 900,
    ),
    'debugMultiScaleRidgeMap': _sampleByteMap(
      multiScaleRidgeMap,
      workW,
      workH,
      mapPt,
      maxSamples: 900,
    ),
    'debugRidgeStrengthHeatmap': _sampleByteMap(
      multiScaleRidgeMap,
      workW,
      workH,
      mapPt,
      maxSamples: 1200,
    ),
    'debugCreaseProbability': _sampleProbabilityMap(
      probability,
      workW,
      workH,
      mapPt,
    ),
    'debugSkeleton': _sampleMask(skeletonBinary, workW, workH, mapPt),
    'debugTraceSeeds': _mapTraceSeeds(
      traceResult.seedSamples,
      workW,
      workH,
      mapPt,
    ),
    'debugTraceDirections': _mapTraceVectors(
      traceResult.directionVectors,
      workW,
      workH,
      mapPt,
    ),
    'debugGapRecoveries': _mapTraceVectors(
      traceResult.gapRecoveries,
      workW,
      workH,
      mapPt,
    ),
    'debugMajorLineScores': debugMajorLineScores,
    'debugTopLifeLineCandidates': debugTopLifeLineCandidates,
    'debugTraceRejectionReasons': debugTraceRejectionReasons,
    'debugLifePrior': _sampleProbabilityMap(
      anatomicalPriors.life,
      workW,
      workH,
      mapPt,
    ),
    'debugHeartPrior': _sampleProbabilityMap(
      anatomicalPriors.heart,
      workW,
      workH,
      mapPt,
    ),
    'debugHeadPrior': _sampleProbabilityMap(
      anatomicalPriors.head,
      workW,
      workH,
      mapPt,
    ),
    'debugFatePrior': _sampleProbabilityMap(
      anatomicalPriors.fate,
      workW,
      workH,
      mapPt,
    ),
    'anatomyWeighted': anatomyRaw,
    'outsideMaskProbabilityPixels': outsideMaskProbabilityPixels,
    'outsideMaskSkeletonPixels': outsideMaskSkeletonPixels,
    'rejectedOutsideMaskTraces': rejectedOutsideMaskTraces,
    'minInsidePalmRatioOfAcceptedCandidates':
        minInsidePalmRatioOfAcceptedCandidates,
    'rejectedOutsideMaskPaths': rejectedOutsideMaskPathsWork
        .map((path) => path.map(mapPt).toList())
        .toList(),
    'debugPalmOutline': _samplePalmOutline(
      boundarySafeMask,
      workW,
      workH,
      mapPt,
    ),
  };
}

// ── Crease probability pipeline ──────────────────────────────────────────────

Uint8List _localContrastNormalizeMasked(
  Uint8List src,
  int w,
  int h,
  List<bool> mask,
) {
  const tiles = 8;
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
          final idx = yw + x;
          if (!mask[idx]) continue;
          hist[src[idx]]++;
          count++;
        }
      }
      if (count < 24) {
        mins[ti] = 24;
        maxs[ti] = 232;
        continue;
      }
      final lowTarget = (count * 0.03).round();
      final highTarget = (count * 0.97).round();
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
      final idx = y * w + x;
      if (!mask[idx]) {
        dst[idx] = src[idx];
        continue;
      }
      final fx = ((x + 0.5) / tileW - 0.5).clamp(0.0, tiles - 1.0);
      final tx0 = fx.floor();
      final tx1 = min(tiles - 1, tx0 + 1);
      final wx = fx - tx0;

      int stretch(int tx, int ty) {
        final ti = ty * tiles + tx;
        final lo = mins[ti];
        final hi = maxs[ti];
        final range = max(18, hi - lo);
        return ((src[idx] - lo) * 255 ~/ range).clamp(0, 255);
      }

      final top = stretch(tx0, ty0) * (1.0 - wx) + stretch(tx1, ty0) * wx;
      final bottom = stretch(tx0, ty1) * (1.0 - wx) + stretch(tx1, ty1) * wx;
      final local = (top * (1.0 - wy) + bottom * wy).round();
      dst[idx] = ((src[idx] * 0.25) + local * 0.75).round().clamp(0, 255);
    }
  }
  return dst;
}

Uint8List _multiScaleBlackTopHat(Uint8List src, int w, int h, List<int> radii) {
  final best = Uint8List(w * h);
  for (final r in radii) {
    final closed = _grayscaleErodeBox(
      _grayscaleDilateBox(src, w, h, r),
      w,
      h,
      r,
    );
    for (int i = 0; i < src.length; i++) {
      final response = closed[i] - src[i];
      if (response > best[i]) best[i] = response.clamp(0, 255);
    }
  }
  return best;
}

Uint8List _differenceOfGaussiansDark(Uint8List src, int w, int h) {
  final best = Uint8List(w * h);
  for (final pair in const [
    [1, 4],
    [2, 7],
  ]) {
    final small = _boxBlur(src, w, h, pair[0]);
    final large = _boxBlur(src, w, h, pair[1]);
    for (int i = 0; i < src.length; i++) {
      final response = large[i] - small[i];
      if (response > best[i]) best[i] = (response * 2).clamp(0, 255);
    }
  }
  return best;
}

Uint8List _multiScaleHessianRidgeResponse(Uint8List src, int w, int h) {
  final best = Float32List(w * h);
  var bestValue = 0.0;
  for (final sigma in const [1.0, 2.0, 3.0, 4.0]) {
    final smooth = _boxBlur(src, w, h, sigma.round());
    final sigma2 = sigma * sigma;
    for (int y = 2; y < h - 2; y++) {
      final yw = y * w;
      for (int x = 2; x < w - 2; x++) {
        final idx = yw + x;
        final c = smooth[idx] * 2.0;
        final hxx = smooth[idx - 1] + smooth[idx + 1] - c;
        final hyy = smooth[idx - w] + smooth[idx + w] - c;
        final hxy =
            (smooth[(y + 1) * w + x + 1] -
                smooth[(y + 1) * w + x - 1] -
                smooth[(y - 1) * w + x + 1] +
                smooth[(y - 1) * w + x - 1]) *
            0.25;
        final trace = hxx + hyy;
        final disc = sqrt((hxx - hyy) * (hxx - hyy) + 4.0 * hxy * hxy);
        final lambdaMax = (trace + disc) * 0.5;
        final lambdaMin = (trace - disc) * 0.5;
        final darkRidge = lambdaMax > 0
            ? (lambdaMax - max(0.0, lambdaMin) * 0.45)
            : 0.0;
        final response = darkRidge * sigma2;
        if (response > best[idx]) {
          best[idx] = response;
          if (response > bestValue) bestValue = response;
        }
      }
    }
  }
  final dst = Uint8List(w * h);
  if (bestValue <= 0) return dst;
  final scale = 255.0 / bestValue;
  for (int i = 0; i < dst.length; i++) {
    dst[i] = (best[i] * scale).round().clamp(0, 255);
  }
  return dst;
}

Int32List _sobelMagnitude(Uint8List src, int w, int h) {
  final mag = Int32List(w * h);
  for (int y = 1; y < h - 1; y++) {
    final yw = y * w;
    for (int x = 1; x < w - 1; x++) {
      final gx =
          -src[(y - 1) * w + x - 1] -
          2 * src[yw + x - 1] -
          src[(y + 1) * w + x - 1] +
          src[(y - 1) * w + x + 1] +
          2 * src[yw + x + 1] +
          src[(y + 1) * w + x + 1];
      final gy =
          -src[(y - 1) * w + x - 1] -
          2 * src[(y - 1) * w + x] -
          src[(y - 1) * w + x + 1] +
          src[(y + 1) * w + x - 1] +
          2 * src[(y + 1) * w + x] +
          src[(y + 1) * w + x + 1];
      mag[yw + x] = gx.abs() + gy.abs();
    }
  }
  return mag;
}

double _adaptiveCreaseThreshold(Float32List probability, List<bool> mask) {
  var count = 0;
  var sum = 0.0;
  var sumSq = 0.0;
  for (int i = 0; i < probability.length; i++) {
    if (!mask[i]) continue;
    final p = probability[i];
    if (p <= 0) continue;
    count++;
    sum += p;
    sumSq += p * p;
  }
  if (count == 0) return 1.0;
  final mean = sum / count;
  final variance = max(0.0, sumSq / count - mean * mean);
  final std = sqrt(variance);
  return max(0.26, mean + std * 0.82).clamp(0.22, 0.62);
}

double _wristBorderPenalty(double y, Map<String, dynamic>? geometry) {
  if (geometry == null) return 1.0;
  final wristY = (geometry['wristY'] as num).toDouble();
  final start = (wristY - 0.055).clamp(0.0, 1.0);
  if (y <= start) return 1.0;
  if (y >= wristY) return 0.20;
  return (1.0 - ((y - start) / max(0.001, wristY - start)) * 0.80).clamp(
    0.20,
    1.0,
  );
}

Uint8List _boxBlur(Uint8List src, int w, int h, int r) {
  if (r <= 0) return Uint8List.fromList(src);
  final tmp = Uint8List(w * h);
  final dst = Uint8List(w * h);
  for (int y = 0; y < h; y++) {
    final pref = Int32List(w + 1);
    for (int x = 0; x < w; x++) {
      pref[x + 1] = pref[x] + src[y * w + x];
    }
    for (int x = 0; x < w; x++) {
      final l = max(0, x - r);
      final rr = min(w - 1, x + r);
      tmp[y * w + x] = (pref[rr + 1] - pref[l]) ~/ (rr - l + 1);
    }
  }
  for (int x = 0; x < w; x++) {
    final pref = Int32List(h + 1);
    for (int y = 0; y < h; y++) {
      pref[y + 1] = pref[y] + tmp[y * w + x];
    }
    for (int y = 0; y < h; y++) {
      final t = max(0, y - r);
      final b = min(h - 1, y + r);
      dst[y * w + x] = (pref[b + 1] - pref[t]) ~/ (b - t + 1);
    }
  }
  return dst;
}

Uint8List _grayscaleDilateBox(Uint8List src, int w, int h, int r) {
  final tmp = Uint8List(w * h);
  final dst = Uint8List(w * h);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      var best = 0;
      for (int xx = max(0, x - r); xx <= min(w - 1, x + r); xx++) {
        final v = src[y * w + xx];
        if (v > best) best = v;
      }
      tmp[y * w + x] = best;
    }
  }
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      var best = 0;
      for (int yy = max(0, y - r); yy <= min(h - 1, y + r); yy++) {
        final v = tmp[yy * w + x];
        if (v > best) best = v;
      }
      dst[y * w + x] = best;
    }
  }
  return dst;
}

Uint8List _grayscaleErodeBox(Uint8List src, int w, int h, int r) {
  final tmp = Uint8List(w * h);
  final dst = Uint8List(w * h);
  for (int y = 0; y < h; y++) {
    for (int x = 0; x < w; x++) {
      var best = 255;
      for (int xx = max(0, x - r); xx <= min(w - 1, x + r); xx++) {
        final v = src[y * w + xx];
        if (v < best) best = v;
      }
      tmp[y * w + x] = best;
    }
  }
  for (int x = 0; x < w; x++) {
    for (int y = 0; y < h; y++) {
      var best = 255;
      for (int yy = max(0, y - r); yy <= min(h - 1, y + r); yy++) {
        final v = tmp[yy * w + x];
        if (v < best) best = v;
      }
      dst[y * w + x] = best;
    }
  }
  return dst;
}

List<bool> _zhangSuenThin(List<bool> binary, int w, int h) {
  final img = List<bool>.from(binary);
  final marker = List<bool>.filled(w * h, false);
  var changed = true;
  var iterations = 0;
  while (changed && iterations < 48) {
    changed = false;
    iterations++;
    for (final step in const [0, 1]) {
      marker.fillRange(0, marker.length, false);
      for (int y = 1; y < h - 1; y++) {
        for (int x = 1; x < w - 1; x++) {
          final idx = y * w + x;
          if (!img[idx]) continue;
          final p2 = img[(y - 1) * w + x];
          final p3 = img[(y - 1) * w + x + 1];
          final p4 = img[y * w + x + 1];
          final p5 = img[(y + 1) * w + x + 1];
          final p6 = img[(y + 1) * w + x];
          final p7 = img[(y + 1) * w + x - 1];
          final p8 = img[y * w + x - 1];
          final p9 = img[(y - 1) * w + x - 1];
          final n = [p2, p3, p4, p5, p6, p7, p8, p9].where((v) => v).length;
          if (n < 2 || n > 6) continue;
          final transitions = _transitionCount([
            p2,
            p3,
            p4,
            p5,
            p6,
            p7,
            p8,
            p9,
            p2,
          ]);
          if (transitions != 1) continue;
          final pass = step == 0
              ? (!p2 || !p4 || !p6) && (!p4 || !p6 || !p8)
              : (!p2 || !p4 || !p8) && (!p2 || !p6 || !p8);
          if (pass) marker[idx] = true;
        }
      }
      for (int i = 0; i < img.length; i++) {
        if (marker[i]) {
          img[i] = false;
          changed = true;
        }
      }
    }
  }
  return img;
}

int _transitionCount(List<bool> p) {
  var transitions = 0;
  for (int i = 0; i < p.length - 1; i++) {
    if (!p[i] && p[i + 1]) transitions++;
  }
  return transitions;
}

// Returns the inner boundary pixels of [mask]: pixels inside mask that touch
// at least one out-of-mask 4-neighbor. Used for the palm outline debug layer.
List<List<double>> _samplePalmOutline(
  List<bool> mask,
  int w,
  int h,
  List<double> Function(List<double>) mapPt,
) {
  final samples = <List<double>>[];
  for (int i = 0; i < mask.length; i++) {
    if (!mask[i]) continue;
    final x = i % w;
    final y = i ~/ w;
    final isEdge =
        (x > 0 && !mask[i - 1]) ||
        (x < w - 1 && !mask[i + 1]) ||
        (y > 0 && !mask[i - w]) ||
        (y < h - 1 && !mask[i + w]);
    if (!isEdge) continue;
    final p = mapPt([x / w, y / h]);
    samples.add([p[0], p[1], 1.0]);
  }
  return samples;
}

List<List<double>> _sampleMask(
  List<bool> mask,
  int w,
  int h,
  List<double> Function(List<double>) mapPt, {
  int maxSamples = 1200,
}) {
  final active = <int>[];
  for (int i = 0; i < mask.length; i++) {
    if (mask[i]) active.add(i);
  }
  if (active.isEmpty) return const [];
  final step = (active.length / maxSamples).ceil().clamp(1, active.length);
  final samples = <List<double>>[];
  for (int i = 0; i < active.length; i += step) {
    final idx = active[i];
    final p = mapPt([(idx % w) / w, (idx ~/ w) / h]);
    samples.add([p[0], p[1], 1.0]);
  }
  return samples;
}

List<List<double>> _sampleByteMap(
  Uint8List map,
  int w,
  int h,
  List<double> Function(List<double>) mapPt, {
  int maxSamples = 1000,
}) {
  final step = max(1, sqrt(map.length / maxSamples).ceil());
  final samples = <List<double>>[];
  for (int y = 0; y < h; y += step) {
    for (int x = 0; x < w; x += step) {
      final v = map[y * w + x] / 255.0;
      if (v <= 0.02) continue;
      final p = mapPt([x / w, y / h]);
      samples.add([p[0], p[1], v]);
    }
  }
  return samples;
}

List<List<double>> _sampleProbabilityMap(
  Float32List map,
  int w,
  int h,
  List<double> Function(List<double>) mapPt, {
  int maxSamples = 1200,
}) {
  final step = max(1, sqrt(map.length / maxSamples).ceil());
  final samples = <List<double>>[];
  for (int y = 0; y < h; y += step) {
    for (int x = 0; x < w; x += step) {
      final v = map[y * w + x];
      if (v <= 0.03) continue;
      final p = mapPt([x / w, y / h]);
      samples.add([p[0], p[1], v.clamp(0.0, 1.0)]);
    }
  }
  return samples;
}

// ── Anatomical prior fields ──────────────────────────────────────────────────

class _AnatomicalPriorMaps {
  const _AnatomicalPriorMaps({
    required this.life,
    required this.heart,
    required this.head,
    required this.fate,
  });

  final Float32List life;
  final Float32List heart;
  final Float32List head;
  final Float32List fate;
}

class _TraceAnatomyScore {
  const _TraceAnatomyScore({
    required this.average,
    required this.life,
    required this.heart,
    required this.head,
    required this.fate,
  });

  final double average;
  final double life;
  final double heart;
  final double head;
  final double fate;
}

class _ScoredTrace {
  const _ScoredTrace({
    required this.trace,
    required this.priorScore,
    required this.weightedProbability,
    required this.majorLineScore,
    required this.rejectionReason,
  });

  final _CreaseTrace trace;
  final _TraceAnatomyScore priorScore;
  final double weightedProbability;
  final double majorLineScore;
  final String rejectionReason;
}

class _MajorLineRank {
  const _MajorLineRank({required this.score, required this.rejectionReason});

  final double score;
  final String rejectionReason;
}

class _TraceEnds {
  const _TraceEnds(this.start, this.end);

  final Offset start;
  final Offset end;
}

_MajorLineRank _majorLineScore(
  _CreaseTrace trace,
  _TraceAnatomyScore prior,
  int w,
  int h,
  Map<String, dynamic>? geometry, {
  required bool lifeMode,
}) {
  final length = _ramp(trace.totalLength, 0.055, 0.52);
  final continuity = trace.continuityScore.clamp(0.0, 1.0);
  final ridgeStrength =
      (trace.averageRidgeResponse * 0.62 + trace.maximumRidgeResponse * 0.38)
          .clamp(0.0, 1.0);
  final anatomy = (lifeMode ? prior.life : prior.average).clamp(0.0, 1.0);
  final darkness = trace.averageDarkness.clamp(0.0, 1.0);
  final curvatureStability = (1.0 - trace.averageCurvature / 0.92).clamp(
    0.0,
    1.0,
  );
  final confidence = trace.averageProbability.clamp(0.0, 1.0);
  final widthScore = (1.0 - (trace.ridgeWidthEstimate - 4.2).abs() / 7.0).clamp(
    0.0,
    1.0,
  );
  final lifePreference = lifeMode
      ? _lifeLinePreference(trace.indices, trace, geometry, w, h)
      : 0.0;

  final base =
      length * 0.24 +
      continuity * 0.15 +
      ridgeStrength * 0.14 +
      anatomy * 0.13 +
      darkness * 0.08 +
      curvatureStability * 0.08 +
      confidence * 0.10 +
      widthScore * 0.04 +
      lifePreference * (lifeMode ? 0.14 : 0.0);

  final shortPenalty = trace.totalLength < 0.12
      ? _ramp(0.12 - trace.totalLength, 0.0, 0.12) * 0.42
      : 0.0;
  final fragmentPenalty = min(
    0.38,
    trace.interruptionCount * 0.045 + (1.0 - continuity) * 0.22,
  );
  final borderPenalty = _borderProximityPenalty(trace.indices, w, h);
  final anatomyPenalty = anatomy < 0.18 ? (0.18 - anatomy) / 0.18 * 0.30 : 0.0;
  final thumbWrinklePenalty = _thumbMoundWrinklePenalty(
    trace.indices,
    geometry,
    w,
    h,
  );
  final branchPenalty = min(0.16, trace.branchCount * 0.018);

  final penalty =
      (shortPenalty +
              fragmentPenalty +
              borderPenalty +
              anatomyPenalty +
              thumbWrinklePenalty +
              branchPenalty)
          .clamp(0.0, 0.82);
  final score = (base * (1.0 - penalty)).clamp(0.0, 1.0);
  return _MajorLineRank(
    score: score,
    rejectionReason: _majorLineRejectionReason(
      score,
      shortPenalty: shortPenalty,
      fragmentPenalty: fragmentPenalty,
      borderPenalty: borderPenalty,
      anatomyPenalty: anatomyPenalty,
      thumbWrinklePenalty: thumbWrinklePenalty,
      branchPenalty: branchPenalty,
    ),
  );
}

double _lifeLinePreference(
  List<int> indices,
  _CreaseTrace trace,
  Map<String, dynamic>? geometry,
  int w,
  int h,
) {
  if (indices.length < 2) return 0.0;
  final points = indices
      .map((idx) => _thumbCanonicalForIndex(idx, geometry, w, h))
      .toList();
  final ends = _orientTraceEnds(
    points,
    const Offset(0.39, 0.08),
    const Offset(0.42, 0.94),
  );
  final start = ends.start;
  final end = ends.end;
  final webStart = _gaussian((start - const Offset(0.39, 0.08)).distance, 0.22);
  final wristEnd =
      _softBandDouble(end.dy, 0.58, 1.04) * _softBandDouble(end.dx, 0.04, 0.70);
  var wrap = 0.0;
  for (final p in points) {
    wrap += _gaussian((p.dx - _lifeExpectedXForY(p.dy)).abs(), 0.16);
  }
  wrap = (wrap / points.length).clamp(0.0, 1.0);
  final ySpan = _indexSpanY(indices, w, h);
  return (webStart * 0.22 +
          wristEnd * 0.18 +
          wrap * 0.24 +
          _ramp(ySpan, 0.30, 0.82) * 0.14 +
          trace.continuityScore * 0.12 +
          trace.averageRidgeResponse * 0.10)
      .clamp(0.0, 1.0);
}

Offset _thumbCanonicalForIndex(
  int idx,
  Map<String, dynamic>? geometry,
  int w,
  int h,
) {
  final imageX = ((idx % w) + 0.5) / w;
  final imageY = ((idx ~/ w) + 0.5) / h;
  if (geometry == null) return Offset(imageX, imageY);
  final bounds = geometry['palmBounds'] as List;
  final left = (bounds[0] as num).toDouble();
  final right = (bounds[2] as num).toDouble();
  final fingerBaseY = (geometry['fingerBaseY'] as num).toDouble();
  final wristY = (geometry['wristY'] as num).toDouble();
  final width = max(0.001, right - left);
  final height = max(0.001, wristY - fingerBaseY);
  final rawX = ((imageX - left) / width).clamp(0.0, 1.0);
  final thumbSide = geometry['thumbSide'] as String? ?? 'unknown';
  final palmX = thumbSide == 'right' ? 1.0 - rawX : rawX;
  final palmY = ((imageY - fingerBaseY) / height).clamp(0.0, 1.0);
  return Offset(palmX, palmY);
}

_TraceEnds _orientTraceEnds(List<Offset> points, Offset start, Offset end) {
  final first = points.first;
  final last = points.last;
  final forward = (first - start).distance + (last - end).distance;
  final backward = (last - start).distance + (first - end).distance;
  return forward <= backward
      ? _TraceEnds(first, last)
      : _TraceEnds(last, first);
}

double _lifeExpectedXForY(double y) =>
    0.43 - 0.28 * sin((y * pi).clamp(0.0, pi)) + 0.07 * y + 0.03 * y * y;

double _borderProximityPenalty(List<int> indices, int w, int h) {
  if (indices.isEmpty) return 0.0;
  var near = 0;
  final mx = max(3, (w * 0.045).round());
  final my = max(3, (h * 0.045).round());
  for (final idx in indices) {
    final x = idx % w;
    final y = idx ~/ w;
    if (x <= mx || x >= w - 1 - mx || y <= my || y >= h - 1 - my) near++;
  }
  return (near / indices.length * 0.42).clamp(0.0, 0.42);
}

double _thumbMoundWrinklePenalty(
  List<int> indices,
  Map<String, dynamic>? geometry,
  int w,
  int h,
) {
  if (indices.length < 2) return 0.0;
  final xSpan = _indexSpanX(indices, w);
  final ySpan = _indexSpanY(indices, w, h);
  final points = indices
      .map((idx) => _thumbCanonicalForIndex(idx, geometry, w, h))
      .toList();
  final mean = _meanOffset(points);
  final horizontal = xSpan > ySpan * 1.55;
  final onThumbMound = mean.dx < 0.45 && mean.dy > 0.20 && mean.dy < 0.66;
  if (!horizontal || !onThumbMound) return 0.0;
  return (0.20 + _ramp(xSpan - ySpan, 0.04, 0.28) * 0.28).clamp(0.0, 0.48);
}

String _majorLineRejectionReason(
  double score, {
  required double shortPenalty,
  required double fragmentPenalty,
  required double borderPenalty,
  required double anatomyPenalty,
  required double thumbWrinklePenalty,
  required double branchPenalty,
}) {
  if (score >= 0.25) return 'accepted';
  final penalties = <String, double>{
    'short': shortPenalty,
    'fragmented': fragmentPenalty,
    'near_palm_border': borderPenalty,
    'outside_expected_region': anatomyPenalty,
    'thumb_mound_wrinkle': thumbWrinklePenalty,
    'branched_or_noisy': branchPenalty,
  };
  return penalties.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
}

double _indexSpanX(List<int> indices, int w) {
  var minX = w;
  var maxX = 0;
  for (final idx in indices) {
    final x = idx % w;
    minX = min(minX, x);
    maxX = max(maxX, x);
  }
  return ((maxX - minX) / max(1, w)).clamp(0.0, 1.0);
}

double _indexSpanY(List<int> indices, int w, int h) {
  var minY = h;
  var maxY = 0;
  for (final idx in indices) {
    final y = idx ~/ w;
    minY = min(minY, y);
    maxY = max(maxY, y);
  }
  return ((maxY - minY) / max(1, h)).clamp(0.0, 1.0);
}

Offset _meanOffset(List<Offset> points) {
  if (points.isEmpty) return Offset.zero;
  var x = 0.0;
  var y = 0.0;
  for (final p in points) {
    x += p.dx;
    y += p.dy;
  }
  return Offset(x / points.length, y / points.length);
}

_AnatomicalPriorMaps _buildAnatomicalPriors(
  Map<String, dynamic>? geometry,
  List<bool> palmMask,
  int w,
  int h,
) {
  final life = Float32List(w * h);
  final heart = Float32List(w * h);
  final head = Float32List(w * h);
  final fate = Float32List(w * h);
  if (geometry == null) {
    for (int i = 0; i < palmMask.length; i++) {
      if (!palmMask[i]) continue;
      life[i] = 0.45;
      heart[i] = 0.45;
      head[i] = 0.45;
      fate[i] = 0.35;
    }
    return _AnatomicalPriorMaps(
      life: life,
      heart: heart,
      head: head,
      fate: fate,
    );
  }

  final bounds = geometry['palmBounds'] as List;
  final left = (bounds[0] as num).toDouble();
  final right = (bounds[2] as num).toDouble();
  final fingerBaseY = (geometry['fingerBaseY'] as num).toDouble();
  final wristY = (geometry['wristY'] as num).toDouble();
  final width = max(0.001, right - left);
  final height = max(0.001, wristY - fingerBaseY);
  final thumbSide = geometry['thumbSide'] as String? ?? 'unknown';
  final mirrorForRightThumb = thumbSide == 'right';

  for (int y = 0; y < h; y++) {
    final imageY = (y + 0.5) / h;
    for (int x = 0; x < w; x++) {
      final idx = y * w + x;
      if (!palmMask[idx]) continue;
      final imageX = (x + 0.5) / w;
      final rawX = ((imageX - left) / width).clamp(0.0, 1.0);
      final palmX = mirrorForRightThumb ? 1.0 - rawX : rawX;
      final palmY = ((imageY - fingerBaseY) / height).clamp(0.0, 1.0);
      final canonical = Offset(palmX, palmY);

      final lifeScore = _lifePrior(canonical);
      final heartScore = _heartPrior(canonical);
      final headScore = _headPrior(canonical);
      final fateScore = _fatePrior(canonical);

      life[idx] = lifeScore;
      heart[idx] = heartScore;
      head[idx] = headScore;
      fate[idx] = fateScore;
    }
  }

  return _AnatomicalPriorMaps(life: life, heart: heart, head: head, fate: fate);
}

double _lifePrior(Offset p) {
  final y = p.dy;
  final expectedX =
      0.43 - 0.28 * sin((y * pi).clamp(0.0, pi)) + 0.07 * y + 0.03 * y * y;
  final distance = (p.dx - expectedX).abs();
  final curveBand = _gaussian(distance, 0.13);
  final thumbSideBand = _softBandDouble(p.dx, 0.04, 0.62);
  final verticalCenterPenalty =
      1.0 - _gaussian((p.dx - 0.50).abs(), 0.055) * 0.55;
  final yBand = _softBandDouble(y, 0.04, 1.00);
  final webBonus =
      _gaussian((p.dx - 0.42).abs(), 0.18) * _gaussian((y - 0.08).abs(), 0.16);
  return (curveBand * 0.58 +
              thumbSideBand * 0.18 +
              yBand * 0.10 +
              webBonus * 0.14)
          .clamp(0.0, 1.0) *
      verticalCenterPenalty.clamp(0.20, 1.0);
}

double _heartPrior(Offset p) {
  final expectedY = 0.23 + 0.035 * cos((p.dx - 0.5) * pi);
  final distance = (p.dy - expectedY).abs();
  final upperBand = _gaussian(distance, 0.105);
  final acrossPalm = _softBandDouble(p.dx, 0.08, 0.96);
  final belowFingerBase = _softBandDouble(p.dy, 0.07, 0.43);
  final centerCrossing = _gaussian((p.dx - 0.50).abs(), 0.46);
  return (upperBand * 0.58 +
          acrossPalm * 0.17 +
          belowFingerBase * 0.15 +
          centerCrossing * 0.10)
      .clamp(0.0, 1.0);
}

double _headPrior(Offset p) {
  final expectedY = 0.39 + p.dx * 0.16;
  final distance = (p.dy - expectedY).abs();
  final midBand = _gaussian(distance, 0.115);
  final startsNearLife = p.dx < 0.42
      ? _gaussian((p.dy - (0.35 + p.dx * 0.25)).abs(), 0.14)
      : 0.55;
  final acrossPalm = _softBandDouble(p.dx, 0.10, 0.98);
  final belowHeart = _softBandDouble(p.dy, 0.30, 0.70);
  return (midBand * 0.56 +
          startsNearLife * 0.13 +
          acrossPalm * 0.16 +
          belowHeart * 0.15)
      .clamp(0.0, 1.0);
}

double _fatePrior(Offset p) {
  final central = _gaussian((p.dx - 0.50).abs(), 0.13);
  final vertical = _softBandDouble(p.dy, 0.18, 0.92);
  final canStopBeforeFingers = p.dy < 0.20
      ? _softBandDouble(p.dy, 0.14, 0.20)
      : 1.0;
  return (central * 0.68 + vertical * 0.24 + canStopBeforeFingers * 0.08).clamp(
    0.0,
    1.0,
  );
}

_TraceAnatomyScore _scoreTraceAnatomy(
  List<int> indices,
  _AnatomicalPriorMaps priors,
) {
  if (indices.isEmpty) {
    return const _TraceAnatomyScore(
      average: 0.0,
      life: 0.0,
      heart: 0.0,
      head: 0.0,
      fate: 0.0,
    );
  }
  var life = 0.0;
  var heart = 0.0;
  var head = 0.0;
  var fate = 0.0;
  var best = 0.0;
  for (final idx in indices) {
    final l = priors.life[idx];
    final h = priors.heart[idx];
    final he = priors.head[idx];
    final f = priors.fate[idx];
    life += l;
    heart += h;
    head += he;
    fate += f;
    best += max(max(l, h), max(he, f));
  }
  final n = indices.length.toDouble();
  return _TraceAnatomyScore(
    average: (best / n).clamp(0.0, 1.0),
    life: (life / n).clamp(0.0, 1.0),
    heart: (heart / n).clamp(0.0, 1.0),
    head: (head / n).clamp(0.0, 1.0),
    fate: (fate / n).clamp(0.0, 1.0),
  );
}

double _weightedTraceProbability(double probability, double anatomicalScore) {
  final factor = 0.50 + anatomicalScore.clamp(0.0, 1.0) * 0.75;
  return (probability * factor).clamp(0.0, 1.0);
}

double _gaussian(double distance, double sigma) {
  final s = max(0.001, sigma);
  return exp(-(distance * distance) / (2.0 * s * s)).clamp(0.0, 1.0);
}

double _softBandDouble(double value, double minValue, double maxValue) {
  if (value >= minValue && value <= maxValue) return 1.0;
  final d = value < minValue ? minValue - value : value - maxValue;
  return (1.0 - d / 0.18).clamp(0.0, 1.0);
}

double _ramp(double value, double low, double high) {
  if (high <= low) return value >= high ? 1.0 : 0.0;
  return ((value - low) / (high - low)).clamp(0.0, 1.0);
}

// ── Palm crease tracing ──────────────────────────────────────────────────────

class _CreaseTraceResult {
  const _CreaseTraceResult({
    required this.traces,
    required this.seedSamples,
    required this.directionVectors,
    required this.gapRecoveries,
  });

  final List<_CreaseTrace> traces;
  final List<_TraceSeedSample> seedSamples;
  final List<_TraceVector> directionVectors;
  final List<_TraceVector> gapRecoveries;
}

class _CreaseTrace {
  const _CreaseTrace({
    required this.indices,
    required this.totalLength,
    required this.averageProbability,
    required this.averageRidgeResponse,
    required this.maximumRidgeResponse,
    required this.ridgeConsistency,
    required this.ridgeWidthEstimate,
    required this.averageDarkness,
    required this.continuityScore,
    required this.averageCurvature,
    required this.interruptionCount,
    required this.branchCount,
  });

  final List<int> indices;
  final double totalLength;
  final double averageProbability;
  final double averageRidgeResponse;
  final double maximumRidgeResponse;
  final double ridgeConsistency;
  final double ridgeWidthEstimate;
  final double averageDarkness;
  final double continuityScore;
  final double averageCurvature;
  final int interruptionCount;
  final int branchCount;
}

class _HalfTrace {
  const _HalfTrace({
    required this.indices,
    required this.gapRecoveries,
    required this.directionVectors,
  });

  final List<int> indices;
  final List<_TraceVector> gapRecoveries;
  final List<_TraceVector> directionVectors;
}

class _TraceStep {
  const _TraceStep({
    required this.idx,
    required this.score,
    required this.distance,
    required this.direction,
    required this.isGap,
  });

  final int idx;
  final double score;
  final double distance;
  final Offset direction;
  final bool isGap;
}

class _TraceSeedSample {
  const _TraceSeedSample({required this.idx, required this.value});

  final int idx;
  final double value;
}

class _TraceVector {
  const _TraceVector({
    required this.fromX,
    required this.fromY,
    required this.toX,
    required this.toY,
    required this.value,
  });

  final double fromX;
  final double fromY;
  final double toX;
  final double toY;
  final double value;
}

_CreaseTraceResult _traceCreases({
  required Float32List probability,
  required List<bool> skeleton,
  required List<bool> creaseMask,
  required List<bool> palmMask,
  required Uint8List topHat,
  required Uint8List valley,
  required int w,
  required int h,
  required double threshold,
}) {
  final seeds = <int>[];
  final minSeedProbability = max(0.20, threshold * 0.92);
  for (int i = 0; i < skeleton.length; i++) {
    if (!skeleton[i] || !palmMask[i]) continue;
    if (probability[i] >= minSeedProbability) seeds.add(i);
  }
  seeds.sort((a, b) => probability[b].compareTo(probability[a]));

  final covered = List<bool>.filled(w * h, false);
  final traces = <_CreaseTrace>[];
  final seedSamples = <_TraceSeedSample>[];
  final directionVectors = <_TraceVector>[];
  final gapRecoveries = <_TraceVector>[];

  for (final seed in seeds) {
    if (covered[seed]) continue;
    final orientation = _estimateTraceOrientation(
      seed,
      probability,
      skeleton,
      w,
      h,
    );
    if (orientation.distance <= 0.001) continue;
    if (seedSamples.length < 80) {
      seedSamples.add(_TraceSeedSample(idx: seed, value: probability[seed]));
    }

    final forward = _traceOneDirection(
      seed: seed,
      initialDirection: orientation,
      probability: probability,
      skeleton: skeleton,
      creaseMask: creaseMask,
      palmMask: palmMask,
      topHat: topHat,
      valley: valley,
      covered: covered,
      w: w,
      h: h,
      threshold: threshold,
    );
    final backward = _traceOneDirection(
      seed: seed,
      initialDirection: -orientation,
      probability: probability,
      skeleton: skeleton,
      creaseMask: creaseMask,
      palmMask: palmMask,
      topHat: topHat,
      valley: valley,
      covered: covered,
      w: w,
      h: h,
      threshold: threshold,
    );

    final combined = <int>[
      ...backward.indices.reversed,
      ...forward.indices.skip(1),
    ];
    final compact = _dedupeTrace(combined);
    if (compact.length < 8) continue;
    final trace = _buildTraceMetrics(
      compact,
      probability,
      skeleton,
      valley,
      topHat,
      w,
      h,
    );
    if (trace.totalLength < 0.035 || trace.averageProbability < 0.14) {
      continue;
    }
    traces.add(trace);
    gapRecoveries
      ..addAll(backward.gapRecoveries)
      ..addAll(forward.gapRecoveries);
    directionVectors
      ..addAll(backward.directionVectors)
      ..addAll(forward.directionVectors);
    _markTraceCovered(compact, skeleton, covered, w, h);
    if (traces.length >= 12) break;
  }

  traces.sort((a, b) => b.totalLength.compareTo(a.totalLength));
  return _CreaseTraceResult(
    traces: traces,
    seedSamples: seedSamples,
    directionVectors: directionVectors.take(96).toList(),
    gapRecoveries: gapRecoveries.take(64).toList(),
  );
}

_HalfTrace _traceOneDirection({
  required int seed,
  required Offset initialDirection,
  required Float32List probability,
  required List<bool> skeleton,
  required List<bool> creaseMask,
  required List<bool> palmMask,
  required Uint8List topHat,
  required Uint8List valley,
  required List<bool> covered,
  required int w,
  required int h,
  required double threshold,
}) {
  final indices = <int>[seed];
  final localVisited = <int>{seed};
  final gapRecoveries = <_TraceVector>[];
  final directionVectors = <_TraceVector>[];
  var current = seed;
  var direction = _unitOffset(initialDirection);
  var lowConfidenceRun = 0;
  var stepCount = 0;
  const maxSteps = 360;

  while (stepCount < maxSteps) {
    stepCount++;
    final cx = current % w;
    final cy = current ~/ w;
    if (cx < 3 || cy < 3 || cx >= w - 3 || cy >= h - 3) break;

    final step = _findNextTraceStep(
      current: current,
      direction: direction,
      probability: probability,
      skeleton: skeleton,
      creaseMask: creaseMask,
      palmMask: palmMask,
      topHat: topHat,
      valley: valley,
      covered: covered,
      localVisited: localVisited,
      w: w,
      h: h,
      threshold: threshold,
    );
    if (step == null) break;
    if (step.score < 0.31) break;

    final angle = _angleBetween(direction, step.direction);
    if (angle > 1.42) break;
    final next = step.idx;
    final localOrientation = _estimateTraceOrientation(
      next,
      probability,
      skeleton,
      w,
      h,
    );
    var alignedLocal = localOrientation;
    if (_dotOffset(alignedLocal, step.direction) < 0) {
      alignedLocal = -alignedLocal;
    }
    direction = _unitOffset(step.direction * 0.72 + alignedLocal * 0.28);

    if (step.isGap) {
      gapRecoveries.add(
        _TraceVector(
          fromX: cx.toDouble(),
          fromY: cy.toDouble(),
          toX: (next % w).toDouble(),
          toY: (next ~/ w).toDouble(),
          value: step.score,
        ),
      );
    }
    if (stepCount % 14 == 0 && directionVectors.length < 64) {
      directionVectors.add(
        _TraceVector(
          fromX: (next % w).toDouble(),
          fromY: (next ~/ w).toDouble(),
          toX: (next % w) + direction.dx * 7.0,
          toY: (next ~/ w) + direction.dy * 7.0,
          value: probability[next],
        ),
      );
    }

    indices.add(next);
    localVisited.add(next);
    current = next;
    if (probability[next] < threshold * 0.55) {
      lowConfidenceRun++;
      if (lowConfidenceRun >= 4) break;
    } else {
      lowConfidenceRun = 0;
    }
  }

  return _HalfTrace(
    indices: indices,
    gapRecoveries: gapRecoveries,
    directionVectors: directionVectors,
  );
}

_TraceStep? _findNextTraceStep({
  required int current,
  required Offset direction,
  required Float32List probability,
  required List<bool> skeleton,
  required List<bool> creaseMask,
  required List<bool> palmMask,
  required Uint8List topHat,
  required Uint8List valley,
  required List<bool> covered,
  required Set<int> localVisited,
  required int w,
  required int h,
  required double threshold,
}) {
  final cx = current % w;
  final cy = current ~/ w;
  _TraceStep? best;

  for (int radius = 2; radius <= 7; radius++) {
    final expectedX = cx + direction.dx * (radius <= 3 ? 1.7 : radius * 0.72);
    final expectedY = cy + direction.dy * (radius <= 3 ? 1.7 : radius * 0.72);
    final minX = max(1, expectedX.round() - radius);
    final maxX = min(w - 2, expectedX.round() + radius);
    final minY = max(1, expectedY.round() - radius);
    final maxY = min(h - 2, expectedY.round() + radius);

    for (int y = minY; y <= maxY; y++) {
      final yw = y * w;
      for (int x = minX; x <= maxX; x++) {
        final idx = yw + x;
        if (idx == current || !palmMask[idx]) continue;
        if (covered[idx] || localVisited.contains(idx)) continue;
        final isSkeleton = skeleton[idx];
        final minProbability = isSkeleton ? threshold * 0.34 : threshold * 0.58;
        if (!isSkeleton &&
            !creaseMask[idx] &&
            probability[idx] < minProbability) {
          continue;
        }
        if (probability[idx] < minProbability) continue;

        final disp = Offset((x - cx).toDouble(), (y - cy).toDouble());
        final distance = disp.distance;
        if (distance < 0.7 || distance > radius + 1.6) continue;
        final stepDir = _unitOffset(disp);
        final forward = _dotOffset(stepDir, direction);
        if (forward < 0.18) continue;

        final localOrientation = _estimateTraceOrientation(
          idx,
          probability,
          skeleton,
          w,
          h,
        );
        final orientationMatch = _orientationMatch(localOrientation, direction);
        final predictionDistance =
            (Offset(x.toDouble(), y.toDouble()) - Offset(expectedX, expectedY))
                .distance;
        final predictionScore = (1.0 - predictionDistance / (radius + 1.0))
            .clamp(0.0, 1.0);
        final probabilityScore = (probability[idx] / max(0.001, threshold))
            .clamp(0.0, 1.25);
        final widthScore = _ridgeWidthScore(
          idx,
          direction,
          topHat,
          valley,
          probability,
          w,
          h,
        );
        final curvatureScore = (1.0 - _angleBetween(direction, stepDir) / 1.35)
            .clamp(0.0, 1.0);
        final skeletonBonus = isSkeleton ? 0.10 : 0.0;
        final gapPenalty = radius > 3 ? 0.10 + (radius - 3) * 0.035 : 0.0;
        final score =
            probabilityScore * 0.30 +
            forward.clamp(0.0, 1.0) * 0.18 +
            orientationMatch * 0.18 +
            curvatureScore * 0.14 +
            widthScore * 0.11 +
            predictionScore * 0.09 +
            skeletonBonus -
            gapPenalty;
        if (best == null || score > best.score) {
          best = _TraceStep(
            idx: idx,
            score: score.clamp(0.0, 1.0),
            distance: distance,
            direction: stepDir,
            isGap: !isSkeleton || distance > 2.25 || radius > 3,
          );
        }
      }
    }
    if (best != null && best.score >= 0.48) return best;
  }
  return best;
}

Offset _estimateTraceOrientation(
  int idx,
  Float32List probability,
  List<bool> skeleton,
  int w,
  int h,
) {
  final cx = idx % w;
  final cy = idx ~/ w;
  var sxx = 0.0;
  var syy = 0.0;
  var sxy = 0.0;
  var total = 0.0;
  const r = 5;
  for (int y = max(1, cy - r); y <= min(h - 2, cy + r); y++) {
    for (int x = max(1, cx - r); x <= min(w - 2, cx + r); x++) {
      final ni = y * w + x;
      final dx = (x - cx).toDouble();
      final dy = (y - cy).toDouble();
      if (dx == 0 && dy == 0) continue;
      final dist2 = dx * dx + dy * dy;
      if (dist2 > r * r) continue;
      final weight = (skeleton[ni] ? 1.0 : 0.35) * probability[ni];
      if (weight <= 0.02) continue;
      sxx += weight * dx * dx;
      syy += weight * dy * dy;
      sxy += weight * dx * dy;
      total += weight;
    }
  }
  if (total <= 0.001) return const Offset(1, 0);
  final theta = 0.5 * atan2(2.0 * sxy, sxx - syy);
  return _unitOffset(Offset(cos(theta), sin(theta)));
}

double _ridgeWidthScore(
  int idx,
  Offset direction,
  Uint8List topHat,
  Uint8List valley,
  Float32List probability,
  int w,
  int h,
) {
  final x = idx % w;
  final y = idx ~/ w;
  final normal = _unitOffset(Offset(-direction.dy, direction.dx));
  var support = 0.0;
  var samples = 0;
  for (final side in const [-1.0, 1.0]) {
    for (int d = 1; d <= 4; d++) {
      final sx = (x + normal.dx * d * side).round();
      final sy = (y + normal.dy * d * side).round();
      if (sx < 0 || sx >= w || sy < 0 || sy >= h) continue;
      final si = sy * w + sx;
      support +=
          (topHat[si] / 255.0) * 0.45 +
          (valley[si] / 255.0) * 0.35 +
          probability[si] * 0.20;
      samples++;
    }
  }
  if (samples == 0) return 0.0;
  final center =
      (topHat[idx] / 255.0) * 0.50 +
      (valley[idx] / 255.0) * 0.30 +
      probability[idx] * 0.20;
  final shoulder = support / samples;
  return (center * 0.70 + shoulder * 0.30).clamp(0.0, 1.0);
}

_CreaseTrace _buildTraceMetrics(
  List<int> indices,
  Float32List probability,
  List<bool> skeleton,
  Uint8List ridgeMap,
  Uint8List topHat,
  int w,
  int h,
) {
  var lengthPx = 0.0;
  var observedPx = 0.0;
  var gapPx = 0.0;
  var probSum = 0.0;
  var ridgeSum = 0.0;
  var ridgeSqSum = 0.0;
  var maxRidge = 0.0;
  var darknessSum = 0.0;
  var widthSum = 0.0;
  var widthCount = 0;
  var curvatureSum = 0.0;
  var curvatureCount = 0;
  var interruptionCount = 0;
  var branchCount = 0;

  for (int i = 0; i < indices.length; i++) {
    final idx = indices[i];
    probSum += probability[idx];
    final ridge = ridgeMap[idx] / 255.0;
    ridgeSum += ridge;
    ridgeSqSum += ridge * ridge;
    if (ridge > maxRidge) maxRidge = ridge;
    darknessSum += topHat[idx] / 255.0;
    if (_skeletonDegree(idx, skeleton, w, h) > 2) branchCount++;
    final direction = _localTraceDirection(indices, i, w);
    if (direction.distance > 0.001) {
      widthSum += _estimateRidgeWidthAt(
        idx,
        direction,
        ridgeMap,
        probability,
        w,
        h,
      );
      widthCount++;
    }
    if (i == 0) continue;
    final prev = indices[i - 1];
    final dist = _pixelDistance(prev, idx, w);
    lengthPx += dist;
    if (dist > 2.25 || !skeleton[idx]) {
      interruptionCount++;
      gapPx += dist;
    } else {
      observedPx += dist;
    }
    if (i >= 2) {
      final a = _unitOffset(_offsetBetween(indices[i - 2], prev, w));
      final b = _unitOffset(_offsetBetween(prev, idx, w));
      curvatureSum += _angleBetween(a, b);
      curvatureCount++;
    }
  }

  final totalLength = lengthPx / max(w, h);
  final averageProbability = probSum / max(1, indices.length);
  final averageRidgeResponse = ridgeSum / max(1, indices.length);
  final ridgeVariance =
      ridgeSqSum / max(1, indices.length) -
      averageRidgeResponse * averageRidgeResponse;
  final ridgeStd = sqrt(max(0.0, ridgeVariance));
  final ridgeConsistency = averageRidgeResponse <= 0.001
      ? 0.0
      : (1.0 - ridgeStd / (averageRidgeResponse + 0.001)).clamp(0.0, 1.0);
  final ridgeWidthEstimate = widthCount == 0 ? 0.0 : widthSum / widthCount;
  final averageDarkness = darknessSum / max(1, indices.length);
  final continuityScore = lengthPx <= 0
      ? 0.0
      : (observedPx / max(1.0, observedPx + gapPx)).clamp(0.0, 1.0);
  final averageCurvature = curvatureCount == 0
      ? 0.0
      : curvatureSum / curvatureCount;
  return _CreaseTrace(
    indices: indices,
    totalLength: totalLength,
    averageProbability: averageProbability,
    averageRidgeResponse: averageRidgeResponse,
    maximumRidgeResponse: maxRidge,
    ridgeConsistency: ridgeConsistency,
    ridgeWidthEstimate: ridgeWidthEstimate,
    averageDarkness: averageDarkness,
    continuityScore: continuityScore,
    averageCurvature: averageCurvature,
    interruptionCount: interruptionCount,
    branchCount: branchCount,
  );
}

Offset _localTraceDirection(List<int> indices, int i, int w) {
  if (indices.length < 2) return Offset.zero;
  final a = indices[max(0, i - 1)];
  final b = indices[min(indices.length - 1, i + 1)];
  return _unitOffset(_offsetBetween(a, b, w));
}

double _estimateRidgeWidthAt(
  int idx,
  Offset direction,
  Uint8List ridgeMap,
  Float32List probability,
  int w,
  int h,
) {
  final x = idx % w;
  final y = idx ~/ w;
  final normal = _unitOffset(Offset(-direction.dy, direction.dx));
  final center = max(ridgeMap[idx] / 255.0, probability[idx]);
  if (center <= 0.02) return 0.0;
  var width = 1.0;
  for (final side in const [-1.0, 1.0]) {
    for (int d = 1; d <= 6; d++) {
      final sx = (x + normal.dx * d * side).round();
      final sy = (y + normal.dy * d * side).round();
      if (sx < 0 || sx >= w || sy < 0 || sy >= h) break;
      final si = sy * w + sx;
      final strength = max(ridgeMap[si] / 255.0, probability[si]);
      if (strength < center * 0.42 && strength < 0.16) break;
      width += 1.0;
    }
  }
  return width;
}

List<int> _dedupeTrace(List<int> indices) {
  final seen = <int>{};
  final out = <int>[];
  for (final idx in indices) {
    if (seen.add(idx)) out.add(idx);
  }
  return out;
}

void _markTraceCovered(
  List<int> indices,
  List<bool> skeleton,
  List<bool> covered,
  int w,
  int h,
) {
  for (final idx in indices) {
    final x = idx % w;
    final y = idx ~/ w;
    for (int dy = -2; dy <= 2; dy++) {
      for (int dx = -2; dx <= 2; dx++) {
        final nx = x + dx;
        final ny = y + dy;
        if (nx < 0 || nx >= w || ny < 0 || ny >= h) continue;
        final ni = ny * w + nx;
        if (skeleton[ni] || dx * dx + dy * dy <= 2) covered[ni] = true;
      }
    }
  }
}

int _skeletonDegree(int idx, List<bool> skeleton, int w, int h) {
  final x = idx % w;
  final y = idx ~/ w;
  var count = 0;
  for (int dy = -1; dy <= 1; dy++) {
    for (int dx = -1; dx <= 1; dx++) {
      if (dx == 0 && dy == 0) continue;
      final nx = x + dx;
      final ny = y + dy;
      if (nx < 0 || nx >= w || ny < 0 || ny >= h) continue;
      if (skeleton[ny * w + nx]) count++;
    }
  }
  return count;
}

List<List<double>> _pathFromTrace(List<int> indices, int w, int h) {
  if (indices.length < 2) return const [];
  const maxPts = 90;
  if (indices.length <= maxPts) {
    return indices.map((i) => [(i % w) / w, (i ~/ w) / h]).toList();
  }
  final step = indices.length / (maxPts - 1);
  final sampled = <List<double>>[];
  for (int i = 0; i < maxPts; i++) {
    final idx = indices[(i * step).round().clamp(0, indices.length - 1)];
    sampled.add([(idx % w) / w, (idx ~/ w) / h]);
  }
  return sampled;
}

Map<String, dynamic> _traceToRaw(
  _ScoredTrace scored,
  int w,
  int h,
  List<double> Function(List<double>) mapPt, {
  double insidePalmRatio = 1.0,
}) {
  final trace = scored.trace;
  return {
    'points': _pathFromTrace(trace.indices, w, h).map(mapPt).toList(),
    'totalLength': trace.totalLength,
    'averageProbability': trace.averageProbability,
    'anatomicalScore': scored.priorScore.average,
    'weightedProbability': scored.weightedProbability,
    'averageRidgeResponse': trace.averageRidgeResponse,
    'maximumRidgeResponse': trace.maximumRidgeResponse,
    'ridgeConsistency': trace.ridgeConsistency,
    'ridgeWidthEstimate': trace.ridgeWidthEstimate,
    'averageDarkness': trace.averageDarkness,
    'majorLineScore': scored.majorLineScore,
    'rejectionReason': scored.rejectionReason,
    'continuityScore': trace.continuityScore,
    'averageCurvature': trace.averageCurvature,
    'interruptionCount': trace.interruptionCount,
    'branchCount': trace.branchCount,
    'insidePalmRatio': insidePalmRatio,
  };
}

List<List<double>> _scoreDebugSamples(
  List<_ScoredTrace> traces,
  int w,
  int h,
  List<double> Function(List<double>) mapPt,
) {
  final samples = <List<double>>[];
  for (final scored in traces) {
    if (scored.trace.indices.isEmpty) continue;
    final idx = scored.trace.indices[scored.trace.indices.length ~/ 2];
    final p = mapPt([(idx % w) / w, (idx ~/ w) / h]);
    samples.add([p[0], p[1], scored.majorLineScore.clamp(0.0, 1.0)]);
  }
  return samples;
}

List<List<double>> _mapTraceSeeds(
  List<_TraceSeedSample> seeds,
  int w,
  int h,
  List<double> Function(List<double>) mapPt,
) {
  return seeds.map((seed) {
    final p = mapPt([(seed.idx % w) / w, (seed.idx ~/ w) / h]);
    return [p[0], p[1], seed.value];
  }).toList();
}

List<List<double>> _mapTraceVectors(
  List<_TraceVector> vectors,
  int w,
  int h,
  List<double> Function(List<double>) mapPt,
) {
  return vectors.map((v) {
    final from = mapPt([v.fromX / w, v.fromY / h]);
    final to = mapPt([v.toX / w, v.toY / h]);
    return [from[0], from[1], to[0], to[1], v.value];
  }).toList();
}

Offset _offsetBetween(int a, int b, int w) {
  return Offset(
    ((b % w) - (a % w)).toDouble(),
    ((b ~/ w) - (a ~/ w)).toDouble(),
  );
}

double _pixelDistance(int a, int b, int w) => _offsetBetween(a, b, w).distance;

Offset _unitOffset(Offset v) {
  final d = v.distance;
  if (d <= 0.0001) return const Offset(1, 0);
  return v / d;
}

double _dotOffset(Offset a, Offset b) => a.dx * b.dx + a.dy * b.dy;

double _orientationMatch(Offset a, Offset b) =>
    _dotOffset(a, b).abs().clamp(0.0, 1.0);

double _angleBetween(Offset a, Offset b) {
  final dot = _dotOffset(_unitOffset(a), _unitOffset(b)).clamp(-1.0, 1.0);
  return acos(dot);
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
  final minRowPixels = max(3, (maxRow * 0.20).round());
  final centerXPx = sumX / comp.length;
  final centerYPx = sumY / comp.length;
  final palmH = max(1, maxY - minY + 1);
  final palmW = max(1, maxX - minX + 1);
  final contour = _maskContourPoints(comp, mask, w, h);
  final hull = _convexHull(contour);

  int firstStableRow() {
    final stablePixels = max(3, (maxRow * 0.42).round());
    for (int y = minY; y <= maxY; y++) {
      var stable = 0;
      for (int yy = y; yy <= min(maxY, y + 5); yy++) {
        if (rowCount[yy] >= stablePixels) stable++;
      }
      if (stable >= 3) return y;
    }
    for (int y = minY; y <= maxY; y++) {
      if (rowCount[y] >= minRowPixels) return y;
    }
    return minY;
  }

  int lastStableRow() {
    final stablePixels = max(3, (maxRow * 0.24).round());
    for (int y = maxY; y >= minY; y--) {
      var stable = 0;
      for (int yy = y; yy >= max(minY, y - 5); yy--) {
        if (rowCount[yy] >= stablePixels) stable++;
      }
      if (stable >= 3) return y;
    }
    for (int y = maxY; y >= minY; y--) {
      if (rowCount[y] >= minRowPixels) return y;
    }
    return maxY;
  }

  final fingerBaseYPx = firstStableRow();
  final wristYPx = lastStableRow();

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

  double avgLeftSpan(double y0f, double y1f) {
    final y0 = minY + (palmH * y0f).round();
    final y1 = minY + (palmH * y1f).round();
    var sum = 0.0;
    var count = 0;
    for (int y = y0.clamp(0, h - 1); y <= y1.clamp(0, h - 1); y++) {
      if (rowCount[y] < minRowPixels) continue;
      sum += max(0.0, centerXPx - rowMin[y]);
      count++;
    }
    return count == 0 ? 0.0 : sum / count;
  }

  double avgRightSpan(double y0f, double y1f) {
    final y0 = minY + (palmH * y0f).round();
    final y1 = minY + (palmH * y1f).round();
    var sum = 0.0;
    var count = 0;
    for (int y = y0.clamp(0, h - 1); y <= y1.clamp(0, h - 1); y++) {
      if (rowCount[y] < minRowPixels) continue;
      sum += max(0.0, rowMax[y] - centerXPx);
      count++;
    }
    return count == 0 ? 0.0 : sum / count;
  }

  double minRowMin(double y0f, double y1f) {
    final y0 = minY + (palmH * y0f).round();
    final y1 = minY + (palmH * y1f).round();
    var best = w.toDouble();
    for (int y = y0.clamp(0, h - 1); y <= y1.clamp(0, h - 1); y++) {
      if (rowCount[y] < minRowPixels) continue;
      best = min(best, rowMin[y].toDouble());
    }
    return best == w.toDouble() ? minX.toDouble() : best;
  }

  double maxRowMin(double y0f, double y1f) {
    final y0 = minY + (palmH * y0f).round();
    final y1 = minY + (palmH * y1f).round();
    var best = -1.0;
    for (int y = y0.clamp(0, h - 1); y <= y1.clamp(0, h - 1); y++) {
      if (rowCount[y] < minRowPixels) continue;
      best = max(best, rowMin[y].toDouble());
    }
    return best < 0 ? minX.toDouble() : best;
  }

  double maxRowMax(double y0f, double y1f) {
    final y0 = minY + (palmH * y0f).round();
    final y1 = minY + (palmH * y1f).round();
    var best = -1.0;
    for (int y = y0.clamp(0, h - 1); y <= y1.clamp(0, h - 1); y++) {
      if (rowCount[y] < minRowPixels) continue;
      best = max(best, rowMax[y].toDouble());
    }
    return best < 0 ? maxX.toDouble() : best;
  }

  double minRowMax(double y0f, double y1f) {
    final y0 = minY + (palmH * y0f).round();
    final y1 = minY + (palmH * y1f).round();
    var best = w.toDouble();
    for (int y = y0.clamp(0, h - 1); y <= y1.clamp(0, h - 1); y++) {
      if (rowCount[y] < minRowPixels) continue;
      best = min(best, rowMax[y].toDouble());
    }
    return best == w.toDouble() ? maxX.toDouble() : best;
  }

  final topCenter = bandCenterX(minY, minY + (palmH * 0.20).round());
  final bottomCenter = bandCenterX(maxY - (palmH * 0.20).round(), maxY);
  final mainAxisAngle = atan2(bottomCenter - topCenter, max(1, maxY - minY));
  final majorAxisAngle = mainAxisAngle;
  final minorAxisAngle = mainAxisAngle + pi / 2.0;

  final asymCue = sideRows == 0
      ? 0.0
      : (leftSpanSum - rightSpanSum) / max(1.0, leftSpanSum + rightSpanSum);
  final leftUpper = avgLeftSpan(0.12, 0.34);
  final rightUpper = avgRightSpan(0.12, 0.34);
  final leftLower = avgLeftSpan(0.42, 0.82);
  final rightLower = avgRightSpan(0.42, 0.82);
  final bulgeCue =
      ((leftLower - leftUpper) - (rightLower - rightUpper)) / max(1.0, palmW);
  final leftValley = maxRowMin(0.12, 0.48) - minRowMin(0.42, 0.82);
  final rightValley = maxRowMax(0.42, 0.82) - minRowMax(0.12, 0.48);
  final valleyCue = (leftValley - rightValley) / max(1.0, palmW);
  final defectCue = _thumbConvexityDefectCue(
    contour,
    hull,
    centerXPx,
    minY,
    palmH,
    palmW,
  );
  final topShiftCue =
      ((centerXPx - topCenter) - (bottomCenter - centerXPx)) / max(1.0, palmW);
  final fusedCue =
      asymCue * 0.36 +
      bulgeCue * 0.25 +
      valleyCue * 0.17 +
      defectCue * 0.14 +
      topShiftCue * 0.08;
  final thumbSideConfidence = (fusedCue.abs() * 4.2).clamp(0.0, 1.0);
  final thumbSide = thumbSideConfidence < 0.16
      ? 'unknown'
      : fusedCue > 0
      ? 'left'
      : 'right';

  int strongestSideRow(bool left, double y0f, double y1f) {
    final y0 = minY + (palmH * y0f).round();
    final y1 = minY + (palmH * y1f).round();
    var bestY = ((y0 + y1) * 0.5).round().clamp(minY, maxY);
    var bestSpan = -1.0;
    for (int y = y0.clamp(0, h - 1); y <= y1.clamp(0, h - 1); y++) {
      if (rowCount[y] < minRowPixels) continue;
      final span = left ? centerXPx - rowMin[y] : rowMax[y] - centerXPx;
      if (span > bestSpan) {
        bestSpan = span;
        bestY = y;
      }
    }
    return bestY;
  }

  int valleyRow(bool left) {
    final y0 = minY + (palmH * 0.12).round();
    final y1 = minY + (palmH * 0.50).round();
    var bestY = (fingerBaseYPx + palmH * 0.18).round().clamp(minY, maxY);
    var best = left ? -1.0 : double.infinity;
    for (int y = y0.clamp(0, h - 1); y <= y1.clamp(0, h - 1); y++) {
      if (rowCount[y] < minRowPixels) continue;
      final v = left ? rowMin[y].toDouble() : rowMax[y].toDouble();
      if ((left && v > best) || (!left && v < best)) {
        best = v;
        bestY = y;
      }
    }
    return bestY;
  }

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
  final thumbIsLeft =
      thumbSide == 'left' || (thumbSide == 'unknown' && fusedCue >= 0);
  final thenar = switch (thumbSide) {
    'left' => [bounds[0], thenarTop, centerX, thenarBottom],
    'right' => [centerX, thenarTop, bounds[2], thenarBottom],
    _ =>
      thumbIsLeft
          ? [bounds[0], thenarTop, centerX, thenarBottom]
          : [centerX, thenarTop, bounds[2], thenarBottom],
  };
  final thumbBaseY = strongestSideRow(thumbIsLeft, 0.42, 0.82);
  final thumbBaseX = thumbIsLeft ? rowMin[thumbBaseY] : rowMax[thumbBaseY];
  final webY = valleyRow(thumbIsLeft);
  final webX = thumbIsLeft ? rowMin[webY] : rowMax[webY];
  final thenarCenterY = minY + (palmH * 0.62).round();
  final safeThenarY = thenarCenterY.clamp(minY, maxY);
  final sideX = thumbIsLeft ? rowMin[safeThenarY] : rowMax[safeThenarY];
  final thenarCenterX = thumbIsLeft
      ? (sideX + centerXPx) * 0.50
      : (centerXPx + sideX) * 0.50;

  final wristLeftX = rowCount[wristYPx] >= minRowPixels
      ? rowMin[wristYPx]
      : minX;
  final wristRightX = rowCount[wristYPx] >= minRowPixels
      ? rowMax[wristYPx]
      : maxX;
  final wristCenterX = (wristLeftX + wristRightX + 1) * 0.5;
  final wristWidthPx = max(0.0, (wristRightX - wristLeftX + 1).toDouble());

  final arcY = fingerBaseYPx;
  final arcLeft = rowCount[arcY] >= minRowPixels ? rowMin[arcY] : minX;
  final arcRight = rowCount[arcY] >= minRowPixels ? rowMax[arcY] : maxX;
  final arcWidth = max(1.0, (arcRight - arcLeft).toDouble());
  final arcBend = max(1.5, palmH * 0.035);
  final fingerBaseArc = <List<double>>[
    for (final t in const [0.12, 0.38, 0.62, 0.88])
      [
        (arcLeft + arcWidth * t) / w,
        (arcY + arcBend * (1.0 - pow((t - 0.5).abs() * 2.0, 2))) / h,
      ],
  ];

  final coverage = comp.length / (w * h).toDouble();
  final extentScore = ((palmH / h) * 1.4).clamp(0.0, 1.0);
  final widthScore = ((palmW / w) * 1.6).clamp(0.0, 1.0);
  final coverageScore = (coverage / 0.18).clamp(0.0, 1.0);
  final sideScore = thumbSide == 'unknown' ? thumbSideConfidence * 0.65 : 1.0;
  final palmCenterConfidence =
      (coverageScore * 0.45 + extentScore * 0.30 + widthScore * 0.25).clamp(
        0.0,
        1.0,
      );
  final fingerArcConfidence =
      ((rowCount[arcY] / max(1, maxRow)) * 0.65 +
              (arcWidth / max(1, palmW)) * 0.35)
          .clamp(0.0, 1.0);
  final wristConfidence =
      ((wristWidthPx / max(1, palmW)) * 0.70 +
              (rowCount[wristYPx] / max(1, maxRow)) * 0.30)
          .clamp(0.0, 1.0);
  final canonicalTransformQuality =
      (palmCenterConfidence * 0.34 +
              fingerArcConfidence * 0.24 +
              wristConfidence * 0.24 +
              thumbSideConfidence * 0.18)
          .clamp(0.0, 1.0);
  final confidence =
      (extentScore * 0.30 +
              widthScore * 0.20 +
              coverageScore * 0.24 +
              sideScore * 0.16 +
              fingerArcConfidence * 0.05 +
              wristConfidence * 0.05)
          .clamp(0.0, 1.0);
  const handedness = 'unknown';

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
    'thumbBase': [thumbBaseX / w, (thumbBaseY + 0.5) / h],
    'thumbIndexWeb': [webX / w, (webY + 0.5) / h],
    'thenarCenter': [thenarCenterX / w, (safeThenarY + 0.5) / h],
    'fingerBaseArc': fingerBaseArc,
    'wristCenter': [wristCenterX / w, wristY],
    'wristLeft': [wristLeftX / w, wristY],
    'wristRight': [(wristRightX + 1) / w, wristY],
    'wristWidth': wristWidthPx / w,
    'palmWidth': palmW / w,
    'palmHeight': palmH / h,
    'majorAxisAngle': majorAxisAngle,
    'minorAxisAngle': minorAxisAngle,
    'handedness': handedness,
    'thumbSideConfidence': thumbSideConfidence,
    'palmCenterConfidence': palmCenterConfidence,
    'fingerArcConfidence': fingerArcConfidence,
    'wristConfidence': wristConfidence,
    'canonicalTransformQuality': canonicalTransformQuality,
  };
}

List<Offset> _maskContourPoints(List<int> comp, List<bool> mask, int w, int h) {
  final contour = <Offset>[];
  for (final idx in comp) {
    final x = idx % w;
    final y = idx ~/ w;
    var boundary = x == 0 || y == 0 || x == w - 1 || y == h - 1;
    if (!boundary) {
      for (int dy = -1; dy <= 1 && !boundary; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
          if (dx == 0 && dy == 0) continue;
          final nx = x + dx;
          final ny = y + dy;
          if (nx < 0 || nx >= w || ny < 0 || ny >= h || !mask[ny * w + nx]) {
            boundary = true;
            break;
          }
        }
      }
    }
    if (boundary) contour.add(Offset(x.toDouble(), y.toDouble()));
  }
  if (contour.length <= 360) return contour;
  final step = (contour.length / 360).ceil();
  return [for (int i = 0; i < contour.length; i += step) contour[i]];
}

List<Offset> _convexHull(List<Offset> points) {
  if (points.length < 4) return points;
  final sorted = [...points]
    ..sort((a, b) {
      final byX = a.dx.compareTo(b.dx);
      return byX != 0 ? byX : a.dy.compareTo(b.dy);
    });

  double cross(Offset o, Offset a, Offset b) =>
      (a.dx - o.dx) * (b.dy - o.dy) - (a.dy - o.dy) * (b.dx - o.dx);

  final lower = <Offset>[];
  for (final p in sorted) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }
  final upper = <Offset>[];
  for (final p in sorted.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }
  return [...lower.take(lower.length - 1), ...upper.take(upper.length - 1)];
}

double _thumbConvexityDefectCue(
  List<Offset> contour,
  List<Offset> hull,
  double centerX,
  int minY,
  int palmH,
  int palmW,
) {
  if (contour.length < 6 || hull.length < 3) return 0.0;
  final y0 = minY + palmH * 0.10;
  final y1 = minY + palmH * 0.58;
  var leftDefect = 0.0;
  var rightDefect = 0.0;
  for (final p in contour) {
    if (p.dy < y0 || p.dy > y1) continue;
    final d = _distanceToHull(p, hull);
    if (p.dx < centerX) {
      leftDefect = max(leftDefect, d);
    } else {
      rightDefect = max(rightDefect, d);
    }
  }
  return ((leftDefect - rightDefect) / max(1.0, palmW.toDouble())).clamp(
    -1.0,
    1.0,
  );
}

double _distanceToHull(Offset p, List<Offset> hull) {
  var best = double.infinity;
  for (int i = 0; i < hull.length; i++) {
    final a = hull[i];
    final b = hull[(i + 1) % hull.length];
    final d = _pointSegmentDistance(p, a, b);
    if (d < best) best = d;
  }
  return best.isFinite ? best : 0.0;
}

double _pointSegmentDistance(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final len2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (len2 <= 0.0001) return (p - a).distance;
  final ap = p - a;
  final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / len2).clamp(0.0, 1.0);
  final q = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
  return (p - q).distance;
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

  List<List<double>> mapPoints(dynamic raw) {
    final points = raw as List<dynamic>? ?? const [];
    return points.map((p) => mapPt(pointFrom(p))).toList();
  }

  final center = mapPt(pointFrom(geometry['palmCenter']));
  final fingerBasePt = mapPt([
    0.0,
    (geometry['fingerBaseY'] as num).toDouble(),
  ]);
  final wristPt = mapPt([0.0, (geometry['wristY'] as num).toDouble()]);
  final wristLeft = mapPt(
    pointFrom(geometry['wristLeft'] ?? [0.0, wristPt[1]]),
  );
  final wristRight = mapPt(
    pointFrom(geometry['wristRight'] ?? [0.0, wristPt[1]]),
  );
  final palmBounds = mapRect(geometry['palmBounds']);
  final palmHeight = (palmBounds[3] - palmBounds[1]).abs();
  final palmWidth = (palmBounds[2] - palmBounds[0]).abs();
  return {
    ...geometry,
    'palmCenter': center,
    'wristY': wristPt[1],
    'fingerBaseY': fingerBasePt[1],
    'palmBounds': palmBounds,
    'thenarRegion': mapRect(geometry['thenarRegion']),
    'thumbBase': mapPt(pointFrom(geometry['thumbBase'] ?? center)),
    'thumbIndexWeb': mapPt(pointFrom(geometry['thumbIndexWeb'] ?? center)),
    'thenarCenter': mapPt(pointFrom(geometry['thenarCenter'] ?? center)),
    'fingerBaseArc': mapPoints(geometry['fingerBaseArc']),
    'wristCenter': mapPt(pointFrom(geometry['wristCenter'] ?? center)),
    'wristLeft': wristLeft,
    'wristRight': wristRight,
    'wristWidth': (wristRight[0] - wristLeft[0]).abs(),
    'palmWidth': palmWidth,
    'palmHeight': palmHeight,
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
  int maxComponents = 10,
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
  return results.take(maxComponents).toList();
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
Uint8List multiScaleRidgeMapForTest(Uint8List img, int w, int h) =>
    _multiScaleHessianRidgeResponse(img, w, h);

@visibleForTesting
PalmGeometry? palmGeometryFromMaskForTest(List<bool> mask, int w, int h) =>
    _geometryFromRaw(_detectPalmGeometry(mask, w, h));

@visibleForTesting
const double anatomyAlphaForTest = _anatomyAlpha;

@visibleForTesting
const double anatomyBetaForTest = _anatomyBeta;

@visibleForTesting
Float32List anatomyWeightedMapForTest(
  Float32List baseProbability,
  Float32List prior,
) {
  final result = Float32List(baseProbability.length);
  for (int i = 0; i < baseProbability.length; i++) {
    final base = baseProbability[i];
    if (base <= 0.0) continue;
    result[i] = (base * (_anatomyAlpha + _anatomyBeta * prior[i])).clamp(
      0.0,
      1.0,
    );
  }
  return result;
}
