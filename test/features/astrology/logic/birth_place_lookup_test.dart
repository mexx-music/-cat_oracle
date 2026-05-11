import 'package:cat_oracle/features/astrology/logic/birth_place_lookup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BirthPlaceLookup', () {
    test('"Wien" findet Wien', () {
      final result = findBirthPlaceByName('Wien');

      expect(result, isNotNull);
      expect(result?.cityName, 'Wien');
    });

    test('"wien" findet Wien', () {
      final result = findBirthPlaceByName('wien');

      expect(result, isNotNull);
      expect(result?.cityName, 'Wien');
    });

    test('"  Wien  " findet Wien', () {
      final result = findBirthPlaceByName('  Wien  ');

      expect(result, isNotNull);
      expect(result?.cityName, 'Wien');
    });

    test('"Trond" findet Trondheim', () {
      final result = findBirthPlaceByName('Trond');

      expect(result, isNotNull);
      expect(result?.cityName, 'Trondheim');
    });

    test('unbekannter Ort gibt null zurück', () {
      final result = findBirthPlaceByName('Atlantis');

      expect(result, isNull);
    });
  });
}
