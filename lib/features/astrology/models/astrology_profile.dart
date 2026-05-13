import 'zodiac_sign.dart';

class AstrologyProfile {
  const AstrologyProfile({
    required this.sunSign,
    this.moonSign,
    this.ascendant,
    this.birthDate,
    this.birthTimeLabel,
    this.birthPlaceName,
    this.birthPlaceCountry,
    this.latitude,
    this.longitude,
  });

  final ZodiacSign sunSign;
  final ZodiacSign? moonSign;
  final ZodiacSign? ascendant;
  final DateTime? birthDate;
  final String? birthTimeLabel;
  final String? birthPlaceName;
  final String? birthPlaceCountry;
  final double? latitude;
  final double? longitude;
}
