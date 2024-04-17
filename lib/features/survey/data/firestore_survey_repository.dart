import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../../firestore/firestore_instance_provider.dart';
import '../domain/survey.dart';

class FirestoreSurveyRepository {
  FirestoreSurveyRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// get survey stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> getSurveyDocStream(String experimentDocId) {
    return _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(settingsCollectionName)
        .doc('survey')
        .snapshots();
  }

  Future<void> addSurveyToExperiment({
    required String experimentDocId,
    required String surveyLink,
  }) async {
    final survey = Survey(surveyLink: surveyLink, showSurvey: false);

    // add a new document for the survey info in sub-collection
    await _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(settingsCollectionName)
        .doc('survey')
        .set(survey.toJson());
  }

  Future<void> activateSurvey({
    required String experimentDocId,
  }) async {
    // activate survey
    await _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(settingsCollectionName)
        .doc('survey')
        .update({'showSurvey': true});
  }
}

final firestoreSurveyRepositoryProvider = Provider<FirestoreSurveyRepository>((ref) {
  return FirestoreSurveyRepository(ref.watch(firestoreInstanceProvider));
});
