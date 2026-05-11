import 'package:cat_oracle/features/astrology/models/astrology_profile.dart';
import 'package:cat_oracle/features/oracle/models/combined_oracle_reading.dart';
import 'package:cat_oracle/features/palmistry/models/palmistry_profile.dart';

class OracleSessionService {
  OracleSessionService._();

  static final OracleSessionService instance = OracleSessionService._();

  AstrologyProfile? astrologyProfile;
  PalmistryProfile? palmistryProfile;
  CombinedOracleReading? combinedReading;

  void setAstrologyProfile(AstrologyProfile profile) {
    astrologyProfile = profile;
  }

  void clearAstrologyProfile() {
    astrologyProfile = null;
  }

  void setPalmistryProfile(PalmistryProfile profile) {
    palmistryProfile = profile;
  }

  void clearPalmistryProfile() {
    palmistryProfile = null;
  }

  void setCombinedReading(CombinedOracleReading reading) {
    combinedReading = reading;
  }

  void clearCombinedReading() {
    combinedReading = null;
  }

  void clearAll() {
    astrologyProfile = null;
    palmistryProfile = null;
    combinedReading = null;
  }
}
