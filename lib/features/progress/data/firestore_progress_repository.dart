import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
  Stream<DocumentSnapshot<ExperimentProgress>> getProgressDocStream(String experimentDocId) {
    return _getProgressDocRef(experimentDocId)
        .withConverter(
          fromFirestore: (snapshot, _) {
            return ExperimentProgress.fromJson(snapshot.data()!);
          },
          toFirestore: (progress, _) => progress.toJson(),
        )
        .snapshots();
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
  }

  /// get current round number
  Future<int> getCurrentRoundNumber({required String experimentDocId}) async {
    try {
      // get doc ref of progress doc of specific experiment
      final docSnap = await _getProgressDocRef(experimentDocId).get();
      final currentProgress = ExperimentProgress.fromJson(docSnap.data()!);
      // return current round number
      return currentProgress.currentRoundNumber;
    } catch (e) {
      throw Exception("Error. Could not get current round number.\n$e");
    }
  }

  /// start a round if current status allows to do so
  Future<void> startRound({
    required String experimentDocId,
    required ExperimentStatus currentStatus,
  }) async {
    // do nothing if current status is not "lockedSchedule" or "roundWaiting"
    if (currentStatus != ExperimentStatus.lockedSchedule &&
        currentStatus != ExperimentStatus.roundWaiting) {
      debugPrint('Round already started.');
      return;
    }

    // get doc ref of progress doc of specific experiment
    final docRef = _getProgressDocRef(experimentDocId);

    // if it looks like it can be started run a transaction
    // to avoid race condition (multiple starts)
    await _firestore.runTransaction((transaction) async {
      try {
        final docSnap = await transaction.get(docRef);
        final dbCurrentProgress = ExperimentProgress.fromJson(docSnap.data()!);
        final dbCurrentStatus = dbCurrentProgress.status;
        if (dbCurrentStatus != ExperimentStatus.lockedSchedule &&
            dbCurrentStatus != ExperimentStatus.roundWaiting) {
          debugPrint('Cannot start round. Wrong state.');
          return;
        }
        // update progress status to "roundPlaying"
        final updatedProgress = dbCurrentProgress.copyWith(status: ExperimentStatus.roundPlaying);
        transaction.update(docRef, updatedProgress.toJson());
      } catch (e) {
        debugPrint(e.toString());
        return;
      }
    });
  }
}

final firestoreProgressRepositoryProvider = Provider<FirestoreProgressRepository>((ref) {
  return FirestoreProgressRepository(ref.watch(firestoreInstanceProvider));
});
