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
      maximumRoundNumber: 0, // will be set when schedule is created
      status: ExperimentProgressStatus.noSchedule,
    );

    // add document with starting data
    await _getProgressDocRef(experimentDocId).set(startingProgress.toJson());
  }

  /// change progress status
  Future<void> changeStatus({
    required String experimentDocId,
    required ExperimentProgressStatus newStatus,
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

  /// update maximum round number
  Future<void> updateMaxRoundNumber({
    required String experimentDocId,
    required int maxRoundNumber,
  }) async {
    try {
      // get doc ref of progress doc of specific experiment
      final docSnap = await _getProgressDocRef(experimentDocId).get();
      final currentProgress = ExperimentProgress.fromJson(docSnap.data()!);

      final updatedProgress = currentProgress.copyWith(maximumRoundNumber: maxRoundNumber);
      docSnap.reference.update(updatedProgress.toJson());
    } catch (e) {
      throw Exception("Error. Could not update maximum round number.\n$e");
    }
  }

  /// start a round if current status allows to do so
  Future<void> startRound({
    required String experimentDocId,
    required ExperimentProgressStatus currentStatus,
  }) async {
    // do nothing if current status is not "lockedSchedule" or "roundFinished"
    if (currentStatus != ExperimentProgressStatus.lockedSchedule &&
        currentStatus != ExperimentProgressStatus.roundFinished) {
      debugPrint('Cannot start round. Wrong state.');
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
        if (dbCurrentStatus != ExperimentProgressStatus.lockedSchedule &&
            dbCurrentStatus != ExperimentProgressStatus.roundFinished) {
          debugPrint('Cannot start round. Wrong state.');
          return;
        }

        // update progress status to "roundPlaying"
        final updatedProgress =
            dbCurrentProgress.copyWith(status: ExperimentProgressStatus.roundPlaying);
        transaction.update(docRef, updatedProgress.toJson());
      } catch (e) {
        debugPrint(e.toString());
        return;
      }
    });
  }

  // move to next round number if possible
  Future<int?> goToNextRound({
    required String experimentDocId,
  }) async {
    // reference to color code sub-collection in specific experiment
    final progressDocRef = _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(settingsCollectionName)
        .doc('progress');

    final returnValue = await _firestore.runTransaction((transaction) async {
      // get doc snap of progress doc
      final progressDocSnap = await transaction.get(progressDocRef);

      // throw error if document or data was not found
      if (!progressDocSnap.exists || progressDocSnap.data() == null) {
        throw 'Document does not exist.';
      }

      // convert to progress class
      final progress = ExperimentProgress.fromJson(progressDocSnap.data()!);

      if (!progress.canIncreaseRoundNumber) {
        return null;
      }

      final newRoundNumber = progress.currentRoundNumber + 1;
      final newProgress = progress.copyWith(
        currentRoundNumber: newRoundNumber,
        status: ExperimentProgressStatus.roundPlaying,
      );

      transaction.update(progressDocRef, newProgress.toJson());

      return newRoundNumber;
    });

    return returnValue;
  }
}

final firestoreProgressRepositoryProvider = Provider<FirestoreProgressRepository>((ref) {
  return FirestoreProgressRepository(ref.watch(firestoreInstanceProvider));
});
