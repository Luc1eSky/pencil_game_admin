import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/tables/data/realtime_database_repository.dart';

import '../../schedule/data/firestore_schedule_repository.dart';
import '../../user/data/firestore_user_repository.dart';
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
          // final progress = snapshot.data?.data();
          // if (progress == null) {
          //   debugPrint('Document has no data!');
          //   return const Text('Error - document has no data.');
          // }

          //final progress = docData;

          return !progress.showScheduleSwitch
              ? Container()
              : Switch(
                  thumbIcon: thumbIcon,
                  value: progress.status == ExperimentStatus.lockedSchedule,
                  onChanged: (bool value) async {
                    // if currently locked, change status to "scheduled"
                    if (progress.status == ExperimentStatus.lockedSchedule) {
                      await ref.read(firestoreProgressRepositoryProvider).changeStatus(
                            experimentDocId: experimentDocId,
                            newStatus: ExperimentStatus.scheduled,
                          );

                      // reset current table number of all users (set to null)
                      ref.read(firestoreUserRepositoryProvider).resetTableNumber(experimentDocId);
                    }
                    // if currently scheduled, change status to "lockedSchedule"
                    else if (progress.status == ExperimentStatus.scheduled) {
                      await ref.read(firestoreProgressRepositoryProvider).changeStatus(
                            experimentDocId: experimentDocId,
                            newStatus: ExperimentStatus.lockedSchedule,
                          );

                      // read first round of schedule
                      final firstRound = await ref
                          .read(firestoreScheduleRepositoryProvider)
                          .getRound(experimentDocId, 1);

                      // create tables in realtime database
                      ref.read(realtimeDatabaseRepositoryProvider).addTablesToDatabase(
                            experimentDocId: experimentDocId,
                            round: firstRound,
                          );

                      // change current table number of all users
                      ref.read(firestoreUserRepositoryProvider).changeCurrentTableNumbers(
                            experimentDocId,
                            firstRound,
                          );
                    }
                  },
                );
        });
  }
}
