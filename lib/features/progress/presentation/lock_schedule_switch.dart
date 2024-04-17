import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/schedule/application/schedule_service.dart';

import '../data/firestore_progress_repository.dart';
import '../domain/experiment_progress.dart';

class LockScheduleSwitch extends ConsumerWidget {
  LockScheduleSwitch({super.key, required this.experimentDocId});
  final String experimentDocId;

  final MaterialStateProperty<Icon?> thumbIcon = MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.lock);
      }
      return const Icon(Icons.lock_open);
    },
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
        stream: ref.read(firestoreProgressRepositoryProvider).getProgressDocStream(experimentDocId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Progress doc snapshot error.!');
            return const Text('Progress doc snapshot error.');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          ExperimentProgress progress;
          try {
            progress = snapshot.data!.data()!;
          } catch (e) {
            return const Text('Progress object conversion error.');
          }

          return !progress.showScheduleSwitch
              ? Container()
              : Switch(
                  thumbIcon: thumbIcon,
                  value: progress.status == ExperimentProgressStatus.lockedSchedule,
                  onChanged: (bool value) async {
                    ref.read(scheduleServiceProvider).lockOrUnlockSchedule(
                          experimentDocId: experimentDocId,
                          status: progress.status,
                        );
                  },
                );
        });
  }
}
