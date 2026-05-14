// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => '3lagy';

  @override
  String get add => 'Add';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get selectProfile => 'Select a profile';

  @override
  String get noMedicines => 'No medicines for this day';

  @override
  String get markTakenTitle => 'Mark as Taken?';

  @override
  String markTakenContent(String medicineName) {
    return 'Are you sure you want to mark $medicineName as taken?';
  }

  @override
  String get unmarkTakenTitle => 'Unmark as Taken?';

  @override
  String unmarkTakenContent(String medicineName) {
    return 'Are you sure you want to unmark $medicineName?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get taken => 'Taken';

  @override
  String get missed => 'Missed';

  @override
  String get timeToTake => 'Time to take';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get allMedicines => 'All Medicines';

  @override
  String get noMedicinesRecorded => 'No medicines recorded';

  @override
  String get started => 'Started';

  @override
  String get ends => 'Ends';

  @override
  String get ongoingIndefinitely => 'Ongoing indefinitely';

  @override
  String get frequency => 'Frequency';

  @override
  String everyXHours(int hours) {
    return 'Every $hours hours';
  }

  @override
  String dailyAt(String time) {
    return 'Daily at $time';
  }

  @override
  String get intakeHistory => 'Intake History';

  @override
  String get noHistoryRecorded => 'No history recorded yet.';

  @override
  String planned(String time) {
    return 'Planned: $time';
  }

  @override
  String get reportTitle => 'Report';

  @override
  String get myPerformance => 'My Performance';

  @override
  String get medicines => 'Medicines';

  @override
  String get active => 'Active';

  @override
  String get dosesTaken => 'Doses Taken';

  @override
  String get adherence => 'Adherence';

  @override
  String get addMedicineTitle => 'Add Medicine';

  @override
  String get editMedicineTitle => 'Edit Medicine';

  @override
  String get medicineName => 'Medicine Name';

  @override
  String get dosage => 'Dosage (e.g., 1 pill, 5ml)';

  @override
  String get startDate => 'Start Date';

  @override
  String get durationDays => 'Duration (Days)';

  @override
  String get optional => 'Optional';

  @override
  String get intervalLabel => 'Interval';

  @override
  String get fixedTimeLabel => 'Fixed Time';

  @override
  String get intervalHours => 'Interval Options';

  @override
  String get selectTime => 'Select Time';

  @override
  String get selectImage => 'Select Image';

  @override
  String get save => 'Save';

  @override
  String get pleaseEnterName => 'Please enter medicine name';

  @override
  String get pleaseEnterDosage => 'Please enter dosage';

  @override
  String get pleaseSelectTime =>
      'Please select a time for fixed daily medication';

  @override
  String get pleaseSelectInterval => 'Please select interval hours';

  @override
  String get deleteProfileTitle => 'Delete Profile?';

  @override
  String deleteProfileContent(String profileName) {
    return 'Are you sure you want to delete $profileName? All medicines associated with this profile will be permanently wiped.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get addProfile => 'Add Profile';

  @override
  String get name => 'Name';

  @override
  String manageProfile(String profileName) {
    return 'Manage Profile: $profileName';
  }

  @override
  String get deleteSelectedMedicines => 'Delete Selected Medicines?';

  @override
  String deleteSelectedContent(int count) {
    return 'This will permanently delete $count medicine(s).';
  }

  @override
  String get pleaseSelectProfileFirst => 'Please select a profile first';

  @override
  String get pleaseSelectProfileOrWait =>
      'Please select a profile or wait for medicines to load first.';

  @override
  String selectedCount(int count) {
    return '$count Selected';
  }

  @override
  String dosageLabel(String dosage) {
    return 'Dosage: $dosage';
  }

  @override
  String get endDate => 'End Date';

  @override
  String get daily => 'Daily';

  @override
  String get allMedicinesTitle => 'All Medicines';

  @override
  String get selectProfileFirst => 'Select a profile first';

  @override
  String get navHome => 'Home';

  @override
  String get navAll => 'All';

  @override
  String get navAdd => 'Add';

  @override
  String get navDelete => 'Delete';

  @override
  String get navReport => 'Report';

  @override
  String get deletionOptions => 'Deletion Options';

  @override
  String get deleteAllMedicines => 'Delete All Medicines';

  @override
  String get completelyClearProfile => 'Completely clear this profile.';

  @override
  String get deleteSpecificMedicine => 'Delete Specific Medicine';

  @override
  String get chooseMedicineModify =>
      'Choose a medicine and modify its past/future occurrences.';

  @override
  String get noActiveMedicines => 'No active medicines found.';

  @override
  String get selectMedicineToDelete => 'Select Medicine To Delete';

  @override
  String deleteRepetitionsFor(String medicineName) {
    return 'Delete Repetitions for $medicineName';
  }

  @override
  String get pastRepetitions => 'Past Repetitions';

  @override
  String get keepFutureHidePast =>
      'Keep future reminders, but hide all past history.';

  @override
  String get futureRepetitions => 'Future Repetitions';

  @override
  String get keepPastStopFuture =>
      'Keep past history, but stop all future reminders.';

  @override
  String get allRepetitions => 'All Repetitions';

  @override
  String get completelyDeleteMedicine =>
      'Completely delete this specific medicine entirely.';

  @override
  String get deleteAllMedicinesTitle => 'Delete All Medicines?';

  @override
  String get deleteAllMedicinesContent =>
      'This will permanently delete all medicines for this profile.';

  @override
  String get navMore => 'More';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get missedDoses => 'Missed Doses';

  @override
  String get excellentAdherence =>
      'Excellent adherence! Keep up the great work 🤗';

  @override
  String get goodAdherence =>
      'Good adherence. You\'re doing well, but try not to miss doses! 👍';

  @override
  String get improveAdherence =>
      'Let\'s try to improve our adherence this week! You can do it 💪';

  @override
  String get textSize => 'Text Size';

  @override
  String get noteLabel => 'Note';

  @override
  String get noteHint => 'Add a note about this medicine...';
}
