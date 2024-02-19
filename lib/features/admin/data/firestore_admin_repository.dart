import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/firestore/firestore_instance_provider.dart';

import '../../../constants.dart';

class FirestoreAdminRepository {
  FirestoreAdminRepository({required this.firestore});
  final FirebaseFirestore firestore;

  /// Creates a new admin document after signup
  Future<void> createAdmin({
    required String adminUid,
    required String firstName,
    required String lastName,
  }) async {
    CollectionReference adminCollectionRef = firestore.collection(adminsCollectionName);

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

    // // final querySnap =
    // //     await adminCollectionRef.where('adminUid', isEqualTo: adminUid).limit(1).get();
    //
    // //if (querySnap.docs.isEmpty) {
    // debugPrint('Creating new admin document.');
    // await adminCollectionRef.add(
    //   {
    //     'firstName': firstName,
    //     'lastName': lastName,
    //     'experiments': [],
    //     'adminUid': adminUid,
    //     'createdOn': Timestamp.now(),
    //   },
    // );
    // } else {
    //   debugPrint('Document for admin $firstName $lastName already exists.');
    // }
  }

  /// get query to user's admin document to keep track of
  /// the experiments that this user has access to
  //Query<Map<String, dynamic>>
  DocumentReference<Map<String, dynamic>> getAdminQuery(String uid) {
    return firestore.collection(adminsCollectionName).doc(uid);
    //return firestore.collection(adminsCollectionName).where('adminUid', isEqualTo: uid).limit(1);
  }
}

final firestoreAdminRepositoryProvider = Provider<FirestoreAdminRepository>((ref) {
  return FirestoreAdminRepository(firestore: ref.watch(firestoreInstanceProvider));
});
