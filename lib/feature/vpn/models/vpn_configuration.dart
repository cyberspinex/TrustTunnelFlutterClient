import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:trusttunnel/common/utils/vpn_config_builder.dart';
import 'package:vpn_plugin/domain/configuration_codec.dart';
import 'package:trusttunnel/data/model/routing_profile.dart';
import 'package:trusttunnel/data/model/server.dart';
import 'package:trusttunnel/data/model/vpn_configuration_log_level.dart';

@immutable
final class VpnConfiguration {
  final Server server;
  final RoutingProfile routingProfile;
  final List<String> excludedRoutes;
  final VpnConfigurationLogLevel logLevel;

  VpnConfiguration({
    required Server server,
    required RoutingProfile routingProfile,
    required List<String> excludedRoutes,
    required this.logLevel,
  }) : server = server.copyWith(
         serverData: server.serverData.copyWith(
           // Selection is metadata and must not participate in configuration equality.
           selected: false,
           dnsServers: List.unmodifiable(server.serverData.dnsServers),
         ),
       ),
       routingProfile = routingProfile.copyWith(
         data: routingProfile.data.copyWith(
           bypassRules: List.unmodifiable(routingProfile.data.bypassRules),
           vpnRules: List.unmodifiable(routingProfile.data.vpnRules),
         ),
       ),
       excludedRoutes = List.unmodifiable(excludedRoutes);

  /// Compared once when the UI attaches to a VPN started by the Android tile.
  bool matchesTileDigest(String digest) {
    final config = buildVpnConfig(
      server: server.serverData,
      routingProfile: routingProfile.data,
      excludedRoutes: excludedRoutes,
      logLevel: logLevel,
    );
    return sha256.convert(utf8.encode(const ConfigurationCodec().encode(config))).toString() == digest;
  }

  @override
  int get hashCode => Object.hashAll([
    server,
    routingProfile,
    Object.hashAll(excludedRoutes),
    logLevel,
  ]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VpnConfiguration &&
          server == other.server &&
          routingProfile == other.routingProfile &&
          listEquals(excludedRoutes, other.excludedRoutes) &&
          logLevel == other.logLevel;
}
