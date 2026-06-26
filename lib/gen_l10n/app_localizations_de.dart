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
}
