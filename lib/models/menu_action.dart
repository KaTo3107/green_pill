import 'package:flutter/material.dart';

class MenuAction {
  String get id => label.toLowerCase().replaceAll(' ', '_');
  final String label;
  final IconData icon;
  final Widget children;
  final void Function(BuildContext context) onTap;

  const MenuAction({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.children,
  });
}