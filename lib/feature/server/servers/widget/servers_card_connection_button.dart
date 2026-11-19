import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:trusttunnel/common/assets/asset_icons.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/common/extensions/theme_extensions.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/data/model/vpn_state.dart';
import 'package:trusttunnel/widgets/buttons/custom_icon_button.dart';
import 'package:trusttunnel/widgets/rotating_wrapper.dart';

class ServersCardConnectionButton extends StatelessWidget {
  final VpnState vpnManagerState;
  final VoidCallback onPressed;

  const ServersCardConnectionButton({super.key, required this.vpnManagerState, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final android = defaultTargetPlatform == TargetPlatform.android;
    final pending = vpnManagerState != VpnState.connected && vpnManagerState != VpnState.disconnected;
    final connected = vpnManagerState == VpnState.connected;
    final darkAndroid = android && context.theme.brightness == Brightness.dark;
    final icon = switch (vpnManagerState) {
      VpnState.waitingForNetwork when android => Icons.signal_wifi_off,
      VpnState.waitingForRecovery when android => Icons.hourglass_empty,
      VpnState.connected when darkAndroid => AssetIcons.check,
      VpnState.connected || VpnState.disconnected => AssetIcons.powerSettingsNew,
      _ => AssetIcons.update,
    };
    final status = android
        ? switch (vpnManagerState) {
            VpnState.connected => context.ln.trayStatusConnected,
            VpnState.disconnected => context.ln.trayStatusDisconnected,
            VpnState.connecting => context.ln.trayStatusConnecting,
            VpnState.waitingForNetwork => context.ln.vpnWaitingForNetwork,
            VpnState.waitingForRecovery => context.ln.vpnWaitingForRecovery,
            VpnState.recovering => context.ln.vpnRecovering,
          }
        : null;
    final action = switch (vpnManagerState) {
      VpnState.connected => context.ln.disconnect,
      VpnState.disconnected => context.ln.connect,
      _ => status,
    };
    final button = CustomIconButton.square(
      icon: icon,
      tooltip: android ? action : null,
      onPressed: onPressed,
      size: 24,
      selected: pending || connected,
    );
    final content = Theme(
      data: context.theme.copyWith(
        iconButtonTheme: pending
            ? context.theme.extension<CustomFilledIconButtonTheme>()!.iconButtonInProgress
            : context.theme.extension<CustomFilledIconButtonTheme>()!.iconButton,
      ),
      child: icon == AssetIcons.update ? RotatingWidget(duration: const Duration(seconds: 1), child: button) : button,
    );
    return android ? Semantics(value: status, child: content) : content;
  }
}
