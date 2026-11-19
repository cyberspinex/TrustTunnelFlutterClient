import 'package:flutter/foundation.dart';

final class AppConstants {
  static const String appName = 'TrustTunnel';
  static const String deepLinkScheme = 'tt';

  static String get displayName =>
      defaultTargetPlatform == TargetPlatform.android ? 'TrustTunnel NAVQS' : appName;
}
