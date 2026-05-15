import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
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
/// import 'l10n/app_localizations.dart';
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Elagy'**
  String get appTitle;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @selectProfile.
  ///
  /// In en, this message translates to:
  /// **'Select a profile'**
  String get selectProfile;

  /// No description provided for @noMedicines.
  ///
  /// In en, this message translates to:
  /// **'No medicines for this day'**
  String get noMedicines;

  /// No description provided for @markTakenTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark as Taken?'**
  String get markTakenTitle;

  /// No description provided for @markTakenContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark {medicineName} as taken?'**
  String markTakenContent(String medicineName);

  /// No description provided for @unmarkTakenTitle.
  ///
  /// In en, this message translates to:
  /// **'Unmark as Taken?'**
  String get unmarkTakenTitle;

  /// No description provided for @unmarkTakenContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unmark {medicineName}?'**
  String unmarkTakenContent(String medicineName);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @taken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get taken;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @timeToTake.
  ///
  /// In en, this message translates to:
  /// **'Time to take'**
  String get timeToTake;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @allMedicines.
  ///
  /// In en, this message translates to:
  /// **'All Medicines'**
  String get allMedicines;

  /// No description provided for @noMedicinesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No medicines recorded'**
  String get noMedicinesRecorded;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @ends.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get ends;

  /// No description provided for @ongoingIndefinitely.
  ///
  /// In en, this message translates to:
  /// **'Ongoing indefinitely'**
  String get ongoingIndefinitely;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @everyXHours.
  ///
  /// In en, this message translates to:
  /// **'Every {hours} hours'**
  String everyXHours(int hours);

  /// No description provided for @dailyAt.
  ///
  /// In en, this message translates to:
  /// **'Daily at {time}'**
  String dailyAt(String time);

  /// No description provided for @intakeHistory.
  ///
  /// In en, this message translates to:
  /// **'Intake History'**
  String get intakeHistory;

  /// No description provided for @noHistoryRecorded.
  ///
  /// In en, this message translates to:
  /// **'No history recorded yet.'**
  String get noHistoryRecorded;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned: {time}'**
  String planned(String time);

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get reportTitle;

  /// No description provided for @myPerformance.
  ///
  /// In en, this message translates to:
  /// **'My Performance'**
  String get myPerformance;

  /// No description provided for @medicines.
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get medicines;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @dosesTaken.
  ///
  /// In en, this message translates to:
  /// **'Doses Taken'**
  String get dosesTaken;

  /// No description provided for @adherence.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get adherence;

  /// No description provided for @addMedicineTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get addMedicineTitle;

  /// No description provided for @editMedicineTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Medicine'**
  String get editMedicineTitle;

  /// No description provided for @medicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get medicineName;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage (e.g., 1 pill, 5ml)'**
  String get dosage;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'Duration (Days)'**
  String get durationDays;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @intervalLabel.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get intervalLabel;

  /// No description provided for @fixedTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Fixed Time'**
  String get fixedTimeLabel;

  /// No description provided for @intervalHours.
  ///
  /// In en, this message translates to:
  /// **'Interval Options'**
  String get intervalHours;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter medicine name'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterDosage.
  ///
  /// In en, this message translates to:
  /// **'Please enter dosage'**
  String get pleaseEnterDosage;

  /// No description provided for @pleaseSelectTime.
  ///
  /// In en, this message translates to:
  /// **'Please select a time for fixed daily medication'**
  String get pleaseSelectTime;

  /// No description provided for @pleaseSelectInterval.
  ///
  /// In en, this message translates to:
  /// **'Please select interval hours'**
  String get pleaseSelectInterval;

  /// No description provided for @deleteProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile?'**
  String get deleteProfileTitle;

  /// No description provided for @deleteProfileContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {profileName}? All medicines associated with this profile will be permanently wiped.'**
  String deleteProfileContent(String profileName);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @addProfile.
  ///
  /// In en, this message translates to:
  /// **'Add Profile'**
  String get addProfile;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @manageProfile.
  ///
  /// In en, this message translates to:
  /// **'Manage Profile: {profileName}'**
  String manageProfile(String profileName);

  /// No description provided for @deleteSelectedMedicines.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected Medicines?'**
  String get deleteSelectedMedicines;

  /// No description provided for @deleteSelectedContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete {count} medicine(s).'**
  String deleteSelectedContent(int count);

  /// No description provided for @pleaseSelectProfileFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a profile first'**
  String get pleaseSelectProfileFirst;

  /// No description provided for @pleaseSelectProfileOrWait.
  ///
  /// In en, this message translates to:
  /// **'Please select a profile or wait for medicines to load first.'**
  String get pleaseSelectProfileOrWait;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Selected'**
  String selectedCount(int count);

  /// No description provided for @dosageLabel.
  ///
  /// In en, this message translates to:
  /// **'Dosage: {dosage}'**
  String dosageLabel(String dosage);

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @allMedicinesTitle.
  ///
  /// In en, this message translates to:
  /// **'All Medicines'**
  String get allMedicinesTitle;

  /// No description provided for @selectProfileFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a profile first'**
  String get selectProfileFirst;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get navAll;

  /// No description provided for @navAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get navAdd;

  /// No description provided for @navDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get navDelete;

  /// No description provided for @navReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get navReport;

  /// No description provided for @deletionOptions.
  ///
  /// In en, this message translates to:
  /// **'Deletion Options'**
  String get deletionOptions;

  /// No description provided for @deleteAllMedicines.
  ///
  /// In en, this message translates to:
  /// **'Delete All Medicines'**
  String get deleteAllMedicines;

  /// No description provided for @completelyClearProfile.
  ///
  /// In en, this message translates to:
  /// **'Completely clear this profile.'**
  String get completelyClearProfile;

  /// No description provided for @deleteSpecificMedicine.
  ///
  /// In en, this message translates to:
  /// **'Delete Specific Medicine'**
  String get deleteSpecificMedicine;

  /// No description provided for @chooseMedicineModify.
  ///
  /// In en, this message translates to:
  /// **'Choose a medicine and modify its past/future occurrences.'**
  String get chooseMedicineModify;

  /// No description provided for @noActiveMedicines.
  ///
  /// In en, this message translates to:
  /// **'No active medicines found.'**
  String get noActiveMedicines;

  /// No description provided for @selectMedicineToDelete.
  ///
  /// In en, this message translates to:
  /// **'Select Medicine To Delete'**
  String get selectMedicineToDelete;

  /// No description provided for @deleteRepetitionsFor.
  ///
  /// In en, this message translates to:
  /// **'Delete Repetitions for {medicineName}'**
  String deleteRepetitionsFor(String medicineName);

  /// No description provided for @pastRepetitions.
  ///
  /// In en, this message translates to:
  /// **'Past Repetitions'**
  String get pastRepetitions;

  /// No description provided for @keepFutureHidePast.
  ///
  /// In en, this message translates to:
  /// **'Keep future reminders, but hide all past history.'**
  String get keepFutureHidePast;

  /// No description provided for @futureRepetitions.
  ///
  /// In en, this message translates to:
  /// **'Future Repetitions'**
  String get futureRepetitions;

  /// No description provided for @keepPastStopFuture.
  ///
  /// In en, this message translates to:
  /// **'Keep past history, but stop all future reminders.'**
  String get keepPastStopFuture;

  /// No description provided for @allRepetitions.
  ///
  /// In en, this message translates to:
  /// **'All Repetitions'**
  String get allRepetitions;

  /// No description provided for @completelyDeleteMedicine.
  ///
  /// In en, this message translates to:
  /// **'Completely delete this specific medicine entirely.'**
  String get completelyDeleteMedicine;

  /// No description provided for @deleteAllMedicinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete All Medicines?'**
  String get deleteAllMedicinesTitle;

  /// No description provided for @deleteAllMedicinesContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all medicines for this profile.'**
  String get deleteAllMedicinesContent;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @missedDoses.
  ///
  /// In en, this message translates to:
  /// **'Missed Doses'**
  String get missedDoses;

  /// No description provided for @excellentAdherence.
  ///
  /// In en, this message translates to:
  /// **'Excellent adherence! Keep up the great work 🤗'**
  String get excellentAdherence;

  /// No description provided for @goodAdherence.
  ///
  /// In en, this message translates to:
  /// **'Good adherence. You\'re doing well, but try not to miss doses! 👍'**
  String get goodAdherence;

  /// No description provided for @improveAdherence.
  ///
  /// In en, this message translates to:
  /// **'Let\'s try to improve our adherence this week! You can do it 💪'**
  String get improveAdherence;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note about this medicine...'**
  String get noteHint;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
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
