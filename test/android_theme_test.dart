import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusttunnel/common/extensions/theme_extensions.dart';
import 'package:trusttunnel/common/theme/app_theme.dart';
import 'package:trusttunnel/common/theme/theme_preference.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('2007 upgrade, malformed preferences, and unrelated settings', () async {
    for (final invalid in [null, 42, 'unknown']) {
      SharedPreferences.setMockInitialValues({'profile': 'keep', if (invalid != null) 'android_theme_mode': invalid});
      final prefs = await SharedPreferences.getInstance();
      final mode = ThemePreference(prefs);
      expect(mode.value, ThemeMode.system);
      for (final choice in [ThemeMode.dark, ThemeMode.light, ThemeMode.system]) {
        expect(await mode.select(choice), isTrue);
        expect(ThemePreference(prefs).value, choice);
        expect(prefs.getString('profile'), 'keep');
      }
    }
  });

  test('rapid taps persist the last choice', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final choice = ThemePreference(prefs);
    await Future.wait([choice.select(ThemeMode.dark), choice.select(ThemeMode.system), choice.select(ThemeMode.light)]);
    expect(ThemePreference(prefs).value, ThemeMode.light);
  });

  test('day palette and both Android system bar icon modes', () {
    final light = AppTheme(Brightness.light).data;
    final dark = AppTheme(Brightness.dark).data;
    expect(light.scaffoldBackgroundColor, Colors.white);
    expect(light.textTheme.bodyLarge!.color, const Color(0xFF333E4C));
    expect(light.primaryColor, const Color(0xFF3972AA));
    for (final theme in [light, dark]) {
      final icons = theme.brightness == Brightness.light ? Brightness.dark : Brightness.light;
      expect(theme.appBarTheme.systemOverlayStyle!.statusBarIconBrightness, icons);
      expect(theme.appBarTheme.systemOverlayStyle!.systemNavigationBarIconBrightness, icons);
      expect(theme.colorScheme.brightness, theme.brightness);
    }
  });

  test('dark text and controls meet contrast targets on the surfaces where they appear', () {
    final theme = AppTheme(Brightness.dark).data;
    final colors = theme.extension<CustomColors>()!;
    void contrast(Color fg, Color bg, double minimum) {
      final first = fg.computeLuminance();
      final second = bg.computeLuminance();
      final ratio = (math.max(first, second) + 0.05) / (math.min(first, second) + 0.05);
      expect(ratio, greaterThanOrEqualTo(minimum), reason: '$fg on $bg');
    }

    for (final surface in [colors.background, colors.backgroundAdditional, colors.backgroundElevated, colors.backgroundSystem]) {
      for (final ink in [colors.neutralBlack, colors.neutralDark, colors.neutralLight, colors.accent, colors.error, colors.attention]) {
        contrast(ink, surface, 4.5);
      }
      contrast(theme.iconButtonTheme.style!.foregroundColor!.resolve({})!, surface, 3);
    }
    final onFill = theme.filledButtonTheme.style!.foregroundColor!.resolve({})!;
    for (final fill in [colors.accent, colors.accentPressed, colors.error, colors.attention, colors.neutralDark]) {
      contrast(onFill, fill, 4.5);
    }
    contrast(theme.snackBarTheme.contentTextStyle!.color!, theme.snackBarTheme.backgroundColor!, 4.5);
    contrast(theme.snackBarTheme.actionTextColor!, theme.snackBarTheme.backgroundColor!, 4.5);
    contrast(theme.colorScheme.onSurface, theme.colorScheme.surface, 4.5);
  });
}
