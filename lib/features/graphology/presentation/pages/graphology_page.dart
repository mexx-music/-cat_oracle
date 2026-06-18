import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../logic/demo_graphology_reading_generator.dart';
import '../../models/graphology_trait.dart';

class GraphologyPage extends StatelessWidget {
  const GraphologyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safePadding = MediaQuery.of(context).padding.vertical;
    final contentTopSpacing = (screenHeight * 0.18)
        .clamp(96.0, 180.0)
        .toDouble();

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/grafologiecat.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x3307040D),
                  Color(0x220C0814),
                  Color(0xAA100A1A),
                  Color(0xE00B0612),
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
                          foregroundColor: const Color(0xFFF3E6BD),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '✒️ Grafologie',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: const Color(0xFFFFF2CC),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Deine Schrift flüstert leise',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFD8C8F7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: contentTopSpacing),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0x3E120F1F),
                        border: Border.all(
                          color: const Color(0x88DAB86E),
                          width: 1.1,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x54120F1E),
                            blurRadius: 26,
                            offset: Offset(0, 12),
                          ),
                          BoxShadow(
                            color: Color(0x1F7A4DCC),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        'Madame Gatto liest Form, Rhythmus und Energie deiner Schrift – symbolisch und ohne Urteil.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFFF1E9FF),
                          height: 1.45,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _GraphologyOptionTile(
                      title: 'Demo-Schriftdeutung starten',
                      onTap: () => _showGraphologyDialog(context),
                    ),
                    const SizedBox(height: 12),
                    _GraphologyOptionTile(
                      icon: Icons.camera_alt_rounded,
                      title: '📷 Schriftprobe hochladen',
                      subtitle: 'Foto einer Handschrift auswählen',
                      onTap: () => _handleImageUpload(context),
                    ),
                    const SizedBox(height: 12),
                    const _GraphologyOptionTile(title: 'Charakter-Impuls'),
                    const SizedBox(height: 12),
                    const _GraphologyOptionTile(title: 'Stimmung & Ausdruck'),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0x2D160F25),
                        border: Border.all(
                          color: const Color(0x88DABA72),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'Grafologie-Orakel erwacht bald',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: const Color(0xFFFFECB8),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
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

void _showGraphologyDialog(BuildContext context) {
  final traits = generateDemoGraphologyReading();
  final reading = composeDemoGraphologyReading(traits);

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
          backgroundColor: const Color(0xFF140F1F),
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                  BoxShadow(
                    color: Color(0x1A7A4DCC),
                    blurRadius: 18,
                    offset: Offset(0, 6),
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
                      '✒️ Grafologie-Orakel',
                      style: Theme.of(dialogContext).textTheme.titleLarge
                          ?.copyWith(
                            color: const Color(0xFFFFE9B0),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Madame Gatto liest die Spuren deiner Schrift',
                      style: Theme.of(dialogContext).textTheme.bodySmall
                          ?.copyWith(
                            color: const Color(0xFFD8C8F7),
                            letterSpacing: 0.3,
                          ),
                    ),
                    const SizedBox(height: 22),
                    for (final trait in traits) ...[
                      _TraitTile(trait: trait),
                      const SizedBox(height: 12),
                    ],
                    const Divider(color: Color(0x44DAB86E), thickness: 0.8),
                    const SizedBox(height: 16),
                    Text(
                      '✨ Gesamtdeutung',
                      style: Theme.of(dialogContext).textTheme.titleSmall
                          ?.copyWith(
                            color: const Color(0xFFFFE9B0),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0x3A1A0F30), Color(0x2A14102A)],
                        ),
                        border: Border.all(color: const Color(0x77DAB86E)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x2A100D1B),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        reading,
                        style: Theme.of(dialogContext).textTheme.bodyMedium
                            ?.copyWith(
                              color: const Color(0xFFF1E9FF),
                              height: 1.65,
                            ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Diese Deutung ist symbolisch und ersetzt keine professionelle Analyse.',
                      textAlign: TextAlign.center,
                      style: Theme.of(dialogContext).textTheme.bodySmall
                          ?.copyWith(
                            color: const Color(0x99D8C8F7),
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                    ),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Schließen'),
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

Future<void> _handleImageUpload(BuildContext context) async {
  final source = await _pickSource(context);
  if (source == null) return;

  XFile? image;
  try {
    image = await ImagePicker().pickImage(source: source, imageQuality: 85);
  } catch (_) {
    return;
  }
  if (image == null) return;
  if (!context.mounted) return;

  _showImagePreviewDialog(context, image.path);
}

Future<ImageSource?> _pickSource(BuildContext context) {
  return showDialog<ImageSource>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: const Color(0xFF140F1F),
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
              'Schriftprobe auswählen',
              style: Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                color: const Color(0xFFFFE9B0),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Wähle eine Quelle für deine Schriftprobe',
              style: Theme.of(dialogContext).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFD8C8F7),
              ),
            ),
            const SizedBox(height: 22),
            _SourceButton(
              icon: Icons.camera_alt_rounded,
              label: 'Kamera',
              onTap: () => Navigator.pop(dialogContext, ImageSource.camera),
            ),
            const SizedBox(height: 10),
            _SourceButton(
              icon: Icons.photo_library_rounded,
              label: 'Galerie',
              onTap: () => Navigator.pop(dialogContext, ImageSource.gallery),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Abbrechen'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showImagePreviewDialog(BuildContext context, String imagePath) {
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
          backgroundColor: const Color(0xFF140F1F),
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                  BoxShadow(
                    color: Color(0x1A7A4DCC),
                    blurRadius: 18,
                    offset: Offset(0, 6),
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
                      '✒️ Schriftprobe',
                      style: Theme.of(dialogContext).textTheme.titleLarge
                          ?.copyWith(
                            color: const Color(0xFFFFE9B0),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Madame Gatto nimmt deine Schriftprobe entgegen',
                      style: Theme.of(dialogContext).textTheme.bodySmall
                          ?.copyWith(
                            color: const Color(0xFFD8C8F7),
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
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Container(
                            height: 160,
                            alignment: Alignment.center,
                            color: const Color(0x2A130F1F),
                            child: const Icon(
                              Icons.broken_image_rounded,
                              color: Color(0xFFD8C8F7),
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
                          'Schriftprobe erfolgreich geladen',
                          style: Theme.of(dialogContext).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFFD4C8F0)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0x3A1A0F30), Color(0x2A14102A)],
                        ),
                        border: Border.all(color: const Color(0x66DAB86E)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Die automatische Analyse befindet sich noch in Entwicklung.',
                            style: Theme.of(dialogContext).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFFFFE9B0),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Madame Gatto kann bereits Schriftproben entgegennehmen. '
                            'Die intelligente Analyse folgt in einer zukünftigen Version.',
                            style: Theme.of(dialogContext).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFFD4C8F0),
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: const Text('Schließen'),
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
          foregroundColor: const Color(0xFFEADBAF),
          side: const BorderSide(color: Color(0x77D5B46B)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _TraitTile extends StatelessWidget {
  const _TraitTile({required this.trait});

  final GraphologyTrait trait;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x3C1A0F2E), Color(0x2A130F22)],
        ),
        border: Border.all(color: const Color(0x88DAB86E), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3A100D1B),
            blurRadius: 14,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                trait.symbol,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFFFFE9B0),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      trait.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFFFFE9B0),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Merkmal',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFFD8C8F7),
                        letterSpacing: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            trait.meaning,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFD4C8F0),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0x20130F1F),
              border: Border.all(color: const Color(0x44D0B16F)),
            ),
            child: Text(
              trait.catMessage,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xCCF1E9FF),
                height: 1.45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GraphologyOptionTile extends StatelessWidget {
  const _GraphologyOptionTile({
    required this.title,
    this.subtitle,
    this.icon = Icons.edit_note_rounded,
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
        color: const Color(0x2B161126),
        border: Border.all(color: const Color(0x66D5B46B), width: 0.9),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40100D1B),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x182F1F4F),
            blurRadius: 10,
            offset: Offset(0, 3),
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
            color: const Color(0x33432D63),
            border: Border.all(color: const Color(0x73E1C27A)),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFFFFD98A),
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: const Color(0xFFF4E9FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xAAD8C8F7),
                ),
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
