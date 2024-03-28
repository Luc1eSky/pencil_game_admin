import 'package:flutter/material.dart';
import 'package:pencil_game_admin/features/tables/domain/realtime_table.dart';
import 'package:pencil_game_admin/style/color_palette.dart';

import '../../../user/domain/simple_user.dart';

class TablePlayerWidget extends StatelessWidget {
  const TablePlayerWidget({
    super.key,
    required this.user,
    required this.userIsPresent,
    required this.status,
  });

  final SimpleUser user;
  final bool userIsPresent;
  final TableStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: userIsPresent
            ? status == TableStatus.playing
                ? ColorPalette().playerCardPlaying
                : status == TableStatus.finished
                    ? ColorPalette().playerCardFinished
                    : ColorPalette().playerCardReady
            : ColorPalette().playerCardWaiting,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            FittedBox(
              child: Text(
                user.colorCode,
                style: const TextStyle(
                  fontSize: 24,
                  //fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FittedBox(
              child: Text(
                user.shortNameString,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
