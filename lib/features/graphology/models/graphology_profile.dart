enum LetterSize { small, medium, large }

enum Slant { left, straight, right }

enum Baseline { rising, straight, falling }

enum Spacing { narrow, normal, wide }

enum Pressure { light, medium, heavy }

enum Shape { round, mixed, angular }

enum SignatureStyle { small, normal, dominant }

class GraphologyProfile {
  const GraphologyProfile({
    required this.letterSize,
    required this.slant,
    required this.baseline,
    required this.spacing,
    required this.pressure,
    required this.shape,
    required this.signatureStyle,
  });

  final LetterSize letterSize;
  final Slant slant;
  final Baseline baseline;
  final Spacing spacing;
  final Pressure pressure;
  final Shape shape;
  final SignatureStyle signatureStyle;
}
