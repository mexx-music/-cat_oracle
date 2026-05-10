import 'zodiac_sign.dart';

class AstrologyProfile {
  const AstrologyProfile({
    required this.sunSign,
    this.moonSign,
    this.ascendant,
  });

  final ZodiacSign sunSign;
  final ZodiacSign? moonSign;
  final ZodiacSign? ascendant;
}
