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
