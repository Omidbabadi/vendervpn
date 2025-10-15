import 'package:flutter/material.dart';
import 'package:vendervpn/core/widgets/bottom_appbar.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key,required this.iconButton});
  final IconButton iconButton;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: AppBar(
        leading: iconButton,
        elevation: 0,
        centerTitle: true,
        title: const Text('VENDER VPN'),
        bottom: AppBarBottom(),
      ),
    );
  }

  @override
  Size get preferredSize => Size.zero;
}
