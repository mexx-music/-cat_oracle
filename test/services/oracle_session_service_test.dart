import 'package:cat_oracle/features/astrology/models/astrology_profile.dart';
import 'package:cat_oracle/features/astrology/models/astrology_session_result.dart';
import 'package:cat_oracle/features/astrology/models/zodiac_sign.dart';
import 'package:cat_oracle/features/oracle/models/combined_oracle_reading.dart';
import 'package:cat_oracle/features/palmistry/models/palm_line_reading.dart';
import 'package:cat_oracle/features/palmistry/models/palm_line_type.dart';
import 'package:cat_oracle/features/palmistry/models/palmistry_profile.dart';
import 'package:cat_oracle/services/oracle_session_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = OracleSessionService.instance;

  setUp(() {
    service.clearAll();
  });

  tearDown(() {
    service.clearAll();
  });

  test('AstrologyProfile speichern', () {
    final profile = AstrologyProfile(
      sunSign: ZodiacSign.aries,
      moonSign: ZodiacSign.cancer,
      ascendant: ZodiacSign.leo,
    );

    service.setAstrologyProfile(profile);

    expect(service.astrologyProfile, profile);
  });

  test('AstrologyProfile löschen', () {
    service.setAstrologyProfile(
      const AstrologyProfile(sunSign: ZodiacSign.taurus),
    );

    service.clearAstrologyProfile();

    expect(service.astrologyProfile, isNull);
  });

  test('AstrologySessionResult speichern', () {
    final result = AstrologySessionResult(
      profile: const AstrologyProfile(sunSign: ZodiacSign.aries),
      composedReading: 'Demo reading',
      createdAt: DateTime(2026, 5, 13),
    );

    service.setAstrologySessionResult(result);

    expect(service.astrologySessionResult, result);
  });

  test('clearAll funktioniert', () {
    service.setAstrologyProfile(
      const AstrologyProfile(sunSign: ZodiacSign.gemini),
    );
    service.setAstrologySessionResult(
      AstrologySessionResult(
        profile: const AstrologyProfile(sunSign: ZodiacSign.gemini),
        composedReading: 'Demo reading',
        createdAt: DateTime(2026, 5, 13),
      ),
    );
    service.setPalmistryProfile(
      const PalmistryProfile(
        lineReadings: [
          PalmLineReading(
            type: PalmLineType.lifeLine,
            title: 'Lebenslinie',
            summary: 'Stabil und ruhig.',
            confidence: 0.8,
          ),
        ],
      ),
    );
    service.setCombinedReading(
      const CombinedOracleReading(
        palmistrySummary: 'Palmistry',
        astrologySummary: 'Astrology',
        combinedCatMessage: 'Combined',
      ),
    );

    service.clearAll();

    expect(service.astrologyProfile, isNull);
    expect(service.astrologySessionResult, isNull);
    expect(service.palmistryProfile, isNull);
    expect(service.combinedReading, isNull);
  });
}
