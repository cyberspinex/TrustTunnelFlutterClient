import 'dart:async';

import 'package:adguard_logger/adguard_logger.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trusttunnel/common/logging/app_logger.dart';
import 'package:trusttunnel/common/utils/vpn_config_builder.dart';
import 'package:trusttunnel/data/database/app_database.dart';
import 'package:trusttunnel/data/datasources/local_sources/logging_settings_datasource_impl.dart';
import 'package:trusttunnel/data/datasources/local_sources/routing_datasource_impl.dart';
import 'package:trusttunnel/data/datasources/local_sources/server_datasource_impl.dart';
import 'package:trusttunnel/data/datasources/local_sources/settings_datasource_impl.dart';
import 'package:trusttunnel/data/model/vpn_configuration_log_level.dart';
import 'package:trusttunnel/feature/server/server_details/domain/service/server_details_service.dart';
import 'package:vpn_plugin/domain/configuration_codec.dart';

/// Read the target, its certificate, DNS and routes from a single DB snapshot.
Future<Map<String, String>> readTileProfile(AppDatabase db, VpnConfigurationLogLevel logLevel) =>
    db.transaction(() async {
      final servers = db.servers;
      final choices =
          await (db.selectOnly(servers)
                ..addColumns([servers.id, servers.selected])
                ..orderBy([OrderingTerm.desc(servers.selected), OrderingTerm.asc(servers.id)])
                ..limit(2))
              .get();
      if (choices.isEmpty) return {'error': 'no_server'};
      if (choices.length > 1 && choices.first.read(servers.selected) != true) return {'error': 'choose_server'};
      if (choices.length > 1 && choices.last.read(servers.selected) == true) return {'error': 'invalid_profile'};

      final id = choices.first.read(servers.id)!.toString();
      final server = await ServerDataSourceImpl.readServer(db, id);
      if (ServerDetailsServiceImpl().validateData(data: server.serverData).isNotEmpty)
        return {'error': 'invalid_profile'};
      final routing = await RoutingDataSourceImpl(database: db).getProfileById(id: server.serverData.routingProfileId);
      final config = buildVpnConfig(
        server: server.serverData,
        routingProfile: routing.data,
        excludedRoutes: await SettingsDataSourceImpl(database: db).getExcludedRoutes(),
        logLevel: logLevel,
      );
      return {'id': id, 'config': const ConfigurationCodec().encode(config)};
    });

/// This isolate never starts the VPN. Android checks the command again after the read.
Future<void> sendQuickSettingsProfile() => runZoned(() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  Map<String, String> reply;
  try {
    final settings = LoggingSettingsDataSourceImpl(preferences: await SharedPreferences.getInstance());
    final level = VpnConfigurationLogLevel.forSettings(
      await settings.getSecurityType(),
      await settings.getLoggingLevel(),
    );
    reply = await readTileProfile(db, level);
  } catch (_) {
    reply = {'error': 'invalid_profile'};
  } finally {
    await db.close();
  }
  await const MethodChannel('trusttunnel/tile_profile').invokeMethod<void>('profile', reply);
}, zoneValues: {Logger.loggerKey: AppLogger()});
