import 'package:flutter/material.dart';
import 'package:trusttunnel/common/extensions/context_extensions.dart';
import 'package:trusttunnel/widgets/custom_icon.dart';

/// Read colors inside the menu route so an already open menu follows Android.
class MenuItemContent extends StatelessWidget {
  const MenuItemContent({required this.icon, required this.label, this.danger = false, super.key});

  final IconData icon;
  final String label;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? context.colors.error : null;
    return Row(
      spacing: 12,
      children: [
        CustomIcon.medium(icon: icon, color: color),
        Flexible(child: Text(label, style: context.textTheme.bodyLarge?.copyWith(color: color))),
      ],
    );
  }
}
