import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _boxName = 'settingsBox';
  static const String _localeKey = 'locale';

  LocaleCubit() : super(const Locale('en')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final box = await Hive.openBox(_boxName);
    final savedCode = box.get(_localeKey);
    if (savedCode != null) {
      emit(Locale(savedCode));
    }
  }

  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    final box = await Hive.openBox(_boxName);
    await box.put(_localeKey, newLocale.languageCode);
    emit(newLocale);
  }
}
