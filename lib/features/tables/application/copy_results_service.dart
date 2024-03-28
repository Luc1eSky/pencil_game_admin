import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/progress/data/firestore_progress_repository.dart';
import 'package:pencil_game_admin/features/progress/domain/experiment_progress.dart';

import '../data/firestore_results_repository.dart';
import '../data/realtime_database_repository.dart';

class CopyResultsService {
  CopyResultsService({
    required this.firestoreResultsRepository,
    required this.realtimeDatabaseRepository,
    required this.firestoreProgressRepository,
  });

  final FirestoreResultsRepository firestoreResultsRepository;
  final RealtimeDatabaseRepository realtimeDatabaseRepository;
  final FirestoreProgressRepository firestoreProgressRepository;

  /// transferring a result from RTDB to firestore
  Future<void> transferResults({
    required experimentDocId,
    required int tableNumber,
  }) async {
    try {
      // get current round number from progress doc
      final currentRoundNumber =
          await firestoreProgressRepository.getCurrentRoundNumber(experimentDocId: experimentDocId);

      // get table data from RTDB
      final table = await realtimeDatabaseRepository.getTable(
        experimentDocId: experimentDocId,
        tableNumber: tableNumber,
      );

      //  add results to firestore
      await firestoreResultsRepository.addResultToExperiment(
        experimentDocId: experimentDocId,
        roundNumber: currentRoundNumber,
        tableNumber: tableNumber,
        table: table,
      );

      // set table to finished
      await realtimeDatabaseRepository.setTableToFinished(
        experimentDocId: experimentDocId,
        tableNumber: tableNumber,
      );
    } catch (e) {
      // passing the error messages upstream
      rethrow;
    }
  }

  /// check if all tables in current round were finished and set progress status
  Future<void> checkIfRoundWasFinished({required experimentDocId}) async {
    print('HERE222!');
    try {
      // check if all tables in RTDB are finished
      final allTablesAreFinished = await realtimeDatabaseRepository.checkIfAllTablesAreFinished(
        experimentDocId: experimentDocId,
      );
      print('allTablesAreFinished: $allTablesAreFinished');
      // change progress status if they are all done to "roundFinished"
      if (allTablesAreFinished) {
        firestoreProgressRepository.changeStatus(
          experimentDocId: experimentDocId,
          newStatus: ExperimentStatus.roundFinished,
        );
      }
    } catch (e) {
      print(e);
    }
  }
}

final copyResultsServiceProvider = Provider<CopyResultsService>((ref) {
  return CopyResultsService(
    firestoreResultsRepository: ref.watch(firestoreResultsRepositoryProvider),
    realtimeDatabaseRepository: ref.watch(realtimeDatabaseRepositoryProvider),
    firestoreProgressRepository: ref.watch(firestoreProgressRepositoryProvider),
  );
});
