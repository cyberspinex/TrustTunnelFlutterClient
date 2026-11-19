import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trusttunnel/common/constants/app_constants.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/common/logging/observers/logging_navigator_observer.dart';
import 'package:trusttunnel/feature/app/widgets/app_system_actions_handler.dart';
import 'package:trusttunnel/feature/app/widgets/app_system_ui_shell.dart';
import 'package:trusttunnel/feature/navigation/navigation_screen.dart';

class App extends StatefulWidget {
  const App({super.key, this.home = const NavigationScreen()});

  final Widget home;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _rootObserver = LoggingNavigatorObserver(navigatorName: 'root');
  bool get _isAndroid => defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    if (_isAndroid) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final style = context.dependencyFactory.lightThemeData.appBarTheme.systemOverlayStyle;
      if (style != null) SystemChrome.setSystemUIOverlayStyle(style);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAndroid) return _buildApp(context, ThemeMode.light);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: context.dependencyFactory.themePreference,
      builder: (context, mode, _) => _buildApp(context, mode),
    );
  }

  Widget _buildApp(BuildContext context, ThemeMode mode) => MaterialApp(
    theme: context.dependencyFactory.lightThemeData,
    darkTheme: _isAndroid ? context.dependencyFactory.darkThemeData : null,
    themeMode: mode,
    builder: (context, child) {
      final content = AppSystemActionsHandler(child: child!);
      if (!_isAndroid) return content;
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: Theme.of(context).appBarTheme.systemOverlayStyle!,
        child: content,
      );
    },
    navigatorObservers: [_rootObserver],
    home: AppSystemUIShell(child: widget.home),
    title: AppConstants.displayName,
    locale: Localization.defaultLocale,
    localizationsDelegates: Localization.localizationDelegates,
    supportedLocales: Localization.supportedLocales,
  );
}
