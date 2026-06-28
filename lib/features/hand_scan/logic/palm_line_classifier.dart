import 'dart:math';

import 'package:flutter/material.dart' show Offset;

import 'palm_line_extractor.dart';
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
  );
}

// ── Classifier ────────────────────────────────────────────────────────────────

class PalmLineClassifier {
  PalmLineClassifier._();

  /// Classifies [extraction.candidatePaths] into life / heart / head / fate
  /// lines using spatial-geometric heuristics.
  ///
  /// Coordinates are in normalised [0, 1] image space where (0, 0) is
  /// top-left.  The assignment is greedy: the (path, lineType) pair with the
  /// highest score wins first, each path and type is used at most once.
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
    if (tracked.majorLines.isNotEmpty) {
      return _fromTrackedLines(tracked);
    }

    final paths = extraction.candidatePaths;
    final stats = paths.map(_computeStats).toList();
    // scores[pi][li] = score of path pi for line type li (0=life,1=heart,2=head,3=fate)
    final scores = [for (final s in stats) _scoreAll(s)];

    const lineCount = 4;
    final assigned = List<int?>.filled(lineCount, null);
    final usedPaths = <int>{};

    // Greedy: each round assign the globally highest unassigned (li, pi) pair.
    for (
      var attempt = 0;
      attempt < paths.length && usedPaths.length < lineCount;
      attempt++
    ) {
      double best = 0.15; // minimum score threshold
      var bestLine = -1;
      var bestPath = -1;

      for (var li = 0; li < lineCount; li++) {
        if (assigned[li] != null) continue;
        for (var pi = 0; pi < paths.length; pi++) {
          if (usedPaths.contains(pi)) continue;
          final s = scores[pi][li];
          if (s > best) {
            best = s;
            bestLine = li;
            bestPath = pi;
          }
        }
      }
      if (bestLine == -1) break;
      assigned[bestLine] = bestPath;
      usedPaths.add(bestPath);
    }

    List<Offset>? getPath(int? idx) => idx != null ? paths[idx] : null;
    double getConf(int li, int? idx) =>
        idx != null ? scores[idx][li].clamp(0.0, 1.0) : 0.0;
    double getLen(int? idx) => idx != null ? stats[idx].arcLength : 0.0;
    double getCurv(int? idx) => idx != null ? stats[idx].curvature : 1.0;

    return PalmLineClassificationResult(
      lifeLinePath: getPath(assigned[0]),
      heartLinePath: getPath(assigned[1]),
      headLinePath: getPath(assigned[2]),
      fateLinePath: getPath(assigned[3]),
      lifeLineConfidence: getConf(0, assigned[0]),
      heartLineConfidence: getConf(1, assigned[1]),
      headLineConfidence: getConf(2, assigned[2]),
      fateLineConfidence: getConf(3, assigned[3]),
      lifeLineLengthRatio: getLen(assigned[0]),
      heartLineLengthRatio: getLen(assigned[1]),
      headLineLengthRatio: getLen(assigned[2]),
      fateLineLengthRatio: getLen(assigned[3]),
      headLineCurvature: getCurv(assigned[2]),
    );
  }

  static PalmLineClassificationResult _fromTrackedLines(
    TrackedPalmLines tracked,
  ) {
    final life = tracked.life;
    final heart = tracked.heart;
    final head = tracked.head;
    final fate = tracked.fate;
    return PalmLineClassificationResult(
      lifeLinePath: life?.points,
      heartLinePath: heart?.points,
      headLinePath: head?.points,
      fateLinePath: fate?.points,
      lifeLineConfidence: life?.averageConfidence ?? 0.0,
      heartLineConfidence: heart?.averageConfidence ?? 0.0,
      headLineConfidence: head?.averageConfidence ?? 0.0,
      fateLineConfidence: fate?.averageConfidence ?? 0.0,
      lifeLineLengthRatio: life?.arcLength ?? 0.0,
      heartLineLengthRatio: heart?.arcLength ?? 0.0,
      headLineLengthRatio: head?.arcLength ?? 0.0,
      fateLineLengthRatio: fate?.arcLength ?? 0.0,
      headLineCurvature: head?.curvature ?? 1.0,
    );
  }

  // ── Per-path statistics ──────────────────────────────────────────────────

  static _PathStats _computeStats(List<Offset> path) {
    if (path.isEmpty) return _PathStats.empty;

    double sumX = 0, sumY = 0;
    double minX = 1, maxX = 0, minY = 1, maxY = 0;
    double arcLen = 0;

    for (var i = 0; i < path.length; i++) {
      final p = path[i];
      sumX += p.dx;
      sumY += p.dy;
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
      if (i > 0) {
        final ddx = p.dx - path[i - 1].dx;
        final ddy = p.dy - path[i - 1].dy;
        arcLen += sqrt(ddx * ddx + ddy * ddy);
      }
    }

    final n = path.length;
    final chordDx = path.last.dx - path.first.dx;
    final chordDy = path.last.dy - path.first.dy;
    final chordLen = sqrt(chordDx * chordDx + chordDy * chordDy);
    final curvature = chordLen > 0.001 ? arcLen / chordLen : 1.0;

    return _PathStats(
      meanX: sumX / n,
      meanY: sumY / n,
      xSpan: maxX - minX,
      ySpan: maxY - minY,
      arcLength: arcLen,
      curvature: curvature,
    );
  }

  // ── Scores for [life, heart, head, fate] ────────────────────────────────

  static List<double> _scoreAll(_PathStats s) => [
    _scoreLife(s),
    _scoreHeart(s),
    _scoreHead(s),
    _scoreFate(s),
  ];

  /// Life line: left-side of palm, arcs vertically from finger base to wrist.
  static double _scoreLife(_PathStats s) {
    // Must be in the left portion of the image.
    if (s.meanX > 0.52) return 0.0;
    var score = 0.0;
    // Strong weight for left position (thumb side).
    score += (0.52 - s.meanX).clamp(0.0, 0.52) * 2.0;
    // Vertical extent – life line runs top-to-wrist.
    score += s.ySpan.clamp(0.0, 0.7) * 1.0;
    // Curvature bonus (the line arcs around the thenar eminence).
    score += (s.curvature - 1.0).clamp(0.0, 0.8) * 0.5;
    // Penalise strongly horizontal paths.
    if (s.xSpan > s.ySpan) score *= 0.4;
    return score.clamp(0.0, 1.0);
  }

  /// Heart line: upper palm, runs roughly horizontally.
  static double _scoreHeart(_PathStats s) {
    if (s.meanY > 0.52) return 0.0;
    var score = 0.0;
    // Upper position weight.
    score += (0.52 - s.meanY).clamp(0.0, 0.52) * 2.0;
    // Horizontal span.
    score += s.xSpan.clamp(0.0, 0.8) * 1.0;
    // Penalise strongly vertical paths.
    if (s.ySpan > s.xSpan) score *= 0.35;
    return score.clamp(0.0, 1.0);
  }

  /// Head line: middle palm, roughly horizontal to slightly diagonal.
  static double _scoreHead(_PathStats s) {
    var score = 0.0;
    // Ideal vertical centre ~0.45.
    score += (1.0 - (s.meanY - 0.45).abs() * 3.5).clamp(0.0, 1.0) * 0.7;
    // Horizontal extent.
    score += s.xSpan.clamp(0.0, 0.8) * 0.8;
    // Penalise strongly vertical paths.
    if (s.ySpan > s.xSpan * 1.5) score *= 0.3;
    return score.clamp(0.0, 1.0);
  }

  /// Fate line: central x, predominantly vertical.
  static double _scoreFate(_PathStats s) {
    // Must be in the central horizontal band.
    if (s.meanX < 0.25 || s.meanX > 0.75) return 0.0;
    var score = 0.0;
    // Central position (ideal x = 0.5).
    score += (1.0 - (s.meanX - 0.50).abs() * 4.0).clamp(0.0, 1.0) * 1.0;
    // Vertical extent.
    score += s.ySpan.clamp(0.0, 0.7) * 0.8;
    // Penalise horizontal paths.
    if (s.xSpan > s.ySpan * 0.8) score *= 0.3;
    return score.clamp(0.0, 1.0);
  }
}

// ── Internal statistics ───────────────────────────────────────────────────────

class _PathStats {
  const _PathStats({
    required this.meanX,
    required this.meanY,
    required this.xSpan,
    required this.ySpan,
    required this.arcLength,
    required this.curvature,
  });

  static const empty = _PathStats(
    meanX: 0.5,
    meanY: 0.5,
    xSpan: 0,
    ySpan: 0,
    arcLength: 0,
    curvature: 1,
  );

  final double meanX;
  final double meanY;
  final double xSpan;
  final double ySpan;

  /// Normalised arc length (sum of segment lengths in [0, 1] space).
  final double arcLength;

  /// arc_length / chord_length; 1.0 = perfectly straight.
  final double curvature;
}
