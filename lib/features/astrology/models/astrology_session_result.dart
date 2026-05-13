import 'astrology_profile.dart';

class AstrologySessionResult {
  const AstrologySessionResult({
    required this.profile,
    required this.composedReading,
    required this.createdAt,
  });

  final AstrologyProfile profile;
  final String composedReading;
  final DateTime createdAt;
}
