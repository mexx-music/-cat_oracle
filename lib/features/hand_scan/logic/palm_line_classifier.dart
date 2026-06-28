import 'package:flutter/material.dart' show Offset;

import 'palm_line_extractor.dart';
import 'palm_line_hypothesis_engine.dart';
import 'palm_line_tracker.dart';

// ── Result model ──────────────────────────────────────────────────────────────

/// Classification of candidate paths into the four main palm lines.
///
/// Each line field is null when no suitable path was found.
/// [*Confidence] is in [0, 1]; values below 0.25 indicate a weak match.
/// [*LengthRatio] is the arc length expressed as a fraction of the normalised
/// image height (0 = not found, 1 = spans the full image height).
/// [headLineCurvature] is arc_length / chord_length (1.0 = straight).
class PalmLineClassificationResult {
  const PalmLineClassificationResult({
    this.lifeLinePath,
    this.heartLinePath,
    this.headLinePath,
    this.fateLinePath,
    this.lifeLineConfidence = 0.0,
    this.heartLineConfidence = 0.0,
    this.headLineConfidence = 0.0,
    this.fateLineConfidence = 0.0,
    this.lifeLineLengthRatio = 0.0,
    this.heartLineLengthRatio = 0.0,
    this.headLineLengthRatio = 0.0,
    this.fateLineLengthRatio = 0.0,
    this.headLineCurvature = 1.0,
    this.hypothesisSolution,
  });

  final List<Offset>? lifeLinePath;
  final List<Offset>? heartLinePath;
  final List<Offset>? headLinePath;
  final List<Offset>? fateLinePath;

  final double lifeLineConfidence;
  final double heartLineConfidence;
  final double headLineConfidence;
  final double fateLineConfidence;

  final double lifeLineLengthRatio;
  final double heartLineLengthRatio;
  final double headLineLengthRatio;
  final double fateLineLengthRatio;

  /// Arc-length / chord-length for the head line (1.0 = perfectly straight).
  final double headLineCurvature;

  /// Multi-hypothesis anatomical assignment diagnostics.
  final PalmLineAssignmentSolution? hypothesisSolution;

  double get totalAnatomicalScore =>
      hypothesisSolution?.totalAnatomicalScore ?? 0.0;
  double get alternativeAnatomicalScore =>
      hypothesisSolution?.alternativeScore ?? 0.0;
  double get anatomicalScoreDifference =>
      hypothesisSolution?.scoreDifference ?? 0.0;
  bool get isAnatomicalAssignmentUncertain =>
      hypothesisSolution?.isUncertain ?? false;

  static const empty = PalmLineClassificationResult();

  PalmLineClassificationResult copyWith({
    List<Offset>? lifeLinePath,
    List<Offset>? heartLinePath,
    List<Offset>? headLinePath,
    List<Offset>? fateLinePath,
    double? lifeLineConfidence,
    double? heartLineConfidence,
    double? headLineConfidence,
    double? fateLineConfidence,
    double? lifeLineLengthRatio,
    double? heartLineLengthRatio,
    double? headLineLengthRatio,
    double? fateLineLengthRatio,
    double? headLineCurvature,
    PalmLineAssignmentSolution? hypothesisSolution,
  }) => PalmLineClassificationResult(
    lifeLinePath: lifeLinePath ?? this.lifeLinePath,
    heartLinePath: heartLinePath ?? this.heartLinePath,
    headLinePath: headLinePath ?? this.headLinePath,
    fateLinePath: fateLinePath ?? this.fateLinePath,
    lifeLineConfidence: lifeLineConfidence ?? this.lifeLineConfidence,
    heartLineConfidence: heartLineConfidence ?? this.heartLineConfidence,
    headLineConfidence: headLineConfidence ?? this.headLineConfidence,
    fateLineConfidence: fateLineConfidence ?? this.fateLineConfidence,
    lifeLineLengthRatio: lifeLineLengthRatio ?? this.lifeLineLengthRatio,
    heartLineLengthRatio: heartLineLengthRatio ?? this.heartLineLengthRatio,
    headLineLengthRatio: headLineLengthRatio ?? this.headLineLengthRatio,
    fateLineLengthRatio: fateLineLengthRatio ?? this.fateLineLengthRatio,
    headLineCurvature: headLineCurvature ?? this.headLineCurvature,
    hypothesisSolution: hypothesisSolution ?? this.hypothesisSolution,
  );
}

// ── Classifier ────────────────────────────────────────────────────────────────

class PalmLineClassifier {
  PalmLineClassifier._();

  /// Classifies [extraction.candidatePaths] into life / heart / head / fate
  /// lines using multi-hypothesis anatomical scoring.
  static PalmLineClassificationResult classify(
    PalmLineExtractionResult extraction,
  ) {
    if (extraction.candidatePaths.isEmpty) {
      return PalmLineClassificationResult.empty;
    }

    final tracked = PalmLineTracker.track(
      geometry: extraction.palmGeometry,
      candidatePaths: extraction.candidatePaths,
      rejectedPaths: extraction.rejectedPaths,
    );

    final evidence = _buildTraceEvidence(extraction, tracked);
    if (evidence.isEmpty) return PalmLineClassificationResult.empty;

    final solution = LineHypothesisEngine.solve(
      geometry: extraction.palmGeometry,
      traces: evidence,
    );
    return _fromHypothesisSolution(solution);
  }

  static List<PalmLineTraceEvidence> _buildTraceEvidence(
    PalmLineExtractionResult extraction,
    TrackedPalmLines tracked,
  ) {
    // Prefer anatomy-weighted type-specific candidates when available.
    final aw = extraction.anatomyWeighted;
    final hasAnatomyData =
        aw.lifeTracedCreases.isNotEmpty ||
        aw.heartTracedCreases.isNotEmpty ||
        aw.headTracedCreases.isNotEmpty ||
        aw.fateTracedCreases.isNotEmpty;
    if (hasAnatomyData) {
      // Only include traces confirmed to be inside the palm mask.
      PalmLineTraceEvidence? fromCrease(PalmTracedCrease c, String id) {
        if (c.insidePalmRatio < 0.98) return null;
        return PalmLineTraceEvidence(
          id: id,
          points: c.points,
          averageProbability: c.averageProbability,
          continuity: c.continuityScore,
          anatomicalPriorScore: c.anatomicalScore,
          gapCount: c.interruptionCount,
          averageRidgeResponse: c.averageRidgeResponse,
          maximumRidgeResponse: c.maximumRidgeResponse,
          ridgeConsistency: c.ridgeConsistency,
          ridgeWidthEstimate: c.ridgeWidthEstimate,
          averageDarkness: c.averageDarkness,
          majorLineScore: c.majorLineScore,
          rejectionReason: c.rejectionReason,
        );
      }

      final evidence = <PalmLineTraceEvidence>[
        for (var i = 0; i < aw.lifeTracedCreases.length; i++)
          ?fromCrease(aw.lifeTracedCreases[i], 'life_$i'),
        for (var i = 0; i < aw.heartTracedCreases.length; i++)
          ?fromCrease(aw.heartTracedCreases[i], 'heart_$i'),
        for (var i = 0; i < aw.headTracedCreases.length; i++)
          ?fromCrease(aw.headTracedCreases[i], 'head_$i'),
        for (var i = 0; i < aw.fateTracedCreases.length; i++)
          ?fromCrease(aw.fateTracedCreases[i], 'fate_$i'),
      ];
      if (evidence.isNotEmpty) return evidence;
    }

    if (tracked.mergedFragments.isNotEmpty) {
      return [
        for (final line in tracked.mergedFragments)
          PalmLineTraceEvidence(
            id: line.id,
            points: line.points,
            averageProbability: line.averageConfidence,
            continuity: line.continuity,
            anatomicalPriorScore: line.averageConfidence,
            gapCount: line.gapCount,
            majorLineScore: line.averageConfidence,
          ),
      ];
    }

    final result = <PalmLineTraceEvidence>[];
    for (var i = 0; i < extraction.candidatePaths.length; i++) {
      final crease = i < extraction.tracedCreases.length
          ? extraction.tracedCreases[i]
          : null;
      // Final safety guard: reject outside-palm traces before they reach scoring.
      if (crease != null && crease.insidePalmRatio < 0.98) continue;
      result.add(
        PalmLineTraceEvidence(
          id: 'trace_$i',
          points: extraction.candidatePaths[i],
          averageProbability:
              crease?.averageProbability ?? extraction.confidence,
          continuity: crease?.continuityScore ?? 0.0,
          anatomicalPriorScore: crease?.anatomicalScore ?? 0.0,
          gapCount: crease?.interruptionCount ?? 0,
          averageRidgeResponse: crease?.averageRidgeResponse ?? 0.0,
          maximumRidgeResponse: crease?.maximumRidgeResponse ?? 0.0,
          ridgeConsistency: crease?.ridgeConsistency ?? 0.0,
          ridgeWidthEstimate: crease?.ridgeWidthEstimate ?? 0.0,
          averageDarkness: crease?.averageDarkness ?? 0.0,
          majorLineScore: crease?.majorLineScore ?? 0.0,
          rejectionReason: crease?.rejectionReason ?? '',
        ),
      );
    }
    return result;
  }

  static PalmLineClassificationResult _fromHypothesisSolution(
    PalmLineAssignmentSolution solution,
  ) {
    final life = solution.life;
    final heart = solution.heart;
    final head = solution.head;
    final fate = solution.fate;
    return PalmLineClassificationResult(
      lifeLinePath: life?.points,
      heartLinePath: heart?.points,
      headLinePath: head?.points,
      fateLinePath: fate?.points,
      lifeLineConfidence: life?.score ?? 0.0,
      heartLineConfidence: heart?.score ?? 0.0,
      headLineConfidence: head?.score ?? 0.0,
      fateLineConfidence: fate?.score ?? 0.0,
      lifeLineLengthRatio: life?.features.arcLength ?? 0.0,
      heartLineLengthRatio: heart?.features.arcLength ?? 0.0,
      headLineLengthRatio: head?.features.arcLength ?? 0.0,
      fateLineLengthRatio: fate?.features.arcLength ?? 0.0,
      headLineCurvature: head?.features.curvature ?? 1.0,
      hypothesisSolution: solution,
    );
  }
}
