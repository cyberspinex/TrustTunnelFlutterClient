import 'package:trusttunnel/common/utils/server_endpoint_encoder.dart';
import 'package:trusttunnel/common/utils/validation_utils.dart';
import 'package:trusttunnel/common/utils/vpn_mode_encoder.dart';
import 'package:trusttunnel/data/model/routing_mode.dart';
import 'package:trusttunnel/data/model/routing_profile_data.dart';
import 'package:trusttunnel/data/model/server_data.dart';
import 'package:trusttunnel/data/model/vpn_configuration_log_level.dart';
import 'package:vpn_plugin/models/configuration.dart';
import 'package:vpn_plugin/models/configuration_log_level.dart';
import 'package:vpn_plugin/models/socks.dart';
import 'package:vpn_plugin/models/tun.dart';

/// Used by foreground commands and by the Android tile's headless entry point.
Configuration buildVpnConfig({
  required ServerData server,
  required RoutingProfileData routingProfile,
  required List<String> excludedRoutes,
  required VpnConfigurationLogLevel logLevel,
}) {
  final rules = switch (routingProfile.defaultMode) {
    RoutingMode.bypass => routingProfile.vpnRules,
    RoutingMode.vpn => routingProfile.bypassRules,
  };
  final domains = <String>{};
  final addresses = <String>{};
  for (final rule in rules) {
    final domain = ValidationUtils.tryParseDomain(rule, allowFirstLevel: true);
    if (domain == null) {
      addresses.add(rule);
    } else {
      domains.add(domain);
      if (!domain.startsWith('*.')) domains.add('*.$domain');
    }
  }
  return Configuration(
    logLevel: switch (logLevel) {
      VpnConfigurationLogLevel.error => ConfigurationLogLevel.error,
      VpnConfigurationLogLevel.info => ConfigurationLogLevel.info,
      VpnConfigurationLogLevel.debug => ConfigurationLogLevel.debug,
    },
    vpnMode: VpnModeEncoder().convert(routingProfile.defaultMode),
    endpoint: ServerEndpointEncoder(exclusions: [...addresses, ...domains]).convert(server),
    tun: Tun(excludedRoutes: excludedRoutes),
    socks: const Socks(),
  );
}
