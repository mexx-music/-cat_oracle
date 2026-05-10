import 'palm_line_type.dart';

class PalmLineReading {
  const PalmLineReading({
    required this.type,
    required this.title,
    required this.summary,
    required this.confidence,
  });

  final PalmLineType type;
  final String title;
  final String summary;
  final double confidence;
}
