import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/settings_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._repository) : super(ThemeMode.system);
  final SettingsRepository _repository;

  Future<void> load() async {
    emit(_toThemeMode(await _repository.getThemeMode()));
  }

  Future<void> setMode(AppThemeMode mode) async {
    emit(_toThemeMode(mode));
    await _repository.setThemeMode(mode);
  }

  static ThemeMode _toThemeMode(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}
