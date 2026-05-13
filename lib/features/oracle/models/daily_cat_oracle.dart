class DailyCatOracle {
  const DailyCatOracle({
    required this.title,
    required this.message,
    required this.mood,
    required this.createdAt,
  });

  final String title;
  final String message;
  final String mood;
  final DateTime createdAt;
}
