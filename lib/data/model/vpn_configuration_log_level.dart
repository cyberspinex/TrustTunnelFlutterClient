import 'package:trusttunnel/common/logging/enum/logging_level.dart';
import 'package:trusttunnel/common/logging/enum/logging_security_type.dart';

/// {@template vpn_configuration_log_level}
/// Defines the available log levels for VPN configuration.
///
/// Log levels control the verbosity of logging in the VPN system:
/// - [error]: Error messages only (lowest enabled verbosity)
/// - [info]: Standard information messages
/// - [debug]: Detailed information for debugging purposes
/// {@endtemplate}
enum VpnConfigurationLogLevel {
  error,
  info,
  debug;

  static VpnConfigurationLogLevel forSettings(LoggingSecurityType security, LoggingLevel level) => switch (security) {
    LoggingSecurityType.stripped => error,
    LoggingSecurityType.full => switch (level) {
      LoggingLevel.defaultLevel => info,
      LoggingLevel.debug => debug,
    },
  };
}
