import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';

/// Go-Volts top app bar.
///
/// Used on all interior screens. Back arrow included by default when a
/// Navigator route is below. Optional [actions] for help/action icons.
class GVTopBar extends StatelessWidget implements PreferredSizeWidget {
  const GVTopBar({
    super.key,
    required this.title,
    this.actions,
    this.backgroundColor = GVColors.white,
    this.foregroundColor = GVColors.nearBlack,
    this.centerTitle = false,
    this.leading,
    this.bottom,
  });

  final String title;
  final List<Widget>? actions;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool centerTitle;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      centerTitle: centerTitle,
      title: Text(title,
          style: GVTypography.h3.copyWith(color: foregroundColor)),
      leading: leading,
      actions: actions,
      bottom: bottom,
      surfaceTintColor: Colors.transparent,
    );
  }
}
