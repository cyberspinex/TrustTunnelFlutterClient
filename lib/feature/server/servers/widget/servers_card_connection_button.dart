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

  const ServersCardConnectionButton({
    super.key,
    required this.vpnManagerState,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final android = defaultTargetPlatform == TargetPlatform.android;
    final pending = vpnManagerState != VpnState.connected && vpnManagerState != VpnState.disconnected;
    final connected = vpnManagerState == VpnState.connected;
    final waitingIcon = android
        ? switch (vpnManagerState) {
            VpnState.waitingForNetwork => Icons.signal_wifi_off,
            VpnState.waitingForRecovery => Icons.hourglass_empty,
            _ => null,
          }
        : null;
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
    final darkConnected = android && connected && context.theme.brightness == Brightness.dark;
    final button = CustomIconButton.square(
      icon: waitingIcon ?? (pending ? AssetIcons.update : darkConnected ? AssetIcons.check : AssetIcons.powerSettingsNew),
      tooltip: android ? (pending ? status : connected ? context.ln.disconnect : context.ln.connect) : null,
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
      child: pending && waitingIcon == null
          ? RotatingWidget(duration: const Duration(seconds: 1), child: button)
          : button,
    );
    return android ? Semantics(value: status, child: content) : content;
  }
}
