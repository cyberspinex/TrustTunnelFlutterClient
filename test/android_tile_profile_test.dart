import 'dart:async';

import 'package:adguard_logger/adguard_logger.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trusttunnel/common/logging/app_logger.dart';
import 'package:trusttunnel/data/database/app_database.dart';
import 'package:trusttunnel/data/model/vpn_configuration_log_level.dart';
import 'package:trusttunnel/feature/vpn/android/tile_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Future<void> withProfiles(Future<void> Function(AppDatabase) check) => runZoned(() async {
    final db = AppDatabase.inMemory(NativeDatabase.memory());
    try {
      await check(db);
    } finally {
      await db.close();
    }
  }, zoneValues: {Logger.loggerKey: AppLogger()});

  Future<int> add(AppDatabase db, String name, {bool selected = false, String domain = 'vpn.example.org'}) => db
      .into(db.servers)
      .insert(
        ServersCompanion.insert(
          ipAddress: '127.0.0.1:4443',
          name: name,
          domain: domain,
          login: 'fixture',
          password: 'fixture',
          vpnProtocolId: 2,
          routingProfileId: 0,
          selected: Value(selected),
        ),
      );

  Future<Map<String, String>> read(AppDatabase db) => readTileProfile(db, VpnConfigurationLogLevel.error);

  test(
    'zero or multiple unselected servers require action; a sole server works',
    () => withProfiles((db) async {
      expect(await read(db), {'error': 'no_server'});
      final first = await add(db, 'One');
      expect((await read(db))['id'], first.toString());
      await add(db, 'Two');
      expect(await read(db), {'error': 'choose_server'});
    }),
  );

  test(
    'a cold read uses selected server and current persisted DNS, rules and excluded routes',
    () => withProfiles((db) async {
      await add(db, 'Other');
      final id = await add(db, 'Chosen', selected: true);
      await db.into(db.dnsServers).insert(DnsServersCompanion.insert(serverId: id, data: '192.0.2.53'));
      await db
          .into(db.profileRules)
          .insert(ProfileRulesCompanion.insert(profileId: 0, mode: 1, data: 'bypass.example.org'));
      await db.into(db.excludedRoutes).insert(ExcludedRoutesCompanion.insert(value: '198.51.100.0/24'));
      final first = await read(db);
      expect(first['id'], id.toString());
      for (final value in ['Chosen', '127.0.0.1:4443', '192.0.2.53', '*.bypass.example.org', '198.51.100.0/24']) {
        expect(first['config'], contains(value));
      }
      await (db.update(
        db.servers,
      )..where((s) => s.id.equals(id))).write(const ServersCompanion(ipAddress: Value('127.0.0.1:5553')));
      final second = await read(db);
      expect(second['config'], contains('127.0.0.1:5553'));
      expect(second['config'], isNot(contains('127.0.0.1:4443')));
    }),
  );

  test(
    'an invalid selected profile cannot silently switch to another server',
    () => withProfiles((db) async {
      await add(db, 'Usable');
      await add(db, 'Invalid', selected: true, domain: '');
      expect(await read(db), {'error': 'invalid_profile'});
    }),
  );
}
