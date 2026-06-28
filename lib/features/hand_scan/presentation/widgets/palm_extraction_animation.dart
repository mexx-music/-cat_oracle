import 'dart:math';
import 'dart:typed_data';

import 'package:cat_oracle/gen_l10n/app_localizations.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../../../features/palmistry/models/palm_trait.dart';
import '../../logic/palm_line_classifier.dart';
import '../../logic/palm_line_continuation.dart';
import '../../logic/palm_line_extractor.dart';
import '../../logic/palm_line_tracker.dart';
import '../../models/palm_extraction_phase.dart';

const _kDuration = 7200;

// ── Widget ────────────────────────────────────────────────────────────────────

class PalmExtractionAnimation extends StatefulWidget {
  const PalmExtractionAnimation({
    super.key,
    required this.imageBytes,
    this.extractionResult,
    this.traits = const [],
    this.reading = '',
    this.classificationResult,
    this.continuationResult,
  });

  final Uint8List imageBytes;
  final PalmLineExtractionResult? extractionResult;
  final List<PalmTrait> traits;
  final String reading;

  /// Pre-computed classification (may include continuation-extended life line).
  final PalmLineClassificationResult? classificationResult;

  /// Continuation tracking result for debug display.
  final PalmLineContinuationResult? continuationResult;

  static Future<bool> show(
    BuildContext context,
    Uint8List imageBytes, {
    PalmLineExtractionResult? extractionResult,
    List<PalmTrait> traits = const [],
    String reading = '',
    PalmLineClassificationResult? classificationResult,
    PalmLineContinuationResult? continuationResult,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black,
      builder: (_) => PalmExtractionAnimation(
        imageBytes: imageBytes,
        extractionResult: extractionResult,
        traits: traits,
        reading: reading,
        classificationResult: classificationResult,
        continuationResult: continuationResult,
      ),
    );
    return result ?? false;
  }

  @override
  State<PalmExtractionAnimation> createState() =>
      _PalmExtractionAnimationState();
}

// ── State ─────────────────────────────────────────────────────────────────────

class _PalmExtractionAnimationState extends State<PalmExtractionAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _mainCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _sparkCtrl;
  late final AnimationController _readingCtrl;
  late final List<Offset> _particles;

  bool _isDone = false;
  bool _showReadingPanel = false;
  int? _activeLineIndex;
  PalmLineClassificationResult? _debugClassification;

  // Computed once in _onMainStatus; split so the painter can colour them
  // differently (original = white, extension = dashed cyan-white).
  List<Offset>? get _debugOrigPath {
    final cont = widget.continuationResult;
    final path = _debugClassification?.lifeLinePath;
    if (path == null) return null;
    if (cont == null || !cont.wasExtended || cont.extensionPointCount <= 0) {
      return path;
    }
    final splitAt = (path.length - cont.extensionPointCount).clamp(
      0,
      path.length,
    );
    return path.sublist(0, splitAt);
  }

  List<Offset>? get _debugExtPath {
    final cont = widget.continuationResult;
    final path = _debugClassification?.lifeLinePath;
    if (path == null || cont == null || !cont.wasExtended) return null;
    final splitAt = (path.length - cont.extensionPointCount).clamp(
      0,
      path.length,
    );
    if (splitAt >= path.length) return null;
    return path.sublist(splitAt);
  }

  static const _lineColors = [
    Color(0xFFFF8A80), // life
    Color(0xFF00CFFF), // heart
    Color(0xFFDAB86E), // head
    Color(0xFFBD7FF5), // fate
  ];

  @override
  void initState() {
    super.initState();
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kDuration),
    )..addStatusListener(_onMainStatus);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _sparkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    )..repeat();
    _readingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    final rng = Random(17);
    _particles = List.generate(
      22,
      (_) => Offset(
        0.08 + rng.nextDouble() * 0.84,
        0.08 + rng.nextDouble() * 0.84,
      ),
    );
    _mainCtrl.forward();
  }

  void _onMainStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      // Prefer the pre-computed classification (with any continuation applied);
      // fall back to classifying fresh only when no external result provided.
      final debug =
          widget.classificationResult ??
          (widget.extractionResult?.hasRealData == true
              ? PalmLineClassifier.classify(widget.extractionResult!)
              : null);
      setState(() {
        _isDone = true;
        _debugClassification = debug;
      });
      // Auto-open reading panel after a brief pause so the 100% state is visible
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted && !_showReadingPanel && widget.traits.isNotEmpty) {
          _openReadingPanel();
        }
      });
    }
  }

  void _openReadingPanel() {
    setState(() => _showReadingPanel = true);
    _readingCtrl.forward();
  }

  void _finish({required bool completed}) {
    if (!mounted) return;
    Navigator.of(context).pop(completed);
  }

  void _showPipelineSheet(AppLocalizations l10n) {
    final er = widget.extractionResult;
    if (er == null) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (_) => _PipelineSheet(er: er, l10n: l10n),
    );
  }

  PalmExtractionPhase get _phase =>
      PalmExtractionPhase.fromProgress(_mainCtrl.value);

  List<String> _statusMessages(AppLocalizations l10n) {
    final v = _mainCtrl.value;
    final er = widget.extractionResult;
    final all = [
      if (v >= 2 / 8) l10n.palmExtractionStatusContrast,
      if (v >= 3 / 8 && er != null && er.hasRealData)
        l10n.palmExtractionStatusEdgeCount(er.edgePointCount),
      if (v >= 4 / 8) l10n.palmExtractionStatusEdges,
      if (v >= 4.5 / 8 && er != null && er.candidatePaths.isNotEmpty)
        l10n.palmExtractionStatusPathCount(er.candidatePaths.length),
      if (v >= 5 / 8) l10n.palmExtractionStatusVectors,
      if (v >= 6 / 8 && er != null && er.hasRealData)
        l10n.palmExtractionStatusConfidence((er.confidence * 100).round()),
      if (v >= 7 / 8) l10n.palmExtractionStatusClassified,
    ];
    return all.length > 4 ? all.sublist(all.length - 4) : all;
  }

  String _phaseLabel(
    AppLocalizations l10n,
    PalmExtractionPhase phase,
  ) => switch (phase) {
    PalmExtractionPhase.imageLoaded => l10n.palmExtractionPhaseImageLoaded,
    PalmExtractionPhase.optimizing => l10n.palmExtractionPhaseOptimizing,
    PalmExtractionPhase.palmDetected => l10n.palmExtractionPhasePalmDetected,
    PalmExtractionPhase.edgeDetection => l10n.palmExtractionPhaseEdges,
    PalmExtractionPhase.lineExtraction => l10n.palmExtractionPhaseLines,
    PalmExtractionPhase.geometricAnalysis => l10n.palmExtractionPhaseGeometry,
    PalmExtractionPhase.gattoConfirms => l10n.palmExtractionPhaseGattoConfirm,
    PalmExtractionPhase.complete => l10n.palmExtractionPhaseComplete,
  };

  bool get _classificationUncertain {
    final er = widget.extractionResult;
    if (!_isDone || er == null || !er.hasRealData) return false;
    final c = _debugClassification;
    if (c == null) return true;
    final strongest = max(
      max(c.lifeLineConfidence, c.heartLineConfidence),
      max(c.headLineConfidence, c.fateLineConfidence),
    );
    return strongest < 0.25;
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _pulseCtrl.dispose();
    _sparkCtrl.dispose();
    _readingCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Material(
            color: const Color(0xFF060310),
            child: Stack(
              children: [
                const _NebulaBackground(),
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedBuilder(
                        animation: Listenable.merge([
                          _mainCtrl,
                          _pulseCtrl,
                          _sparkCtrl,
                          _readingCtrl,
                        ]),
                        builder: (context, _) {
                          final progress = _mainCtrl.value;
                          final phase = _phase;
                          final isWide = constraints.maxWidth >= 580;
                          final imageHeight = isWide
                              ? (screenHeight * 0.50).clamp(260.0, 450.0)
                              : (screenHeight * 0.46).clamp(220.0, 400.0);
                          final readingT = _readingCtrl.value;
                          const readingPanelWidth = 340.0;

                          // Metric computations
                          int lineQ(double start, int target) =>
                              progress < start
                              ? 0
                              : (((progress - start) * 8).clamp(0.0, 1.0) *
                                        target)
                                    .round();
                          final lifeQ = lineQ(4 / 8, 84);
                          final heartQ = lineQ(4.5 / 8, 76);
                          final headQ = lineQ(5 / 8, 91);
                          final fateQ = lineQ(5.5 / 8, 68);
                          final contrast = progress < 2 / 8
                              ? 0
                              : (((progress - 2 / 8) / (5 / 8)).clamp(
                                          0.0,
                                          1.0,
                                        ) *
                                        94)
                                    .round();
                          final clarity = progress < 2 / 8
                              ? 0
                              : (((progress - 2 / 8) / (5 / 8)).clamp(
                                          0.0,
                                          1.0,
                                        ) *
                                        88)
                                    .round();
                          final vecCount =
                              (progress >= 4 / 8 ? 1 : 0) +
                              (progress >= 4.5 / 8 ? 1 : 0) +
                              (progress >= 5 / 8 ? 1 : 0) +
                              (progress >= 5.5 / 8 ? 1 : 0);

                          // Available image width
                          final double availableImageWidth;
                          if (isWide && _showReadingPanel) {
                            availableImageWidth =
                                (constraints.maxWidth -
                                        readingPanelWidth * readingT -
                                        24.0)
                                    .clamp(100.0, 800.0);
                          } else if (isWide) {
                            availableImageWidth = (constraints.maxWidth - 196.0)
                                .clamp(100.0, 800.0);
                          } else {
                            availableImageWidth = constraints.maxWidth;
                          }

                          final imageArea = _buildImageStack(
                            progress: progress,
                            imageHeight: imageHeight,
                            availableWidth: availableImageWidth,
                            l10n: l10n,
                          );

                          // ── Desktop with reading panel ───────────────────
                          if (isWide && _showReadingPanel) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _Header(
                                  l10n: l10n,
                                  onAbort: () => _finish(completed: false),
                                  onPipeline: widget.extractionResult != null
                                      ? () => _showPipelineSheet(l10n)
                                      : null,
                                ),
                                SizedBox(
                                  height: imageHeight,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: imageArea,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Reading panel slides in from right
                                      SizedBox(
                                        width: readingPanelWidth * readingT,
                                        child: ClipRect(
                                          child: SizedBox(
                                            width: readingPanelWidth,
                                            child: _buildReadingPanelContent(
                                              l10n,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (readingT > 0.01)
                                        const SizedBox(width: 8),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: _PhaseCard(
                                    emoji: phase.emoji,
                                    label: _phaseLabel(l10n, phase),
                                    phase: phase,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: _ProgressBar(progress: progress),
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (final msg in _statusMessages(l10n))
                                          _StatusLine(text: msg),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          // ── Desktop without reading panel ────────────────
                          if (isWide) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _Header(
                                  l10n: l10n,
                                  onAbort: () => _finish(completed: false),
                                  onPipeline: widget.extractionResult != null
                                      ? () => _showPipelineSheet(l10n)
                                      : null,
                                ),
                                _buildDesktopRow(
                                  l10n: l10n,
                                  imageArea: imageArea,
                                  imageHeight: imageHeight,
                                  lifeQ: lifeQ,
                                  heartQ: heartQ,
                                  headQ: headQ,
                                  fateQ: fateQ,
                                  contrast: contrast,
                                  clarity: clarity,
                                  vecCount: vecCount,
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: _PhaseCard(
                                    emoji: phase.emoji,
                                    label: _phaseLabel(l10n, phase),
                                    phase: phase,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: _ProgressBar(progress: progress),
                                ),
                                const SizedBox(height: 6),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        for (final msg in _statusMessages(l10n))
                                          _StatusLine(text: msg),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    10,
                                    0,
                                    10,
                                    14,
                                  ),
                                  child: AnimatedOpacity(
                                    opacity: _isDone ? 1.0 : 0.0,
                                    duration: const Duration(milliseconds: 400),
                                    child: SizedBox(
                                      height: 52,
                                      child: FilledButton.icon(
                                        onPressed: _isDone
                                            ? _openReadingPanel
                                            : null,
                                        icon: const Icon(
                                          Icons.auto_awesome_rounded,
                                          size: 18,
                                        ),
                                        label: Text(
                                          l10n.palmExtractionCompleteButton,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFFDAB86E,
                                          ),
                                          foregroundColor: const Color(
                                            0xFF060310,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          // ── Mobile ───────────────────────────────────────
                          final mobileMainContent = Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _Header(
                                l10n: l10n,
                                onAbort: () => _finish(completed: false),
                                onPipeline: widget.extractionResult != null
                                    ? () => _showPipelineSheet(l10n)
                                    : null,
                              ),
                              _buildMobileImage(imageArea: imageArea),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: _buildMobileMetrics(
                                  l10n: l10n,
                                  contrast: contrast,
                                  clarity: clarity,
                                  vecCount: vecCount,
                                  lifeQ: lifeQ,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: _PhaseCard(
                                  emoji: phase.emoji,
                                  label: _phaseLabel(l10n, phase),
                                  phase: phase,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: _ProgressBar(progress: progress),
                              ),
                              const SizedBox(height: 6),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (final msg in _statusMessages(l10n))
                                        _StatusLine(text: msg),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  0,
                                  10,
                                  14,
                                ),
                                child: AnimatedOpacity(
                                  opacity: (_isDone && !_showReadingPanel)
                                      ? 1.0
                                      : 0.0,
                                  duration: const Duration(milliseconds: 400),
                                  child: SizedBox(
                                    height: 52,
                                    child: FilledButton.icon(
                                      onPressed: (_isDone && !_showReadingPanel)
                                          ? _openReadingPanel
                                          : null,
                                      icon: const Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 18,
                                      ),
                                      label: Text(
                                        l10n.palmExtractionCompleteButton,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFDAB86E,
                                        ),
                                        foregroundColor: const Color(
                                          0xFF060310,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );

                          if (!_showReadingPanel) return mobileMainContent;

                          // Reading panel slides up as overlay
                          final panelHeight = constraints.maxHeight * 0.76;
                          return Stack(
                            children: [
                              Positioned.fill(child: mobileMainContent),
                              // Dim backdrop
                              IgnorePointer(
                                ignoring: readingT < 0.05,
                                child: Container(
                                  color: Color.fromRGBO(
                                    0,
                                    0,
                                    0,
                                    (0.52 * readingT).clamp(0.0, 0.52),
                                  ),
                                ),
                              ),
                              // Panel
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Transform.translate(
                                  offset: Offset(
                                    0,
                                    panelHeight * (1.0 - readingT),
                                  ),
                                  child: SizedBox(
                                    height: panelHeight,
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(22),
                                      ),
                                      child: _buildReadingPanelContent(l10n),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Reading panel ──────────────────────────────────────────────────────────

  Widget _buildReadingPanelContent(AppLocalizations l10n) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF090520),
        border: Border(
          top: BorderSide(color: Color(0x55DAB86E), width: 0.8),
          left: BorderSide(color: Color(0x33DAB86E), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 10, 6),
            child: Row(
              children: [
                Text(
                  l10n.palmExtractionReadingTitle,
                  style: const TextStyle(
                    color: Color(0xFFFFE9B0),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _finish(completed: false),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0x22FFFFFF),
                    foregroundColor: const Color(0x88E6DDF8),
                    minimumSize: const Size(32, 32),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0x33DAB86E), height: 1, thickness: 0.5),
          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Symbolic note chip
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0x2A2E1A4A),
                        border: Border.all(
                          color: const Color(0x66DAB86E),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        l10n.palmistrySymbolicNote,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFFE6DDF8),
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Trait tiles (tappable → pulses corresponding line)
                  for (int i = 0; i < widget.traits.length; i++) ...[
                    _ReadingTraitTile(
                      trait: widget.traits[i],
                      isActive: _activeLineIndex == i,
                      lineColor: _lineColors[i % _lineColors.length],
                      l10n: l10n,
                      onTap: () => setState(() {
                        _activeLineIndex = _activeLineIndex == i ? null : i;
                      }),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Overall reading
                  const Divider(
                    color: Color(0x44DAB86E),
                    height: 1,
                    thickness: 0.5,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.palmistryOverallReading,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: const Color(0xFFFFE9B0),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0x3A1A0F30), Color(0x2A14102A)],
                      ),
                      border: Border.all(color: const Color(0x77DAB86E)),
                    ),
                    child: Text(
                      widget.reading,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFF3ECFF),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.palmistryDisclaimer,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0x88E6DDF8),
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => _finish(completed: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE5D0A0),
                        side: const BorderSide(color: Color(0x66DAB86E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.palmistryClose),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Layout helpers ─────────────────────────────────────────────────────────

  Widget _buildImageStack({
    required double progress,
    required double imageHeight,
    required double availableWidth,
    required AppLocalizations l10n,
  }) {
    final er = widget.extractionResult;
    final aspect = (er != null && er.imageWidth >= 8 && er.imageHeight >= 8)
        ? er.imageWidth / er.imageHeight
        : 3 / 4.0;

    final double dispW, dispH;
    if (availableWidth / aspect <= imageHeight) {
      dispW = availableWidth;
      dispH = availableWidth / aspect;
    } else {
      dispH = imageHeight;
      dispW = imageHeight * aspect;
    }

    return SizedBox(
      height: imageHeight,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: dispW,
            height: dispH,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(widget.imageBytes, fit: BoxFit.fill),
                Container(color: const Color(0x88060310)),
                CustomPaint(
                  painter: PalmOverlayPainter(
                    progress: progress,
                    pulse: _pulseCtrl.value,
                    spark: _sparkCtrl.value,
                    particles: _particles,
                    isDone: _isDone,
                    extractionResult: widget.extractionResult,
                    activeLineIndex: _activeLineIndex,
                    debugLifePath: _isDone ? _debugOrigPath : null,
                    debugExtensionPath: _isDone ? _debugExtPath : null,
                  ),
                ),
                _PercentageOverlay(progress: progress),
                if (_isDone)
                  _CompletionSeal(label: l10n.palmExtractionReleased),
                if (_classificationUncertain)
                  _UncertainClassificationBadge(
                    label: l10n.palmExtractionClassificationUncertain,
                  ),
                if (_isDone &&
                    _debugClassification != null &&
                    widget.extractionResult != null)
                  _LifeLineDebugPanel(
                    classResult: _debugClassification!,
                    extractionResult: widget.extractionResult!,
                    continuationResult: widget.continuationResult,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopRow({
    required AppLocalizations l10n,
    required Widget imageArea,
    required double imageHeight,
    required int lifeQ,
    required int heartQ,
    required int headQ,
    required int fateQ,
    required int contrast,
    required int clarity,
    required int vecCount,
  }) {
    const panelWidth = 82.0;
    return SizedBox(
      height: imageHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(width: 8),
          SizedBox(
            width: panelWidth,
            child: _SidePanel(
              title: l10n.palmExtractionPanelLines,
              metrics: [
                _SidePanelMetric(
                  label: l10n.palmExtractionPanelLife,
                  value: lifeQ > 0 ? '$lifeQ' : '--',
                  fraction: lifeQ / 100.0,
                  color: const Color(0xFFFF8A80),
                ),
                _SidePanelMetric(
                  label: l10n.palmExtractionPanelHeart,
                  value: heartQ > 0 ? '$heartQ' : '--',
                  fraction: heartQ / 100.0,
                  color: const Color(0xFF00CFFF),
                ),
                _SidePanelMetric(
                  label: l10n.palmExtractionPanelHead,
                  value: headQ > 0 ? '$headQ' : '--',
                  fraction: headQ / 100.0,
                  color: const Color(0xFFDAB86E),
                ),
                _SidePanelMetric(
                  label: l10n.palmExtractionPanelFate,
                  value: fateQ > 0 ? '$fateQ' : '--',
                  fraction: fateQ / 100.0,
                  color: const Color(0xFFBD7FF5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageArea,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: panelWidth,
            child: _SidePanel(
              title: l10n.palmExtractionPanelStatus,
              metrics: [
                _SidePanelMetric(
                  label: l10n.palmExtractionPanelContrast,
                  value: '$contrast%',
                  fraction: contrast / 100.0,
                  color: const Color(0xFF00CFFF),
                ),
                _SidePanelMetric(
                  label: l10n.palmExtractionPanelClarity,
                  value: '$clarity%',
                  fraction: clarity / 100.0,
                  color: const Color(0xFFDAB86E),
                ),
                _SidePanelMetric(
                  label: l10n.palmExtractionPanelVector,
                  value: '$vecCount/4',
                  fraction: vecCount / 4.0,
                  color: const Color(0xFFBD7FF5),
                ),
                _SidePanelMetric(
                  label: l10n.palmExtractionPanelQuality,
                  value: vecCount >= 3 ? 'OK' : '--',
                  fraction: vecCount >= 3 ? 1.0 : vecCount / 4.0,
                  color: vecCount >= 3
                      ? const Color(0xFF8AE07A)
                      : const Color(0x44FFFFFF),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMobileImage({required Widget imageArea}) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
      child: imageArea,
    );
  }

  Widget _buildMobileMetrics({
    required AppLocalizations l10n,
    required int contrast,
    required int clarity,
    required int vecCount,
    required int lifeQ,
  }) {
    return Row(
      children: [
        _MetricChip(
          label: l10n.palmExtractionPanelContrast,
          value: '$contrast%',
          color: const Color(0xFF00CFFF),
        ),
        const SizedBox(width: 5),
        _MetricChip(
          label: l10n.palmExtractionPanelClarity,
          value: '$clarity%',
          color: const Color(0xFFDAB86E),
        ),
        const SizedBox(width: 5),
        _MetricChip(
          label: l10n.palmExtractionPanelVector,
          value: '$vecCount/4',
          color: const Color(0xFFBD7FF5),
        ),
        const SizedBox(width: 5),
        _MetricChip(
          label: l10n.palmExtractionPanelQuality,
          value: vecCount >= 4 ? 'OK' : '--',
          color: vecCount >= 4
              ? const Color(0xFF8AE07A)
              : const Color(0x55FFFFFF),
        ),
      ],
    );
  }
}

// ── Reading trait tile ─────────────────────────────────────────────────────────

class _ReadingTraitTile extends StatelessWidget {
  const _ReadingTraitTile({
    required this.trait,
    required this.isActive,
    required this.lineColor,
    required this.l10n,
    required this.onTap,
  });

  final PalmTrait trait;
  final bool isActive;
  final Color lineColor;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isActive
            ? lineColor.withValues(alpha: 0.10)
            : const Color(0x12FFFFFF),
        border: Border.all(
          color: isActive
              ? lineColor.withValues(alpha: 0.75)
              : const Color(0x22DAB86E),
          width: isActive ? 1.2 : 0.7,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: lineColor.withValues(alpha: 0.22),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(trait.symbol, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trait.title,
                            style: TextStyle(
                              color: isActive
                                  ? lineColor
                                  : const Color(0xFFFFE9B0),
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            l10n.palmistryTraitLabel.toUpperCase(),
                            style: TextStyle(
                              color: lineColor.withValues(
                                alpha: isActive ? 0.9 : 0.5,
                              ),
                              fontSize: 9,
                              letterSpacing: 1.6,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isActive ? Icons.lens_rounded : Icons.lens_outlined,
                      color: isActive ? lineColor : const Color(0x33FFFFFF),
                      size: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  trait.meaning,
                  style: const TextStyle(
                    color: Color(0xFFD8CCEE),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: lineColor.withValues(alpha: isActive ? 0.08 : 0.04),
                    border: Border.all(
                      color: lineColor.withValues(
                        alpha: isActive ? 0.35 : 0.15,
                      ),
                    ),
                  ),
                  child: Text(
                    trait.catMessage,
                    style: const TextStyle(
                      color: Color(0xCCF3ECFF),
                      fontSize: 11,
                      height: 1.4,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Debug: life line measurement panel ───────────────────────────────────────

class _LifeLineDebugPanel extends StatelessWidget {
  const _LifeLineDebugPanel({
    required this.classResult,
    required this.extractionResult,
    this.continuationResult,
  });

  final PalmLineClassificationResult classResult;
  final PalmLineExtractionResult extractionResult;
  final PalmLineContinuationResult? continuationResult;

  @override
  Widget build(BuildContext context) {
    final path = classResult.lifeLinePath;
    final arcLen = classResult.lifeLineLengthRatio;
    final conf = classResult.lifeLineConfidence;
    final cont = continuationResult;

    double ySpan = 0.0;
    Offset? startPt, endPt;
    if (path != null && path.isNotEmpty) {
      double minY = double.infinity, maxY = double.negativeInfinity;
      for (final p in path) {
        if (p.dy < minY) minY = p.dy;
        if (p.dy > maxY) maxY = p.dy;
      }
      ySpan = maxY - minY;
      startPt = path.first;
      endPt = path.last;
    }

    final roiFrac = extractionResult.hasRoi
        ? (extractionResult.roiBottom! - extractionResult.roiTop!) /
              extractionResult.imageHeight
        : null;

    final classification = arcLen < 0.38
        ? 'SHORT  (< 0.38)'
        : arcLen < 0.62
        ? 'MEDIUM (0.38–0.62)'
        : 'LONG   (≥ 0.62)';
    final classColor = arcLen < 0.38
        ? const Color(0xFFFF4455)
        : arcLen < 0.62
        ? const Color(0xFFFFAA22)
        : const Color(0xFF44FF88);

    const mono = TextStyle(
      color: Color(0xFFE0E0E0),
      fontSize: 10,
      fontFeatures: [FontFeature.tabularFigures()],
      height: 1.6,
    );
    const label = TextStyle(
      color: Color(0xFF88AACC),
      fontSize: 10,
      fontFeatures: [FontFeature.tabularFigures()],
      height: 1.6,
    );

    Widget row(String lbl, String val, {Color? valColor}) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(lbl, style: label),
        Text(val, style: mono.copyWith(color: valColor)),
      ],
    );

    // Determine which end marker label to show
    final hasExt = cont != null && cont.wasExtended;
    final endLabel = hasExt ? 'OldEnd 🟠  ' : 'End    🔴  ';
    final endColor = hasExt ? const Color(0xFFFF8800) : const Color(0xFFFF4455);

    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: const Color(0xDD060310),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: classColor.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'LEBENSLINIE  DEBUG',
              style: TextStyle(
                color: Color(0xFFDAB86E),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 4),
            if (path == null)
              const Text(
                '⚠  nicht erkannt',
                style: TextStyle(color: Color(0xFFFF4455), fontSize: 10),
              )
            else ...[
              row('Arc Length  ', arcLen.toStringAsFixed(4)),
              row('ySpan       ', ySpan.toStringAsFixed(4)),
              row('Confidence  ', '${(conf * 100).toStringAsFixed(1)} %'),
              if (roiFrac != null)
                row('ROI Height  ', roiFrac.toStringAsFixed(4)),
              if (startPt != null)
                row(
                  'Start       ',
                  '(${startPt.dx.toStringAsFixed(3)}, '
                      '${startPt.dy.toStringAsFixed(3)})',
                  valColor: const Color(0xFF44FF88),
                ),
              if (endPt != null && !hasExt)
                row(
                  endLabel,
                  '(${endPt.dx.toStringAsFixed(3)}, '
                  '${endPt.dy.toStringAsFixed(3)})',
                  valColor: endColor,
                ),
              row('Pts in path ', '${path.length}'),
            ],
            // ── Continuation section ──────────────────────────────────────
            if (cont != null) ...[
              const SizedBox(height: 3),
              const Divider(
                color: Color(0x33FFFFFF),
                height: 6,
                thickness: 0.4,
              ),
              row(
                'Cont.       ',
                cont.wasExtended ? 'YES' : 'NO',
                valColor: cont.wasExtended
                    ? const Color(0xFF00EEFF)
                    : const Color(0xFFFF4455),
              ),
              if (cont.wasExtended) ...[
                row(
                  'OldEnd Y    ',
                  cont.oldEndY.toStringAsFixed(3),
                  valColor: const Color(0xFFFF8800),
                ),
                row(
                  'NewEnd Y 🔴 ',
                  cont.newEndY.toStringAsFixed(3),
                  valColor: const Color(0xFFFF2244),
                ),
                row('Ext. Pts    ', '${cont.extensionPointCount}'),
                row('Ext. ArcLen ', cont.extensionArcLength.toStringAsFixed(4)),
                row(
                  'Ext. Conf.  ',
                  '${(cont.extensionConfidence * 100).toStringAsFixed(0)} %',
                ),
              ] else if (cont.skipReason != null)
                row('Skip reason ', cont.skipReason!),
            ],
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: classColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: classColor, width: 0.8),
              ),
              child: Text(
                classification,
                style: TextStyle(
                  color: classColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              hasExt ? '🟢 Start  🟠 OldEnd  🔴 NewEnd' : '🟢 Start  🔴 End',
              style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Background ────────────────────────────────────────────────────────────────

class _NebulaBackground extends StatelessWidget {
  const _NebulaBackground();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.2, -0.4),
            radius: 1.2,
            colors: [Color(0xFF120830), Color(0xFF090520), Color(0xFF060310)],
          ),
        ),
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.l10n, required this.onAbort, this.onPipeline});

  final AppLocalizations l10n;
  final VoidCallback onAbort;
  final VoidCallback? onPipeline;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.palmExtractionTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  l10n.palmExtractionSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0x99E6DDF8),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          if (onPipeline != null) ...[
            IconButton(
              onPressed: onPipeline,
              tooltip: l10n.palmExtractionPipelineButton,
              icon: const Icon(Icons.info_outline_rounded, size: 18),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0x22FFFFFF),
                foregroundColor: const Color(0x99BD7FF5),
                minimumSize: const Size(36, 36),
              ),
            ),
            const SizedBox(width: 6),
          ],
          IconButton(
            onPressed: onAbort,
            icon: const Icon(Icons.close_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0x22FFFFFF),
              foregroundColor: const Color(0x77E6DDF8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Percentage overlay ────────────────────────────────────────────────────────

class _PercentageOverlay extends StatelessWidget {
  const _PercentageOverlay({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Positioned(
      bottom: 10,
      right: 14,
      child: Text(
        '$pct%',
        style: const TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w900,
          color: Color(0xCCDAB86E),
          letterSpacing: -2,
          height: 1.0,
          shadows: [
            Shadow(
              color: Color(0xCC060310),
              blurRadius: 16,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Completion seal ───────────────────────────────────────────────────────────

class _CompletionSeal extends StatelessWidget {
  const _CompletionSeal({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.elasticOut,
      builder: (_, t, __) {
        final opacity = (t * 2).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.65,
                colors: [Color(0x448AE07A), Color(0x00000000)],
              ),
            ),
            child: Center(
              child: Transform.scale(
                scale: t.clamp(0.0, 1.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xCC060310),
                        border: Border.all(
                          color: const Color(0xFF8AE07A),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF8AE07A,
                            ).withValues(alpha: 0.45),
                            blurRadius: 22,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Text('🐾', style: TextStyle(fontSize: 42)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xCC060310),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF8AE07A),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF8AE07A,
                            ).withValues(alpha: 0.25),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Color(0xFF8AE07A),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UncertainClassificationBadge extends StatelessWidget {
  const _UncertainClassificationBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 16,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xDD060310),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xAADAB86E), width: 0.8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFFFE9B0),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Side panel ────────────────────────────────────────────────────────────────

class _SidePanelMetric {
  const _SidePanelMetric({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });

  final String label;
  final String value;
  final double fraction;
  final Color color;
}

class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.title, required this.metrics});

  final String title;
  final List<_SidePanelMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0x14FFFFFF),
        border: Border.all(color: const Color(0x1AFFFFFF), width: 0.5),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0x99DAB86E),
              fontSize: 8,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          const Divider(color: Color(0x22DAB86E), thickness: 0.5, height: 1),
          const SizedBox(height: 8),
          for (int i = 0; i < metrics.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _MetricBar(
              label: metrics[i].label,
              value: metrics[i].value,
              fraction: metrics[i].fraction,
              color: metrics[i].color,
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricBar extends StatelessWidget {
  const _MetricBar({
    required this.label,
    required this.value,
    required this.fraction,
    required this.color,
  });

  final String label;
  final String value;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 7,
                color: color.withValues(alpha: 0.7),
                letterSpacing: 0.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 9,
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 3,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.8)),
          ),
        ),
      ],
    );
  }
}

// ── Compact metric chip (mobile) ──────────────────────────────────────────────

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: const Color(0x18FFFFFF),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 7,
                color: color.withValues(alpha: 0.7),
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Phase card ────────────────────────────────────────────────────────────────

class _PhaseCard extends StatelessWidget {
  const _PhaseCard({
    required this.emoji,
    required this.label,
    required this.phase,
  });

  final String emoji;
  final String label;
  final PalmExtractionPhase phase;

  @override
  Widget build(BuildContext context) {
    final isGatto = phase == PalmExtractionPhase.gattoConfirms;
    final isDone = phase == PalmExtractionPhase.complete;
    final accent = isDone
        ? const Color(0xFF8AE07A)
        : isGatto
        ? const Color(0xFFDAB86E)
        : const Color(0xFF00CFFF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0x1A060310),
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent,
              boxShadow: [
                BoxShadow(color: accent.withValues(alpha: 0.6), blurRadius: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress bar ──────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ANALYSE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0x55DAB86E),
                letterSpacing: 2.2,
                fontSize: 8,
              ),
            ),
            Text(
              '$pct %',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: const Color(0xFFDAB86E),
                letterSpacing: 0.8,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: const Color(0x22DAB86E),
            valueColor: const AlwaysStoppedAnimation(Color(0xFFDAB86E)),
          ),
        ),
      ],
    );
  }
}

// ── Status line ───────────────────────────────────────────────────────────────

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 12,
            color: Color(0xFF8AE07A),
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0x99E6DDF8),
              letterSpacing: 0.3,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── CustomPainter ─────────────────────────────────────────────────────────────

class PalmOverlayPainter extends CustomPainter {
  const PalmOverlayPainter({
    required this.progress,
    required this.pulse,
    required this.spark,
    required this.particles,
    required this.isDone,
    this.extractionResult,
    this.activeLineIndex,
    this.debugLifePath,
    this.debugExtensionPath,
  });

  final double progress;
  final double pulse;
  final double spark;
  final List<Offset> particles;
  final bool isDone;
  final PalmLineExtractionResult? extractionResult;
  final int? activeLineIndex;

  /// Original (pre-continuation) life line path — drawn solid white.
  final List<Offset>? debugLifePath;

  /// Extension points appended by continuation — drawn dashed cyan-white.
  final List<Offset>? debugExtensionPath;

  static const _cyan = Color(0xFF00CFFF);
  static const _gold = Color(0xFFDAB86E);
  static const _violet = Color(0xFFBD7FF5);
  static const _green = Color(0xFF8AE07A);
  static const _lifeLine = Color(0xFFFF8A80);
  static const _heartLine = Color(0xFF00CFFF);
  static const _headLine = Color(0xFFDAB86E);
  static const _fateLine = Color(0xFFBD7FF5);

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawCornerMarkers(canvas, size);
    if (!isDone) _drawScanline(canvas, size);
    if (progress >= 3 / 8) _drawHandContour(canvas, size);
    if (progress >= 4 / 8) _drawPalmLines(canvas, size);
    if (kDebugMode && isDone) _drawTrackerDebug(canvas, size);
    if (progress >= 5 / 8) _drawParticles(canvas, size);
    if (kDebugMode && isDone) _drawPalmGeometryDebug(canvas, size);
    if (isDone) _drawCompletionRing(canvas, size);
    // Active line glow drawn on top of everything
    if (isDone && activeLineIndex != null) _drawActiveLineGlow(canvas, size);
    // Debug life line: original segment (white) + extension (dashed)
    if (isDone && debugLifePath != null) _drawDebugLifeLine(canvas, size);
    if (isDone &&
        debugExtensionPath != null &&
        debugExtensionPath!.isNotEmpty) {
      _drawDebugExtension(canvas, size);
    }
  }

  void _drawGrid(Canvas canvas, Size size) {
    final opacity = 0.06 + 0.03 * sin(pulse * 2 * pi);
    final paint = Paint()
      ..color = _violet.withValues(alpha: opacity)
      ..strokeWidth = 0.5;
    const spacing = 26.0;
    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawCornerMarkers(Canvas canvas, Size size) {
    final color = isDone ? _green : _cyan;
    final opacity = isDone
        ? 1.0
        : (0.6 + 0.3 * sin(pulse * 2 * pi)).clamp(0.0, 1.0);
    final strokeW = isDone ? 2.0 : 1.5;
    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke;
    const m = 2.0;
    final cl = size.width * 0.09;
    canvas
      ..drawLine(Offset(m, m), Offset(m + cl, m), paint)
      ..drawLine(Offset(m, m), Offset(m, m + cl), paint)
      ..drawLine(
        Offset(size.width - m, m),
        Offset(size.width - m - cl, m),
        paint,
      )
      ..drawLine(
        Offset(size.width - m, m),
        Offset(size.width - m, m + cl),
        paint,
      )
      ..drawLine(
        Offset(m, size.height - m),
        Offset(m + cl, size.height - m),
        paint,
      )
      ..drawLine(
        Offset(m, size.height - m),
        Offset(m, size.height - m - cl),
        paint,
      )
      ..drawLine(
        Offset(size.width - m, size.height - m),
        Offset(size.width - m - cl, size.height - m),
        paint,
      )
      ..drawLine(
        Offset(size.width - m, size.height - m),
        Offset(size.width - m, size.height - m - cl),
        paint,
      );
  }

  void _drawScanline(Canvas canvas, Size size) {
    final y = (progress * (size.height + 48) - 24).clamp(0.0, size.height);
    final glowRect = Rect.fromLTWH(
      0,
      (y - 28).clamp(0.0, size.height),
      size.width,
      28,
    );
    if (glowRect.height > 0) {
      canvas.drawRect(
        glowRect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _cyan.withValues(alpha: 0.0),
              _cyan.withValues(alpha: 0.28 + 0.12 * sin(pulse * 2 * pi)),
            ],
          ).createShader(glowRect),
      );
    }
    canvas.drawLine(
      Offset(0, y),
      Offset(size.width, y),
      Paint()
        ..color = _cyan.withValues(alpha: 0.85 + 0.15 * sin(pulse * 2 * pi))
        ..strokeWidth = 1.4,
    );
    final trailRect = Rect.fromLTWH(0, y, size.width, 8);
    canvas.drawRect(
      trailRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_cyan.withValues(alpha: 0.15), _cyan.withValues(alpha: 0.0)],
        ).createShader(trailRect),
    );
  }

  void _drawHandContour(Canvas canvas, Size size) {
    final t = ((progress - 3 / 8) / (1 / 8)).clamp(0.0, 1.0);
    final pulseVal = sin(pulse * 2 * pi);
    final opacity = (0.18 * t + 0.06 * pulseVal.abs()).clamp(0.0, 1.0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.48, size.height * 0.52),
        width: size.width * 0.70,
        height: size.height * 0.76,
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = _gold.withValues(alpha: opacity)
        ..strokeWidth = 1.0,
    );
    if (progress >= 4 / 8) {
      final roiT = ((progress - 4 / 8) / (1 / 8)).clamp(0.0, 1.0);
      final crossPaint = Paint()
        ..color = _cyan.withValues(alpha: 0.35 * roiT)
        ..strokeWidth = 0.7;
      final cx = size.width * 0.48;
      final cy = size.height * 0.52;
      const r = 14.0;
      canvas
        ..drawLine(Offset(cx - r, cy), Offset(cx + r, cy), crossPaint)
        ..drawLine(Offset(cx, cy - r), Offset(cx, cy + r), crossPaint)
        ..drawCircle(
          Offset(cx, cy),
          r * 0.4,
          crossPaint..style = PaintingStyle.stroke,
        );
    }
  }

  void _drawPalmLines(Canvas canvas, Size size) {
    final er = extractionResult;
    if (er != null && er.candidatePaths.isNotEmpty) {
      _drawRealLines(canvas, size, er);
    } else if (er != null && er.hasRealData) {
      _drawEdgePoints(canvas, size, er);
    }
  }

  void _drawRealLines(Canvas canvas, Size size, PalmLineExtractionResult er) {
    // Draw rejected (outer-edge) paths first in muted gray, underneath.
    _drawRejectedLinePaths(canvas, size, er.rejectedPaths);

    const lineColors = [
      _lifeLine,
      _heartLine,
      _headLine,
      _fateLine,
      _cyan,
      _gold,
      _violet,
      _lifeLine,
    ];
    final paths = er.candidatePaths;
    final n = paths.length.clamp(1, 8);
    for (int i = 0; i < n; i++) {
      final startAt = 4 / 8 + i * (1.5 / 8) / n;
      final color = lineColors[i % lineColors.length];
      final path = _catmullRomPath(paths[i], size);
      _drawLine(
        canvas,
        color: color,
        path: path,
        startAt: startAt,
        glowRadius: 5,
      );
    }
  }

  void _drawRejectedLinePaths(
    Canvas canvas,
    Size size,
    List<List<Offset>> rejected,
  ) {
    if (progress < 4 / 8 || rejected.isEmpty) return;
    final t = ((progress - 4 / 8) / (1 / 8)).clamp(0.0, 1.0);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF888888).withValues(alpha: 0.25 * t)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final pts in rejected) {
      if (pts.length < 2) continue;
      canvas.drawPath(_catmullRomPath(pts, size), paint);
    }
  }

  void _drawTrackerDebug(Canvas canvas, Size size) {
    final er = extractionResult;
    if (er == null || er.palmGeometry == null || er.candidatePaths.isEmpty) {
      return;
    }
    final tracked = PalmLineTracker.track(
      geometry: er.palmGeometry,
      candidatePaths: er.candidatePaths,
      rejectedPaths: er.rejectedPaths,
    );
    if (tracked.rawFragmentCount == 0) return;

    _drawTrackerRawFragments(canvas, size, er.candidatePaths);
    _drawTrackerMergedFragments(canvas, size, tracked.mergedFragments);
    _drawTrackerRejectedMerges(canvas, size, tracked.rejectedMerges);
    _drawTrackerGapBridges(canvas, size, tracked.gapBridges);
    _drawTrackerFinalLines(canvas, size, tracked);
  }

  void _drawTrackerRawFragments(
    Canvas canvas,
    Size size,
    List<List<Offset>> paths,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final points in paths.take(48)) {
      if (points.length < 2) continue;
      canvas.drawPath(_catmullRomPath(points, size), paint);
    }
  }

  void _drawTrackerMergedFragments(
    Canvas canvas,
    Size size,
    List<TrackedPalmLine> lines,
  ) {
    for (final line in lines.take(24)) {
      if (line.points.length < 2) continue;
      final color = _trackerColor(line.type);
      canvas.drawPath(
        _catmullRomPath(line.points, size),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color.withValues(alpha: 0.24)
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  void _drawTrackerRejectedMerges(
    Canvas canvas,
    Size size,
    List<PalmLineMergeDecision> rejected,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFFF3B5C).withValues(alpha: 0.34)
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;
    for (final merge in rejected.take(18)) {
      final path = Path()
        ..moveTo(merge.from.dx * size.width, merge.from.dy * size.height)
        ..lineTo(merge.to.dx * size.width, merge.to.dy * size.height);
      _drawDashed(canvas, path, paint, dash: 4, gap: 5);
    }
  }

  void _drawTrackerGapBridges(
    Canvas canvas,
    Size size,
    List<PalmLineGapBridge> bridges,
  ) {
    for (final bridge in bridges.take(24)) {
      final path = Path()
        ..moveTo(bridge.from.dx * size.width, bridge.from.dy * size.height)
        ..lineTo(bridge.to.dx * size.width, bridge.to.dy * size.height);
      _drawDashed(
        canvas,
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = _gold.withValues(alpha: 0.78)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
        dash: 7,
        gap: 4,
      );
    }
  }

  void _drawTrackerFinalLines(
    Canvas canvas,
    Size size,
    TrackedPalmLines tracked,
  ) {
    for (final line in tracked.majorLines) {
      if (line.points.length < 2) continue;
      final color = _trackerColor(line.type);
      final path = _catmullRomPath(line.points, size);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color.withValues(alpha: 0.42)
          ..strokeWidth = 12
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color.withValues(alpha: 0.96)
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
      final labelAt = line.points[line.points.length ~/ 2];
      _drawTrackerLabel(
        canvas,
        size,
        labelAt,
        '${_trackerLabel(line.type)} ${(line.averageConfidence * 100).round()}%',
        color,
      );
    }
  }

  Color _trackerColor(TrackedPalmLineType type) {
    return switch (type) {
      TrackedPalmLineType.life => _lifeLine,
      TrackedPalmLineType.heart => _heartLine,
      TrackedPalmLineType.head => _headLine,
      TrackedPalmLineType.fate => _fateLine,
      TrackedPalmLineType.unknown => Colors.white,
    };
  }

  String _trackerLabel(TrackedPalmLineType type) {
    return switch (type) {
      TrackedPalmLineType.life => 'life',
      TrackedPalmLineType.heart => 'heart',
      TrackedPalmLineType.head => 'head',
      TrackedPalmLineType.fate => 'fate',
      TrackedPalmLineType.unknown => 'unknown',
    };
  }

  void _drawTrackerLabel(
    Canvas canvas,
    Size size,
    Offset normalized,
    String label,
    Color color,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 16);
    final origin = Offset(
      (normalized.dx * size.width + 6).clamp(
        6.0,
        size.width - textPainter.width - 6,
      ),
      (normalized.dy * size.height - 12).clamp(
        6.0,
        size.height - textPainter.height - 6,
      ),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          origin.dx - 4,
          origin.dy - 2,
          textPainter.width + 8,
          textPainter.height + 4,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xD0060310),
    );
    textPainter.paint(canvas, origin);
  }

  void _drawEdgePoints(Canvas canvas, Size size, PalmLineExtractionResult er) {
    if (progress < 4 / 8) return;
    final t = ((progress - 4 / 8) / (2 / 8)).clamp(0.0, 1.0);
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    for (final p in er.edgePoints) {
      paint.color = _cyan.withValues(alpha: (0.35 * t).clamp(0, 1));
      canvas.drawCircle(
        Offset(p.dx * size.width, p.dy * size.height),
        1.2,
        paint,
      );
    }
  }

  void _drawPalmGeometryDebug(Canvas canvas, Size size) {
    final g = extractionResult?.palmGeometry;
    if (g == null) return;

    Offset pt(Offset p) => Offset(p.dx * size.width, p.dy * size.height);
    Rect rect(Rect r) => Rect.fromLTRB(
      r.left * size.width,
      r.top * size.height,
      r.right * size.width,
      r.bottom * size.height,
    );

    final bounds = rect(g.palmBounds);
    final thenar = rect(g.thenarRegion);
    final center = pt(g.palmCenter);
    final wristY = g.wristY * size.height;
    final fingerBaseY = g.fingerBaseY * size.height;

    canvas.drawRect(
      thenar,
      Paint()
        ..style = PaintingStyle.fill
        ..color = _lifeLine.withValues(alpha: 0.14),
    );
    canvas.drawRect(
      bounds,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = _green.withValues(alpha: 0.78),
    );

    final fingerPaint = Paint()
      ..color = _cyan.withValues(alpha: 0.82)
      ..strokeWidth = 1.5;
    final wristPaint = Paint()
      ..color = _gold.withValues(alpha: 0.82)
      ..strokeWidth = 1.5;
    canvas
      ..drawLine(
        Offset(bounds.left, fingerBaseY),
        Offset(bounds.right, fingerBaseY),
        fingerPaint,
      )
      ..drawLine(
        Offset(bounds.left, wristY),
        Offset(bounds.right, wristY),
        wristPaint,
      )
      ..drawCircle(center, 6, Paint()..color = _green.withValues(alpha: 0.95))
      ..drawCircle(
        center,
        10,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = _green.withValues(alpha: 0.55),
      );

    final axisLen = bounds.height * 0.35;
    final axisDx = sin(g.mainAxisAngle) * axisLen;
    final axisDy = cos(g.mainAxisAngle) * axisLen;
    canvas.drawLine(
      Offset(center.dx - axisDx, center.dy - axisDy),
      Offset(center.dx + axisDx, center.dy + axisDy),
      Paint()
        ..color = _violet.withValues(alpha: 0.85)
        ..strokeWidth = 1.2,
    );

    final sideLabel = switch (g.thumbSide) {
      PalmThumbSide.left => 'thumb: left',
      PalmThumbSide.right => 'thumb: right',
      PalmThumbSide.unknown => 'thumb: unknown',
    };
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Palm geometry ${(g.confidence * 100).round()}%  $sideLabel',
        style: const TextStyle(
          color: Color(0xFFE6DDF8),
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 24);
    final labelOffset = Offset(
      bounds.left.clamp(8.0, size.width - textPainter.width - 8),
      (bounds.top - 18).clamp(8.0, size.height - 20),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          labelOffset.dx - 5,
          labelOffset.dy - 3,
          textPainter.width + 10,
          textPainter.height + 6,
        ),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xCC060310),
    );
    textPainter.paint(canvas, labelOffset);
  }

  // Active line pulses with a bright glow on top of the regular drawing
  void _drawActiveLineGlow(Canvas canvas, Size size) {
    final idx = activeLineIndex!;
    const colors = [_lifeLine, _heartLine, _headLine, _fateLine];
    if (idx >= colors.length) return;
    final color = colors[idx];

    final er = extractionResult;
    if (er == null || er.candidatePaths.length <= idx) return;
    final path = _catmullRomPath(er.candidatePaths[idx], size);

    final glow = 0.30 + 0.22 * sin(pulse * 2 * pi);

    // Outer wide glow
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color.withValues(alpha: glow)
        ..strokeWidth = 18
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
    // Sharp bright line on top
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  // ── Debug: original life line (white) + endpoint markers ────────────────
  void _drawDebugLifeLine(Canvas canvas, Size size) {
    final pts = debugLifePath!;
    if (pts.isEmpty) return;

    final path = _catmullRomPath(pts, size);
    final hasExt = debugExtensionPath != null && debugExtensionPath!.isNotEmpty;

    // White glow
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xCCFFFFFF)
        ..strokeWidth = 10
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Solid white line
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.white
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Start point — green
    final s = Offset(pts.first.dx * size.width, pts.first.dy * size.height);
    canvas
      ..drawCircle(s, 8, Paint()..color = const Color(0xFF00FF66))
      ..drawCircle(
        s,
        8,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

    // Original end point:
    //   orange when continuation extended it further, red otherwise.
    final endColor = hasExt
        ? const Color(0xFFFF8800) // orange = old endpoint, extension continues
        : const Color(0xFFFF2244); // red = final endpoint
    final e = Offset(pts.last.dx * size.width, pts.last.dy * size.height);
    canvas
      ..drawCircle(e, 8, Paint()..color = endColor)
      ..drawCircle(
        e,
        8,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
  }

  // ── Debug: extension segment (dashed cyan-white) + new red endpoint ──────
  void _drawDebugExtension(Canvas canvas, Size size) {
    final extPts = debugExtensionPath!;
    if (extPts.isEmpty) return;

    // Connect from last point of original path
    final origPts = debugLifePath;
    final joinPts = [
      if (origPts != null && origPts.isNotEmpty) origPts.last,
      ...extPts,
    ];
    if (joinPts.length < 2) return;

    final extPath = _catmullRomPath(joinPts, size);

    // Soft cyan glow
    canvas.drawPath(
      extPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0x8800EEFF)
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Dashed cyan-white stroke
    _drawDashed(
      canvas,
      extPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xCC88EEFF)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round,
    );

    // New endpoint — red
    final e = Offset(extPts.last.dx * size.width, extPts.last.dy * size.height);
    canvas
      ..drawCircle(e, 8, Paint()..color = const Color(0xFFFF2244))
      ..drawCircle(
        e,
        8,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
  }

  void _drawDashed(
    Canvas canvas,
    Path path,
    Paint paint, {
    double dash = 8,
    double gap = 5,
  }) {
    final metrics = path.computeMetrics();
    for (final m in metrics) {
      double pos = 0;
      bool drawing = true;
      while (pos < m.length) {
        final next = pos + (drawing ? dash : gap);
        if (drawing) {
          canvas.drawPath(m.extractPath(pos, next.clamp(0, m.length)), paint);
        }
        pos = next;
        drawing = !drawing;
      }
    }
  }

  Path _catmullRomPath(List<Offset> pts, Size size) {
    if (pts.length < 2) return Path();
    final s = pts
        .map((p) => Offset(p.dx * size.width, p.dy * size.height))
        .toList();
    if (s.length == 2) {
      return Path()
        ..moveTo(s[0].dx, s[0].dy)
        ..lineTo(s[1].dx, s[1].dy);
    }
    final path = Path()..moveTo(s[0].dx, s[0].dy);
    for (int i = 0; i < s.length - 1; i++) {
      final p0 = i > 0 ? s[i - 1] : s[i];
      final p1 = s[i];
      final p2 = s[i + 1];
      final p3 = i + 2 < s.length ? s[i + 2] : s[i + 1];
      path.cubicTo(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
        p2.dx,
        p2.dy,
      );
    }
    return path;
  }

  void _drawLine(
    Canvas canvas, {
    required Color color,
    required Path path,
    required double startAt,
    required double glowRadius,
  }) {
    if (progress < startAt) return;
    final t = ((progress - startAt) / (1 / 8)).clamp(0.0, 1.0);
    final pulseVal = sin(pulse * 2 * pi);
    final partial = _partialPath(path, t);
    canvas.drawPath(
      partial,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color.withValues(
          alpha: (0.18 * t + 0.06 * pulseVal.abs()).clamp(0, 1),
        )
        ..strokeWidth = glowRadius.toDouble()
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      partial,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color.withValues(alpha: (0.85 * t).clamp(0, 1))
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  Path _partialPath(Path full, double fraction) {
    if (fraction <= 0) return Path();
    if (fraction >= 1) return full;
    final metrics = full.computeMetrics().toList();
    if (metrics.isEmpty) return full;
    return metrics.first.extractPath(0, metrics.first.length * fraction);
  }

  void _drawParticles(Canvas canvas, Size size) {
    final t = ((progress - 5 / 8) / (1 / 8)).clamp(0.0, 1.0);
    final colors = [_gold, _cyan, _violet, _lifeLine];
    for (int i = 0; i < particles.length; i++) {
      final phase = (spark + i / particles.length) % 1.0;
      final opacity = (sin(phase * pi).abs() * 0.9 * t).clamp(0.0, 1.0);
      if (opacity < 0.04) continue;
      final color = colors[i % colors.length];
      final r = 1.4 + 1.2 * sin(phase * pi).abs();
      final p = particles[i];
      canvas.drawCircle(
        Offset(p.dx * size.width, p.dy * size.height),
        r,
        Paint()
          ..color = color.withValues(alpha: opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  void _drawCompletionRing(Canvas canvas, Size size) {
    final r = min(size.width, size.height) * 0.44;
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final glow = 0.18 + 0.08 * sin(pulse * 2 * pi);
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = _green.withValues(alpha: glow)
        ..strokeWidth = 1.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  @override
  bool shouldRepaint(PalmOverlayPainter old) =>
      old.progress != progress ||
      old.pulse != pulse ||
      old.spark != spark ||
      old.isDone != isDone ||
      old.extractionResult != extractionResult ||
      old.activeLineIndex != activeLineIndex ||
      old.debugLifePath != debugLifePath ||
      old.debugExtensionPath != debugExtensionPath;
}

// ── Pipeline details sheet ────────────────────────────────────────────────────

class _PipelineSheet extends StatelessWidget {
  const _PipelineSheet({required this.er, required this.l10n});

  final PalmLineExtractionResult er;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final confidencePct = (er.confidence * 100).round();
    final roiLabel = er.hasRoi
        ? l10n.palmExtractionPipelineRoiYes
        : l10n.palmExtractionPipelineRoiNo;
    final roiColor = er.hasRoi
        ? const Color(0xFF8AE07A)
        : const Color(0x77E6DDF8);
    final workSize = er.normalizedWidth > 0
        ? '${er.normalizedWidth}×${er.normalizedHeight}'
        : '–';

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0720),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x33BD7FF5), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBD7FF5).withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0x33FFFFFF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 6),
              child: Row(
                children: [
                  const Icon(
                    Icons.analytics_outlined,
                    size: 15,
                    color: Color(0xFFBD7FF5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.palmExtractionPipelineTitle,
                    style: const TextStyle(
                      color: Color(0xFFBD7FF5),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0x22BD7FF5), height: 1, thickness: 0.5),
            const SizedBox(height: 4),
            _PipelineRow(
              label: l10n.palmExtractionPipelineRoi,
              value: roiLabel,
              valueColor: roiColor,
            ),
            _PipelineRow(
              label: l10n.palmExtractionPipelineEdgePixels,
              value: '${er.edgePointCount}',
              valueColor: er.edgePointCount > 0
                  ? const Color(0xFF00CFFF)
                  : const Color(0x55E6DDF8),
            ),
            _PipelineRow(
              label: l10n.palmExtractionPipelineLineCandidates,
              value: '${er.candidatePathCount}',
              valueColor: er.candidatePathCount > 0
                  ? const Color(0xFFDAB86E)
                  : const Color(0x55E6DDF8),
            ),
            _PipelineRow(
              label: l10n.palmExtractionPipelineConfidence,
              value: '$confidencePct %',
              valueColor: _confidenceColor(er.confidence),
            ),
            _PipelineRow(
              label: l10n.palmExtractionPipelineWorkSize,
              value: workSize,
            ),
            _PipelineRow(
              label: l10n.palmExtractionPipelinePalmMaskCoverage,
              value: '${(er.palmMaskCoverage * 100).round()} %',
            ),
            _PipelineRow(
              label: l10n.palmExtractionPipelineDarkLinePixels,
              value: '${er.darkLinePixelCount}',
              valueColor: er.darkLinePixelCount > 0
                  ? const Color(0xFF00CFFF)
                  : const Color(0x55E6DDF8),
            ),
            _PipelineRow(
              label: l10n.palmExtractionPipelineSobelPixels,
              value: '${er.sobelPixelCount}',
            ),
            _PipelineRow(
              label: l10n.palmExtractionPipelineAcceptedInterior,
              value: '${(er.acceptedInteriorRatio * 100).round()} %',
            ),
            _PipelineRow(
              label: l10n.palmExtractionPipelineRejectedBoundary,
              value: '${(er.rejectedBoundaryRatio * 100).round()} %',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Color _confidenceColor(double c) {
    if (c >= 0.65) return const Color(0xFF8AE07A);
    if (c >= 0.35) return const Color(0xFFDAB86E);
    return const Color(0x77E6DDF8);
  }
}

class _PipelineRow extends StatelessWidget {
  const _PipelineRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final vColor = valueColor ?? const Color(0xFFE6DDF8);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0x88E6DDF8),
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: vColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
