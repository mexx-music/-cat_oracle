import 'package:cat_oracle/features/astrology/logic/astrology_reading_composer.dart';
import 'package:cat_oracle/features/astrology/models/zodiac_sign.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('composeDemoAstrologyReading', () {
    test('erzeugt Text mit Sonnenzeichen', () {
      final text = composeDemoAstrologyReading(
        sunSign: ZodiacSign.aries,
        moonSign: ZodiacSign.cancer,
        ascendant: ZodiacSign.leo,
      );

      expect(text.toLowerCase(), contains('widder'));
    });

    test('funktioniert ohne Mondzeichen', () {
      final text = composeDemoAstrologyReading(
        sunSign: ZodiacSign.taurus,
        moonSign: null,
        ascendant: ZodiacSign.libra,
      );

      expect(text.toLowerCase(), contains('mondzeichen'));
      expect(text, isNotEmpty);
    });

    test('funktioniert ohne Aszendent', () {
      final text = composeDemoAstrologyReading(
        sunSign: ZodiacSign.gemini,
        moonSign: ZodiacSign.virgo,
        ascendant: null,
      );

      expect(text.toLowerCase(), contains('aszendent'));
      expect(text, isNotEmpty);
    });

    test('gibt keinen leeren Text zurück', () {
      final text = composeDemoAstrologyReading(
        sunSign: ZodiacSign.pisces,
        moonSign: null,
        ascendant: null,
      );

      expect(text.trim(), isNotEmpty);
    });
  });
}
