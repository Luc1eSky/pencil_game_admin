import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/firestore/firestore_instance_provider.dart';

import '../../../constants.dart';
import '../../../utils/utils.dart';
import '../domain/experiment.dart';
import '../domain/experiment_status.dart';

class FirestoreExperimentRepository {
  FirestoreExperimentRepository(this._firestore);
  final FirebaseFirestore _firestore;

  /// get stream to a specific experiment document
  Stream<DocumentSnapshot<Map<String, dynamic>>> getExperimentStream(
      String docId) {
    return _firestore
        .collection(experimentCollectionName)
        .doc(docId)
        .snapshots();
  }

  /// Creates a new experiment based on the user's input and stores it in firestore
  Future<String> addExperimentDoc({
    required String experimentName,
    required String experimentLocation,
    required String adminUid,
    required Treatment treatment,
    required bool showSurvey,
  }) async {
    // get new experiment doc id (auto generated)
    final newExperimentDocRef =
        _firestore.collection(experimentCollectionName).doc();
    final newDocumentId = newExperimentDocRef.id;

    // create new experiment object and convert it to a JSON map
    final newExperimentMap = Experiment(
      name: experimentName,
      location: experimentLocation,
      createdByUid: adminUid,
      createdOn: DateTime.now(),
      status: ExperimentStatus.scheduled,
      treatment: treatment,
      showSurvey: false,
    ).toJson();

    // add a new document for the experiment
    await newExperimentDocRef.set(newExperimentMap);

    // return the doc id of the newly created experiment
    return newDocumentId;
  }

  /// get existing share code for experiment or create a new one
  Future<String> getOrCreateCode(String docId) async {
    // get existing code (or null if not found)
    final existingCode = await _getExistingCode(docId: docId);

    // return code if it exists
    if (existingCode != null) {
      return existingCode;
    }

    // otherwise generate a new random code
    String randomCode;
    while (true) {
      // generate random 6 letter code
      randomCode = generateRandomCode();

      // check if document with code already exists
      final querySnap = await _firestore
          .collection(adminShareCodeCollectionName)
          .where('code', isEqualTo: randomCode)
          .limit(1)
          .get();

      // exit if no document with current code was found
      if (querySnap.docs.isEmpty) {
        break;
      }
    }
    // add share code to firestore
    await _addShareCode(code: randomCode, docId: docId);

    // return code
    return randomCode;
  }

  /// get share code of a specific experiment if it exists
  Future<String?> _getExistingCode({required String docId}) async {
    final querySnap = await _firestore
        .collection(adminShareCodeCollectionName)
        .where('experimentDocId', isEqualTo: docId)
        .limit(1)
        .get();

    return querySnap.docs.isEmpty ? null : querySnap.docs.first.get('code');
  }

  /// add share code document to shareCodes collection
  Future<void> _addShareCode(
      {required String code, required String docId}) async {
    await _firestore.collection(adminShareCodeCollectionName).add({
      'code': code,
      'experimentDocId': docId,
      'createdOn': Timestamp.now(),
    });
  }

  /// try to join an experiment as an admin via a share code
  Future<JoinStatus> tryToJoinExperiment(
      {required String code, required String? uid}) async {
    // get query of share code doc with specific share code
    final codeQuerySnap = await _firestore
        .collection(adminShareCodeCollectionName)
        .where('code', isEqualTo: code)
        .limit(1)
        .get();

    // get admin doc snap for specific admin UID
    final adminDocSnap =
        await _firestore.collection(adminsCollectionName).doc(uid).get();

    // check if document snapshots exist and and uid is not null
    if (codeQuerySnap.docs.isEmpty ||
        !codeQuerySnap.docs.first.exists ||
        !adminDocSnap.exists ||
        uid == null) {
      return JoinStatus.notFound;
    }

    // check if data that is returned is not null and not empty
    final adminData = adminDocSnap.data();
    final shareCodeData = codeQuerySnap.docs.first.data();

    if (adminData == null || adminData.isEmpty || shareCodeData.isEmpty) {
      return JoinStatus.notFound;
    }

    // get experimentDocId from share code document
    String? experimentDocId = shareCodeData['experimentDocId'];

    // exit if there was no experimentDocId
    if (experimentDocId == null) {
      return JoinStatus.notFound;
    }

    // get list of experiment doc IDs of current user as list of strings
    final listOfExperimentDocIds =
        (adminData[experimentsListName] as List<dynamic>)
            .map((e) => e.toString())
            .toList();

    // exit if user was already admin
    if (listOfExperimentDocIds.contains(experimentDocId)) {
      return JoinStatus.alreadyAdmin;
    }

    // try to join experiment
    try {
      // add experiment doc id to admin doc
      FieldPath experimentsListPath = FieldPath(const [experimentsListName]);
      await adminDocSnap.reference.update({
        experimentsListPath: FieldValue.arrayUnion([experimentDocId])
      });

      // add admin uid to experiment doc
      FieldPath adminsListPath = FieldPath(const [sharedAdminListName]);
      await _firestore
          .collection(experimentCollectionName)
          .doc(experimentDocId)
          .update({
        adminsListPath: FieldValue.arrayUnion([uid])
      });

      return JoinStatus.success;
    } catch (e) {
      return JoinStatus.error;
    }
  }
}

final firestoreExperimentRepositoryProvider =
    Provider<FirestoreExperimentRepository>((ref) {
  return FirestoreExperimentRepository(ref.watch(firestoreInstanceProvider));
});

enum JoinStatus {
  notFound,
  alreadyAdmin,
  error,
  success,
}
