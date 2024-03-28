import 'package:flutter/material.dart';
import 'package:pencil_game_admin/features/tables/domain/realtime_table.dart';

class PenIndicator extends StatelessWidget {
  const PenIndicator({required this.realtimeTable, super.key});

  final RealtimeTable realtimeTable;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      //heightFactor: 1.0,
      widthFactor: 0.90,
      child: Stack(
        children: [
          Center(
            child: FractionallySizedBox(
              heightFactor: 0.6,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
          AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: realtimeTable.player1HasPen
                ? Alignment.centerLeft
                : realtimeTable.player2HasPen
                    ? Alignment.centerRight
                    : Alignment.center,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(5.0),
                child: FittedBox(
                  child: Icon(
                    Icons.edit,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
