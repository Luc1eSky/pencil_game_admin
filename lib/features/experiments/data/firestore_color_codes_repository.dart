import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/constants.dart';

import '../../../firestore/firestore_instance_provider.dart';

class FirestoreColorCodesRepository {
  FirestoreColorCodesRepository(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> copyColorCodesToExperiment({required String experimentDocId}) async {
    // Reference to the colorCodes document
    final colorCodesDocRef = _firestore.collection('colorCodes').doc('colorCodes');

    // get color codes doc snap
    final colorCodesDocSnap = await colorCodesDocRef.get();

    // TODO: HANDLE ERROR
    // exit if there no matching color code document was found
    if (!colorCodesDocSnap.exists && colorCodesDocSnap.data() != null) {
      //debugPrint('Error - Could not find color codes document.');
      return;
    }

    // add a new document for the color codes in sub-collection
    await _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection('colorCodes')
        .doc('colorCodes')
        .set(colorCodesDocSnap.data()!);
  }
}

final firestoreColorCodesRepositoryProvider = Provider<FirestoreColorCodesRepository>((ref) {
  return FirestoreColorCodesRepository(ref.watch(firestoreInstanceProvider));
});
