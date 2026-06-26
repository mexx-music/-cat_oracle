class GrandOracleReading {
  const GrandOracleReading({
    required this.title,
    required this.mood,
    required this.strengths,
    required this.challenge,
    required this.catAdvice,
    required this.luckySymbol,
    required this.pawRating,
    required this.summaryText,
    required this.completedModules,
  });

  final String title;
  final String mood;
  final String strengths;
  final String challenge;
  final String catAdvice;
  final String luckySymbol;

  /// 1–5 paw rating.
  final int pawRating;

  final String summaryText;

  /// How many of the 4 modules contributed to this reading.
  final int completedModules;

  bool get isComplete => completedModules == 4;
}
