import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/progress/data/firestore_progress_repository.dart';
import 'package:pencil_game_admin/features/tables/domain/realtime_table.dart';

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

  /// copy results of current round and move to next round
  Future<void> copyResults({
    required experimentDocId,
    required List<RealtimeTable> tables,
  }) async {
    try {
      // get current round number from progress doc
      final currentRoundNumber =
          await firestoreProgressRepository.getCurrentRoundNumber(experimentDocId: experimentDocId);

      // go through all tables
      for (RealtimeTable table in tables) {
        // only copy if status of table is finished
        if (table.status != TableStatus.finished) {
          throw Exception('Error - could not copy data. Table ${table.tableNumber} was not '
              'finished');
        }

        //  add results to firestore
        await firestoreResultsRepository.addResultToExperiment(
          experimentDocId: experimentDocId,
          roundNumber: currentRoundNumber,
          table: table,
        );
      }
      print('all results copied');
    } catch (e) {
      // passing the error messages upstream
      rethrow;
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
