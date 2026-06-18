import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/demo_tarot_cards.dart';
import '../../models/tarot_card.dart';

Future<TarotCard?> showTarotDrawOverlay(BuildContext context) {
  return showDialog<TarotCard>(
    context: context,
    barrierColor: const Color(0xCC06030F),
    builder: (_) => const TarotDrawOverlay(),
  );
}

int _gridCols(double width) {
  if (width >= 480) return 7;
  if (width >= 300) return 5;
  return 4;
}

class TarotDrawOverlay extends StatelessWidget {
  const TarotDrawOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0D0919),
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x88DAB86E), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x44300060),
                blurRadius: 40,
                spreadRadius: 4,
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '🃏 Wähle eine Karte',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Madame Gatto mischt das Deck',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0x99D8C8F7),
                    letterSpacing: 0.3,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0x33DAB86E), thickness: 0.8),
                const SizedBox(height: 14),
                LayoutBuilder(
                  builder: (ctx, constraints) {
                    final cols = _gridCols(constraints.maxWidth);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: demoTarotCards.length,
                      itemBuilder: (_, i) => _CardBack(index: i),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
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

class _CardBack extends StatefulWidget {
  final int index;

  const _CardBack({required this.index});

  @override
  State<_CardBack> createState() => _CardBackState();
}

class _CardBackState extends State<_CardBack> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () {
          final card = demoTarotCards[Random().nextInt(demoTarotCards.length)];
          Navigator.of(context).pop(card);
        },
        child: AnimatedScale(
          scale: _hovered ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDAB86E), width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x35DAB86E),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                'assets/images/tarot/tarot_back.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A0F2E), Color(0xFF110C1F)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.index.isEven ? '🐾' : '🃏',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
