import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/tables/application/copy_results_service.dart';

import '../../../../style/color_palette.dart';
import '../../domain/realtime_table.dart';

class TimerWidget extends ConsumerStatefulWidget {
  const TimerWidget({
    super.key,
    required this.experimentDocId,
    required this.table,
    required this.databaseOffset,
    required this.size,
  });

  final String experimentDocId;
  final RealtimeTable table;
  final Duration databaseOffset;
  final double size;

  @override
  ConsumerState<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends ConsumerState<TimerWidget> {
  late DateTime _serverEndTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _serverEndTime = widget.table.endedOn!;
    _startTimer();
  }

  void _startTimer() {
    const oneSecond = Duration(seconds: 1);
    Duration delay = oneSecond - Duration(milliseconds: _serverTimeNow().millisecond);

    Timer(delay, () {
      _timer = Timer.periodic(oneSecond, (timer) async {
        if (mounted) setState(() {});
        if (_serverTimeNow().isAfter(_serverEndTime)) {
          timer.cancel();
          await Future.delayed(const Duration(seconds: 3));
          try {
            // copy data to firestore and set table to "finished"
            await ref.read(copyResultsServiceProvider).transferResults(
                  experimentDocId: widget.experimentDocId,
                  tableNumber: widget.table.tableNumber,
                );
            print('HERE!');
            // TODO: check if all tables have been finished
            // if all finished --> set progress status to "roundFinished"
            await ref.read(copyResultsServiceProvider).checkIfRoundWasFinished(
                  experimentDocId: widget.experimentDocId,
                );
          } catch (e) {
            // TODO: show snackbar and log result (create function)

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: ColorPalette().snackBarError,
                  content: Text('Error closing table ${widget.table.tableNumber}.\n $e'),
                ),
              );
            }
          }
        }
      });
    });
  }

  /// returns local time including offset to get server time
  DateTime _serverTimeNow() {
    return DateTime.now().add(widget.databaseOffset);
  }

  @override
  void dispose() {
    print('dispose');
    //_timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // calculate time left
    final timeLeft = _serverEndTime.difference(_serverTimeNow());
    final timeLeftDuration = timeLeft.isNegative ? Duration.zero : timeLeft;
    final formattedTimeLeftDuration = _printDuration(timeLeftDuration);
    return Text(
      formattedTimeLeftDuration,
      style: TextStyle(
        fontSize: widget.size,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

String _printDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, "0");
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60).abs());
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60).abs());
  return "$twoDigitMinutes:$twoDigitSeconds";
}
