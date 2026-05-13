import 'package:flutter/material.dart';

import 'package:cat_oracle/features/astrology/models/zodiac_sign.dart';

// Demo-Approximation: Diese Funktion ist keine echte Aszendenten-Berechnung.
ZodiacSign? calculateDemoAscendant({
  required TimeOfDay? birthTime,
  required double? longitude,
}) {
  if (birthTime == null || longitude == null) {
    return null;
  }

  final rawIndex = birthTime.hour + (longitude / 30).round();
  final normalizedIndex = ((rawIndex % 12) + 12) % 12;
  return ZodiacSign.values[normalizedIndex];
}
