import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/progress/data/firestore_progress_repository.dart';
import 'package:pencil_game_admin/features/schedule/data/firestore_schedule_repository.dart';
import 'package:pencil_game_admin/features/tables/data/realtime_database_repository.dart';
import 'package:pencil_game_admin/features/user/data/firestore_user_repository.dart';

import '../../progress/domain/experiment_progress.dart';

class ScheduleService {
  ScheduleService({
    required this.firestoreScheduleRepository,
    required this.firestoreProgressRepository,
    required this.firestoreUserRepository,
    required this.realtimeDatabaseRepository,
  });

  final FirestoreScheduleRepository firestoreScheduleRepository;
  final FirestoreProgressRepository firestoreProgressRepository;
  final FirestoreUserRepository firestoreUserRepository;
  final RealtimeDatabaseRepository realtimeDatabaseRepository;

  /// create a schedule based on the current amount of users and admin settings (tables and rounds)
  Future<void> createSchedule({required String experimentDocId}) async {
    try {
      // calculate schedule (null if there was an error)
      final schedule = await firestoreScheduleRepository.calculateSchedule(
        experimentDocId: experimentDocId,
      );

      if (schedule == null) {
        throw Exception('Error - Could not calculate schedule.');
      }

      // update schedule documents
      await firestoreScheduleRepository.updateSchedule(
        experimentDocId: experimentDocId,
        schedule: schedule,
      );

      // set status to "scheduled"
      await firestoreProgressRepository.changeStatus(
        experimentDocId: experimentDocId,
        newStatus: ExperimentProgressStatus.scheduled,
      );
    } catch (e) {
      // TODO: UPDATE ERROR HANDLING (AFTER LESSON)
      print('logging error...');
      rethrow;
    }
  }

  /// changes the from locked to unlocked status for the current schedule
  Future<void> lockOrUnlockSchedule({
    required String experimentDocId,
    required ExperimentProgressStatus status,
  }) async {
    // if currently locked, change status to "scheduled"
    if (status == ExperimentProgressStatus.lockedSchedule) {
      await firestoreProgressRepository.changeStatus(
        experimentDocId: experimentDocId,
        newStatus: ExperimentProgressStatus.scheduled,
      );

      // reset current table number of all users (set to null)
      await firestoreUserRepository.resetTableNumber(experimentDocId);
    }
    // if currently scheduled, change status to "lockedSchedule"
    else if (status == ExperimentProgressStatus.scheduled) {
      await firestoreProgressRepository.changeStatus(
        experimentDocId: experimentDocId,
        newStatus: ExperimentProgressStatus.lockedSchedule,
      );

      // read first round of schedule
      final firstRound =
          await firestoreScheduleRepository.getSchedule(experimentDocId, 1);

      // get maximum round number from schedule
      final maxRoundNumber =
          await firestoreScheduleRepository.getMaxRoundNumber(experimentDocId);

      // update maximum round number in progress
      await firestoreProgressRepository.updateMaxRoundNumber(
        experimentDocId: experimentDocId,
        maxRoundNumber: maxRoundNumber,
      );

      // create tables in realtime database
      await realtimeDatabaseRepository.addTablesToDatabase(
        experimentDocId: experimentDocId,
        round: firstRound,
      );

      // change current table number of all users
      firestoreUserRepository.changeCurrentTableNumbers(
        experimentDocId,
        firstRound,
      );
    }
  }

  /// moves to next round of the schedule
  Future<void> moveToNextRound({
    required String experimentDocId,
  }) async {
    // increase round number if not already at max
    final nextRoundNumber = await firestoreProgressRepository.goToNextRound(
        experimentDocId: experimentDocId);

    // exit if the round number could not increase
    if (nextRoundNumber == null) {
      return;
    }

    // reset current table number of all users (set to null)
    await firestoreUserRepository.resetTableNumber(experimentDocId);

    // get next round data
    final nextRound = await firestoreScheduleRepository.getSchedule(
        experimentDocId, nextRoundNumber);

    // create tables in realtime database
    await realtimeDatabaseRepository.addTablesToDatabase(
      experimentDocId: experimentDocId,
      round: nextRound,
    );

    // change current table number of all users
    await firestoreUserRepository.changeCurrentTableNumbers(
      experimentDocId,
      nextRound,
    );
  }
}

final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService(
    firestoreScheduleRepository: ref.watch(firestoreScheduleRepositoryProvider),
    firestoreProgressRepository: ref.watch(firestoreProgressRepositoryProvider),
    firestoreUserRepository: ref.watch(firestoreUserRepositoryProvider),
    realtimeDatabaseRepository: ref.watch(realtimeDatabaseRepositoryProvider),
  );
});
