import 'package:cat_oracle/features/astrology/models/astrology_profile.dart';
import 'package:cat_oracle/features/astrology/models/astrology_session_result.dart';
import 'package:cat_oracle/features/graphology/models/graphology_profile.dart';
import 'package:cat_oracle/features/graphology/models/graphology_trait.dart';
import 'package:cat_oracle/features/oracle/models/combined_oracle_reading.dart';
import 'package:cat_oracle/features/palmistry/models/palm_trait.dart';
import 'package:cat_oracle/features/palmistry/models/palmistry_analysis_profile.dart';
import 'package:cat_oracle/features/palmistry/models/palmistry_profile.dart';
import 'package:cat_oracle/features/tarot/models/tarot_card.dart';
import 'package:cat_oracle/features/hand_scan/models/scanned_hand.dart';
import 'package:flutter/foundation.dart';

class OracleSessionService extends ChangeNotifier {
  OracleSessionService._();

  static final OracleSessionService instance = OracleSessionService._();

  // ── Existing fields ────────────────────────────────────────────────────────

  AstrologyProfile? astrologyProfile;
  AstrologySessionResult? astrologySessionResult;
  PalmistryProfile? palmistryProfile;
  CombinedOracleReading? combinedReading;

  // ── Grand Reading fields ───────────────────────────────────────────────────

  TarotCard? lastDrawnTarotCard;

  PalmistryAnalysisProfile? palmistryAnalysisProfile;
  List<PalmTrait>? palmistryTraits;
  ScannedHand palmistryScannedHand = ScannedHand.unknown;

  GraphologyProfile? graphologyProfile;
  List<GraphologyTrait>? graphologyTraits;

  // ── Existing setters ───────────────────────────────────────────────────────

  void setAstrologyProfile(AstrologyProfile profile) {
    astrologyProfile = profile;
  }

  void clearAstrologyProfile() {
    astrologyProfile = null;
  }

  void setAstrologySessionResult(AstrologySessionResult result) {
    astrologySessionResult = result;
    notifyListeners();
  }

  void clearAstrologySessionResult() {
    astrologySessionResult = null;
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

  // ── Grand Reading setters ──────────────────────────────────────────────────

  void setLastDrawnTarotCard(TarotCard card) {
    lastDrawnTarotCard = card;
    notifyListeners();
  }

  void setPalmistryAnalysis({
    required PalmistryAnalysisProfile profile,
    required List<PalmTrait> traits,
    ScannedHand? scannedHand,
  }) {
    palmistryAnalysisProfile = profile;
    palmistryTraits = traits;
    palmistryScannedHand = scannedHand ?? profile.scannedHand;
    notifyListeners();
  }

  void setGraphologyAnalysis({
    required GraphologyProfile profile,
    required List<GraphologyTrait> traits,
  }) {
    graphologyProfile = profile;
    graphologyTraits = traits;
    notifyListeners();
  }

  // ── Completion status ──────────────────────────────────────────────────────

  bool get hasTarot => lastDrawnTarotCard != null;
  bool get hasAstrology => astrologySessionResult != null;
  bool get hasPalmistry => palmistryAnalysisProfile != null;
  bool get hasGraphology => graphologyProfile != null;

  int get completedCount =>
      (hasTarot ? 1 : 0) +
      (hasAstrology ? 1 : 0) +
      (hasPalmistry ? 1 : 0) +
      (hasGraphology ? 1 : 0);

  bool get isGrandReadingReady => completedCount >= 1;

  // ── Clear all ──────────────────────────────────────────────────────────────

  void clearAll() {
    astrologyProfile = null;
    astrologySessionResult = null;
    palmistryProfile = null;
    combinedReading = null;
    lastDrawnTarotCard = null;
    palmistryAnalysisProfile = null;
    palmistryTraits = null;
    palmistryScannedHand = ScannedHand.unknown;
    graphologyProfile = null;
    graphologyTraits = null;
  }
}
