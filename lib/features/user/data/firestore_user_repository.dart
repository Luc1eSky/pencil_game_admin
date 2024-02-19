import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/constants.dart';
import 'package:pencil_game_admin/firestore/firestore_instance_provider.dart';

import '../../../utils/utils.dart';

class FirestoreUserRepository {
  FirestoreUserRepository(this._firestore);
  final FirebaseFirestore _firestore;

  /// returns stream to a document with a specific share code
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserShareCodeStream(String code) {
    return _firestore
        .collection(userShareCodeCollectionName)
        .where('code', isEqualTo: code)
        .limit(1)
        .snapshots();
  }

  /// get the next color code in experiment for a new user
  Future<String?> _getColorCode(String experimentDocId) async {
    // reference to color code sub-collection in specific experiment
    final colorCodeDocRef = _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection('colorCodes')
        .doc('colorCodes');

    try {
      return await _firestore.runTransaction((transaction) async {
        // get doc snap
        final docSnap = await transaction.get(colorCodeDocRef);

        // throw error if document or data was not found
        if (!docSnap.exists || docSnap.data() == null) {
          throw 'Document does not exist.';
        }

        // get all codes as list of strings
        final codes =
            (docSnap.get('codes') as List<dynamic>).map((code) => code.toString()).toList();

        // get first color code and remove from list
        final chosenColorCode = codes.first;
        print(chosenColorCode);
        codes.removeAt(0);

        // update document and return color code
        transaction.update(colorCodeDocRef, {'codes': codes});
        return chosenColorCode;
      });
    } catch (e) {
      // debug print error and return null
      debugPrint('Transaction with color code document failed. Error: $e');
      return null;
    }
  }

  /// Creates a new admin document after signup
  Future<String?> createUserShareCodeEntry({
    required String experimentDocId,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // reference to user sub-collection in specific experiment
      final shareCollectionRef = _firestore.collection(userShareCodeCollectionName);

      String randomCode;
      while (true) {
        // create random code 6 letter code (for users it is letters only)
        randomCode = generateRandomCode(isUserCode: true);

        // exit if code does not already exist (for a user in this experiment)
        final querySnap =
            await shareCollectionRef.where('uid', isEqualTo: randomCode).limit(1).get();
        if (querySnap.docs.isEmpty) {
          break;
        }
      }

      // get the next color code for user
      final colorCode = await _getColorCode(experimentDocId);

      // if there was an error with the color code throw an error
      if (colorCode == null) {
        throw 'Could not find color code.';
      }

      // if code is unique add user to user collection in experiment
      await shareCollectionRef.add({
        'code': randomCode,
        'firstName': firstName,
        'lastName': lastName,
        'colorCode': colorCode,
        'experimentDocId': experimentDocId,
        'createdOn': Timestamp.now(),
      });

      // return user uid
      return randomCode;
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }
}

final firestoreUserRepositoryProvider = Provider<FirestoreUserRepository>((ref) {
  return FirestoreUserRepository(ref.watch(firestoreInstanceProvider));
});
