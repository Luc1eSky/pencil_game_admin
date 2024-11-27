import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../../firestore/firestore_instance_provider.dart';

class FirestoreSurveyRepository {
  FirestoreSurveyRepository(this._firestore);

  final FirebaseFirestore _firestore;

  /// get survey stream
  Stream<DocumentSnapshot<Map<String, dynamic>>> getSurveyDocStream(
      String experimentDocId) {
    return _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection('survey') // Todo: create variable for the collection
        .doc('survey')
        .snapshots();
  }

// Future<void> addSurveyStatusToExperiment({
//   required String experimentDocId,
// }) async {
//   const survey = Survey(showSurvey: false, gender: Gender.male);
//
//   // add a new document for the survey info in sub-collection
//   await _firestore
//       .collection(experimentCollectionName)
//       .doc(experimentDocId)
//       .collection(settingsCollectionName)
//       .doc('survey')
//       .set(survey.toJson());
// }

//   Future<void> activateSurvey({
//     required String experimentDocId,
//   }) async {
//     // change surveyStatus to true
//     await _firestore
//         .collection(experimentCollectionName)
//         .doc(experimentDocId)
//         .update({'showSurvey': true});
//   }
}

final firestoreSurveyRepositoryProvider =
    Provider<FirestoreSurveyRepository>((ref) {
  return FirestoreSurveyRepository(ref.watch(firestoreInstanceProvider));
});
