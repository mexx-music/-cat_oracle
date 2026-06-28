import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Madame Gatto Futuro'**
  String get appTitle;

  /// Home: hero headline
  ///
  /// In en, this message translates to:
  /// **'🐾 Cat Oracle 🔮'**
  String get homeTitle;

  /// Home: hero subtitle
  ///
  /// In en, this message translates to:
  /// **'Your Cat Oracle Reading'**
  String get homeSubtitle;

  /// Home: hero description paragraph
  ///
  /// In en, this message translates to:
  /// **'Discover tarot, astrology, graphology and palm reading in the mystical style of Madame Gatto Futuro.'**
  String get homeDescription;

  /// Home: palmistry entry card title
  ///
  /// In en, this message translates to:
  /// **'Palm Reading'**
  String get homePalmistryTitle;

  /// Home: palmistry entry card subtitle
  ///
  /// In en, this message translates to:
  /// **'Read your lines'**
  String get homePalmistrySubtitle;

  /// Home: oracle entry card title
  ///
  /// In en, this message translates to:
  /// **'Demo Reading'**
  String get homeOracleTitle;

  /// Home: oracle entry card subtitle
  ///
  /// In en, this message translates to:
  /// **'View the cat oracle'**
  String get homeOracleSubtitle;

  /// Home: astrology entry card title
  ///
  /// In en, this message translates to:
  /// **'Astrology'**
  String get homeAstrologyTitle;

  /// Home: astrology entry card subtitle
  ///
  /// In en, this message translates to:
  /// **'Stars & signs'**
  String get homeAstrologySubtitle;

  /// Home: tarot entry card title
  ///
  /// In en, this message translates to:
  /// **'Tarot'**
  String get homeTarotTitle;

  /// Home: tarot entry card subtitle
  ///
  /// In en, this message translates to:
  /// **'The cards whisper'**
  String get homeTarotSubtitle;

  /// Home: graphology entry card title
  ///
  /// In en, this message translates to:
  /// **'Graphology'**
  String get homeGraphologyTitle;

  /// Home: graphology entry card subtitle
  ///
  /// In en, this message translates to:
  /// **'Writing reveals character'**
  String get homeGraphologySubtitle;

  /// Home: grand reading entry card title
  ///
  /// In en, this message translates to:
  /// **'Grand Reading'**
  String get homeGrandReadingTitle;

  /// Home: grand reading subtitle when no modules done
  ///
  /// In en, this message translates to:
  /// **'Collect signs first'**
  String get homeGrandReadingEmpty;

  /// Home: grand reading subtitle when 1-3 modules done
  ///
  /// In en, this message translates to:
  /// **'Start partial reading'**
  String get homeGrandReadingPartial;

  /// Home: grand reading subtitle when all 4 modules done
  ///
  /// In en, this message translates to:
  /// **'Start grand reading'**
  String get homeGrandReadingReady;

  /// Title of the grand reading page
  ///
  /// In en, this message translates to:
  /// **'Madame Gatto\'s Grand Reading'**
  String get grandReadingTitle;

  /// Subtitle for partial grand reading
  ///
  /// In en, this message translates to:
  /// **'Partial reading'**
  String get grandReadingSubtitlePartial;

  /// Subtitle for complete grand reading
  ///
  /// In en, this message translates to:
  /// **'All signs gathered'**
  String get grandReadingSubtitleComplete;

  /// Progress indicator for grand reading
  ///
  /// In en, this message translates to:
  /// **'{count} of 4 signs gathered'**
  String grandReadingProgress(int count);

  /// Label for mood section
  ///
  /// In en, this message translates to:
  /// **'Overall mood'**
  String get grandReadingMoodLabel;

  /// Label for strengths section
  ///
  /// In en, this message translates to:
  /// **'Your strength'**
  String get grandReadingStrengthsLabel;

  /// Label for challenge section
  ///
  /// In en, this message translates to:
  /// **'Your challenge'**
  String get grandReadingChallengeLabel;

  /// Label for cat advice section
  ///
  /// In en, this message translates to:
  /// **'Madame Gatto\'s advice'**
  String get grandReadingCatAdviceLabel;

  /// Label for lucky symbol section
  ///
  /// In en, this message translates to:
  /// **'Lucky symbol'**
  String get grandReadingLuckySymbolLabel;

  /// Label for paw rating section
  ///
  /// In en, this message translates to:
  /// **'Paw rating'**
  String get grandReadingPawRatingLabel;

  /// Label for summary section
  ///
  /// In en, this message translates to:
  /// **'Overall reading'**
  String get grandReadingSummaryLabel;

  /// Disclaimer on grand reading page
  ///
  /// In en, this message translates to:
  /// **'Symbolic entertainment – no predictions, no diagnosis.'**
  String get grandReadingDisclaimer;

  /// Hint shown when no modules are completed
  ///
  /// In en, this message translates to:
  /// **'Visit Tarot, Astrology, Palm reading or Graphology to collect signs.'**
  String get grandReadingEmptyHint;

  /// Badge label when all 4 modules done
  ///
  /// In en, this message translates to:
  /// **'Grand reading complete'**
  String get grandReadingComplete;

  /// Shows how many modules contributed
  ///
  /// In en, this message translates to:
  /// **'{count} of 4 modules'**
  String grandReadingModulesUsed(int count);

  /// Tarot page headline
  ///
  /// In en, this message translates to:
  /// **'Tarot'**
  String get tarotTitle;

  /// Tarot page subtitle
  ///
  /// In en, this message translates to:
  /// **'The cards whisper'**
  String get tarotSubtitle;

  /// Label for the daily tarot card
  ///
  /// In en, this message translates to:
  /// **'Daily Card'**
  String get tarotDailyCard;

  /// Button label to draw a random card
  ///
  /// In en, this message translates to:
  /// **'Draw a Card'**
  String get tarotDrawCard;

  /// Menu entry and dialog title for the three-card spread
  ///
  /// In en, this message translates to:
  /// **'Three-Card Spread'**
  String get tarotThreeCardSpread;

  /// Menu entry and dialog title for the love spread
  ///
  /// In en, this message translates to:
  /// **'Love & Relationships'**
  String get tarotLoveRelationships;

  /// Sub-label shown below every tarot card name
  ///
  /// In en, this message translates to:
  /// **'Major Arcana'**
  String get tarotMajorArcana;

  /// Close button label in tarot dialogs
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get tarotClose;

  /// Position label: past in the three-card spread
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get tarotPast;

  /// Position label: present in the three-card spread
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get tarotPresent;

  /// Position label: impulse in spreads
  ///
  /// In en, this message translates to:
  /// **'Impulse'**
  String get tarotImpulse;

  /// Position label: self in the love spread
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get tarotSelf;

  /// Position label: connection in the love spread
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get tarotConnection;

  /// Section heading for the love reading interpretation
  ///
  /// In en, this message translates to:
  /// **'Love Reading'**
  String get tarotLoveReading;

  /// Section heading for the overall three-card interpretation
  ///
  /// In en, this message translates to:
  /// **'Overall Reading'**
  String get tarotOverallReading;

  /// Footer hint in the daily card dialog
  ///
  /// In en, this message translates to:
  /// **'This card renews daily.'**
  String get tarotDailyRenewHint;

  /// Teaser paragraph on the tarot main page
  ///
  /// In en, this message translates to:
  /// **'Draw a card or open a spread. Madame Gatto reads the symbols in simple language.'**
  String get tarotTeaserText;

  /// Button label to open the daily card dialog
  ///
  /// In en, this message translates to:
  /// **'Open Daily Card'**
  String get tarotOpenDailyCard;

  /// Title of the drawn card dialog
  ///
  /// In en, this message translates to:
  /// **'Drawn Card'**
  String get tarotDrawnCardTitle;

  /// Title of the hand scan / palmistry page
  ///
  /// In en, this message translates to:
  /// **'Palm Reading'**
  String get palmistryTitle;

  /// Subtitle on the palmistry page
  ///
  /// In en, this message translates to:
  /// **'Your hand tells its lines'**
  String get palmistrySubtitle;

  /// Teaser paragraph on the palmistry page
  ///
  /// In en, this message translates to:
  /// **'Madame Gatto reads the life line, heart line, head line and fate line – symbolically and without judgement.'**
  String get palmistryTeaserText;

  /// Button to upload a palm photo
  ///
  /// In en, this message translates to:
  /// **'Upload palm print'**
  String get palmistryUploadButton;

  /// Subtitle under the upload button
  ///
  /// In en, this message translates to:
  /// **'Choose a photo of your palm'**
  String get palmistryUploadSubtitle;

  /// Button to start the palmistry analysis
  ///
  /// In en, this message translates to:
  /// **'Start analysis'**
  String get palmistryStartAnalysis;

  /// Title of the palm image preview dialog
  ///
  /// In en, this message translates to:
  /// **'Palm print'**
  String get palmistryPreviewTitle;

  /// Subtitle of the palm image preview dialog
  ///
  /// In en, this message translates to:
  /// **'Madame Gatto receives your palm print'**
  String get palmistryPreviewSubtitle;

  /// Success message after palm image upload
  ///
  /// In en, this message translates to:
  /// **'Palm print loaded successfully'**
  String get palmistryImageLoaded;

  /// Question asking which real hand was scanned
  ///
  /// In en, this message translates to:
  /// **'Which hand was scanned?'**
  String get palmistryScannedHandQuestion;

  /// Hint explaining semantic hand selection
  ///
  /// In en, this message translates to:
  /// **'This describes the real hand. The image thumb side stays separate.'**
  String get palmistryScannedHandHint;

  /// Button/label for the left scanned hand
  ///
  /// In en, this message translates to:
  /// **'Left hand'**
  String get palmistryLeftHand;

  /// Button/label for the right scanned hand
  ///
  /// In en, this message translates to:
  /// **'Right hand'**
  String get palmistryRightHand;

  /// Fallback label when scanned hand is unknown
  ///
  /// In en, this message translates to:
  /// **'Unknown hand'**
  String get palmistryUnknownHand;

  /// Small note indicating the selected scanned hand
  ///
  /// In en, this message translates to:
  /// **'Analyzed hand: {hand}'**
  String palmistryAnalyzedHand(String hand);

  /// Title of the analysis result dialog
  ///
  /// In en, this message translates to:
  /// **'Palm Line Analysis'**
  String get palmistryAnalysisTitle;

  /// Subtitle of the analysis result dialog
  ///
  /// In en, this message translates to:
  /// **'Madame Gatto reads the lines of your hand'**
  String get palmistryAnalysisSubtitle;

  /// Section heading for the overall palmistry interpretation
  ///
  /// In en, this message translates to:
  /// **'✨ Overall Reading'**
  String get palmistryOverallReading;

  /// Disclaimer chip in the analysis dialog
  ///
  /// In en, this message translates to:
  /// **'Symbolic analysis – for entertainment only'**
  String get palmistrySymbolicNote;

  /// Full disclaimer at the bottom of the analysis dialog
  ///
  /// In en, this message translates to:
  /// **'This reading is symbolic, does not constitute a diagnosis, and makes no predictions about the future.'**
  String get palmistryDisclaimer;

  /// Label shown under each palm trait title
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get palmistryTraitLabel;

  /// Close button in palmistry dialogs
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get palmistryClose;

  /// Cancel button in palmistry source picker
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get palmistryCancel;

  /// Title of the image source picker dialog
  ///
  /// In en, this message translates to:
  /// **'Select palm print'**
  String get palmistryPickSource;

  /// Subtitle in the source picker dialog
  ///
  /// In en, this message translates to:
  /// **'Choose a source for your palm photo'**
  String get palmistryPickSourceHint;

  /// Camera option in source picker
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get palmistryCamera;

  /// Gallery option in source picker
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get palmistryGallery;

  /// Error message shown when image picking fails
  ///
  /// In en, this message translates to:
  /// **'The image could not be loaded. Please try again.'**
  String get imagePickError;

  /// Info message when camera is tapped on macOS but no delegate is registered
  ///
  /// In en, this message translates to:
  /// **'Camera capture is not yet available on macOS in this version. Please use \'Select image\' instead.'**
  String get cameraMacOSNotAvailable;

  /// Error message when camera permission is denied
  ///
  /// In en, this message translates to:
  /// **'Camera access was denied. Please allow access in System Settings.'**
  String get cameraPermissionDenied;

  /// Subtitle on the graphology main page
  ///
  /// In en, this message translates to:
  /// **'Your writing whispers softly'**
  String get graphologySubtitle;

  /// Title of the image preview dialog
  ///
  /// In en, this message translates to:
  /// **'Handwriting Sample'**
  String get graphologySampleTitle;

  /// Subtitle of the image preview dialog
  ///
  /// In en, this message translates to:
  /// **'Madame Gatto receives your handwriting sample'**
  String get graphologySampleSubtitle;

  /// Label shown under each graphology trait title
  ///
  /// In en, this message translates to:
  /// **'Trait'**
  String get graphologyTraitLabel;

  /// Teaser paragraph on the graphology main page
  ///
  /// In en, this message translates to:
  /// **'Madame Gatto reads the form, rhythm and energy of your writing – symbolically and without judgement.'**
  String get graphologyTeaserText;

  /// Button to upload a handwriting photo
  ///
  /// In en, this message translates to:
  /// **'Upload handwriting sample'**
  String get graphologyUploadButton;

  /// Subtitle under the upload button
  ///
  /// In en, this message translates to:
  /// **'Choose a photo of handwriting'**
  String get graphologyUploadSubtitle;

  /// Button to start the graphology analysis after uploading
  ///
  /// In en, this message translates to:
  /// **'Start analysis'**
  String get graphologyStartAnalysis;

  /// Title of the analysis result dialog
  ///
  /// In en, this message translates to:
  /// **'Handwriting Analysis'**
  String get graphologyAnalysisTitle;

  /// Subtitle of the analysis result dialog
  ///
  /// In en, this message translates to:
  /// **'Madame Gatto reads the traces of your writing'**
  String get graphologyAnalysisSubtitle;

  /// Section heading for the overall graphology interpretation
  ///
  /// In en, this message translates to:
  /// **'✨ Overall Reading'**
  String get graphologyOverallReading;

  /// Disclaimer chip shown in the analysis dialog
  ///
  /// In en, this message translates to:
  /// **'Symbolic analysis – for entertainment only'**
  String get graphologySymbolicNote;

  /// Full disclaimer text at the bottom of the analysis dialog
  ///
  /// In en, this message translates to:
  /// **'This reading is symbolic and does not replace professional analysis.'**
  String get graphologyDisclaimer;

  /// Close button in graphology dialogs
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get graphologyClose;

  /// Cancel button in graphology source picker
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get graphologyCancel;

  /// Success message after image upload
  ///
  /// In en, this message translates to:
  /// **'Handwriting sample loaded successfully'**
  String get graphologyImageLoaded;

  /// Title of the image source picker dialog
  ///
  /// In en, this message translates to:
  /// **'Select handwriting sample'**
  String get graphologyPickSource;

  /// Subtitle in the source picker dialog
  ///
  /// In en, this message translates to:
  /// **'Choose a source for your handwriting sample'**
  String get graphologyPickSourceHint;

  /// Camera option in source picker
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get graphologyCamera;

  /// Gallery option in source picker
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get graphologyGallery;

  /// Onboarding slide 1 title
  ///
  /// In en, this message translates to:
  /// **'Welcome to Madame Gatto'**
  String get onboardingPage1Title;

  /// Onboarding slide 1 body
  ///
  /// In en, this message translates to:
  /// **'Madame Gatto Futuro guides you through Tarot, Astrology, Palm Reading and Graphology – mystical, playful and always with a wink.'**
  String get onboardingPage1Body;

  /// Onboarding slide 2 title
  ///
  /// In en, this message translates to:
  /// **'Your four signs'**
  String get onboardingPage2Title;

  /// Onboarding slide 2 body
  ///
  /// In en, this message translates to:
  /// **'Show your palm, let the cards speak, gaze at the stars or reveal your handwriting. Each sign tells something about you.'**
  String get onboardingPage2Body;

  /// Onboarding slide 3 title
  ///
  /// In en, this message translates to:
  /// **'Unlock the Grand Reading'**
  String get onboardingPage3Title;

  /// Onboarding slide 3 body
  ///
  /// In en, this message translates to:
  /// **'Once you have visited all four modules, Madame Gatto can create a Grand Reading – a combined interpretation of all your signs.'**
  String get onboardingPage3Body;

  /// Onboarding slide 4 title
  ///
  /// In en, this message translates to:
  /// **'A note beforehand'**
  String get onboardingPage4Title;

  /// Onboarding slide 4 body
  ///
  /// In en, this message translates to:
  /// **'Cat Oracle is symbolic entertainment. No predictions, no diagnosis, no substitute for professional advice. Madame Gatto purrs – but does not foretell.'**
  String get onboardingPage4Body;

  /// Onboarding next page button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// Onboarding last page button
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get onboardingBegin;

  /// Onboarding skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Settings section: language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageLabel;

  /// Settings section: actions
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get settingsActionsLabel;

  /// Settings section: app info
  ///
  /// In en, this message translates to:
  /// **'App Info'**
  String get settingsAppInfoLabel;

  /// App version string in settings
  ///
  /// In en, this message translates to:
  /// **'Version 1.0'**
  String get settingsAppVersion;

  /// Settings section: disclaimer
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get settingsDisclaimerLabel;

  /// Full disclaimer in settings
  ///
  /// In en, this message translates to:
  /// **'Cat Oracle is entertainment only. The readings are symbolic and based on random algorithms. They do not constitute a diagnosis, life advice or prediction of the future.'**
  String get settingsDisclaimerText;

  /// Settings button: reset onboarding
  ///
  /// In en, this message translates to:
  /// **'Show onboarding again'**
  String get settingsResetOnboarding;

  /// Settings button: reset session
  ///
  /// In en, this message translates to:
  /// **'Reset session'**
  String get settingsResetSession;

  /// Confirmation text for session reset
  ///
  /// In en, this message translates to:
  /// **'All collected signs (Tarot, Astrology, Palm Reading, Graphology) will be deleted. Continue?'**
  String get settingsResetSessionConfirm;

  /// Snackbar after session reset
  ///
  /// In en, this message translates to:
  /// **'Session has been reset.'**
  String get settingsResetSessionDone;

  /// Cancel button in settings dialogs
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancelButton;

  /// Confirm reset button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get settingsResetButton;

  /// Title of the palm extraction animation screen
  ///
  /// In en, this message translates to:
  /// **'Palm Line Extraction'**
  String get palmExtractionTitle;

  /// Subtitle of the palm extraction animation screen
  ///
  /// In en, this message translates to:
  /// **'Madame Gatto is analysing your signs'**
  String get palmExtractionSubtitle;

  /// Phase 1 label
  ///
  /// In en, this message translates to:
  /// **'Image capture / Original loaded'**
  String get palmExtractionPhaseImageLoaded;

  /// Phase 2 label
  ///
  /// In en, this message translates to:
  /// **'Image optimisation / Contrast & clarity'**
  String get palmExtractionPhaseOptimizing;

  /// Phase 3 label
  ///
  /// In en, this message translates to:
  /// **'Palm detected / ROI segmentation'**
  String get palmExtractionPhasePalmDetected;

  /// Phase 4 label
  ///
  /// In en, this message translates to:
  /// **'Edge detection / Line structure'**
  String get palmExtractionPhaseEdges;

  /// Phase 5 label
  ///
  /// In en, this message translates to:
  /// **'Extracting main lines'**
  String get palmExtractionPhaseLines;

  /// Phase 6 label
  ///
  /// In en, this message translates to:
  /// **'Geometric analysis'**
  String get palmExtractionPhaseGeometry;

  /// Phase 7 label
  ///
  /// In en, this message translates to:
  /// **'Madame Gatto confirms'**
  String get palmExtractionPhaseGattoConfirm;

  /// Phase 8 label
  ///
  /// In en, this message translates to:
  /// **'Analysis complete'**
  String get palmExtractionPhaseComplete;

  /// Status message: contrast done
  ///
  /// In en, this message translates to:
  /// **'Contrast optimised'**
  String get palmExtractionStatusContrast;

  /// Status message: edges done
  ///
  /// In en, this message translates to:
  /// **'Edges detected'**
  String get palmExtractionStatusEdges;

  /// Status message: vectors done
  ///
  /// In en, this message translates to:
  /// **'Line vectors calculated'**
  String get palmExtractionStatusVectors;

  /// Status message: classification done
  ///
  /// In en, this message translates to:
  /// **'Symbolic patterns classified'**
  String get palmExtractionStatusClassified;

  /// Status message: real edge pixel count from extraction
  ///
  /// In en, this message translates to:
  /// **'Edge points detected: {count}'**
  String palmExtractionStatusEdgeCount(int count);

  /// Status message: number of extracted line paths
  ///
  /// In en, this message translates to:
  /// **'Line candidates: {count}'**
  String palmExtractionStatusPathCount(int count);

  /// Status message: extraction confidence percentage
  ///
  /// In en, this message translates to:
  /// **'Confidence: {pct} %'**
  String palmExtractionStatusConfidence(int pct);

  /// Button shown when extraction animation is done – opens inline reading panel
  ///
  /// In en, this message translates to:
  /// **'To Reading'**
  String get palmExtractionCompleteButton;

  /// Completion seal text on palm extraction animation
  ///
  /// In en, this message translates to:
  /// **'ANALYSIS RELEASED'**
  String get palmExtractionReleased;

  /// Left side-panel header: palm lines
  ///
  /// In en, this message translates to:
  /// **'LINES'**
  String get palmExtractionPanelLines;

  /// Right side-panel header: status
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get palmExtractionPanelStatus;

  /// Panel metric label: life line
  ///
  /// In en, this message translates to:
  /// **'LIFE'**
  String get palmExtractionPanelLife;

  /// Panel metric label: heart line
  ///
  /// In en, this message translates to:
  /// **'HEART'**
  String get palmExtractionPanelHeart;

  /// Panel metric label: head line
  ///
  /// In en, this message translates to:
  /// **'HEAD'**
  String get palmExtractionPanelHead;

  /// Panel metric label: fate line
  ///
  /// In en, this message translates to:
  /// **'FATE'**
  String get palmExtractionPanelFate;

  /// Panel metric label: contrast
  ///
  /// In en, this message translates to:
  /// **'CONTR.'**
  String get palmExtractionPanelContrast;

  /// Panel metric label: clarity
  ///
  /// In en, this message translates to:
  /// **'CLARITY'**
  String get palmExtractionPanelClarity;

  /// Panel metric label: vector count
  ///
  /// In en, this message translates to:
  /// **'VECTOR'**
  String get palmExtractionPanelVector;

  /// Panel metric label: overall quality
  ///
  /// In en, this message translates to:
  /// **'QUALITY'**
  String get palmExtractionPanelQuality;

  /// Button/chip label to open the pipeline details sheet
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get palmExtractionPipelineButton;

  /// Title of the pipeline details bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Pipeline Details'**
  String get palmExtractionPipelineTitle;

  /// Pipeline detail label: ROI detection status
  ///
  /// In en, this message translates to:
  /// **'ROI detected'**
  String get palmExtractionPipelineRoi;

  /// Value when ROI was detected
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get palmExtractionPipelineRoiYes;

  /// Value when ROI was not detected (full image used)
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get palmExtractionPipelineRoiNo;

  /// Pipeline detail label: total edge pixel count
  ///
  /// In en, this message translates to:
  /// **'Edge pixels'**
  String get palmExtractionPipelineEdgePixels;

  /// Pipeline detail label: number of candidate paths found
  ///
  /// In en, this message translates to:
  /// **'Line candidates'**
  String get palmExtractionPipelineLineCandidates;

  /// Pipeline detail label: extraction confidence score
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get palmExtractionPipelineConfidence;

  /// Pipeline detail label: dimensions of the normalised work image
  ///
  /// In en, this message translates to:
  /// **'Work size'**
  String get palmExtractionPipelineWorkSize;

  /// Pipeline detail label: fraction of the work image covered by the palm interior mask
  ///
  /// In en, this message translates to:
  /// **'Palm mask coverage'**
  String get palmExtractionPipelinePalmMaskCoverage;

  /// Pipeline detail label: pixels detected by the dark-line evidence map
  ///
  /// In en, this message translates to:
  /// **'Dark-line pixels'**
  String get palmExtractionPipelineDarkLinePixels;

  /// Pipeline detail label: pixels detected by auxiliary Sobel evidence
  ///
  /// In en, this message translates to:
  /// **'Sobel auxiliary pixels'**
  String get palmExtractionPipelineSobelPixels;

  /// Pipeline detail label: mean interior ratio of accepted components
  ///
  /// In en, this message translates to:
  /// **'Accepted interior'**
  String get palmExtractionPipelineAcceptedInterior;

  /// Pipeline detail label: mean boundary ratio of rejected components
  ///
  /// In en, this message translates to:
  /// **'Rejected boundary'**
  String get palmExtractionPipelineRejectedBoundary;

  /// Overlay shown when line evidence exists but classification confidence is low
  ///
  /// In en, this message translates to:
  /// **'Lines detected, assignment uncertain'**
  String get palmExtractionClassificationUncertain;

  /// Title of the inline reading panel shown after palm extraction completes
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get palmExtractionReadingTitle;

  /// Header of the scan quality gate panel
  ///
  /// In en, this message translates to:
  /// **'Scan Quality'**
  String get scanQualityTitle;

  /// Loading state shown while quality assessment runs
  ///
  /// In en, this message translates to:
  /// **'Analyzing image quality…'**
  String get scanQualityAnalyzing;

  /// Scan quality grade: Excellent
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get scanQualityGradeExcellent;

  /// Scan quality grade: Good
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get scanQualityGradeGood;

  /// Scan quality grade: Acceptable
  ///
  /// In en, this message translates to:
  /// **'Acceptable'**
  String get scanQualityGradeAcceptable;

  /// Scan quality grade: Poor
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get scanQualityGradePoor;

  /// Scan quality grade: please retake the photo
  ///
  /// In en, this message translates to:
  /// **'Please retake'**
  String get scanQualityGradeRetake;

  /// Quality dimension label: background
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get scanQualityDimBackground;

  /// Quality dimension label: lighting
  ///
  /// In en, this message translates to:
  /// **'Lighting'**
  String get scanQualityDimLighting;

  /// Quality dimension label: sharpness / blur
  ///
  /// In en, this message translates to:
  /// **'Sharpness'**
  String get scanQualityDimSharpness;

  /// Quality dimension label: hand position and isolation
  ///
  /// In en, this message translates to:
  /// **'Hand Position'**
  String get scanQualityDimHandPosition;

  /// Quality dimension label: how much of the frame is filled by the palm
  ///
  /// In en, this message translates to:
  /// **'Palm Coverage'**
  String get scanQualityDimPalmCoverage;

  /// Warning shown when quality is acceptable but not ideal
  ///
  /// In en, this message translates to:
  /// **'Results may be less accurate.'**
  String get scanQualityWarningAcceptable;

  /// Primary button when quality is poor: retake the photo
  ///
  /// In en, this message translates to:
  /// **'Retake photo'**
  String get scanQualityRetakeButton;

  /// Secondary button when quality is poor: proceed despite low quality
  ///
  /// In en, this message translates to:
  /// **'Analyze anyway'**
  String get scanQualityAnalyzeAnywayButton;

  /// Attribution label for the Madame Gatto background tip
  ///
  /// In en, this message translates to:
  /// **'Madame Gatto says:'**
  String get scanQualityMadameSays;

  /// Madame Gatto tip about using a plain background
  ///
  /// In en, this message translates to:
  /// **'I can read your lines much better when your hand is photographed against a plain background.'**
  String get scanQualityBgTip;

  /// Header for the list of suggested backgrounds
  ///
  /// In en, this message translates to:
  /// **'Suggested backgrounds:'**
  String get scanQualityBgSuggestionsTitle;

  /// Background suggestion 1
  ///
  /// In en, this message translates to:
  /// **'white sheet of paper'**
  String get scanQualityBgSuggestion1;

  /// Background suggestion 2
  ///
  /// In en, this message translates to:
  /// **'gray table'**
  String get scanQualityBgSuggestion2;

  /// Background suggestion 3
  ///
  /// In en, this message translates to:
  /// **'black cloth'**
  String get scanQualityBgSuggestion3;

  /// Background suggestion 4
  ///
  /// In en, this message translates to:
  /// **'plain wall'**
  String get scanQualityBgSuggestion4;

  /// Header of the hand segmentation preview panel
  ///
  /// In en, this message translates to:
  /// **'Hand Detection'**
  String get handSegmentTitle;

  /// Loading state while segmentation runs
  ///
  /// In en, this message translates to:
  /// **'Detecting hand outline…'**
  String get handSegmentAnalyzing;

  /// Segmentation grade: Excellent
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get handSegmentGradeExcellent;

  /// Segmentation grade: Good
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get handSegmentGradeGood;

  /// Segmentation grade: Acceptable
  ///
  /// In en, this message translates to:
  /// **'Acceptable'**
  String get handSegmentGradeAcceptable;

  /// Segmentation grade: Poor – hand not clearly detected
  ///
  /// In en, this message translates to:
  /// **'Hand not fully detected'**
  String get handSegmentGradePoor;

  /// Segmentation metric: how much of the frame the hand fills
  ///
  /// In en, this message translates to:
  /// **'Coverage'**
  String get handSegmentDimCoverage;

  /// Segmentation metric: sharpness of the hand boundary
  ///
  /// In en, this message translates to:
  /// **'Edge Quality'**
  String get handSegmentDimEdge;

  /// Segmentation metric: finger visibility
  ///
  /// In en, this message translates to:
  /// **'Fingers'**
  String get handSegmentDimFingers;

  /// Segmentation metric: thumb visibility
  ///
  /// In en, this message translates to:
  /// **'Thumb'**
  String get handSegmentDimThumb;

  /// Segmentation metric: wrist visibility
  ///
  /// In en, this message translates to:
  /// **'Wrist'**
  String get handSegmentDimWrist;

  /// Label shown below the cutout preview image
  ///
  /// In en, this message translates to:
  /// **'Detected hand'**
  String get handSegmentCutoutLabel;

  /// Tip shown when segmentation quality is poor
  ///
  /// In en, this message translates to:
  /// **'Madame Gatto recommends photographing your hand against a plain background for the most accurate reading.'**
  String get handSegmentPoorTip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
