import 'dart:math';

import 'package:flutter/material.dart' show Offset;

import 'palm_line_extractor.dart';

enum TrackedPalmLineType { life, heart, head, fate, unknown }

class TrackedPalmLine {
  const TrackedPalmLine({
    required this.id,
    required this.type,
    required this.points,
    required this.arcLength,
    required this.curvature,
    required this.continuity,
    required this.averageConfidence,
    required this.sourceFragmentIds,
    required this.gapCount,
  });

  final String id;
  final TrackedPalmLineType type;
  final List<Offset> points;
  final double arcLength;
  final double curvature;
  final double continuity;
  final double averageConfidence;
  final List<int> sourceFragmentIds;
  final int gapCount;
}

class PalmLineMergeDecision {
  const PalmLineMergeDecision({
    required this.type,
    required this.fromFragmentId,
    required this.toFragmentId,
    required this.from,
    required this.to,
    required this.score,
    required this.gapDistance,
    required this.accepted,
  });

  final TrackedPalmLineType type;
  final int fromFragmentId;
  final int toFragmentId;
  final Offset from;
  final Offset to;
  final double score;
  final double gapDistance;
  final bool accepted;
}

class PalmLineGapBridge {
  const PalmLineGapBridge({
    required this.type,
    required this.from,
    required this.to,
    required this.distance,
    required this.score,
  });

  final TrackedPalmLineType type;
  final Offset from;
  final Offset to;
  final double distance;
  final double score;
}

class TrackedPalmLines {
  const TrackedPalmLines({
    this.life,
    this.heart,
    this.head,
    this.fate,
    this.unknown = const [],
    this.mergedFragments = const [],
    this.rejectedMerges = const [],
    this.gapBridges = const [],
    this.rawFragmentCount = 0,
  });

  final TrackedPalmLine? life;
  final TrackedPalmLine? heart;
  final TrackedPalmLine? head;
  final TrackedPalmLine? fate;
  final List<TrackedPalmLine> unknown;
  final List<TrackedPalmLine> mergedFragments;
  final List<PalmLineMergeDecision> rejectedMerges;
  final List<PalmLineGapBridge> gapBridges;
  final int rawFragmentCount;

  List<TrackedPalmLine> get majorLines => [
    if (life != null) life!,
    if (heart != null) heart!,
    if (head != null) head!,
    if (fate != null) fate!,
  ];

  List<TrackedPalmLine> get allLines => [...majorLines, ...unknown];

  static const empty = TrackedPalmLines();
}

class PalmLineTracker {
  PalmLineTracker._();

  static TrackedPalmLines track({
    required PalmGeometry? geometry,
    required List<List<Offset>> candidatePaths,
    List<List<Offset>> rejectedPaths = const [],
  }) {
    if (!_validGeometry(geometry) || candidatePaths.isEmpty) {
      return TrackedPalmLines.empty;
    }
    final g = geometry!;
    final fragments = <_Fragment>[];
    for (var i = 0; i < candidatePaths.length; i++) {
      final fragment = _Fragment.fromPath(i, candidatePaths[i], g);
      if (fragment != null && fragment.arcLength >= 0.018) {
        fragments.add(fragment);
      }
    }
    if (fragments.isEmpty) {
      return TrackedPalmLines(rawFragmentCount: candidatePaths.length);
    }

    final byType = <TrackedPalmLineType, List<_TrackCandidate>>{
      TrackedPalmLineType.life: [],
      TrackedPalmLineType.heart: [],
      TrackedPalmLineType.head: [],
      TrackedPalmLineType.fate: [],
      TrackedPalmLineType.unknown: [],
    };

    for (final fragment in fragments) {
      final assignment = _assignFragment(fragment, g);
      byType[assignment.type]!.add(
        _TrackCandidate.fromFragment(
          fragment,
          assignment.type,
          assignment.score,
        ),
      );
    }

    final rejectedMerges = <PalmLineMergeDecision>[];
    final gapBridges = <PalmLineGapBridge>[];
    final merged = <TrackedPalmLine>[];
    final unknown = <TrackedPalmLine>[];
    final pickedByType = <TrackedPalmLineType, TrackedPalmLine>{};

    for (final type in const [
      TrackedPalmLineType.life,
      TrackedPalmLineType.heart,
      TrackedPalmLineType.head,
      TrackedPalmLineType.fate,
    ]) {
      final tracks = _mergeType(
        type: type,
        tracks: byType[type]!,
        geometry: g,
        rejectedMerges: rejectedMerges,
        gapBridges: gapBridges,
      ).map((candidate) => _buildLine(candidate, type)).toList();
      merged.addAll(tracks);
      if (tracks.isEmpty) continue;
      tracks.sort((a, b) => _lineRank(b).compareTo(_lineRank(a)));
      final best = tracks.first;
      if (best.averageConfidence >= 0.28 && best.arcLength >= 0.045) {
        pickedByType[type] = best;
        unknown.addAll(
          tracks.skip(1).map((line) => _asUnknown(line, 'unknown_${line.id}')),
        );
      } else {
        unknown.addAll(
          tracks.map((line) => _asUnknown(line, 'unknown_${line.id}')),
        );
      }
    }

    for (final candidate in byType[TrackedPalmLineType.unknown]!) {
      final line = _buildLine(candidate, TrackedPalmLineType.unknown);
      merged.add(line);
      unknown.add(line);
    }

    return TrackedPalmLines(
      life: pickedByType[TrackedPalmLineType.life],
      heart: pickedByType[TrackedPalmLineType.heart],
      head: pickedByType[TrackedPalmLineType.head],
      fate: pickedByType[TrackedPalmLineType.fate],
      unknown: unknown,
      mergedFragments: merged,
      rejectedMerges: rejectedMerges.take(36).toList(),
      gapBridges: gapBridges,
      rawFragmentCount: fragments.length,
    );
  }

  static bool _validGeometry(PalmGeometry? geometry) {
    if (geometry == null) return false;
    if (geometry.confidence <= 0.05) return false;
    if (geometry.palmBounds.width <= 0.03) return false;
    if (geometry.wristY - geometry.fingerBaseY <= 0.06) return false;
    return true;
  }

  static _FragmentAssignment _assignFragment(
    _Fragment fragment,
    PalmGeometry g,
  ) {
    final scores = <TrackedPalmLineType, double>{
      for (final type in const [
        TrackedPalmLineType.life,
        TrackedPalmLineType.heart,
        TrackedPalmLineType.head,
        TrackedPalmLineType.fate,
      ])
        type: _fragmentScore(type, fragment, g),
    };
    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final best = ranked.first;
    final second = ranked.length > 1 ? ranked[1].value : 0.0;
    if (best.value < 0.36 || best.value - second < 0.035) {
      return const _FragmentAssignment(TrackedPalmLineType.unknown, 0.22);
    }
    return _FragmentAssignment(best.key, best.value);
  }

  static List<_TrackCandidate> _mergeType({
    required TrackedPalmLineType type,
    required List<_TrackCandidate> tracks,
    required PalmGeometry geometry,
    required List<PalmLineMergeDecision> rejectedMerges,
    required List<PalmLineGapBridge> gapBridges,
  }) {
    final working = tracks.map((track) => track.orientedFor(type)).toList();
    if (working.length < 2) return working;

    var iterations = 0;
    while (working.length > 1 && iterations < 24) {
      iterations++;
      _MergeProposal? best;
      final localRejected = <PalmLineMergeDecision>[];
      for (var i = 0; i < working.length; i++) {
        for (var j = i + 1; j < working.length; j++) {
          final proposal = _bestProposal(
            type,
            working[i],
            working[j],
            geometry,
          );
          if (proposal == null) continue;
          if (proposal.accepted) {
            if (best == null || proposal.score > best.score) {
              best = proposal;
            }
          } else if (proposal.score >= 0.30) {
            localRejected.add(proposal.toDecision(accepted: false));
          }
        }
      }
      if (best == null || best.score < _acceptThreshold(type)) {
        rejectedMerges.addAll(
          localRejected..sort((a, b) => b.score.compareTo(a.score)),
        );
        break;
      }

      rejectedMerges.addAll(localRejected.take(4));
      working
        ..remove(best.a)
        ..remove(best.b)
        ..add(best.merged);
      gapBridges.add(
        PalmLineGapBridge(
          type: type,
          from: best.fromImage,
          to: best.toImage,
          distance: best.distance,
          score: best.score,
        ),
      );
    }

    return working.map((track) => track.orientedFor(type)).toList();
  }

  static _MergeProposal? _bestProposal(
    TrackedPalmLineType type,
    _TrackCandidate a,
    _TrackCandidate b,
    PalmGeometry geometry,
  ) {
    _MergeProposal? best;
    for (final reverseA in const [false, true]) {
      for (final reverseB in const [false, true]) {
        final left = reverseA ? a.reversed() : a;
        final right = reverseB ? b.reversed() : b;
        final proposal = _scoreMerge(type, left, right, geometry, a, b);
        if (proposal == null) continue;
        if (best == null || proposal.score > best.score) {
          best = proposal;
        }
      }
    }
    return best;
  }

  static _MergeProposal? _scoreMerge(
    TrackedPalmLineType type,
    _TrackCandidate left,
    _TrackCandidate right,
    PalmGeometry geometry,
    _TrackCandidate originalA,
    _TrackCandidate originalB,
  ) {
    final end = left.palmPoints.last;
    final start = right.palmPoints.first;
    final gap = start - end;
    final distance = gap.distance;
    final maxGap = _maxGap(type);
    final hardMax = maxGap * 1.32;
    if (distance > hardMax) return null;

    final tanA = _endTangent(left.palmPoints);
    final tanB = _startTangent(right.palmPoints);
    final tangentDot = _dot(tanA, tanB);
    final gapDir = distance > 0.0001 ? gap / distance : tanA;
    final gapAlignment = ((_dot(tanA, gapDir) + _dot(tanB, gapDir)) * 0.5)
        .clamp(-1.0, 1.0);
    final region = min(
      min(
        _regionScore(type, end, geometry),
        _regionScore(type, start, geometry),
      ),
      _regionScore(
        type,
        Offset((end.dx + start.dx) * 0.5, (end.dy + start.dy) * 0.5),
        geometry,
      ),
    );
    final curvatureDelta = (left.curvature - right.curvature).abs();
    final curveScore = (1.0 - curvatureDelta / 1.15).clamp(0.0, 1.0);
    final distanceScore = (1.0 - distance / maxGap).clamp(0.0, 1.0);
    final tangentScore =
        ((((tangentDot + 1.0) * 0.5) * 0.70) +
                (gapAlignment.clamp(0.0, 1.0) * 0.30))
            .clamp(0.0, 1.0);
    final anatomicalOrder = _orderScore(type, left, right, geometry);

    var score =
        distanceScore * 0.34 +
        tangentScore * 0.26 +
        region * 0.22 +
        curveScore * 0.10 +
        anatomicalOrder * 0.08;

    if (distance > maxGap || tangentDot < -0.10 || region < 0.24) {
      score *= 0.55;
    }
    if (gapAlignment < -0.15) score *= 0.65;

    final accepted =
        score >= _acceptThreshold(type) &&
        distance <= maxGap &&
        tangentDot >= -0.10 &&
        region >= 0.24 &&
        anatomicalOrder >= 0.35;

    final merged = accepted
        ? _TrackCandidate(
            type: type,
            imagePoints: [...left.imagePoints, ...right.imagePoints],
            palmPoints: [...left.palmPoints, ...right.palmPoints],
            sourceFragmentIds: [
              ...left.sourceFragmentIds,
              ...right.sourceFragmentIds,
            ],
            sourceArcLength: left.sourceArcLength + right.sourceArcLength,
            gapDistanceSum:
                left.gapDistanceSum + right.gapDistanceSum + distance,
            gapCount:
                left.gapCount + right.gapCount + (distance > 0.010 ? 1 : 0),
            typeScore:
                (left.typeScore * left.sourceFragmentIds.length +
                    right.typeScore * right.sourceFragmentIds.length) /
                (left.sourceFragmentIds.length +
                    right.sourceFragmentIds.length),
          ).orientedFor(type)
        : left;

    return _MergeProposal(
      a: originalA,
      b: originalB,
      merged: merged,
      type: type,
      score: score.clamp(0.0, 1.0),
      distance: distance,
      fromImage: left.imagePoints.last,
      toImage: right.imagePoints.first,
      accepted: accepted,
    );
  }

  static double _acceptThreshold(TrackedPalmLineType type) {
    return switch (type) {
      TrackedPalmLineType.life => 0.58,
      TrackedPalmLineType.heart => 0.56,
      TrackedPalmLineType.head => 0.56,
      TrackedPalmLineType.fate => 0.57,
      TrackedPalmLineType.unknown => 1.0,
    };
  }

  static double _maxGap(TrackedPalmLineType type) {
    return switch (type) {
      TrackedPalmLineType.life => 0.18,
      TrackedPalmLineType.heart => 0.15,
      TrackedPalmLineType.head => 0.16,
      TrackedPalmLineType.fate => 0.14,
      TrackedPalmLineType.unknown => 0.0,
    };
  }

  static TrackedPalmLine _buildLine(
    _TrackCandidate candidate,
    TrackedPalmLineType type,
  ) {
    final arc = _arcLength(candidate.palmPoints);
    final curvature = _curvature(candidate.palmPoints);
    final trackedLength = arc + candidate.gapDistanceSum;
    final continuity = trackedLength <= 0
        ? 0.0
        : (candidate.sourceArcLength / trackedLength).clamp(0.0, 1.0);
    final smoothness = (1.0 - ((curvature - 1.0).abs() / 1.6)).clamp(0.0, 1.0);
    final lengthScore = (arc / _expectedLength(type)).clamp(0.0, 1.0);
    final confidence =
        candidate.typeScore * 0.42 +
        continuity * 0.25 +
        smoothness * 0.16 +
        lengthScore * 0.17;
    final sourceKey = candidate.sourceFragmentIds.join('_');
    return TrackedPalmLine(
      id: '${_typeName(type)}_$sourceKey',
      type: type,
      points: candidate.imagePoints,
      arcLength: arc,
      curvature: curvature,
      continuity: continuity,
      averageConfidence: confidence.clamp(0.0, 1.0),
      sourceFragmentIds: candidate.sourceFragmentIds,
      gapCount: candidate.gapCount,
    );
  }

  static TrackedPalmLine _asUnknown(TrackedPalmLine line, String id) {
    return TrackedPalmLine(
      id: id,
      type: TrackedPalmLineType.unknown,
      points: line.points,
      arcLength: line.arcLength,
      curvature: line.curvature,
      continuity: line.continuity,
      averageConfidence: line.averageConfidence,
      sourceFragmentIds: line.sourceFragmentIds,
      gapCount: line.gapCount,
    );
  }

  static double _lineRank(TrackedPalmLine line) {
    return line.averageConfidence * 0.72 +
        (line.arcLength / _expectedLength(line.type)).clamp(0.0, 1.0) * 0.28;
  }

  static double _expectedLength(TrackedPalmLineType type) {
    return switch (type) {
      TrackedPalmLineType.life => 0.58,
      TrackedPalmLineType.heart => 0.46,
      TrackedPalmLineType.head => 0.48,
      TrackedPalmLineType.fate => 0.42,
      TrackedPalmLineType.unknown => 0.35,
    };
  }

  static double _fragmentScore(
    TrackedPalmLineType type,
    _Fragment fragment,
    PalmGeometry geometry,
  ) {
    final region = fragment.meanRegionScore(type, geometry);
    final spanSum = max(0.001, fragment.xSpan + fragment.ySpan);
    final horizontal = fragment.xSpan / spanSum;
    final vertical = fragment.ySpan / spanSum;
    final lengthScore = (fragment.arcLength / _expectedLength(type)).clamp(
      0.0,
      1.0,
    );
    final curveBonus = ((fragment.curvature - 1.0) / 0.65).clamp(0.0, 1.0);

    return switch (type) {
      TrackedPalmLineType.life =>
        (region * 0.48 +
                vertical * 0.24 +
                curveBonus * 0.15 +
                lengthScore * 0.13)
            .clamp(0.0, 1.0),
      TrackedPalmLineType.heart =>
        (region * 0.54 + horizontal * 0.30 + lengthScore * 0.16).clamp(
          0.0,
          1.0,
        ),
      TrackedPalmLineType.head =>
        (region * 0.52 + horizontal * 0.29 + lengthScore * 0.19).clamp(
          0.0,
          1.0,
        ),
      TrackedPalmLineType.fate =>
        (region * 0.54 + vertical * 0.32 + lengthScore * 0.14).clamp(0.0, 1.0),
      TrackedPalmLineType.unknown => 0.0,
    };
  }

  static double _regionScore(
    TrackedPalmLineType type,
    Offset p,
    PalmGeometry geometry,
  ) {
    final x = p.dx.clamp(0.0, 1.0);
    final y = p.dy.clamp(0.0, 1.0);
    return switch (type) {
      TrackedPalmLineType.life => _lifeRegionScore(x, y, geometry),
      TrackedPalmLineType.heart =>
        _bell(y, 0.22, 0.22) * 0.76 + _softBand(x, 0.08, 0.95) * 0.24,
      TrackedPalmLineType.head =>
        _bell(y, 0.50, 0.24) * 0.74 + _softBand(x, 0.08, 0.95) * 0.26,
      TrackedPalmLineType.fate =>
        _bell(x, 0.50, 0.20) * 0.72 + _softBand(y, 0.18, 0.98) * 0.28,
      TrackedPalmLineType.unknown => 0.0,
    };
  }

  static double _lifeRegionScore(double x, double y, PalmGeometry geometry) {
    final leftThumb = geometry.thumbSide != PalmThumbSide.right;
    final sideCenter = leftThumb ? 0.26 : 0.74;
    final side = _bell(x, sideCenter, 0.28);
    final yScore = _softBand(y, 0.08, 1.02);
    final thenarY = _softBand(y, 0.18, 0.94);
    final notExtremeEdge = leftThumb
        ? _softBand(x, 0.03, 0.62)
        : _softBand(x, 0.38, 0.97);
    return (side * 0.44 +
            yScore * 0.25 +
            thenarY * 0.16 +
            notExtremeEdge * 0.15)
        .clamp(0.0, 1.0);
  }

  static double _orderScore(
    TrackedPalmLineType type,
    _TrackCandidate left,
    _TrackCandidate right,
    PalmGeometry geometry,
  ) {
    final a = left.palmPoints.first;
    final b = right.palmPoints.last;
    return switch (type) {
      TrackedPalmLineType.life => (b.dy >= a.dy - 0.08 ? 1.0 : 0.35),
      TrackedPalmLineType.heart => (b.dx >= a.dx - 0.08 ? 1.0 : 0.35),
      TrackedPalmLineType.head => (b.dx >= a.dx - 0.08 ? 1.0 : 0.35),
      TrackedPalmLineType.fate => (b.dy >= a.dy - 0.08 ? 1.0 : 0.35),
      TrackedPalmLineType.unknown => 0.0,
    };
  }

  static String _typeName(TrackedPalmLineType type) {
    return switch (type) {
      TrackedPalmLineType.life => 'life',
      TrackedPalmLineType.heart => 'heart',
      TrackedPalmLineType.head => 'head',
      TrackedPalmLineType.fate => 'fate',
      TrackedPalmLineType.unknown => 'unknown',
    };
  }
}

class _FragmentAssignment {
  const _FragmentAssignment(this.type, this.score);

  final TrackedPalmLineType type;
  final double score;
}

class _Fragment {
  const _Fragment({
    required this.id,
    required this.imagePoints,
    required this.palmPoints,
    required this.arcLength,
    required this.curvature,
    required this.mean,
    required this.xSpan,
    required this.ySpan,
  });

  static _Fragment? fromPath(int id, List<Offset> path, PalmGeometry geometry) {
    if (path.length < 2) return null;
    final palmPoints = path.map(geometry.imageToPalm).toList();
    var minX = 1.0;
    var maxX = 0.0;
    var minY = 1.0;
    var maxY = 0.0;
    var sumX = 0.0;
    var sumY = 0.0;
    for (final p in palmPoints) {
      minX = min(minX, p.dx);
      maxX = max(maxX, p.dx);
      minY = min(minY, p.dy);
      maxY = max(maxY, p.dy);
      sumX += p.dx;
      sumY += p.dy;
    }
    return _Fragment(
      id: id,
      imagePoints: List<Offset>.of(path),
      palmPoints: palmPoints,
      arcLength: _arcLength(palmPoints),
      curvature: _curvature(palmPoints),
      mean: Offset(sumX / palmPoints.length, sumY / palmPoints.length),
      xSpan: maxX - minX,
      ySpan: maxY - minY,
    );
  }

  final int id;
  final List<Offset> imagePoints;
  final List<Offset> palmPoints;
  final double arcLength;
  final double curvature;
  final Offset mean;
  final double xSpan;
  final double ySpan;

  double meanRegionScore(TrackedPalmLineType type, PalmGeometry geometry) {
    var total = 0.0;
    for (final p in palmPoints) {
      total += PalmLineTracker._regionScore(type, p, geometry);
    }
    return total / palmPoints.length;
  }
}

class _TrackCandidate {
  const _TrackCandidate({
    required this.type,
    required this.imagePoints,
    required this.palmPoints,
    required this.sourceFragmentIds,
    required this.sourceArcLength,
    required this.gapDistanceSum,
    required this.gapCount,
    required this.typeScore,
  });

  factory _TrackCandidate.fromFragment(
    _Fragment fragment,
    TrackedPalmLineType type,
    double typeScore,
  ) {
    return _TrackCandidate(
      type: type,
      imagePoints: fragment.imagePoints,
      palmPoints: fragment.palmPoints,
      sourceFragmentIds: [fragment.id],
      sourceArcLength: fragment.arcLength,
      gapDistanceSum: 0.0,
      gapCount: 0,
      typeScore: typeScore,
    );
  }

  final TrackedPalmLineType type;
  final List<Offset> imagePoints;
  final List<Offset> palmPoints;
  final List<int> sourceFragmentIds;
  final double sourceArcLength;
  final double gapDistanceSum;
  final int gapCount;
  final double typeScore;

  double get curvature => _curvature(palmPoints);

  _TrackCandidate reversed() {
    return _TrackCandidate(
      type: type,
      imagePoints: imagePoints.reversed.toList(),
      palmPoints: palmPoints.reversed.toList(),
      sourceFragmentIds: sourceFragmentIds.reversed.toList(),
      sourceArcLength: sourceArcLength,
      gapDistanceSum: gapDistanceSum,
      gapCount: gapCount,
      typeScore: typeScore,
    );
  }

  _TrackCandidate orientedFor(TrackedPalmLineType targetType) {
    if (palmPoints.length < 2) return this;
    final start = palmPoints.first;
    final end = palmPoints.last;
    final shouldReverse = switch (targetType) {
      TrackedPalmLineType.life => end.dy < start.dy,
      TrackedPalmLineType.fate => end.dy < start.dy,
      TrackedPalmLineType.heart => end.dx < start.dx,
      TrackedPalmLineType.head => end.dx < start.dx,
      TrackedPalmLineType.unknown => false,
    };
    return shouldReverse ? reversed() : this;
  }
}

class _MergeProposal {
  const _MergeProposal({
    required this.a,
    required this.b,
    required this.merged,
    required this.type,
    required this.score,
    required this.distance,
    required this.fromImage,
    required this.toImage,
    required this.accepted,
  });

  final _TrackCandidate a;
  final _TrackCandidate b;
  final _TrackCandidate merged;
  final TrackedPalmLineType type;
  final double score;
  final double distance;
  final Offset fromImage;
  final Offset toImage;
  final bool accepted;

  PalmLineMergeDecision toDecision({required bool accepted}) {
    return PalmLineMergeDecision(
      type: type,
      fromFragmentId: a.sourceFragmentIds.first,
      toFragmentId: b.sourceFragmentIds.first,
      from: fromImage,
      to: toImage,
      score: score,
      gapDistance: distance,
      accepted: accepted,
    );
  }
}

double _arcLength(List<Offset> points) {
  var length = 0.0;
  for (var i = 1; i < points.length; i++) {
    length += (points[i] - points[i - 1]).distance;
  }
  return length;
}

double _curvature(List<Offset> points) {
  if (points.length < 2) return 1.0;
  final arc = _arcLength(points);
  final chord = (points.last - points.first).distance;
  if (chord <= 0.0001) return 1.0;
  return (arc / chord).clamp(1.0, 4.0);
}

Offset _startTangent(List<Offset> points) {
  if (points.length < 2) return const Offset(1, 0);
  final end = min(points.length - 1, 4);
  return _unit(points[end] - points.first);
}

Offset _endTangent(List<Offset> points) {
  if (points.length < 2) return const Offset(1, 0);
  final start = max(0, points.length - 5);
  return _unit(points.last - points[start]);
}

Offset _unit(Offset v) {
  final d = v.distance;
  if (d <= 0.0001) return const Offset(1, 0);
  return v / d;
}

double _dot(Offset a, Offset b) => a.dx * b.dx + a.dy * b.dy;

double _bell(double value, double center, double radius) {
  final d = (value - center).abs();
  return (1.0 - d / max(0.001, radius)).clamp(0.0, 1.0);
}

double _softBand(double value, double minValue, double maxValue) {
  if (value >= minValue && value <= maxValue) return 1.0;
  final d = value < minValue ? minValue - value : value - maxValue;
  return (1.0 - d / 0.18).clamp(0.0, 1.0);
}
