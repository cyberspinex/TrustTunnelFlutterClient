import 'package:flutter/material.dart';
import 'package:trusttunnel/common/assets/asset_icons.dart';
import 'package:trusttunnel/common/localization/localization.dart';
import 'package:trusttunnel/data/model/routing_mode.dart';
import 'package:trusttunnel/feature/routing/routing_details/widgets/routing_details_change_routing_dialog.dart';
import 'package:trusttunnel/feature/routing/routing_details/widgets/routing_details_delete_rules_dialog.dart';
import 'package:trusttunnel/widgets/common/scaffold_messenger_provider.dart';

import 'package:trusttunnel/widgets/custom_icon.dart';
import 'package:trusttunnel/widgets/menu/menu_item_content.dart';

class RoutingDetailsScreenAppBarAction extends StatelessWidget {
  final void Function(BuildContext context) onClearRulesPressed;
  final void Function(BuildContext context, RoutingMode mode) onDefaultModePicked;

  final String profileName;
  final RoutingMode pickedRoutingMode;

  const RoutingDetailsScreenAppBarAction({
    required this.onClearRulesPressed,
    required this.onDefaultModePicked,
    required this.profileName,
    required this.pickedRoutingMode,
    super.key,
  });

  @override
  Widget build(BuildContext context) => PopupMenuButton(
    icon: CustomIcon.medium(
      icon: AssetIcons.moreVert,
    ),
    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      PopupMenuItem<String>(
        onTap: () => _onChangeDefaultRoutingMode(context),
        child: MenuItemContent(
          icon: AssetIcons.update,
          label: context.ln.changeDefaultRoutingMode,
        ),
      ),
      PopupMenuItem<String>(
        onTap: () => _onClearRulesPressed(context),
        child: MenuItemContent(
          icon: AssetIcons.delete,
          label: context.ln.deleteAllRules,
          danger: true,
        ),
      ),
    ],
  );

  void _onClearRulesPressed(BuildContext context) {
    final parentScaffoldMessenger = ScaffoldMessenger.maybeOf(context);

    showDialog(
      context: context,

      builder: (innerContext) => ScaffoldMessengerProvider(
        value: parentScaffoldMessenger ?? ScaffoldMessenger.of(innerContext),
        child: RoutingDetailsDeleteRulesDialog(
          onDeletePressed: () => onClearRulesPressed(context),
          profileName: profileName,
        ),
      ),
    );
  }

  void _onChangeDefaultRoutingMode(BuildContext context) {
    final parentScaffoldMessenger = ScaffoldMessenger.maybeOf(context);

    showDialog(
      context: context,
      builder: (innerContext) => ScaffoldMessengerProvider(
        value: parentScaffoldMessenger ?? ScaffoldMessenger.of(innerContext),
        child: RoutingDetailsChangeRoutingDialog(
          onSavePressed: (mode) => onDefaultModePicked(context, mode),
          currentRoutingMode: pickedRoutingMode,
        ),
      ),
    );
  }
}
