import 'package:cat_oracle/features/astrology/data/demo_city_coordinates.dart';
import 'package:cat_oracle/features/astrology/models/birth_place_coordinates.dart';

BirthPlaceCoordinates? findBirthPlaceByName(String input) {
  final query = input.trim().toLowerCase();
  if (query.isEmpty) {
    return null;
  }

  for (final place in demoCityCoordinates) {
    if (place.cityName.toLowerCase() == query) {
      return place;
    }
  }

  for (final place in demoCityCoordinates) {
    if (place.cityName.toLowerCase().startsWith(query)) {
      return place;
    }
  }

  return null;
}
