import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/logging/enum/logging_level.dart';
import 'package:trusttunnel/common/logging/enum/logging_security_type.dart';
import 'package:trusttunnel/common/theme/app_theme.dart';
import 'package:trusttunnel/common/theme/theme_preference.dart';
import 'package:trusttunnel/data/model/routing_mode.dart';
import 'package:trusttunnel/data/model/routing_profile.dart';
import 'package:trusttunnel/data/model/routing_profile_data.dart';
import 'package:trusttunnel/data/model/server.dart';
import 'package:trusttunnel/data/model/server_data.dart';
import 'package:trusttunnel/data/model/vpn_configuration_log_level.dart';
import 'package:trusttunnel/data/model/vpn_log.dart';
import 'package:trusttunnel/data/model/vpn_state.dart';
import 'package:trusttunnel/data/repository/auto_connect_on_launch_settings_repository.dart';
import 'package:trusttunnel/data/repository/logging_settings_repository.dart';
import 'package:trusttunnel/data/repository/routing_repository.dart';
import 'package:trusttunnel/data/repository/server_repository.dart';
import 'package:trusttunnel/data/repository/settings_repository.dart';
import 'package:trusttunnel/data/repository/vpn_repository.dart';
import 'package:trusttunnel/di/model/dependency_factory.dart';
import 'package:trusttunnel/di/model/repository_factory.dart';
import 'package:trusttunnel/di/widgets/dependency_scope.dart';
import 'package:trusttunnel/feature/app/app.dart';
import 'package:trusttunnel/feature/routing/routing/widgets/scope/routing_scope.dart';
import 'package:trusttunnel/feature/server/servers/widget/scope/servers_scope.dart';
import 'package:trusttunnel/feature/settings/app_logging/widgets/scope/app_logging_scope.dart';
import 'package:trusttunnel/feature/settings/excluded_routes/widgets/scope/excluded_routes_scope.dart';
import 'package:trusttunnel/feature/settings/settings/widgets/theme_settings_tile.dart';
import 'package:trusttunnel/feature/vpn/widgets/vpn_scope.dart';
import 'package:trusttunnel/feature/routing/routing_details/widgets/routing_details_screen_app_bar_action.dart';
import 'package:trusttunnel/widgets/inputs/custom_text_field.dart';

class _Dependencies extends Fake implements DependencyFactory {
  _Dependencies(SharedPreferences prefs) : themePreference = ThemePreference(prefs);
  @override
  final ThemePreference themePreference;
  @override
  final lightThemeData = AppTheme(Brightness.light).data;
  @override
  final darkThemeData = AppTheme(Brightness.dark).data;
  @override
  Future<void> close() async {}
}

// The real scopes and VPN controller read a local profile and routing rules.
// Only storage and the native VPN transport are substituted.
class _Repositories extends Fake implements RepositoryFactory, ServerRepository, RoutingRepository,
    LoggingSettingsRepository, SettingsRepository, AutoConnectOnLaunchSettingsRepository {
  @override
  ServerRepository get serverRepository => this;
  @override
  RoutingRepository get routingRepository => this;
  @override
  LoggingSettingsRepository get loggingSettingsRepository => this;
  @override
  SettingsRepository get settingsRepository => this;
  @override
  AutoConnectOnLaunchSettingsRepository get autoConnectOnLaunchSettingsRepository => this;
  @override
  Future<List<Server>> getAllServers() async => [Server(id: '1', serverData: const ServerData.empty(name: 'Local fixture', selected: true, routingProfileId: '2'))];
  @override
  Future<List<RoutingProfile>> getAllProfiles() async => [RoutingProfile(id: '2', data: const RoutingProfileData.empty())];
  @override
  Future<List<String>> getExcludedRoutes() async => [];
  @override
  Future<LoggingLevel> getLoggingLevel() async => LoggingLevel.defaultLevel;
  @override
  Future<LoggingSecurityType> getSecurityType() async => LoggingSecurityType.stripped;
}

class _NativeVpn extends Fake implements VpnRepository {
  final commands = <String>[];
  final states = StreamController<VpnState>.broadcast();
  VpnState state = VpnState.disconnected;
  @override
  Future<Stream<VpnState>> listenToStates() async => states.stream;
  @override
  Future<Stream<VpnLog>> listenToLogs() async => const Stream.empty();
  @override
  Future<VpnState> requestState() async => state;
  @override
  Future<void> start({required Server server, required RoutingProfile routingProfile, required List<String> excludedRoutes, required VpnConfigurationLogLevel logLevel, bool fallIntoRecovery = false}) async {
    commands.add('start');
    states.add(state = VpnState.connected);
  }
  @override
  Future<void> stop() async {
    commands.add('stop');
    states.add(state = VpnState.disconnected);
  }
  @override
  Future<void> updateConfiguration({required Server server, required RoutingProfile routingProfile, required List<String> excludedRoutes, required VpnConfigurationLogLevel logLevel}) async => commands.add('update');
  @override
  Future<void> deleteConfiguration() async => commands.add('delete');
}

const _field = ValueKey('editable field');

class _Screen extends StatelessWidget {
  const _Screen();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListView(children: [
      ThemeSettingsTile(preference: context.dependencyFactory.themePreference),
      TextButton(
        child: const Text('Edit profile'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const _Editor()),
        ),
      ),
    ]),
  );
}

class _Editor extends StatelessWidget {
  const _Editor();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    body: Column(children: [
      CustomTextField(key: _field, value: 'unsaved profile', maxLines: 3),
      RoutingDetailsScreenAppBarAction(
        profileName: 'Test profile',
        pickedRoutingMode: RoutingMode.vpn,
        onClearRulesPressed: (_) {},
        onDefaultModePicked: (_, _) {},
      ),
      TextButton(
        child: const Text('Show dialog'),
        onPressed: () => showDialog<void>(
          context: context, builder: (_) => const AlertDialog(title: Text('Still open')),
        ),
      ),
    ]),
  );
}

void main() {
  for (final width in [390.0, 1024.0]) {
    testWidgets('Android theme, navigation, and VPN stay independent at width $width', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final dispatcher = tester.platformDispatcher;
      dispatcher.platformBrightnessTestValue = Brightness.light;
      addTearDown(dispatcher.clearPlatformBrightnessTestValue);
      SharedPreferences.setMockInitialValues({});
      final deps = _Dependencies(await SharedPreferences.getInstance());
      final nativeVpn = _NativeVpn();
      await tester.pumpWidget(DependencyScope(
        dependenciesFactory: deps,
        repositoryFactory: _Repositories(),
        child: AppLoggingScope(child: RoutingScope(child: ExcludedRoutesScope(child: ServersScope(
          child: VpnScope(vpnRepository: nativeVpn, appWindowControllerProvider: () => throw UnsupportedError('Android'),
            child: const App(home: _Screen())),
        )))),
      ));
      await tester.pumpAndSettle();
      final home = tester.element(find.byType(_Screen));
      final vpn = VpnScope.vpnControllerOf(home, listen: false);
      final startup = List.of(nativeVpn.commands);
      Future<void> choose(String label) async {
        await tester.tap(find.byType(ThemeSettingsTile));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(RadioListTile<ThemeMode>, label));
        await tester.pumpAndSettle();
      }
      await choose('Dark');
      expect(Theme.of(home).brightness, Brightness.dark);
      expect(nativeVpn.commands, startup);
      expect(vpn.state, VpnState.disconnected);
      vpn.connectToServer('1');
      await tester.pumpAndSettle();
      expect(nativeVpn.commands.last, 'start');
      expect(vpn.state, VpnState.connected);
      final connected = List.of(nativeVpn.commands);
      await choose('Light');
      dispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      expect(Theme.of(home).brightness, Brightness.light);
      await choose('System');
      expect(Theme.of(home).brightness, Brightness.dark);
      await tester.tap(find.text('Edit profile'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(_field), 'unsaved profile\n');
      await tester.tap(find.text('Show dialog'));
      await tester.pumpAndSettle();
      dispatcher.platformBrightnessTestValue = Brightness.light;
      await tester.pumpAndSettle();
      expect(Theme.of(tester.element(find.text('Still open'))).brightness, Brightness.light);
      Navigator.of(tester.element(find.text('Still open'))).pop();
      await tester.pumpAndSettle();
      expect(find.text('unsaved profile\n'), findsOneWidget);
      await tester.tap(find.byType(RoutingDetailsScreenAppBarAction));
      await tester.pumpAndSettle();
      dispatcher.platformBrightnessTestValue = Brightness.dark;
      await tester.pumpAndSettle();
      final deleteLabel = find.text('Delete all rules');
      final deleteText = tester.widget<Text>(deleteLabel);
      expect(deleteText.style!.color, tester.element(deleteLabel).colors.error);
      Navigator.of(tester.element(deleteLabel)).pop();
      await tester.pumpAndSettle();
      expect(vpn.state, VpnState.connected);
      expect(vpn.currentlyConnectedServerId, '1');
      expect(nativeVpn.commands, connected);
      expect(VpnScope.vpnControllerOf(home, listen: false), same(vpn));
      vpn.disconnect();
      await tester.pumpAndSettle();
      expect(nativeVpn.commands.last, 'stop');
      expect(vpn.state, VpnState.disconnected);
      await tester.pumpWidget(const SizedBox());
      await nativeVpn.states.close();
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  }
}
