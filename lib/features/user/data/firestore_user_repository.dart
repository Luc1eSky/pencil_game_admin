import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/constants.dart';
import 'package:pencil_game_admin/features/schedule/domain/round.dart';
import 'package:pencil_game_admin/firestore/firestore_instance_provider.dart';

import '../../../utils/utils.dart';
import '../domain/app_user.dart';

class FirestoreUserRepository {
  FirestoreUserRepository(this._firestore);
  final FirebaseFirestore _firestore;

  /// helper function to get a reference to
  /// the users collection of a certain experiment
  CollectionReference<Map<String, dynamic>> _getUserCollectionRef(String experimentDocId) {
    return _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(userCollectionName);
  }

  /// returns stream to a document with a specific share code
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserShareCodeStream(String code) {
    return _firestore
        .collection(userShareCodeCollectionName)
        .where('code', isEqualTo: code)
        .limit(1)
        .snapshots();
  }

  /// returns query of all users of a specific experiment
  Query<AppUser> getUsersQuery(String experimentDocId) {
    return _getUserCollectionRef(experimentDocId).orderBy('createdOn').withConverter(
          fromFirestore: (snapshot, _) => AppUser.fromFirestore(snapshot.data()!, snapshot.id),
          toFirestore: (user, _) => user.toFirestore(),
        );
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
        'currentTableNumber': null,
      });

      // return user uid
      return randomCode;
    } catch (e) {
      debugPrint('Error: $e');
      return null;
    }
  }

  /// changes the table number variable for all users based on the current round,
  /// this shows the user where to go
  void changeCurrentTableNumbers(String experimentDocId, Round round) {
    for (var game in round.games) {
      // get list of uids of playing users and table number
      final listOfUserUids = game.assignedUsers.map((u) => u.uid).toList();
      final tableNumber = game.tableNumber;

      // update User documents with table numbers
      for (var uid in listOfUserUids) {
        _getUserCollectionRef(experimentDocId).doc(uid).update(
          {'currentTableNumber': tableNumber},
        );
      }

      // get list of uids of pausing players
      final listOfPausingUids = round.pausingUsers.map((u) => u.uid).toList();

      // update User documents with 0 for pausing players
      for (var uid in listOfPausingUids) {
        _getUserCollectionRef(experimentDocId).doc(uid).update(
          {'currentTableNumber': 0},
        );
      }
    }
  }

  /// resets the table number for all users to null
  void resetTableNumber(String experimentDocId) async {
    // get user query of all users in experiment
    final userQuerySnap = await getUsersQuery(experimentDocId).get();

    // go through all doc snaps of query
    for (var docSnap in userQuerySnap.docs) {
      // create user from document data
      final user = docSnap.data();
      // create updated user with table number null
      final updatedUser = user.copyWith(currentTableNumber: null);
      // update data in firestore
      _getUserCollectionRef(experimentDocId).doc(updatedUser.uid).update(updatedUser.toFirestore());
    }
  }

  // delete user entry in experiment and in root users collection
  Future<void> deleteUser({
    required String experimentDocId,
    required AppUser user,
  }) async {
    print('DELETING USER ${user.firstName} FROM EXPERIMENT: $experimentDocId');
    // delete user from experiment
    await _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(userCollectionName)
        .doc(user.uid)
        .delete();

    // delete user from user collection
    await _firestore.collection(userCollectionName).doc(user.uid).delete();
  }
}

final firestoreUserRepositoryProvider = Provider<FirestoreUserRepository>((ref) {
  return FirestoreUserRepository(ref.watch(firestoreInstanceProvider));
});
