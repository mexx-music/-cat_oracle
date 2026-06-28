import 'dart:math';

import 'package:flutter/material.dart' show Offset, Rect;

import 'palm_line_extractor.dart';

enum PalmLineHypothesisType { life, heart, head, fate }

class PalmLineTraceEvidence {
  const PalmLineTraceEvidence({
    required this.id,
    required this.points,
    this.averageProbability = 0.0,
    this.continuity = 0.0,
    this.anatomicalPriorScore = 0.0,
    this.gapCount = 0,
  });

  final String id;
  final List<Offset> points;
  final double averageProbability;
  final double continuity;
  final double anatomicalPriorScore;
  final int gapCount;
}

class PalmLineTraceFeatures {
  const PalmLineTraceFeatures({
    required this.arcLength,
    required this.curvature,
    required this.continuity,
    required this.averageProbability,
    required this.anatomicalPriorScore,
    required this.startLocation,
    required this.endLocation,
    required this.orientation,
    required this.distanceToPalmCenter,
    required this.distanceToThumbMound,
    required this.distanceToWrist,
    required this.distanceToFingerBase,
    required this.crossingsWithOtherTraces,
  });

  final double arcLength;
  final double curvature;
  final double continuity;
  final double averageProbability;
  final double anatomicalPriorScore;
  final Offset startLocation;
  final Offset endLocation;
  final double orientation;
  final double distanceToPalmCenter;
  final double distanceToThumbMound;
  final double distanceToWrist;
  final double distanceToFingerBase;
  final int crossingsWithOtherTraces;
}

class PalmLineTraceScorecard {
  const PalmLineTraceScorecard({
    required this.traceIndex,
    required this.traceId,
    required this.points,
    required this.features,
    required this.lifeScore,
    required this.heartScore,
    required this.headScore,
    required this.fateScore,
  });

  final int traceIndex;
  final String traceId;
  final List<Offset> points;
  final PalmLineTraceFeatures features;
  final double lifeScore;
  final double heartScore;
  final double headScore;
  final double fateScore;

  double scoreFor(PalmLineHypothesisType type) => switch (type) {
    PalmLineHypothesisType.life => lifeScore,
    PalmLineHypothesisType.heart => heartScore,
    PalmLineHypothesisType.head => headScore,
    PalmLineHypothesisType.fate => fateScore,
  };

  PalmLineHypothesisType get winningType {
    final scores = {
      PalmLineHypothesisType.life: lifeScore,
      PalmLineHypothesisType.heart: heartScore,
      PalmLineHypothesisType.head: headScore,
      PalmLineHypothesisType.fate: fateScore,
    };
    return scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  double get winningScore => scoreFor(winningType);
}

class PalmLineHypothesis {
  const PalmLineHypothesis({
    required this.type,
    required this.traceIndex,
    required this.traceId,
    required this.points,
    required this.features,
    required this.score,
    required this.isCloseAlternative,
  });

  final PalmLineHypothesisType type;
  final int traceIndex;
  final String traceId;
  final List<Offset> points;
  final PalmLineTraceFeatures features;
  final double score;
  final bool isCloseAlternative;
}

class PalmLineAssignmentSolution {
  const PalmLineAssignmentSolution({
    this.life,
    this.heart,
    this.head,
    this.fate,
    this.scorecards = const [],
    this.topHypotheses = const {},
    this.totalAnatomicalScore = 0.0,
    this.alternativeScore = 0.0,
    this.scoreDifference = 0.0,
    this.isUncertain = false,
  });

  final PalmLineHypothesis? life;
  final PalmLineHypothesis? heart;
  final PalmLineHypothesis? head;
  final PalmLineHypothesis? fate;
  final List<PalmLineTraceScorecard> scorecards;
  final Map<PalmLineHypothesisType, List<PalmLineHypothesis>> topHypotheses;
  final double totalAnatomicalScore;
  final double alternativeScore;
  final double scoreDifference;
  final bool isUncertain;

  PalmLineHypothesis? hypothesisFor(PalmLineHypothesisType type) =>
      switch (type) {
        PalmLineHypothesisType.life => life,
        PalmLineHypothesisType.heart => heart,
        PalmLineHypothesisType.head => head,
        PalmLineHypothesisType.fate => fate,
      };

  bool get hasAssignments =>
      life != null || heart != null || head != null || fate != null;

  static const empty = PalmLineAssignmentSolution();
}

class LineHypothesisEngine {
  LineHypothesisEngine._();

  static PalmLineAssignmentSolution solve({
    required PalmGeometry? geometry,
    required List<PalmLineTraceEvidence> traces,
  }) {
    final valid = traces
        .asMap()
        .entries
        .where((entry) => entry.value.points.length >= 2)
        .toList();
    if (valid.isEmpty) return PalmLineAssignmentSolution.empty;

    final work = <_TraceWork>[];
    for (final entry in valid) {
      final trace = entry.value;
      work.add(
        _TraceWork(
          originalIndex: entry.key,
          evidence: trace,
          canonical: trace.points
              .map((p) => _canonicalPoint(geometry, p))
              .toList(),
          thumbCanonical: trace.points
              .map((p) => _thumbCanonicalPoint(geometry, p))
              .toList(),
        ),
      );
    }

    final crossingCounts = _crossingCounts(work);
    final scorecards = <PalmLineTraceScorecard>[];
    final hypotheses = <PalmLineHypothesisType, List<PalmLineHypothesis>>{
      for (final type in PalmLineHypothesisType.values) type: [],
    };

    for (var i = 0; i < work.length; i++) {
      final trace = work[i];
      final features = _featuresFor(trace, geometry, crossingCounts[i]);
      final scores = {
        PalmLineHypothesisType.life: _scoreLife(trace, features),
        PalmLineHypothesisType.heart: _scoreHeart(trace, features),
        PalmLineHypothesisType.head: _scoreHead(trace, features),
        PalmLineHypothesisType.fate: _scoreFate(trace, features),
      };
      final scorecard = PalmLineTraceScorecard(
        traceIndex: trace.originalIndex,
        traceId: trace.evidence.id,
        points: trace.evidence.points,
        features: features,
        lifeScore: scores[PalmLineHypothesisType.life]!,
        heartScore: scores[PalmLineHypothesisType.heart]!,
        headScore: scores[PalmLineHypothesisType.head]!,
        fateScore: scores[PalmLineHypothesisType.fate]!,
      );
      scorecards.add(scorecard);
      for (final type in PalmLineHypothesisType.values) {
        hypotheses[type]!.add(
          PalmLineHypothesis(
            type: type,
            traceIndex: trace.originalIndex,
            traceId: trace.evidence.id,
            points: trace.evidence.points,
            features: features,
            score: scores[type]!,
            isCloseAlternative: false,
          ),
        );
      }
    }

    final top = <PalmLineHypothesisType, List<PalmLineHypothesis>>{};
    for (final type in PalmLineHypothesisType.values) {
      final ranked = [...hypotheses[type]!]
        ..sort((a, b) => b.score.compareTo(a.score));
      final best = ranked.isEmpty ? 0.0 : ranked.first.score;
      top[type] = ranked.take(5).map((h) {
        final close = best > 0 && (best - h.score).abs() <= best * 0.05;
        return PalmLineHypothesis(
          type: h.type,
          traceIndex: h.traceIndex,
          traceId: h.traceId,
          points: h.points,
          features: h.features,
          score: h.score,
          isCloseAlternative: close,
        );
      }).toList();
    }

    return _solveGlobal(top, scorecards);
  }

  static PalmLineAssignmentSolution _solveGlobal(
    Map<PalmLineHypothesisType, List<PalmLineHypothesis>> top,
    List<PalmLineTraceScorecard> scorecards,
  ) {
    const order = [
      PalmLineHypothesisType.life,
      PalmLineHypothesisType.heart,
      PalmLineHypothesisType.head,
      PalmLineHypothesisType.fate,
    ];
    final choices = <PalmLineHypothesisType, List<PalmLineHypothesis?>>{};
    for (final type in order) {
      final threshold = _assignmentThreshold(type);
      choices[type] = <PalmLineHypothesis?>[
        null,
        ...top[type]!.where((h) => h.score >= threshold),
      ];
    }

    _AssignmentCandidate? best;
    _AssignmentCandidate? second;

    void visit(
      int depth,
      Map<PalmLineHypothesisType, PalmLineHypothesis?> picked,
      Set<int> used,
      double total,
    ) {
      if (depth == order.length) {
        final candidate = _AssignmentCandidate(
          life: picked[PalmLineHypothesisType.life],
          heart: picked[PalmLineHypothesisType.heart],
          head: picked[PalmLineHypothesisType.head],
          fate: picked[PalmLineHypothesisType.fate],
          score: total,
        );
        if (best == null || candidate.score > best!.score) {
          second = best;
          best = candidate;
        } else if (second == null || candidate.score > second!.score) {
          second = candidate;
        }
        return;
      }

      final type = order[depth];
      for (final hypothesis in choices[type]!) {
        if (hypothesis != null && used.contains(hypothesis.traceIndex)) {
          continue;
        }
        picked[type] = hypothesis;
        if (hypothesis != null) used.add(hypothesis.traceIndex);
        visit(depth + 1, picked, used, total + (hypothesis?.score ?? 0.0));
        if (hypothesis != null) used.remove(hypothesis.traceIndex);
      }
    }

    visit(0, {}, <int>{}, 0.0);
    final winner = best;
    if (winner == null || winner.score <= 0) {
      return PalmLineAssignmentSolution(
        scorecards: scorecards,
        topHypotheses: top,
      );
    }
    final alternative = second?.score ?? 0.0;
    final diff = (winner.score - alternative).clamp(0.0, 1.0);
    final uncertain = alternative > 0 && diff <= winner.score * 0.05;
    return PalmLineAssignmentSolution(
      life: winner.life,
      heart: winner.heart,
      head: winner.head,
      fate: winner.fate,
      scorecards: scorecards,
      topHypotheses: top,
      totalAnatomicalScore: winner.score,
      alternativeScore: alternative,
      scoreDifference: diff,
      isUncertain: uncertain,
    );
  }

  static double _assignmentThreshold(PalmLineHypothesisType type) =>
      switch (type) {
        PalmLineHypothesisType.life => 0.25,
        PalmLineHypothesisType.heart => 0.25,
        PalmLineHypothesisType.head => 0.25,
        PalmLineHypothesisType.fate => 0.38,
      };

  static PalmLineTraceFeatures _featuresFor(
    _TraceWork trace,
    PalmGeometry? geometry,
    int crossingCount,
  ) {
    final points = trace.evidence.points;
    var arc = 0.0;
    for (var i = 1; i < points.length; i++) {
      arc += (points[i] - points[i - 1]).distance;
    }
    final chord = (points.last - points.first).distance;
    final curvature = chord > 0.001 ? arc / chord : 1.0;
    final continuity = trace.evidence.continuity > 0
        ? trace.evidence.continuity.clamp(0.0, 1.0)
        : _estimateContinuity(points);
    final probability = trace.evidence.averageProbability > 0
        ? trace.evidence.averageProbability.clamp(0.0, 1.0)
        : 0.62;
    final prior = trace.evidence.anatomicalPriorScore > 0
        ? trace.evidence.anatomicalPriorScore.clamp(0.0, 1.0)
        : _meanBestPrior(trace.thumbCanonical);
    final center = geometry?.palmCenter ?? const Offset(0.5, 0.55);
    final thenar =
        geometry?.thenarRegion ?? const Rect.fromLTRB(0.08, 0.42, 0.5, 0.92);
    final thumbCenter = thenar.isEmpty
        ? Offset(center.dx, (center.dy + (geometry?.wristY ?? 0.92)) * 0.5)
        : thenar.center;
    final wristY = geometry?.wristY ?? 0.92;
    final fingerBaseY = geometry?.fingerBaseY ?? 0.12;
    final mean = _meanPoint(points);
    final nearestWrist = points
        .map((p) => (p.dy - wristY).abs())
        .fold<double>(double.infinity, min);
    final nearestFingerBase = points
        .map((p) => (p.dy - fingerBaseY).abs())
        .fold<double>(double.infinity, min);
    final orientation = atan2(
      points.last.dy - points.first.dy,
      points.last.dx - points.first.dx,
    );
    return PalmLineTraceFeatures(
      arcLength: arc,
      curvature: curvature.clamp(1.0, 6.0),
      continuity: continuity,
      averageProbability: probability,
      anatomicalPriorScore: prior,
      startLocation: points.first,
      endLocation: points.last,
      orientation: orientation,
      distanceToPalmCenter: (mean - center).distance,
      distanceToThumbMound: (mean - thumbCenter).distance,
      distanceToWrist: nearestWrist,
      distanceToFingerBase: nearestFingerBase,
      crossingsWithOtherTraces: crossingCount,
    );
  }

  static double _scoreLife(_TraceWork trace, PalmLineTraceFeatures f) {
    final oriented = _orientForTargets(
      trace.thumbCanonical,
      const Offset(0.39, 0.08),
      const Offset(0.42, 0.92),
    );
    final start = oriented.start;
    final end = oriented.end;
    final xSpan = _spanX(trace.thumbCanonical);
    final ySpan = _spanY(trace.thumbCanonical);
    final vertical = _verticality(start, end);
    final mean = _meanPoint(trace.thumbCanonical);
    final prior = _meanPrior(trace.thumbCanonical, PalmLineHypothesisType.life);
    final webStart = _gaussianDistance(start, const Offset(0.39, 0.08), 0.20);
    final wristEnd =
        _softBand(end.dy, 0.62, 1.02) * _softBand(end.dx, 0.05, 0.66);
    final thenarWrap = _meanCurveFit(
      trace.thumbCanonical,
      _lifeExpectedX,
      0.16,
    );
    final thumbSide = _fraction(trace.thumbCanonical, (p) => p.dx <= 0.68);
    final length = _ramp(f.arcLength, 0.10, 0.52);
    final curvature = _gaussian((f.curvature - 1.35).abs(), 0.55);
    final base =
        webStart * 0.16 +
        wristEnd * 0.16 +
        thenarWrap * 0.19 +
        thumbSide * 0.10 +
        length * 0.12 +
        curvature * 0.08 +
        f.continuity * 0.08 +
        f.averageProbability * 0.05 +
        max(prior, f.anatomicalPriorScore) * 0.06;
    final centerVerticalPenalty =
        vertical * _gaussian((mean.dx - 0.50).abs(), 0.11) * 0.46;
    final centerCrossPenalty =
        _fraction(
          trace.thumbCanonical,
          (p) => (p - const Offset(0.5, 0.56)).distance < 0.12,
        ) *
        0.28;
    final middleFingerEndPenalty =
        _gaussian((end.dx - 0.50).abs(), 0.10) *
        _softBand(end.dy, 0.18, 0.58) *
        0.22;
    final lowStartPenalty = _ramp(start.dy, 0.24, 0.48) * 0.28;
    final horizontalPenalty = xSpan > ySpan * 0.95 ? 0.34 : 0.0;
    final crossingPenalty = min(0.18, f.crossingsWithOtherTraces * 0.035);
    return (base *
            (1.0 -
                centerVerticalPenalty -
                centerCrossPenalty -
                middleFingerEndPenalty -
                lowStartPenalty -
                horizontalPenalty -
                crossingPenalty))
        .clamp(0.0, 1.0);
  }

  static double _scoreHeart(_TraceWork trace, PalmLineTraceFeatures f) {
    final oriented = _orientForHorizontal(trace.thumbCanonical);
    final start = oriented.start;
    final end = oriented.end;
    final mean = _meanPoint(trace.thumbCanonical);
    final xSpan = _spanX(trace.thumbCanonical);
    final horizontal = _horizontality(start, end);
    final prior = _meanPrior(
      trace.thumbCanonical,
      PalmLineHypothesisType.heart,
    );
    final upperBand = _gaussian((mean.dy - 0.23).abs(), 0.14);
    final belowFingerBase = _softBand(mean.dy, 0.08, 0.42);
    final crossesPalm = _ramp(xSpan, 0.22, 0.68);
    final base =
        upperBand * 0.22 +
        horizontal * 0.19 +
        belowFingerBase * 0.12 +
        crossesPalm * 0.16 +
        f.continuity * 0.10 +
        f.averageProbability * 0.07 +
        max(prior, f.anatomicalPriorScore) * 0.14;
    final thumbPenalty =
        _fraction(trace.thumbCanonical, (p) => p.dx < 0.35 && p.dy > 0.36) *
        0.34;
    final verticalPenalty = _verticality(start, end) * 0.38;
    final lowPenalty = _ramp(mean.dy, 0.46, 0.72) * 0.30;
    return (base * (1.0 - thumbPenalty - verticalPenalty - lowPenalty)).clamp(
      0.0,
      1.0,
    );
  }

  static double _scoreHead(_TraceWork trace, PalmLineTraceFeatures f) {
    final oriented = _orientForHorizontal(trace.thumbCanonical);
    final start = oriented.start;
    final end = oriented.end;
    final mean = _meanPoint(trace.thumbCanonical);
    final xSpan = _spanX(trace.thumbCanonical);
    final ySpan = _spanY(trace.thumbCanonical);
    final horizontal = _horizontality(start, end);
    final diagonal = _gaussian(
      ((end.dy - start.dy) / max(0.001, (end.dx - start.dx).abs()) - 0.18)
          .abs(),
      0.42,
    );
    final prior = _meanPrior(trace.thumbCanonical, PalmLineHypothesisType.head);
    final middleBand = _gaussian((mean.dy - 0.46).abs(), 0.17);
    final crossesPalm = _ramp(xSpan, 0.20, 0.66);
    final startsNearLife = _gaussianDistance(
      start,
      const Offset(0.25, 0.38),
      0.25,
    );
    final base =
        middleBand * 0.22 +
        max(horizontal, diagonal) * 0.16 +
        crossesPalm * 0.16 +
        startsNearLife * 0.08 +
        f.continuity * 0.10 +
        f.averageProbability * 0.08 +
        max(prior, f.anatomicalPriorScore) * 0.14 +
        _ramp(f.arcLength, 0.12, 0.48) * 0.06;
    final tooHigh = _ramp(0.28 - mean.dy, 0.0, 0.16) * 0.34;
    final tooLow = _ramp(mean.dy, 0.68, 0.88) * 0.34;
    final verticalPenalty = ySpan > xSpan * 1.2 ? 0.36 : 0.0;
    return (base * (1.0 - tooHigh - tooLow - verticalPenalty)).clamp(0.0, 1.0);
  }

  static double _scoreFate(_TraceWork trace, PalmLineTraceFeatures f) {
    final oriented = _orientForTargets(
      trace.thumbCanonical,
      const Offset(0.50, 0.94),
      const Offset(0.50, 0.18),
    );
    final start = oriented.start;
    final end = oriented.end;
    final mean = _meanPoint(trace.thumbCanonical);
    final xSpan = _spanX(trace.thumbCanonical);
    final ySpan = _spanY(trace.thumbCanonical);
    final vertical = _verticality(start, end);
    final prior = _meanPrior(trace.thumbCanonical, PalmLineHypothesisType.fate);
    final central = _gaussian((mean.dx - 0.50).abs(), 0.16);
    final verticalSpan = _ramp(ySpan, 0.18, 0.60);
    final base =
        central * 0.25 +
        vertical * 0.24 +
        verticalSpan * 0.16 +
        f.continuity * 0.08 +
        f.averageProbability * 0.06 +
        max(prior, f.anatomicalPriorScore * 0.85) * 0.13 +
        _softBand(mean.dy, 0.22, 0.88) * 0.08;
    final horizontalPenalty = xSpan > ySpan * 0.72 ? 0.44 : 0.0;
    final sidePenalty = (1.0 - central) * 0.24;
    final shortPenalty = _ramp(0.18 - ySpan, 0.0, 0.18) * 0.28;
    final score = base * (1.0 - horizontalPenalty - sidePenalty - shortPenalty);
    return score < 0.38 ? score * 0.72 : score.clamp(0.0, 1.0);
  }
}

class _TraceWork {
  const _TraceWork({
    required this.originalIndex,
    required this.evidence,
    required this.canonical,
    required this.thumbCanonical,
  });

  final int originalIndex;
  final PalmLineTraceEvidence evidence;
  final List<Offset> canonical;
  final List<Offset> thumbCanonical;
}

class _OrientedEnds {
  const _OrientedEnds(this.start, this.end);

  final Offset start;
  final Offset end;
}

class _AssignmentCandidate {
  const _AssignmentCandidate({
    required this.life,
    required this.heart,
    required this.head,
    required this.fate,
    required this.score,
  });

  final PalmLineHypothesis? life;
  final PalmLineHypothesis? heart;
  final PalmLineHypothesis? head;
  final PalmLineHypothesis? fate;
  final double score;
}

Offset _canonicalPoint(PalmGeometry? geometry, Offset p) {
  if (geometry == null || geometry.confidence <= 0.05) {
    return Offset(p.dx.clamp(0.0, 1.0), p.dy.clamp(0.0, 1.0));
  }
  return geometry.imageToPalm(p);
}

Offset _thumbCanonicalPoint(PalmGeometry? geometry, Offset p) {
  final palm = _canonicalPoint(geometry, p);
  if (geometry?.thumbSide == PalmThumbSide.right) {
    return Offset(1.0 - palm.dx, palm.dy);
  }
  return palm;
}

List<int> _crossingCounts(List<_TraceWork> traces) {
  final counts = List<int>.filled(traces.length, 0);
  for (var i = 0; i < traces.length; i++) {
    for (var j = i + 1; j < traces.length; j++) {
      if (_pathsCross(traces[i].evidence.points, traces[j].evidence.points)) {
        counts[i]++;
        counts[j]++;
      }
    }
  }
  return counts;
}

bool _pathsCross(List<Offset> a, List<Offset> b) {
  final aa = _sampleForCrossings(a);
  final bb = _sampleForCrossings(b);
  for (var i = 1; i < aa.length; i++) {
    for (var j = 1; j < bb.length; j++) {
      if (_segmentsIntersect(aa[i - 1], aa[i], bb[j - 1], bb[j])) {
        return true;
      }
    }
  }
  return false;
}

List<Offset> _sampleForCrossings(List<Offset> pts) {
  if (pts.length <= 36) return pts;
  final step = pts.length / 35.0;
  return [
    for (var i = 0; i < 36; i++)
      pts[(i * step).round().clamp(0, pts.length - 1)],
  ];
}

bool _segmentsIntersect(Offset a, Offset b, Offset c, Offset d) {
  final den = (b.dx - a.dx) * (d.dy - c.dy) - (b.dy - a.dy) * (d.dx - c.dx);
  if (den.abs() < 1e-6) return false;
  final ua =
      ((d.dx - c.dx) * (a.dy - c.dy) - (d.dy - c.dy) * (a.dx - c.dx)) / den;
  final ub =
      ((b.dx - a.dx) * (a.dy - c.dy) - (b.dy - a.dy) * (a.dx - c.dx)) / den;
  return ua > 0.02 && ua < 0.98 && ub > 0.02 && ub < 0.98;
}

double _estimateContinuity(List<Offset> points) {
  if (points.length < 3) return 1.0;
  final distances = <double>[];
  var total = 0.0;
  var gap = 0.0;
  for (var i = 1; i < points.length; i++) {
    final d = (points[i] - points[i - 1]).distance;
    distances.add(d);
    total += d;
  }
  final sorted = [...distances]..sort();
  final median = sorted[sorted.length ~/ 2];
  final gapThreshold = max(0.018, median * 2.8);
  for (final d in distances) {
    if (d > gapThreshold) gap += d;
  }
  return total <= 0 ? 0.0 : (1.0 - gap / total).clamp(0.0, 1.0);
}

double _meanBestPrior(List<Offset> points) {
  if (points.isEmpty) return 0.0;
  var sum = 0.0;
  for (final p in points) {
    sum += PalmLineHypothesisType.values
        .map((type) => _prior(type, p))
        .reduce(max);
  }
  return (sum / points.length).clamp(0.0, 1.0);
}

double _meanPrior(List<Offset> points, PalmLineHypothesisType type) {
  if (points.isEmpty) return 0.0;
  var sum = 0.0;
  for (final p in points) {
    sum += _prior(type, p);
  }
  return (sum / points.length).clamp(0.0, 1.0);
}

double _prior(PalmLineHypothesisType type, Offset p) => switch (type) {
  PalmLineHypothesisType.life =>
    _meanCurveFit([p], _lifeExpectedX, 0.15) *
        _softBand(p.dx, 0.02, 0.68) *
        _softBand(p.dy, 0.02, 1.02),
  PalmLineHypothesisType.heart =>
    _gaussian((p.dy - (0.23 + 0.035 * cos((p.dx - 0.5) * pi))).abs(), 0.12) *
        _softBand(p.dx, 0.06, 0.98),
  PalmLineHypothesisType.head =>
    _gaussian((p.dy - (0.39 + p.dx * 0.16)).abs(), 0.13) *
        _softBand(p.dx, 0.08, 0.98),
  PalmLineHypothesisType.fate =>
    _gaussian((p.dx - 0.50).abs(), 0.14) * _softBand(p.dy, 0.16, 0.94),
};

double _lifeExpectedX(double y) =>
    0.43 - 0.28 * sin((y * pi).clamp(0.0, pi)) + 0.07 * y + 0.03 * y * y;

double _meanCurveFit(
  List<Offset> points,
  double Function(double y) expectedX,
  double sigma,
) {
  if (points.isEmpty) return 0.0;
  var sum = 0.0;
  for (final p in points) {
    sum += _gaussian((p.dx - expectedX(p.dy)).abs(), sigma);
  }
  return (sum / points.length).clamp(0.0, 1.0);
}

_OrientedEnds _orientForTargets(
  List<Offset> points,
  Offset targetStart,
  Offset targetEnd,
) {
  final first = points.first;
  final last = points.last;
  final forward = (first - targetStart).distance + (last - targetEnd).distance;
  final backward = (last - targetStart).distance + (first - targetEnd).distance;
  return forward <= backward
      ? _OrientedEnds(first, last)
      : _OrientedEnds(last, first);
}

_OrientedEnds _orientForHorizontal(List<Offset> points) {
  final first = points.first;
  final last = points.last;
  return first.dx <= last.dx
      ? _OrientedEnds(first, last)
      : _OrientedEnds(last, first);
}

double _spanX(List<Offset> points) {
  var minX = double.infinity;
  var maxX = double.negativeInfinity;
  for (final p in points) {
    minX = min(minX, p.dx);
    maxX = max(maxX, p.dx);
  }
  return (maxX - minX).clamp(0.0, 1.0);
}

double _spanY(List<Offset> points) {
  var minY = double.infinity;
  var maxY = double.negativeInfinity;
  for (final p in points) {
    minY = min(minY, p.dy);
    maxY = max(maxY, p.dy);
  }
  return (maxY - minY).clamp(0.0, 1.0);
}

Offset _meanPoint(List<Offset> points) {
  if (points.isEmpty) return const Offset(0.5, 0.5);
  var x = 0.0;
  var y = 0.0;
  for (final p in points) {
    x += p.dx;
    y += p.dy;
  }
  return Offset(x / points.length, y / points.length);
}

double _fraction(List<Offset> points, bool Function(Offset p) test) {
  if (points.isEmpty) return 0.0;
  var count = 0;
  for (final p in points) {
    if (test(p)) count++;
  }
  return count / points.length;
}

double _horizontality(Offset a, Offset b) {
  final d = b - a;
  final len = d.distance;
  if (len <= 0.001) return 0.0;
  return (d.dx.abs() / len).clamp(0.0, 1.0);
}

double _verticality(Offset a, Offset b) {
  final d = b - a;
  final len = d.distance;
  if (len <= 0.001) return 0.0;
  return (d.dy.abs() / len).clamp(0.0, 1.0);
}

double _gaussianDistance(Offset a, Offset b, double sigma) =>
    _gaussian((a - b).distance, sigma);

double _gaussian(double distance, double sigma) {
  final s = max(0.001, sigma);
  return exp(-(distance * distance) / (2.0 * s * s)).clamp(0.0, 1.0);
}

double _softBand(double value, double minValue, double maxValue) {
  if (value >= minValue && value <= maxValue) return 1.0;
  final d = value < minValue ? minValue - value : value - maxValue;
  return (1.0 - d / 0.18).clamp(0.0, 1.0);
}

double _ramp(double value, double low, double high) {
  if (high <= low) return value >= high ? 1.0 : 0.0;
  return ((value - low) / (high - low)).clamp(0.0, 1.0);
}
