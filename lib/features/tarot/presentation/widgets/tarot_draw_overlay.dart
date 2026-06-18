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

class TarotDrawOverlay extends StatefulWidget {
  const TarotDrawOverlay({super.key});

  @override
  State<TarotDrawOverlay> createState() => _TarotDrawOverlayState();
}

class _TarotDrawOverlayState extends State<TarotDrawOverlay> {
  int? _selectedIndex;
  TarotCard? _revealedCard;
  bool _isRevealing = false;

  Future<void> _onCardTapped(int index) async {
    if (_isRevealing) return;
    final card = demoTarotCards[Random().nextInt(demoTarotCards.length)];
    setState(() {
      _selectedIndex = index;
      _revealedCard = card;
      _isRevealing = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) Navigator.of(context).pop(_revealedCard);
  }

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
                      itemBuilder: (_, i) => _CardBack(
                        index: i,
                        isRevealing: _isRevealing,
                        isSelected: _selectedIndex == i,
                        revealedCard: _selectedIndex == i ? _revealedCard : null,
                        onTap: () => _onCardTapped(i),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _isRevealing ? null : () => Navigator.of(context).pop(),
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

// ---------------------------------------------------------------------------

class _CardBack extends StatefulWidget {
  final int index;
  final bool isRevealing;
  final bool isSelected;
  final TarotCard? revealedCard;
  final VoidCallback onTap;

  const _CardBack({
    required this.index,
    required this.isRevealing,
    required this.isSelected,
    required this.onTap,
    this.revealedCard,
  });

  @override
  State<_CardBack> createState() => _CardBackState();
}

class _CardBackState extends State<_CardBack> {
  bool _hovered = false;

  bool get _showFront => widget.isSelected && widget.revealedCard != null;
  bool get _effectiveHovered => _hovered && !widget.isRevealing;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.isSelected ? const Color(0xFFFFD700) : const Color(0xFFDAB86E);
    final borderWidth = widget.isSelected ? 2.0 : 1.0;
    final glowColor =
        widget.isSelected ? const Color(0x66FFD700) : const Color(0x35DAB86E);
    final glowBlur = widget.isSelected ? 18.0 : 8.0;
    final glowSpread = widget.isSelected ? 2.0 : 0.0;

    return MouseRegion(
      cursor: widget.isRevealing
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: widget.isRevealing ? null : (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.isRevealing ? null : widget.onTap,
        child: AnimatedScale(
          scale: (_effectiveHovered || widget.isSelected) ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: [
                BoxShadow(
                  color: glowColor,
                  blurRadius: glowBlur,
                  spreadRadius: glowSpread,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(
                      begin: 0.82,
                      end: 1.0,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    )),
                    child: child,
                  ),
                ),
                child: _showFront
                    ? _CardFrontImage(
                        key: const ValueKey('front'),
                        card: widget.revealedCard!,
                      )
                    : _CardBackImage(
                        key: ValueKey('back_${widget.index}'),
                        index: widget.index,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CardBackImage extends StatelessWidget {
  final int index;

  const _CardBackImage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
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
            index.isEven ? '🐾' : '🃏',
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ),
    );
  }
}

class _CardFrontImage extends StatelessWidget {
  final TarotCard card;

  const _CardFrontImage({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final asset = card.imageAsset;
    if (asset == null) return _fallback();
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFF1A0F2E),
      child: Center(
        child: Text(
          card.symbol,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}
