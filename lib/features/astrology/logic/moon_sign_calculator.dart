import 'package:cat_oracle/features/astrology/models/zodiac_sign.dart';

ZodiacSign calculateDemoMoonSign(DateTime birthDate) {
  final dayIndex = (birthDate.day - 1) % ZodiacSign.values.length;
  return ZodiacSign.values[dayIndex];
}
