import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/firestore/firestore_instance_provider.dart';

import '../../../constants.dart';

class FirestoreAdminRepository {
  FirestoreAdminRepository(this._firestore);
  final FirebaseFirestore _firestore;

  /// Creates a new admin document after signup
  Future<void> createAdmin({
    required String adminUid,
    required String firstName,
    required String lastName,
  }) async {
    CollectionReference adminCollectionRef = _firestore.collection(adminsCollectionName);

    debugPrint('Searching for admin document.');
    final adminDoc = await adminCollectionRef.doc(adminUid).get();

    if (adminDoc.exists) {
      debugPrint('Document for admin $firstName $lastName already exists.');
      return;
    }

    debugPrint('New admin $firstName $lastName created.');
    await adminCollectionRef.doc(adminUid).set(
      {
        'firstName': firstName,
        'lastName': lastName,
        'experiments': [],
        'adminUid': adminUid,
        'createdOn': Timestamp.now(),
      },
    );
  }

  /// get query to user's admin document to keep track of
  /// the experiments that this user has access to
  DocumentReference<Map<String, dynamic>> getAdminDocRef(String uid) {
    return _firestore.collection(adminsCollectionName).doc(uid);
  }

  /// add a reference to an existing experiment to an admin
  /// this controls which experiments the admin has access to
  Future<void> addExperimentToAdmin({
    required experimentDocId,
    required adminUid,
  }) async {
    // find admin doc of current user via admin UID
    final adminDocSnap = await _firestore.collection(adminsCollectionName).doc(adminUid).get();

    //TODO: HANDLE ERROR?!
    // exit if there no matching admin document was found
    if (!adminDocSnap.exists && adminDocSnap.data() != null) {
      debugPrint('Error - Could not find admin document for uid: $adminUid.');
      return;
    }

    // add experiment doc reference to array in admin doc
    // this is needed to identify who has access to which experiment
    await adminDocSnap.reference.update({
      'experiments': FieldValue.arrayUnion([experimentDocId]),
    });
  }
}

final firestoreAdminRepositoryProvider = Provider<FirestoreAdminRepository>((ref) {
  return FirestoreAdminRepository(ref.watch(firestoreInstanceProvider));
});
