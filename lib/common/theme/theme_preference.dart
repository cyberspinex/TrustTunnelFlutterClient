import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The saved value is the user's choice, including "system", not the current brightness.
class ThemePreference extends ValueNotifier<ThemeMode> {
  static const _key = 'android_theme_mode';
  final SharedPreferences _preferences;
  ThemeMode _saved;
  Future<void> _writes = Future<void>.value();
  int _revision = 0;

  ThemePreference(SharedPreferences preferences)
    : _preferences = preferences,
      _saved = switch (preferences.get(_key)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      super(ThemeMode.system) {
    value = _saved;
  }

  Future<bool> select(ThemeMode mode) {
    final revision = ++_revision;
    value = mode;
    final result = _writes.then((_) async {
      if (_saved == mode) return true;
      try {
        if (await _preferences.setString(_key, mode.name)) {
          _saved = mode;
          return true;
        }
      } on Exception {
        // The settings screen reports the failure and keeps the last saved choice.
      }
      if (revision == _revision) value = _saved;
      return false;
    });
    _writes = result.then<void>((_) {});
    return result;
  }
}
