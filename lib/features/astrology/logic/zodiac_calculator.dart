import 'package:cat_oracle/features/astrology/models/zodiac_sign.dart';

/// Berechnet das Sternzeichen basierend auf dem Geburtsdatum.
/// Verwendung: ZodiacSign sign = calculateSunSign(DateTime(1990, 3, 21));
ZodiacSign calculateSunSign(DateTime birthDate) {
  final month = birthDate.month;
  final day = birthDate.day;

  // Sternzeichen-Grenzen (Tag.Monat – Tag.Monat)
  // Aries: 21.03 – 19.04
  if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
    return ZodiacSign.aries;
  }

  // Taurus: 20.04 – 20.05
  if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
    return ZodiacSign.taurus;
  }

  // Gemini: 21.05 – 20.06
  if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
    return ZodiacSign.gemini;
  }

  // Cancer: 21.06 – 22.07
  if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
    return ZodiacSign.cancer;
  }

  // Leo: 23.07 – 22.08
  if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
    return ZodiacSign.leo;
  }

  // Virgo: 23.08 – 22.09
  if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
    return ZodiacSign.virgo;
  }

  // Libra: 23.09 – 22.10
  if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
    return ZodiacSign.libra;
  }

  // Scorpio: 23.10 – 21.11
  if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
    return ZodiacSign.scorpio;
  }

  // Sagittarius: 22.11 – 21.12
  if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
    return ZodiacSign.sagittarius;
  }

  // Capricorn: 22.12 – 19.01
  if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
    return ZodiacSign.capricorn;
  }

  // Aquarius: 20.01 – 18.02
  if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
    return ZodiacSign.aquarius;
  }

  // Pisces: 19.02 – 20.03
  if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) {
    return ZodiacSign.pisces;
  }

  // Fallback (sollte nicht erreicht werden)
  return ZodiacSign.aries;
}
