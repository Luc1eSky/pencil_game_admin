import 'package:flutter/material.dart';

import '../../../../constants.dart';
import '../../../../style/color_palette.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(text ?? appName),
      backgroundColor: ColorPalette().appBarBackground,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(appBarHeight);
}
