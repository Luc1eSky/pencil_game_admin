import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/tables/domain/firestore_result.dart';
import 'package:pencil_game_admin/features/tables/domain/realtime_table.dart';
import 'package:pencil_game_admin/firestore/firestore_instance_provider.dart';

import '../../../constants.dart';

class FirestoreResultsRepository {
  FirestoreResultsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  // /// get stream to results of a specific experiment document
  // Stream<DocumentSnapshot<Map<String, dynamic>>> getExperimentStream(String docId) {
  //   return _firestore.collection(experimentCollectionName).doc(docId).snapshots();
  // }

  /// add a new result to a specific experiment
  Future<void> addResultToExperiment({
    required experimentDocId,
    required int roundNumber,
    required int tableNumber,
    required RealtimeTable table,
    // required List<NumberCopyResult> numberResultsPerUser,
    // required List<Click> clicks,
  }) async {
    // get reference to new result doc with auto id
    final resultsCollectionRef =
        _firestore.collection(experimentCollectionName).doc(experimentDocId).collection('results');

    final newResult = FirestoreResult(
      roundNumber: roundNumber,
      tableNumber: tableNumber,
      startedOn: table.startedOn!,
      endedOn: table.endedOn!,
      clicks: table.archivedClicks ?? [],
      numberCopyResults: table.numberCopyResults ?? [],
    );

    await resultsCollectionRef.add(newResult.toJson());
    return;
  }
}

final firestoreResultsRepositoryProvider = Provider<FirestoreResultsRepository>((ref) {
  return FirestoreResultsRepository(ref.watch(firestoreInstanceProvider));
});
