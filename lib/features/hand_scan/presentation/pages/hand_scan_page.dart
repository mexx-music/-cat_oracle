import 'package:cat_oracle/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../features/palmistry/logic/palmistry_reading_engine.dart';
import '../../../../services/oracle_session_service.dart';
import '../../../../shared/services/image_pick_service.dart';
import '../../logic/palm_line_classifier.dart';
import '../../logic/palm_line_continuation.dart';
import '../../logic/palm_line_extractor.dart';
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
  final l10n = AppLocalizations.of(context)!;
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
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
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
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
                      style: Theme.of(dialogContext).textTheme.titleLarge
                          ?.copyWith(
                            color: const Color(0xFFFFE9B0),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      l10n.palmistryPreviewSubtitle,
                      style: Theme.of(dialogContext).textTheme.bodySmall
                          ?.copyWith(
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
                          result.bytes,
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
                          style: Theme.of(dialogContext).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFFE6DDF8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.of(dialogContext).pop();
                          if (!context.mounted) return;

                          final extractionResult =
                              await PalmLineExtractor.extract(result.bytes);
                          if (!context.mounted) return;

                          // Classify, then attempt life line continuation
                          // before computing the profile so the reading
                          // reflects the extended arc length.
                          var classResult =
                              PalmLineClassifier.classify(extractionResult);

                          var continuationResult =
                              PalmLineContinuationResult.none;
                          if (extractionResult.hasRealData &&
                              classResult.lifeLinePath != null &&
                              classResult.lifeLineConfidence >= 0.25) {
                            continuationResult =
                                await PalmLineContinuation.extend(
                              result.bytes,
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

                          if (!context.mounted) return;

                          final profile = extractionResult.hasRealData
                              ? profileFromClassification(
                                  classResult,
                                  extractionResult,
                                  fallbackSeed: result.seedString,
                                )
                              : profileFromImagePath(result.seedString);
                          final traits = traitsFromProfile(profile);
                          final reading = readingFromProfile(profile);
                          OracleSessionService.instance.setPalmistryAnalysis(
                            profile: profile,
                            traits: traits,
                          );
                          if (!context.mounted) return;
                          await PalmExtractionAnimation.show(
                            context,
                            result.bytes,
                            extractionResult: extractionResult,
                            traits: traits,
                            reading: reading,
                            classificationResult: classResult,
                            continuationResult: continuationResult,
                          );
                        },
                        icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                        label: Text(l10n.palmistryStartAnalysis),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E1A4A),
                          foregroundColor: const Color(0xFFFFE9B0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: const BorderSide(
                            color: Color(0x88DAB86E),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(l10n.palmistryClose),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
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
