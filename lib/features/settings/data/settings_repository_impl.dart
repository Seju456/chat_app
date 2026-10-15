import '../../../core/database/app_database.dart';
import '../domain/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._db);
  final AppDatabase _db;

  static const _themeKey = 'theme_mode';

  @override
  Future<AppThemeMode> getThemeMode() async {
    final row = await (_db.select(
      _db.keyValues,
    )..where((t) => t.entryKey.equals(_themeKey))).getSingleOrNull();
    return AppThemeMode.values.asNameMap()[row?.entryValue] ??
        AppThemeMode.system;
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) => _db
      .into(_db.keyValues)
      .insertOnConflictUpdate(
        KeyValuesCompanion.insert(entryKey: _themeKey, entryValue: mode.name),
      );
}
