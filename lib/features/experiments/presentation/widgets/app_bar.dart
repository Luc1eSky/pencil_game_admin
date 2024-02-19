import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../style/color_palette.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(appName),
      backgroundColor: ColorPalette().appBarBackground,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}
