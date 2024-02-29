import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/firestore/firestore_instance_provider.dart';

import '../../../constants.dart';
import '../domain/experiment_progress.dart';

class FirestoreProgressRepository {
  FirestoreProgressRepository(this._firestore);
  final FirebaseFirestore _firestore;

  /// local helper function to get document reference
  DocumentReference<Map<String, dynamic>> _getProgressDocRef(String experimentDocId) {
    return _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(settingsCollectionName)
        .doc(progressDocName);
  }

  /// stream progress document for a specific experiment
  Stream<DocumentSnapshot<Map<String, dynamic>>> getProgressDocStream(String experimentDocId) {
    return _getProgressDocRef(experimentDocId).snapshots();
  }

  /// Creates a new progress document for a specific experiment
  Future<void> addProgressDoc(String experimentDocId) async {
    // create progress object with starting data
    const startingProgress = ExperimentProgress(
      currentRoundNumber: 1,
      status: ExperimentStatus.noSchedule,
    );

    // add document with starting data
    await _getProgressDocRef(experimentDocId).set(startingProgress.toJson());
  }

  /// change progress status
  Future<void> changeStatus({
    required String experimentDocId,
    required ExperimentStatus newStatus,
  }) async {
    // get doc ref of progress doc of specific experiment
    final docRef = _getProgressDocRef(experimentDocId);

    // update doc with new status
    docRef.update({'status': newStatus.name});

    print(newStatus.name);
  }
}

final firestoreProgressRepositoryProvider = Provider<FirestoreProgressRepository>((ref) {
  return FirestoreProgressRepository(ref.watch(firestoreInstanceProvider));
});
