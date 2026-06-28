import 'package:cat_oracle/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../features/palmistry/logic/palmistry_reading_engine.dart';
import '../../../../services/oracle_session_service.dart';
import '../../../../shared/services/image_pick_service.dart';
import '../../logic/palm_line_classifier.dart';
import '../../logic/palm_line_continuation.dart';
import '../../logic/palm_line_extractor.dart';
import '../../logic/hand_segmentor.dart';
import '../../logic/scan_quality_assessor.dart';
import '../../models/scanned_hand.dart';
import '../widgets/palm_extraction_animation.dart';

typedef _NoCam = CameraNotAvailableException;
typedef _NoPerm = CameraPermissionDeniedException;

class HandScanPage extends StatelessWidget {
  const HandScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final safePadding = MediaQuery.of(context).padding.vertical;

    return Scaffold(
      body: Stack(
        children: [
          Opacity(
            opacity: 0.82,
            child: SizedBox.expand(
              child: Image.asset(
                'assets/images/palmcat.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xB0090711),
                  Color(0xA8150E22),
                  Color(0xBC0E0818),
                  Color(0xD806050C),
                ],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - safePadding - 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0x33FFFFFF),
                          foregroundColor: const Color(0xFFF3DFA3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '✋ ${l10n.palmistryTitle}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: const Color(0xFFFFE9B0),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.palmistrySubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFE6DDF8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 36),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0x40110D1D),
                        border: Border.all(
                          color: const Color(0x88DAB86E),
                          width: 1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x54110D1C),
                            blurRadius: 26,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Text(
                        l10n.palmistryTeaserText,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFF3ECFF),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _PalmOptionTile(
                      icon: Icons.camera_alt_rounded,
                      title: l10n.palmistryUploadButton,
                      subtitle: l10n.palmistryUploadSubtitle,
                      onTap: () => _handleImageUpload(context),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Image upload flow ───────────────────────────────────────────────────────

Future<void> _handleImageUpload(BuildContext context) async {
  final l10n = AppLocalizations.of(context)!;

  // Desktop / web: skip Camera/Gallery dialog — open file picker directly.
  // Mobile: ask the user which source to use.
  ImagePickSource source = ImagePickSource.gallery;
  if (ImagePickService.supportsCamera) {
    final chosen = await _pickSource(context);
    if (chosen == null) return;
    source = chosen;
  }

  ImagePickResult? result;
  try {
    result = await ImagePickService.pick(source: source);
  } on _NoCam {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.cameraMacOSNotAvailable),
        duration: const Duration(seconds: 5),
      ),
    );
    return;
  } on _NoPerm {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.cameraPermissionDenied)));
    return;
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.imagePickError)));
    return;
  }

  if (result == null) return; // user cancelled
  if (!context.mounted) return;

  _showImagePreviewDialog(context, result);
}

Future<ImagePickSource?> _pickSource(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<ImagePickSource>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: const Color(0xFF0E0818),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x99DAB86E), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x50100D1B),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.palmistryPickSource,
              style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFFFE9B0),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              l10n.palmistryPickSourceHint,
              style: Theme.of(
                dialogContext,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFFE6DDF8)),
            ),
            const SizedBox(height: 22),
            _SourceButton(
              icon: Icons.camera_alt_rounded,
              label: l10n.palmistryCamera,
              onTap: () => Navigator.pop(dialogContext, ImagePickSource.camera),
            ),
            const SizedBox(height: 10),
            _SourceButton(
              icon: Icons.photo_library_rounded,
              label: l10n.palmistryGallery,
              onTap: () =>
                  Navigator.pop(dialogContext, ImagePickSource.gallery),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.palmistryCancel),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showImagePreviewDialog(BuildContext context, ImagePickResult result) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) =>
        _ImagePreviewDialog(result: result, outerContext: context),
  );
}

// ── Preview dialog (stateful for quality gate) ──────────────────────────────

class _ImagePreviewDialog extends StatefulWidget {
  const _ImagePreviewDialog({required this.result, required this.outerContext});

  final ImagePickResult result;
  final BuildContext outerContext;

  @override
  State<_ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<_ImagePreviewDialog> {
  ScanQualityResult? _quality;
  HandSegmentResult? _segmentation;
  Future<HandSegmentResult>? _segmentationFuture;

  @override
  void initState() {
    super.initState();
    _runQualityAssessment();
    _runSegmentation();
  }

  Future<void> _runQualityAssessment() async {
    final q = await ScanQualityAssessor.assess(widget.result.bytes);
    if (mounted) setState(() => _quality = q);
  }

  Future<void> _runSegmentation() async {
    final future = HandSegmentor.segment(widget.result.bytes);
    _segmentationFuture = future;
    final s = await future;
    if (mounted) setState(() => _segmentation = s);
  }

  Future<void> _startAnalysis() async {
    final imageBytes = widget.result.bytes;
    final seedString = widget.result.seedString;
    final navigator = Navigator.of(context);
    final outerCtx = widget.outerContext;
    final segmentation =
        _segmentation ??
        await (_segmentationFuture ?? HandSegmentor.segment(imageBytes));

    navigator.pop();
    if (!outerCtx.mounted) return;

    final selectedHand =
        await _pickScannedHand(outerCtx) ?? ScannedHand.unknown;
    if (!outerCtx.mounted) return;

    final extractionResult = (await PalmLineExtractor.extract(
      imageBytes,
      segmentation: segmentation,
    )).copyWith(scannedHand: selectedHand);
    if (!outerCtx.mounted) return;

    var classResult = PalmLineClassifier.classify(extractionResult);

    var continuationResult = PalmLineContinuationResult.none;
    if (extractionResult.hasRealData &&
        classResult.lifeLinePath != null &&
        classResult.lifeLineConfidence >= 0.25) {
      continuationResult = await PalmLineContinuation.extend(
        imageBytes,
        classResult.lifeLinePath!,
      );
      if (continuationResult.wasExtended) {
        classResult = classResult.copyWith(
          lifeLinePath: continuationResult.extendedPath,
          lifeLineLengthRatio:
              classResult.lifeLineLengthRatio +
              continuationResult.extensionArcLength,
        );
      }
    }

    if (!outerCtx.mounted) return;

    final profile = extractionResult.hasRealData
        ? profileFromClassification(
            classResult,
            extractionResult,
            fallbackSeed: seedString,
            scannedHand: selectedHand,
          )
        : profileFromImagePath(seedString, scannedHand: selectedHand);
    final traits = traitsFromProfile(profile);
    final reading = readingFromProfile(profile);
    OracleSessionService.instance.setPalmistryAnalysis(
      profile: profile,
      traits: traits,
      scannedHand: selectedHand,
    );
    if (!outerCtx.mounted) return;
    await PalmExtractionAnimation.show(
      outerCtx,
      imageBytes,
      extractionResult: extractionResult,
      traits: traits,
      reading: reading,
      classificationResult: classResult,
      continuationResult: continuationResult,
      scannedHand: selectedHand,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final q = _quality;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.86 + 0.14 * t, child: child),
      ),
      child: Dialog(
        backgroundColor: const Color(0xFF0E0818),
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0x99DAB86E), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x50100D1B),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '✋ ${l10n.palmistryPreviewTitle}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: const Color(0xFFFFE9B0),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    l10n.palmistryPreviewSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFE6DDF8),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0x55DAB86E),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Image.memory(
                        widget.result.bytes,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          height: 160,
                          alignment: Alignment.center,
                          color: const Color(0x2A0E0818),
                          child: const Icon(
                            Icons.broken_image_rounded,
                            color: Color(0xFFE6DDF8),
                            size: 48,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF8BC34A),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.palmistryImageLoaded,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFE6DDF8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // ── Quality gate panel ──────────────────────────────────
                  _ScanQualityPanel(quality: q),
                  const SizedBox(height: 10),
                  // ── Hand segmentation panel ─────────────────────────────
                  _HandSegmentationPanel(segmentation: _segmentation),
                  const SizedBox(height: 16),
                  // ── Action buttons depending on grade ───────────────────
                  _ActionButtons(
                    qualityGrade: q?.overallGrade,
                    segmentGrade: _segmentation?.grade,
                    onAnalyze: _startAnalysis,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Quality panel widget ────────────────────────────────────────────────────

class _ScanQualityPanel extends StatelessWidget {
  const _ScanQualityPanel({required this.quality});

  final ScanQualityResult? quality;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final q = quality;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0x28160D28),
        border: Border.all(color: const Color(0x44DAB86E), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.scanQualityTitle,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFFFFE9B0),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (q != null)
                _GradeChip(grade: q.overallGrade)
              else
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Color(0xFFDAB86E),
                  ),
                ),
            ],
          ),
          if (q == null) ...[
            const SizedBox(height: 10),
            Text(
              l10n.scanQualityAnalyzing,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xAAE6DDF8)),
            ),
          ] else ...[
            const SizedBox(height: 12),
            _QualityRow(
              label: l10n.scanQualityDimBackground,
              score: q.backgroundScore,
            ),
            _QualityRow(
              label: l10n.scanQualityDimLighting,
              score: q.lightingScore,
            ),
            _QualityRow(
              label: l10n.scanQualityDimSharpness,
              score: q.sharpnessScore,
            ),
            _QualityRow(
              label: l10n.scanQualityDimHandPosition,
              score: q.handPositionScore,
            ),
            _QualityRow(
              label: l10n.scanQualityDimPalmCoverage,
              score: q.palmCoverageScore,
            ),
            // Madame Gatto tip for poor background
            if (q.backgroundScore < 0.35) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0x22DAB86E),
                  border: Border.all(
                    color: const Color(0x55DAB86E),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🐱 ${l10n.scanQualityMadameSays}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: const Color(0xFFFFE9B0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"${l10n.scanQualityBgTip}"',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFE6DDF8),
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.scanQualityBgSuggestionsTitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFDAB86E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    for (final s in [
                      l10n.scanQualityBgSuggestion1,
                      l10n.scanQualityBgSuggestion2,
                      l10n.scanQualityBgSuggestion3,
                      l10n.scanQualityBgSuggestion4,
                    ])
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '• $s',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xCCE6DDF8)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _GradeChip extends StatelessWidget {
  const _GradeChip({required this.grade});

  final ScanQualityGrade grade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (stars, label, color) = switch (grade) {
      ScanQualityGrade.excellent => (
        '★★★★★',
        l10n.scanQualityGradeExcellent,
        const Color(0xFF66BB6A),
      ),
      ScanQualityGrade.good => (
        '★★★★☆',
        l10n.scanQualityGradeGood,
        const Color(0xFF8BC34A),
      ),
      ScanQualityGrade.acceptable => (
        '★★★☆☆',
        l10n.scanQualityGradeAcceptable,
        const Color(0xFFFFCA28),
      ),
      ScanQualityGrade.poor => (
        '★★☆☆☆',
        l10n.scanQualityGradePoor,
        const Color(0xFFFF8A65),
      ),
      ScanQualityGrade.retake => (
        '★☆☆☆☆',
        l10n.scanQualityGradeRetake,
        const Color(0xFFEF5350),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stars,
            style: TextStyle(fontSize: 10, color: color, letterSpacing: 1),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QualityRow extends StatelessWidget {
  const _QualityRow({required this.label, required this.score});

  final String label;
  final double score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 0.75
        ? const Color(0xFF66BB6A)
        : score >= 0.52
        ? const Color(0xFF8BC34A)
        : score >= 0.28
        ? const Color(0xFFFFCA28)
        : const Color(0xFFFF8A65);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            score >= 0.28 ? Icons.check_rounded : Icons.warning_amber_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xCCE6DDF8)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: score.clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: const Color(0x22FFFFFF),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hand segmentation panel ─────────────────────────────────────────────────

class _HandSegmentationPanel extends StatelessWidget {
  const _HandSegmentationPanel({required this.segmentation});

  final HandSegmentResult? segmentation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final seg = segmentation;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0x28160D28),
        border: Border.all(color: const Color(0x44DAB86E), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.handSegmentTitle,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: const Color(0xFFFFE9B0),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (seg != null)
                _SegGradeChip(grade: seg.grade)
              else
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Color(0xFFDAB86E),
                  ),
                ),
            ],
          ),
          if (seg == null) ...[
            const SizedBox(height: 10),
            Text(
              l10n.handSegmentAnalyzing,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xAAE6DDF8)),
            ),
          ] else ...[
            const SizedBox(height: 10),
            // Cutout preview + metrics side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cutout thumbnail
                if (seg.cutoutBytes.isNotEmpty)
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 72,
                          height: 90,
                          child: Image.memory(
                            seg.cutoutBytes,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.back_hand_rounded,
                              color: Color(0x66E6DDF8),
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.handSegmentCutoutLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0x88E6DDF8),
                        ),
                      ),
                    ],
                  ),
                if (seg.cutoutBytes.isNotEmpty) const SizedBox(width: 12),
                // Metrics
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _QualityRow(
                        label: l10n.handSegmentDimCoverage,
                        score: seg.maskCoverage,
                      ),
                      _QualityRow(
                        label: l10n.handSegmentDimEdge,
                        score: seg.edgeConfidence,
                      ),
                      _QualityRow(
                        label: l10n.handSegmentDimFingers,
                        score: seg.fingerVisibility,
                      ),
                      _QualityRow(
                        label: l10n.handSegmentDimThumb,
                        score: seg.thumbVisibility,
                      ),
                      _QualityRow(
                        label: l10n.handSegmentDimWrist,
                        score: seg.wristVisibility,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Madame Gatto tip when segmentation is poor
            if (seg.grade == SegmentationGrade.poor) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: const Color(0x22DAB86E),
                  border: Border.all(
                    color: const Color(0x55DAB86E),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🐱', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.handSegmentPoorTip,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFE6DDF8),
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _SegGradeChip extends StatelessWidget {
  const _SegGradeChip({required this.grade});

  final SegmentationGrade grade;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final (label, color) = switch (grade) {
      SegmentationGrade.excellent => (
        l10n.handSegmentGradeExcellent,
        const Color(0xFF66BB6A),
      ),
      SegmentationGrade.good => (
        l10n.handSegmentGradeGood,
        const Color(0xFF8BC34A),
      ),
      SegmentationGrade.acceptable => (
        l10n.handSegmentGradeAcceptable,
        const Color(0xFFFFCA28),
      ),
      SegmentationGrade.poor => (
        l10n.handSegmentGradePoor,
        const Color(0xFFFF8A65),
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Action buttons ──────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.qualityGrade,
    required this.segmentGrade,
    required this.onAnalyze,
    required this.onClose,
  });

  final ScanQualityGrade? qualityGrade;
  final SegmentationGrade? segmentGrade;
  final VoidCallback onAnalyze;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isPoor =
        qualityGrade == ScanQualityGrade.poor ||
        qualityGrade == ScanQualityGrade.retake ||
        segmentGrade == SegmentationGrade.poor;
    final isAcceptable =
        !isPoor && (qualityGrade == ScanQualityGrade.acceptable);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isAcceptable)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 14,
                  color: Color(0xFFFFCA28),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.scanQualityWarningAcceptable,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFFFCA28),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            onPressed: onAnalyze,
            icon: const Icon(Icons.auto_awesome_rounded, size: 18),
            label: Text(
              isPoor
                  ? l10n.scanQualityAnalyzeAnywayButton
                  : l10n.palmistryStartAnalysis,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isPoor
                  ? const Color(0xFF1E1030)
                  : const Color(0xFF2E1A4A),
              foregroundColor: const Color(0xFFFFE9B0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(
                color: isPoor
                    ? const Color(0x55DAB86E)
                    : const Color(0x88DAB86E),
                width: 1,
              ),
            ),
          ),
        ),
        if (isPoor) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onClose,
              icon: const Icon(Icons.camera_alt_rounded, size: 17),
              label: Text(l10n.scanQualityRetakeButton),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF5E7BF),
                side: const BorderSide(color: Color(0x99DAB86E)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onClose,
              child: Text(l10n.palmistryClose),
            ),
          ),
        ],
      ],
    );
  }
}

Future<ScannedHand?> _pickScannedHand(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<ScannedHand>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => Dialog(
      backgroundColor: const Color(0xFF0E0818),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x99DAB86E), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x50100D1B),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.palmistryScannedHandQuestion,
              style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFFFE9B0),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.palmistryScannedHandHint,
              style: Theme.of(
                dialogContext,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFFE6DDF8)),
            ),
            const SizedBox(height: 20),
            _SourceButton(
              icon: Icons.back_hand_rounded,
              label: l10n.palmistryLeftHand,
              onTap: () => Navigator.pop(dialogContext, ScannedHand.left),
            ),
            const SizedBox(height: 10),
            _SourceButton(
              icon: Icons.front_hand_rounded,
              label: l10n.palmistryRightHand,
              onTap: () => Navigator.pop(dialogContext, ScannedHand.right),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Reusable widgets ────────────────────────────────────────────────────────

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFF5E7BF),
          side: const BorderSide(color: Color(0x77DAB86E)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _PalmOptionTile extends StatelessWidget {
  const _PalmOptionTile({
    required this.title,
    this.subtitle,
    this.icon = Icons.back_hand_rounded,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0x2B100B20),
        border: Border.all(color: const Color(0x66DAB86E), width: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40100D1B),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x33402860),
            border: Border.all(color: const Color(0x73E1C27A)),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFFFD98A)),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFFF5E7BF),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xAAE6DDF8)),
              )
            : null,
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFFE5D0A0),
        ),
      ),
    );

    if (onTap == null) return tile;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: tile,
        ),
      ),
    );
  }
}
