import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class SettingsCubit extends Cubit<double> {
  final Box _settingsBox;

  SettingsCubit(this._settingsBox) : super(_settingsBox.get('textScale', defaultValue: 1.0));

  void updateTextScale(double scale) {
    _settingsBox.put('textScale', scale);
    emit(scale);
  }
}
