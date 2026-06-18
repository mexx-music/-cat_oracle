import 'dart:math';

import 'package:flutter/material.dart';

import '../../data/demo_tarot_cards.dart';
import '../../models/tarot_card.dart';

/// Single-card draw — original API unchanged.
Future<TarotCard?> showTarotDrawOverlay(BuildContext context) async {
  final cards = await showTarotMultiDrawOverlay(context, count: 1);
  return cards?.first;
}

/// Multi-card draw. [positionLabels] is shown in the subtitle while the user
/// picks, e.g. ["Vergangenheit", "Gegenwart", "Impuls"].
Future<List<TarotCard>?> showTarotMultiDrawOverlay(
  BuildContext context, {
  required int count,
  List<String>? positionLabels,
}) {
  return showDialog<List<TarotCard>>(
    context: context,
    barrierColor: const Color(0xCC06030F),
    builder: (_) => TarotDrawOverlay(count: count, positionLabels: positionLabels),
  );
}

// ---------------------------------------------------------------------------

int _gridCols(double width) {
  if (width >= 480) return 7;
  if (width >= 300) return 5;
  return 4;
}

String _staticTitle(int count) {
  switch (count) {
    case 1:
      return '🃏 Wähle eine Karte';
    case 3:
      return '🃏 Wähle drei Karten';
    default:
      return '🃏 Wähle $count Karten';
  }
}

// ---------------------------------------------------------------------------

class TarotDrawOverlay extends StatefulWidget {
  final int count;
  final List<String>? positionLabels;

  const TarotDrawOverlay({
    super.key,
    this.count = 1,
    this.positionLabels,
  });

  @override
  State<TarotDrawOverlay> createState() => _TarotDrawOverlayState();
}

class _TarotDrawOverlayState extends State<TarotDrawOverlay> {
  final List<int> _selectedIndices = [];
  final List<TarotCard> _revealedCards = [];
  bool _isRevealing = false;
  bool _isDone = false;

  bool get _blocked => _isRevealing || _isDone;

  /// Subtitle shown below the title; updates with each card pick.
  String get _subtitle {
    if (_isDone) return 'Madame Gatto legt die Karten …';
    final labels = widget.positionLabels;
    if (labels != null && _revealedCards.length < labels.length) {
      return 'Wähle die Karte für: ${labels[_revealedCards.length]}';
    }
    // Fallback for count=1 or no labels
    return widget.count == 3
        ? 'Wähle drei Karten nacheinander'
        : 'Madame Gatto mischt das Deck';
  }

  Future<void> _onCardTapped(int index) async {
    if (_blocked) return;
    if (_selectedIndices.contains(index)) return;

    final pool =
        demoTarotCards.where((c) => !_revealedCards.contains(c)).toList();
    if (pool.isEmpty) return;
    final card = pool[Random().nextInt(pool.length)];

    setState(() {
      _selectedIndices.add(index);
      _revealedCards.add(card);
      _isRevealing = true;
    });

    final allDone = _revealedCards.length >= widget.count;

    if (!allDone) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() => _isRevealing = false);
    } else {
      setState(() => _isDone = true);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.of(context)
            .pop(List<TarotCard>.unmodifiable(_revealedCards));
      }
    }
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
                  _staticTitle(widget.count),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFFFFE9B0),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _subtitle,
                    key: ValueKey(_subtitle),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0x99D8C8F7),
                      letterSpacing: 0.3,
                      fontSize: 11,
                    ),
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
                      itemBuilder: (_, i) {
                        final pos = _selectedIndices.indexOf(i);
                        final isSelected = pos >= 0;
                        return _CardBack(
                          index: i,
                          blocked: _blocked,
                          isSelected: isSelected,
                          revealedCard:
                              isSelected ? _revealedCards[pos] : null,
                          onTap: () => _onCardTapped(i),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed:
                        _blocked ? null : () => Navigator.of(context).pop(),
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
  final bool blocked;
  final bool isSelected;
  final TarotCard? revealedCard;
  final VoidCallback onTap;

  const _CardBack({
    required this.index,
    required this.blocked,
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
  bool get _effectiveHovered =>
      _hovered && !widget.blocked && !widget.isSelected;

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
      cursor: (widget.blocked || widget.isSelected)
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (widget.blocked || widget.isSelected)
          ? null
          : (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: (widget.blocked || widget.isSelected) ? null : widget.onTap,
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
                    scale: Tween<double>(begin: 0.82, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      ),
                    ),
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

  Widget _fallback() => Container(
        color: const Color(0xFF1A0F2E),
        child: Center(
          child: Text(card.symbol, style: const TextStyle(fontSize: 28)),
        ),
      );
}
