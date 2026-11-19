import 'package:flutter/material.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/common/theme/theme_preference.dart';

class ThemeSettingsTile extends StatelessWidget {
  const ThemeSettingsTile({required this.preference, super.key});

  final ThemePreference preference;

  String _label(BuildContext context, ThemeMode mode) => switch (mode) {
    ThemeMode.system => context.ln.themeSystem,
    ThemeMode.light => context.ln.themeLight,
    ThemeMode.dark => context.ln.themeDark,
  };

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: preference,
    builder: (context, mode, _) => ListTile(
      title: Text(context.ln.themeSetting),
      subtitle: Text(_label(context, mode)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _chooseMode(context),
    ),
  );

  Future<void> _chooseMode(BuildContext context) async {
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(dialogContext.ln.themeSetting),
        children: [
          RadioGroup<ThemeMode>(
            groupValue: preference.value,
            onChanged: (value) => Navigator.of(dialogContext).pop(value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final mode in ThemeMode.values)
                  RadioListTile<ThemeMode>(value: mode, title: Text(_label(dialogContext, mode))),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected == null) return;
    final saved = await preference.select(selected);
    if (!saved && context.mounted) context.showInfoSnackBar(message: context.ln.themeSaveFailed);
  }
}
