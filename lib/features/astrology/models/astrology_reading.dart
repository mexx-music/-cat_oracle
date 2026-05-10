import 'zodiac_sign.dart';

class AstrologyReading {
  const AstrologyReading({
    required this.title,
    required this.summary,
    required this.zodiacSign,
  });

  final String title;
  final String summary;
  final ZodiacSign zodiacSign;
}
