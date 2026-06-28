// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Madame Gatto Futuro';

  @override
  String get homeTitle => '🐾 Cat Oracle 🔮';

  @override
  String get homeSubtitle => 'Your Cat Oracle Reading';

  @override
  String get homeDescription =>
      'Discover tarot, astrology, graphology and palm reading in the mystical style of Madame Gatto Futuro.';

  @override
  String get homePalmistryTitle => 'Palm Reading';

  @override
  String get homePalmistrySubtitle => 'Read your lines';

  @override
  String get homeOracleTitle => 'Demo Reading';

  @override
  String get homeOracleSubtitle => 'View the cat oracle';

  @override
  String get homeAstrologyTitle => 'Astrology';

  @override
  String get homeAstrologySubtitle => 'Stars & signs';

  @override
  String get homeTarotTitle => 'Tarot';

  @override
  String get homeTarotSubtitle => 'The cards whisper';

  @override
  String get homeGraphologyTitle => 'Graphology';

  @override
  String get homeGraphologySubtitle => 'Writing reveals character';

  @override
  String get homeGrandReadingTitle => 'Grand Reading';

  @override
  String get homeGrandReadingEmpty => 'Collect signs first';

  @override
  String get homeGrandReadingPartial => 'Start partial reading';

  @override
  String get homeGrandReadingReady => 'Start grand reading';

  @override
  String get grandReadingTitle => 'Madame Gatto\'s Grand Reading';

  @override
  String get grandReadingSubtitlePartial => 'Partial reading';

  @override
  String get grandReadingSubtitleComplete => 'All signs gathered';

  @override
  String grandReadingProgress(int count) {
    return '$count of 4 signs gathered';
  }

  @override
  String get grandReadingMoodLabel => 'Overall mood';

  @override
  String get grandReadingStrengthsLabel => 'Your strength';

  @override
  String get grandReadingChallengeLabel => 'Your challenge';

  @override
  String get grandReadingCatAdviceLabel => 'Madame Gatto\'s advice';

  @override
  String get grandReadingLuckySymbolLabel => 'Lucky symbol';

  @override
  String get grandReadingPawRatingLabel => 'Paw rating';

  @override
  String get grandReadingSummaryLabel => 'Overall reading';

  @override
  String get grandReadingDisclaimer =>
      'Symbolic entertainment – no predictions, no diagnosis.';

  @override
  String get grandReadingEmptyHint =>
      'Visit Tarot, Astrology, Palm reading or Graphology to collect signs.';

  @override
  String get grandReadingComplete => 'Grand reading complete';

  @override
  String grandReadingModulesUsed(int count) {
    return '$count of 4 modules';
  }

  @override
  String get tarotTitle => 'Tarot';

  @override
  String get tarotSubtitle => 'The cards whisper';

  @override
  String get tarotDailyCard => 'Daily Card';

  @override
  String get tarotDrawCard => 'Draw a Card';

  @override
  String get tarotThreeCardSpread => 'Three-Card Spread';

  @override
  String get tarotLoveRelationships => 'Love & Relationships';

  @override
  String get tarotMajorArcana => 'Major Arcana';

  @override
  String get tarotClose => 'Close';

  @override
  String get tarotPast => 'Past';

  @override
  String get tarotPresent => 'Present';

  @override
  String get tarotImpulse => 'Impulse';

  @override
  String get tarotSelf => 'You';

  @override
  String get tarotConnection => 'Connection';

  @override
  String get tarotLoveReading => 'Love Reading';

  @override
  String get tarotOverallReading => 'Overall Reading';

  @override
  String get tarotDailyRenewHint => 'This card renews daily.';

  @override
  String get tarotTeaserText =>
      'Draw a card or open a spread. Madame Gatto reads the symbols in simple language.';

  @override
  String get tarotOpenDailyCard => 'Open Daily Card';

  @override
  String get tarotDrawnCardTitle => 'Drawn Card';

  @override
  String get palmistryTitle => 'Palm Reading';

  @override
  String get palmistrySubtitle => 'Your hand tells its lines';

  @override
  String get palmistryTeaserText =>
      'Madame Gatto reads the life line, heart line, head line and fate line – symbolically and without judgement.';

  @override
  String get palmistryUploadButton => 'Upload palm print';

  @override
  String get palmistryUploadSubtitle => 'Choose a photo of your palm';

  @override
  String get palmistryStartAnalysis => 'Start analysis';

  @override
  String get palmistryPreviewTitle => 'Palm print';

  @override
  String get palmistryPreviewSubtitle =>
      'Madame Gatto receives your palm print';

  @override
  String get palmistryImageLoaded => 'Palm print loaded successfully';

  @override
  String get palmistryScannedHandQuestion => 'Which hand was scanned?';

  @override
  String get palmistryScannedHandHint =>
      'This describes the real hand. The image thumb side stays separate.';

  @override
  String get palmistryLeftHand => 'Left hand';

  @override
  String get palmistryRightHand => 'Right hand';

  @override
  String get palmistryUnknownHand => 'Unknown hand';

  @override
  String palmistryAnalyzedHand(String hand) {
    return 'Analyzed hand: $hand';
  }

  @override
  String get palmistryAnalysisTitle => 'Palm Line Analysis';

  @override
  String get palmistryAnalysisSubtitle =>
      'Madame Gatto reads the lines of your hand';

  @override
  String get palmistryOverallReading => '✨ Overall Reading';

  @override
  String get palmistrySymbolicNote =>
      'Symbolic analysis – for entertainment only';

  @override
  String get palmistryDisclaimer =>
      'This reading is symbolic, does not constitute a diagnosis, and makes no predictions about the future.';

  @override
  String get palmistryTraitLabel => 'Line';

  @override
  String get palmistryClose => 'Close';

  @override
  String get palmistryCancel => 'Cancel';

  @override
  String get palmistryPickSource => 'Select palm print';

  @override
  String get palmistryPickSourceHint => 'Choose a source for your palm photo';

  @override
  String get palmistryCamera => 'Camera';

  @override
  String get palmistryGallery => 'Gallery';

  @override
  String get imagePickError =>
      'The image could not be loaded. Please try again.';

  @override
  String get cameraMacOSNotAvailable =>
      'Camera capture is not yet available on macOS in this version. Please use \'Select image\' instead.';

  @override
  String get cameraPermissionDenied =>
      'Camera access was denied. Please allow access in System Settings.';

  @override
  String get graphologySubtitle => 'Your writing whispers softly';

  @override
  String get graphologySampleTitle => 'Handwriting Sample';

  @override
  String get graphologySampleSubtitle =>
      'Madame Gatto receives your handwriting sample';

  @override
  String get graphologyTraitLabel => 'Trait';

  @override
  String get graphologyTeaserText =>
      'Madame Gatto reads the form, rhythm and energy of your writing – symbolically and without judgement.';

  @override
  String get graphologyUploadButton => 'Upload handwriting sample';

  @override
  String get graphologyUploadSubtitle => 'Choose a photo of handwriting';

  @override
  String get graphologyStartAnalysis => 'Start analysis';

  @override
  String get graphologyAnalysisTitle => 'Handwriting Analysis';

  @override
  String get graphologyAnalysisSubtitle =>
      'Madame Gatto reads the traces of your writing';

  @override
  String get graphologyOverallReading => '✨ Overall Reading';

  @override
  String get graphologySymbolicNote =>
      'Symbolic analysis – for entertainment only';

  @override
  String get graphologyDisclaimer =>
      'This reading is symbolic and does not replace professional analysis.';

  @override
  String get graphologyClose => 'Close';

  @override
  String get graphologyCancel => 'Cancel';

  @override
  String get graphologyImageLoaded => 'Handwriting sample loaded successfully';

  @override
  String get graphologyPickSource => 'Select handwriting sample';

  @override
  String get graphologyPickSourceHint =>
      'Choose a source for your handwriting sample';

  @override
  String get graphologyCamera => 'Camera';

  @override
  String get graphologyGallery => 'Gallery';

  @override
  String get onboardingPage1Title => 'Welcome to Madame Gatto';

  @override
  String get onboardingPage1Body =>
      'Madame Gatto Futuro guides you through Tarot, Astrology, Palm Reading and Graphology – mystical, playful and always with a wink.';

  @override
  String get onboardingPage2Title => 'Your four signs';

  @override
  String get onboardingPage2Body =>
      'Show your palm, let the cards speak, gaze at the stars or reveal your handwriting. Each sign tells something about you.';

  @override
  String get onboardingPage3Title => 'Unlock the Grand Reading';

  @override
  String get onboardingPage3Body =>
      'Once you have visited all four modules, Madame Gatto can create a Grand Reading – a combined interpretation of all your signs.';

  @override
  String get onboardingPage4Title => 'A note beforehand';

  @override
  String get onboardingPage4Body =>
      'Cat Oracle is symbolic entertainment. No predictions, no diagnosis, no substitute for professional advice. Madame Gatto purrs – but does not foretell.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingBegin => 'Begin';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguageLabel => 'Language';

  @override
  String get settingsActionsLabel => 'Actions';

  @override
  String get settingsAppInfoLabel => 'App Info';

  @override
  String get settingsAppVersion => 'Version 1.0';

  @override
  String get settingsDisclaimerLabel => 'Notice';

  @override
  String get settingsDisclaimerText =>
      'Cat Oracle is entertainment only. The readings are symbolic and based on random algorithms. They do not constitute a diagnosis, life advice or prediction of the future.';

  @override
  String get settingsResetOnboarding => 'Show onboarding again';

  @override
  String get settingsResetSession => 'Reset session';

  @override
  String get settingsResetSessionConfirm =>
      'All collected signs (Tarot, Astrology, Palm Reading, Graphology) will be deleted. Continue?';

  @override
  String get settingsResetSessionDone => 'Session has been reset.';

  @override
  String get settingsCancelButton => 'Cancel';

  @override
  String get settingsResetButton => 'Reset';

  @override
  String get palmExtractionTitle => 'Palm Line Extraction';

  @override
  String get palmExtractionSubtitle => 'Madame Gatto is analysing your signs';

  @override
  String get palmExtractionPhaseImageLoaded =>
      'Image capture / Original loaded';

  @override
  String get palmExtractionPhaseOptimizing =>
      'Image optimisation / Contrast & clarity';

  @override
  String get palmExtractionPhasePalmDetected =>
      'Palm detected / ROI segmentation';

  @override
  String get palmExtractionPhaseEdges => 'Edge detection / Line structure';

  @override
  String get palmExtractionPhaseLines => 'Extracting main lines';

  @override
  String get palmExtractionPhaseGeometry => 'Geometric analysis';

  @override
  String get palmExtractionPhaseGattoConfirm => 'Madame Gatto confirms';

  @override
  String get palmExtractionPhaseComplete => 'Analysis complete';

  @override
  String get palmExtractionStatusContrast => 'Contrast optimised';

  @override
  String get palmExtractionStatusEdges => 'Edges detected';

  @override
  String get palmExtractionStatusVectors => 'Line vectors calculated';

  @override
  String get palmExtractionStatusClassified => 'Symbolic patterns classified';

  @override
  String palmExtractionStatusEdgeCount(int count) {
    return 'Edge points detected: $count';
  }

  @override
  String palmExtractionStatusPathCount(int count) {
    return 'Line candidates: $count';
  }

  @override
  String palmExtractionStatusConfidence(int pct) {
    return 'Confidence: $pct %';
  }

  @override
  String get palmExtractionCompleteButton => 'To Reading';

  @override
  String get palmExtractionReleased => 'ANALYSIS RELEASED';

  @override
  String get palmExtractionPanelLines => 'LINES';

  @override
  String get palmExtractionPanelStatus => 'STATUS';

  @override
  String get palmExtractionPanelLife => 'LIFE';

  @override
  String get palmExtractionPanelHeart => 'HEART';

  @override
  String get palmExtractionPanelHead => 'HEAD';

  @override
  String get palmExtractionPanelFate => 'FATE';

  @override
  String get palmExtractionPanelContrast => 'CONTR.';

  @override
  String get palmExtractionPanelClarity => 'CLARITY';

  @override
  String get palmExtractionPanelVector => 'VECTOR';

  @override
  String get palmExtractionPanelQuality => 'QUALITY';

  @override
  String get palmExtractionPipelineButton => 'Details';

  @override
  String get palmExtractionPipelineTitle => 'Pipeline Details';

  @override
  String get palmExtractionPipelineRoi => 'ROI detected';

  @override
  String get palmExtractionPipelineRoiYes => 'Yes';

  @override
  String get palmExtractionPipelineRoiNo => 'No';

  @override
  String get palmExtractionPipelineEdgePixels => 'Edge pixels';

  @override
  String get palmExtractionPipelineLineCandidates => 'Line candidates';

  @override
  String get palmExtractionPipelineConfidence => 'Confidence';

  @override
  String get palmExtractionPipelineWorkSize => 'Work size';

  @override
  String get palmExtractionPipelinePalmMaskCoverage => 'Palm mask coverage';

  @override
  String get palmExtractionPipelineDarkLinePixels => 'Dark-line pixels';

  @override
  String get palmExtractionPipelineSobelPixels => 'Sobel auxiliary pixels';

  @override
  String get palmExtractionPipelineAcceptedInterior => 'Accepted interior';

  @override
  String get palmExtractionPipelineRejectedBoundary => 'Rejected boundary';

  @override
  String get palmExtractionClassificationUncertain =>
      'Lines detected, assignment uncertain';

  @override
  String get palmExtractionReadingTitle => 'Reading';

  @override
  String get scanQualityTitle => 'Scan Quality';

  @override
  String get scanQualityAnalyzing => 'Analyzing image quality…';

  @override
  String get scanQualityGradeExcellent => 'Excellent';

  @override
  String get scanQualityGradeGood => 'Good';

  @override
  String get scanQualityGradeAcceptable => 'Acceptable';

  @override
  String get scanQualityGradePoor => 'Poor';

  @override
  String get scanQualityGradeRetake => 'Please retake';

  @override
  String get scanQualityDimBackground => 'Background';

  @override
  String get scanQualityDimLighting => 'Lighting';

  @override
  String get scanQualityDimSharpness => 'Sharpness';

  @override
  String get scanQualityDimHandPosition => 'Hand Position';

  @override
  String get scanQualityDimPalmCoverage => 'Palm Coverage';

  @override
  String get scanQualityWarningAcceptable => 'Results may be less accurate.';

  @override
  String get scanQualityRetakeButton => 'Retake photo';

  @override
  String get scanQualityAnalyzeAnywayButton => 'Analyze anyway';

  @override
  String get scanQualityMadameSays => 'Madame Gatto says:';

  @override
  String get scanQualityBgTip =>
      'I can read your lines much better when your hand is photographed against a plain background.';

  @override
  String get scanQualityBgSuggestionsTitle => 'Suggested backgrounds:';

  @override
  String get scanQualityBgSuggestion1 => 'white sheet of paper';

  @override
  String get scanQualityBgSuggestion2 => 'gray table';

  @override
  String get scanQualityBgSuggestion3 => 'black cloth';

  @override
  String get scanQualityBgSuggestion4 => 'plain wall';

  @override
  String get handSegmentTitle => 'Hand Detection';

  @override
  String get handSegmentAnalyzing => 'Detecting hand outline…';

  @override
  String get handSegmentGradeExcellent => 'Excellent';

  @override
  String get handSegmentGradeGood => 'Good';

  @override
  String get handSegmentGradeAcceptable => 'Acceptable';

  @override
  String get handSegmentGradePoor => 'Hand not fully detected';

  @override
  String get handSegmentDimCoverage => 'Coverage';

  @override
  String get handSegmentDimEdge => 'Edge Quality';

  @override
  String get handSegmentDimFingers => 'Fingers';

  @override
  String get handSegmentDimThumb => 'Thumb';

  @override
  String get handSegmentDimWrist => 'Wrist';

  @override
  String get handSegmentCutoutLabel => 'Detected hand';

  @override
  String get handSegmentPoorTip =>
      'Madame Gatto recommends photographing your hand against a plain background for the most accurate reading.';
}
