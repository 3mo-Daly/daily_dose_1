// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'علاجي';

  @override
  String get add => 'إضافة';

  @override
  String get yesterday => 'أمس';

  @override
  String get today => 'اليوم';

  @override
  String get tomorrow => 'غداً';

  @override
  String get selectProfile => 'اختر ملفاً شخصياً';

  @override
  String get noMedicines => 'لا توجد أدوية لهذا اليوم';

  @override
  String get markTakenTitle => 'تأكيد التناول؟';

  @override
  String markTakenContent(String medicineName) {
    return 'هل أنت متأكد أنك تريد تحديد $medicineName كمتناول؟';
  }

  @override
  String get unmarkTakenTitle => 'التراجع عن التناول؟';

  @override
  String unmarkTakenContent(String medicineName) {
    return 'هل أنت متأكد أنك تريد التراجع عن تناول $medicineName؟';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get taken => 'تم التناول';

  @override
  String get missed => 'فائت';

  @override
  String get timeToTake => 'وقت التناول';

  @override
  String get upcoming => 'قادم';

  @override
  String get allMedicines => 'جميع الأدوية';

  @override
  String get noMedicinesRecorded => 'لم يتم تسجيل أي أدوية';

  @override
  String get started => 'بدأ';

  @override
  String get ends => 'ينتهي';

  @override
  String get ongoingIndefinitely => 'مستمر لأجل غير مسمى';

  @override
  String get frequency => 'التكرار';

  @override
  String everyXHours(int hours) {
    return 'كل $hours ساعات';
  }

  @override
  String dailyAt(String time) {
    return 'يوميا في $time';
  }

  @override
  String get intakeHistory => 'سجل التناول';

  @override
  String get noHistoryRecorded => 'لم يتم تسجيل أي سجل حتى الآن.';

  @override
  String planned(String time) {
    return 'مخطط: $time';
  }

  @override
  String get reportTitle => 'التقرير';

  @override
  String get myPerformance => 'أدائي';

  @override
  String get medicines => 'الأدوية';

  @override
  String get active => 'نشط';

  @override
  String get dosesTaken => 'الجرعات المتناولة';

  @override
  String get adherence => 'الالتزام';

  @override
  String get addMedicineTitle => 'إضافة دواء';

  @override
  String get editMedicineTitle => 'تعديل الدواء';

  @override
  String get medicineName => 'اسم الدواء';

  @override
  String get dosage => 'الجرعة (مثال: 1 حبة، 5 مل)';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get durationDays => 'المدة (بالأيام)';

  @override
  String get optional => 'اختياري';

  @override
  String get intervalLabel => 'فترة زمنية';

  @override
  String get fixedTimeLabel => 'وقت محدد';

  @override
  String get intervalHours => 'خيارات الفترة';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get selectImage => 'اختر صورة';

  @override
  String get save => 'حفظ';

  @override
  String get pleaseEnterName => 'الرجاء إدخال اسم الدواء';

  @override
  String get pleaseEnterDosage => 'الرجاء إدخال الجرعة';

  @override
  String get pleaseSelectTime => 'الرجاء تحديد وقت للدواء اليومي الثابت';

  @override
  String get pleaseSelectInterval => 'الرجاء تحديد ساعات الفترة الزمنية';

  @override
  String get deleteProfileTitle => 'حذف الملف الشخصي؟';

  @override
  String deleteProfileContent(String profileName) {
    return 'هل أنت متأكد أنك تريد حذف $profileName؟ سيتم مسح جميع الأدوية المرتبطة بهذا الملف الشخصي بشكل دائم.';
  }

  @override
  String get delete => 'حذف';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get addProfile => 'إضافة ملف شخصي';

  @override
  String get name => 'الاسم';

  @override
  String manageProfile(String profileName) {
    return 'إدارة الملف الشخصي: $profileName';
  }

  @override
  String get deleteSelectedMedicines => 'حذف الأدوية المحددة؟';

  @override
  String deleteSelectedContent(int count) {
    return 'سيؤدي هذا إلى الحذف الدائم لـ $count دواء (أدوية).';
  }

  @override
  String get pleaseSelectProfileFirst => 'يرجى تحديد ملف شخصي أولاً';

  @override
  String get pleaseSelectProfileOrWait =>
      'يرجى تحديد ملف شخصي أو انتظار تحميل الأدوية أولاً.';

  @override
  String selectedCount(int count) {
    return '$count محدد';
  }

  @override
  String dosageLabel(String dosage) {
    return 'الجرعة: $dosage';
  }

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get daily => 'يوميا';

  @override
  String get allMedicinesTitle => 'جميع الأدوية';

  @override
  String get selectProfileFirst => 'اختر ملفاً شخصياً أولاً';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navAll => 'الكل';

  @override
  String get navAdd => 'إضافة';

  @override
  String get navDelete => 'حذف';

  @override
  String get navReport => 'التقرير';

  @override
  String get deletionOptions => 'خيارات الحذف';

  @override
  String get deleteAllMedicines => 'حذف جميع الأدوية';

  @override
  String get completelyClearProfile => 'مسح هذا الملف الشخصي تمامًا.';

  @override
  String get deleteSpecificMedicine => 'حذف دواء محدد';

  @override
  String get chooseMedicineModify =>
      'اختر دواء وعدل أوقاته الماضية/المستقبلية.';

  @override
  String get noActiveMedicines => 'لم يتم العثور على أدوية نشطة.';

  @override
  String get selectMedicineToDelete => 'اختر الدواء للحذف';

  @override
  String deleteRepetitionsFor(String medicineName) {
    return 'حذف تكرارات $medicineName';
  }

  @override
  String get pastRepetitions => 'التكرارات الماضية';

  @override
  String get keepFutureHidePast =>
      'احتفظ بالتذكيرات المستقبلية، لكن أخفِ كل السجل الماضي.';

  @override
  String get futureRepetitions => 'التكرارات المستقبلية';

  @override
  String get keepPastStopFuture =>
      'احتفظ بالسجل الماضي، لكن أوقف جميع التذكيرات المستقبلية.';

  @override
  String get allRepetitions => 'جميع التكرارات';

  @override
  String get completelyDeleteMedicine => 'حذف هذا الدواء بالتحديد بالكامل.';

  @override
  String get deleteAllMedicinesTitle => 'حذف جميع الأدوية؟';

  @override
  String get deleteAllMedicinesContent =>
      'سيؤدي هذا إلى حذف جميع الأدوية المرتبطة بهذا الملف الشخصي بشكل دائم.';

  @override
  String get navMore => 'المزيد';

  @override
  String get settings => 'الإعدادات';

  @override
  String get theme => 'المظهر';

  @override
  String get language => 'اللغة';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get missedDoses => 'الجرعات الفائتة';

  @override
  String get excellentAdherence => 'التزام ممتاز! استمر في العمل الرائع 🤗';

  @override
  String get goodAdherence =>
      'التزام جيد. أنت تبلي بلاءً حسناً، لكن حاول ألا تفوت الجرعات! 👍';

  @override
  String get improveAdherence =>
      'حاول تحسين التزامك هذا الأسبوع! يمكنك القيام بذلك 💪';
}
