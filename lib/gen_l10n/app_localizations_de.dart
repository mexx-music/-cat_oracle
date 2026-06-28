// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Madame Gatto Futuro';

  @override
  String get homeTitle => '🐾 Cat Oracle 🔮';

  @override
  String get homeSubtitle => 'Deine Katzen-Orakel-Lesung';

  @override
  String get homeDescription =>
      'Entdecke Tarot, Astrologie, Grafologie und Handlesen im mystischen Stil von Madame Gatto Futuro.';

  @override
  String get homePalmistryTitle => 'Handlesen';

  @override
  String get homePalmistrySubtitle => 'Lies deine Linien';

  @override
  String get homeOracleTitle => 'Demo-Lesung';

  @override
  String get homeOracleSubtitle => 'Katzen-Orakel ansehen';

  @override
  String get homeAstrologyTitle => 'Astrologie';

  @override
  String get homeAstrologySubtitle => 'Sterne & Zeichen';

  @override
  String get homeTarotTitle => 'Tarot';

  @override
  String get homeTarotSubtitle => 'Die Karten flüstern';

  @override
  String get homeGraphologyTitle => 'Grafologie';

  @override
  String get homeGraphologySubtitle => 'Schrift offenbart Charakter';

  @override
  String get homeGrandReadingTitle => 'Grosse Lesung';

  @override
  String get homeGrandReadingEmpty => 'Sammle zuerst Zeichen';

  @override
  String get homeGrandReadingPartial => 'Teil-Lesung starten';

  @override
  String get homeGrandReadingReady => 'Grosse Lesung starten';

  @override
  String get grandReadingTitle => 'Madame Gattos Grosse Lesung';

  @override
  String get grandReadingSubtitlePartial => 'Teil-Lesung';

  @override
  String get grandReadingSubtitleComplete => 'Alle Zeichen gelesen';

  @override
  String grandReadingProgress(int count) {
    return '$count von 4 Zeichen gesammelt';
  }

  @override
  String get grandReadingMoodLabel => 'Gesamtstimmung';

  @override
  String get grandReadingStrengthsLabel => 'Deine Staerke';

  @override
  String get grandReadingChallengeLabel => 'Deine Herausforderung';

  @override
  String get grandReadingCatAdviceLabel => 'Madame Gattos Rat';

  @override
  String get grandReadingLuckySymbolLabel => 'Glueckssymbol';

  @override
  String get grandReadingPawRatingLabel => 'Pfoten-Wertung';

  @override
  String get grandReadingSummaryLabel => 'Gesamtdeutung';

  @override
  String get grandReadingDisclaimer =>
      'Symbolische Unterhaltung – keine Zukunftsvorhersage, keine Diagnose.';

  @override
  String get grandReadingEmptyHint =>
      'Besuche Tarot, Astrologie, Handlesen oder Grafologie, um Zeichen zu sammeln.';

  @override
  String get grandReadingComplete => 'Grosse Lesung vollstaendig';

  @override
  String grandReadingModulesUsed(int count) {
    return '$count von 4 Modulen';
  }

  @override
  String get tarotTitle => 'Tarot';

  @override
  String get tarotSubtitle => 'Die Karten flüstern';

  @override
  String get tarotDailyCard => 'Tageskarte';

  @override
  String get tarotDrawCard => 'Eine Karte ziehen';

  @override
  String get tarotThreeCardSpread => 'Drei-Karten-Legung';

  @override
  String get tarotLoveRelationships => 'Liebe & Beziehungen';

  @override
  String get tarotMajorArcana => 'Große Arkana';

  @override
  String get tarotClose => 'Schließen';

  @override
  String get tarotPast => 'Vergangenheit';

  @override
  String get tarotPresent => 'Gegenwart';

  @override
  String get tarotImpulse => 'Impuls';

  @override
  String get tarotSelf => 'Du';

  @override
  String get tarotConnection => 'Verbindung';

  @override
  String get tarotLoveReading => 'Liebesdeutung';

  @override
  String get tarotOverallReading => 'Gesamtdeutung';

  @override
  String get tarotDailyRenewHint => 'Diese Karte erneuert sich täglich.';

  @override
  String get tarotTeaserText =>
      'Ziehe eine Karte oder öffne eine Legung. Madame Gatto deutet die Symbole in einfacher Sprache.';

  @override
  String get tarotOpenDailyCard => 'Tageskarte öffnen';

  @override
  String get tarotDrawnCardTitle => 'Gezogene Karte';

  @override
  String get palmistryTitle => 'Handlesen';

  @override
  String get palmistrySubtitle => 'Deine Hand erzählt ihre Linien';

  @override
  String get palmistryTeaserText =>
      'Madame Gatto liest Lebenslinie, Herzlinie, Kopflinie und Schicksalslinie – symbolisch und ohne Urteil.';

  @override
  String get palmistryUploadButton => 'Handabdruck hochladen';

  @override
  String get palmistryUploadSubtitle => 'Foto deiner Handfläche auswählen';

  @override
  String get palmistryStartAnalysis => 'Analyse starten';

  @override
  String get palmistryPreviewTitle => 'Handabdruck';

  @override
  String get palmistryPreviewSubtitle =>
      'Madame Gatto nimmt deinen Handabdruck entgegen';

  @override
  String get palmistryImageLoaded => 'Handabdruck erfolgreich geladen';

  @override
  String get palmistryScannedHandQuestion => 'Welche Hand wurde gescannt?';

  @override
  String get palmistryScannedHandHint =>
      'Diese Auswahl beschreibt die echte Hand. Die Bild-Daumenseite bleibt davon getrennt.';

  @override
  String get palmistryLeftHand => 'Linke Hand';

  @override
  String get palmistryRightHand => 'Rechte Hand';

  @override
  String get palmistryUnknownHand => 'Unbekannte Hand';

  @override
  String palmistryAnalyzedHand(String hand) {
    return 'Analysierte Hand: $hand';
  }

  @override
  String get palmistryAnalysisTitle => 'Handlinien-Analyse';

  @override
  String get palmistryAnalysisSubtitle =>
      'Madame Gatto liest die Linien deiner Hand';

  @override
  String get palmistryOverallReading => '✨ Gesamtdeutung';

  @override
  String get palmistrySymbolicNote =>
      'Symbolische Analyse – nur zur Unterhaltung';

  @override
  String get palmistryDisclaimer =>
      'Diese Deutung ist symbolisch, stellt keine Diagnose dar und trifft keine Zukunftsvorhersagen.';

  @override
  String get palmistryTraitLabel => 'Linie';

  @override
  String get palmistryClose => 'Schließen';

  @override
  String get palmistryCancel => 'Abbrechen';

  @override
  String get palmistryPickSource => 'Handabdruck auswählen';

  @override
  String get palmistryPickSourceHint =>
      'Wähle eine Quelle für dein Handabdruck-Foto';

  @override
  String get palmistryCamera => 'Kamera';

  @override
  String get palmistryGallery => 'Galerie';

  @override
  String get imagePickError =>
      'Bild konnte nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get cameraMacOSNotAvailable =>
      'Kameraaufnahme ist auf macOS in dieser Version noch nicht verfügbar. Bitte verwende \'Bild auswaehlen\'.';

  @override
  String get cameraPermissionDenied =>
      'Kamerazugriff wurde verweigert. Bitte erlaube den Zugriff in den Systemeinstellungen.';

  @override
  String get graphologySubtitle => 'Deine Schrift flüstert leise';

  @override
  String get graphologySampleTitle => 'Schriftprobe';

  @override
  String get graphologySampleSubtitle =>
      'Madame Gatto nimmt deine Schriftprobe entgegen';

  @override
  String get graphologyTraitLabel => 'Merkmal';

  @override
  String get graphologyTeaserText =>
      'Madame Gatto liest Form, Rhythmus und Energie deiner Schrift – symbolisch und ohne Urteil.';

  @override
  String get graphologyUploadButton => 'Schriftprobe hochladen';

  @override
  String get graphologyUploadSubtitle => 'Foto einer Handschrift auswählen';

  @override
  String get graphologyStartAnalysis => 'Analyse starten';

  @override
  String get graphologyAnalysisTitle => 'Schriftanalyse';

  @override
  String get graphologyAnalysisSubtitle =>
      'Madame Gatto liest die Spuren deiner Schrift';

  @override
  String get graphologyOverallReading => '✨ Gesamtdeutung';

  @override
  String get graphologySymbolicNote =>
      'Symbolische Analyse – nur zur Unterhaltung';

  @override
  String get graphologyDisclaimer =>
      'Diese Deutung ist symbolisch und ersetzt keine professionelle Analyse.';

  @override
  String get graphologyClose => 'Schließen';

  @override
  String get graphologyCancel => 'Abbrechen';

  @override
  String get graphologyImageLoaded => 'Schriftprobe erfolgreich geladen';

  @override
  String get graphologyPickSource => 'Schriftprobe auswählen';

  @override
  String get graphologyPickSourceHint =>
      'Wähle eine Quelle für deine Schriftprobe';

  @override
  String get graphologyCamera => 'Kamera';

  @override
  String get graphologyGallery => 'Galerie';

  @override
  String get onboardingPage1Title => 'Willkommen bei Madame Gatto';

  @override
  String get onboardingPage1Body =>
      'Madame Gatto Futuro begleitet dich durch Tarot, Astrologie, Handlesen und Grafologie – mystisch, spielerisch und immer mit einem Augenzwinkern.';

  @override
  String get onboardingPage2Title => 'Deine vier Zeichen';

  @override
  String get onboardingPage2Body =>
      'Leg deine Hand auf, lass die Karten sprechen, blick in die Sterne oder zeig deine Handschrift. Jedes Zeichen erzählt etwas über dich.';

  @override
  String get onboardingPage3Title => 'Grosse Lesung freischalten';

  @override
  String get onboardingPage3Body =>
      'Hast du alle vier Module besucht, kann Madame Gatto eine Grosse Lesung erstellen – eine Zusammenfassung aller Zeichen.';

  @override
  String get onboardingPage4Title => 'Ein Wort vorab';

  @override
  String get onboardingPage4Body =>
      'Cat Oracle ist symbolische Unterhaltung. Keine Zukunftsvorhersage, keine Diagnose, kein Ersatz fuer professionelle Beratung. Madame Gatto schnurrt – aber weissagt nicht.';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingBegin => 'Beginnen';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsLanguageLabel => 'Sprache';

  @override
  String get settingsActionsLabel => 'Aktionen';

  @override
  String get settingsAppInfoLabel => 'App-Info';

  @override
  String get settingsAppVersion => 'Version 1.0';

  @override
  String get settingsDisclaimerLabel => 'Hinweis';

  @override
  String get settingsDisclaimerText =>
      'Cat Oracle ist ein reines Unterhaltungsangebot. Die Deutungen sind symbolisch und basieren auf Zufallsalgorithmen. Sie stellen keine Diagnose, keine Lebensberatung und keine Zukunftsvorhersage dar.';

  @override
  String get settingsResetOnboarding => 'Onboarding erneut anzeigen';

  @override
  String get settingsResetSession => 'Session zurücksetzen';

  @override
  String get settingsResetSessionConfirm =>
      'Alle gesammelten Zeichen (Tarot, Astrologie, Handlesen, Grafologie) werden gelöscht. Fortfahren?';

  @override
  String get settingsResetSessionDone => 'Session wurde zurückgesetzt.';

  @override
  String get settingsCancelButton => 'Abbrechen';

  @override
  String get settingsResetButton => 'Zurücksetzen';

  @override
  String get palmExtractionTitle => 'Handlinien-Extraktion';

  @override
  String get palmExtractionSubtitle => 'Madame Gatto analysiert deine Zeichen';

  @override
  String get palmExtractionPhaseImageLoaded =>
      'Bildaufnahme / Originalbild geladen';

  @override
  String get palmExtractionPhaseOptimizing =>
      'Bildoptimierung / Kontrast & Klarheit';

  @override
  String get palmExtractionPhasePalmDetected =>
      'Handflaehe erkannt / ROI-Segmentierung';

  @override
  String get palmExtractionPhaseEdges => 'Kantenerkennung / Linienstruktur';

  @override
  String get palmExtractionPhaseLines => 'Hauptlinien extrahieren';

  @override
  String get palmExtractionPhaseGeometry => 'Geometrische Analyse';

  @override
  String get palmExtractionPhaseGattoConfirm => 'Madame Gatto bestaetigt';

  @override
  String get palmExtractionPhaseComplete => 'Analyse abgeschlossen';

  @override
  String get palmExtractionStatusContrast => 'Kontrast optimiert';

  @override
  String get palmExtractionStatusEdges => 'Kanten erkannt';

  @override
  String get palmExtractionStatusVectors => 'Linienvektoren berechnet';

  @override
  String get palmExtractionStatusClassified =>
      'Symbolische Muster klassifiziert';

  @override
  String palmExtractionStatusEdgeCount(int count) {
    return 'Kantenpunkte erkannt: $count';
  }

  @override
  String palmExtractionStatusPathCount(int count) {
    return 'Linienkandidaten: $count';
  }

  @override
  String palmExtractionStatusConfidence(int pct) {
    return 'Konfidenz: $pct %';
  }

  @override
  String get palmExtractionCompleteButton => 'Zur Deutung';

  @override
  String get palmExtractionReleased => 'ANALYSE FREIGEGEBEN';

  @override
  String get palmExtractionPanelLines => 'LINIEN';

  @override
  String get palmExtractionPanelStatus => 'STATUS';

  @override
  String get palmExtractionPanelLife => 'LEBEN.';

  @override
  String get palmExtractionPanelHeart => 'HERZ';

  @override
  String get palmExtractionPanelHead => 'KOPF';

  @override
  String get palmExtractionPanelFate => 'SCHICKS.';

  @override
  String get palmExtractionPanelContrast => 'KONTR.';

  @override
  String get palmExtractionPanelClarity => 'KLARH.';

  @override
  String get palmExtractionPanelVector => 'VEKTOR';

  @override
  String get palmExtractionPanelQuality => 'GUETE';

  @override
  String get palmExtractionPipelineButton => 'Details';

  @override
  String get palmExtractionPipelineTitle => 'Pipeline-Details';

  @override
  String get palmExtractionPipelineRoi => 'ROI erkannt';

  @override
  String get palmExtractionPipelineRoiYes => 'Ja';

  @override
  String get palmExtractionPipelineRoiNo => 'Nein';

  @override
  String get palmExtractionPipelineEdgePixels => 'Kantenpunkte';

  @override
  String get palmExtractionPipelineLineCandidates => 'Linienkandidaten';

  @override
  String get palmExtractionPipelineConfidence => 'Konfidenz';

  @override
  String get palmExtractionPipelineWorkSize => 'Arbeitsgröße';

  @override
  String get palmExtractionPipelinePalmMaskCoverage => 'Handflächenmaske';

  @override
  String get palmExtractionPipelineDarkLinePixels => 'Dunkellinien-Pixel';

  @override
  String get palmExtractionPipelineSobelPixels => 'Sobel-Hilfspixel';

  @override
  String get palmExtractionPipelineAcceptedInterior => 'Innerer Anteil';

  @override
  String get palmExtractionPipelineRejectedBoundary => 'Rand-Ablehnung';

  @override
  String get palmExtractionClassificationUncertain =>
      'Linien erkannt, Zuordnung unsicher';

  @override
  String get palmExtractionReadingTitle => 'Deutung';

  @override
  String get scanQualityTitle => 'Scan-Qualität';

  @override
  String get scanQualityAnalyzing => 'Bildqualität wird analysiert…';

  @override
  String get scanQualityGradeExcellent => 'Ausgezeichnet';

  @override
  String get scanQualityGradeGood => 'Gut';

  @override
  String get scanQualityGradeAcceptable => 'Akzeptabel';

  @override
  String get scanQualityGradePoor => 'Schlecht';

  @override
  String get scanQualityGradeRetake => 'Bitte neu aufnehmen';

  @override
  String get scanQualityDimBackground => 'Hintergrund';

  @override
  String get scanQualityDimLighting => 'Beleuchtung';

  @override
  String get scanQualityDimSharpness => 'Schärfe';

  @override
  String get scanQualityDimHandPosition => 'Handposition';

  @override
  String get scanQualityDimPalmCoverage => 'Handflächenanteil';

  @override
  String get scanQualityWarningAcceptable =>
      'Ergebnisse können weniger genau sein.';

  @override
  String get scanQualityRetakeButton => 'Foto wiederholen';

  @override
  String get scanQualityAnalyzeAnywayButton => 'Trotzdem analysieren';

  @override
  String get scanQualityMadameSays => 'Madame Gatto sagt:';

  @override
  String get scanQualityBgTip =>
      'Ich kann deine Linien viel besser lesen, wenn deine Hand vor einem einfarbigen Hintergrund fotografiert wird.';

  @override
  String get scanQualityBgSuggestionsTitle => 'Empfohlene Hintergründe:';

  @override
  String get scanQualityBgSuggestion1 => 'weißes Blatt Papier';

  @override
  String get scanQualityBgSuggestion2 => 'grauer Tisch';

  @override
  String get scanQualityBgSuggestion3 => 'schwarzes Tuch';

  @override
  String get scanQualityBgSuggestion4 => 'schlichte Wand';

  @override
  String get handSegmentTitle => 'Handerkennung';

  @override
  String get handSegmentAnalyzing => 'Handkontur wird erkannt…';

  @override
  String get handSegmentGradeExcellent => 'Ausgezeichnet';

  @override
  String get handSegmentGradeGood => 'Gut';

  @override
  String get handSegmentGradeAcceptable => 'Akzeptabel';

  @override
  String get handSegmentGradePoor => 'Hand nicht vollständig erkannt';

  @override
  String get handSegmentDimCoverage => 'Bildanteil';

  @override
  String get handSegmentDimEdge => 'Kantenqualität';

  @override
  String get handSegmentDimFingers => 'Finger';

  @override
  String get handSegmentDimThumb => 'Daumen';

  @override
  String get handSegmentDimWrist => 'Handgelenk';

  @override
  String get handSegmentCutoutLabel => 'Erkannte Hand';

  @override
  String get handSegmentPoorTip =>
      'Madame Gatto empfiehlt, die Hand vor einem einfarbigen Hintergrund zu fotografieren, um die genaueste Deutung zu erhalten.';
}
