import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/schedule/domain/detailed_round.dart';

import '../../../constants.dart';
import '../../../firestore/firestore_instance_provider.dart';
import '../domain/table.dart';

class FirestoreTableRepository {
  FirestoreTableRepository(this._firestore);
  final FirebaseFirestore _firestore;

  /// helper function to get tables collection ref of specific experiment
  CollectionReference<Map<String, dynamic>> _getTablesCollectionRef(String experimentDocId) {
    return _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(tableCollectionName);
  }

  /// create tables for a new round with the assigned players
  Future<void> createTablesFromRound({
    required String experimentDocId,
    required DetailedRound round,
  }) async {
    // reference to the table collection of current experiment
    final tableCollectionRef = _getTablesCollectionRef(experimentDocId);

    // save max amount of tables in case there are
    // less tables then before, so the leftover tables can be deleted
    int tableNumberToDelete = round.games.length + 1;
    while (true) {
      // try to get table document
      final tableDocSnap = await tableCollectionRef.doc('table$tableNumberToDelete').get();
      // exit if it doesn't exist
      if (!tableDocSnap.exists) {
        break;
      }
      // delete it if it does exist and increase table number
      await tableDocSnap.reference.delete();
      tableNumberToDelete++;
    }

    // create a table for each game in this round
    for (var game in round.games) {
      // get table number
      final tableNumber = game.tableNumber;

      // create new table object with assigned users
      final newTable = Table(
        tableNumber: tableNumber,
        assignedUsers: game.userPair,
        signedInUsers: {},
      );

      // create table doc id (12 -> "table12")
      final tableDocId = 'table$tableNumber';

      // set table document to new table
      tableCollectionRef.doc(tableDocId).set(newTable.toJson());
    }
  }

  /// remove all signed in players from table
  Future<void> removePlayersFromTable(DocumentReference tableDocRef) async {
    await tableDocRef.update({
      'signedInUsers': [],
    });
  }

  // /// Add a new table to the tables collection of a specific experiment
  // Future<void> addTable({
  //   required String experimentDocId,
  // }) async {
  //   // reference to the table collection of current experiment
  //   final tableCollectionRef = firestore
  //       .collection(experimentCollectionName)
  //       .doc(experimentDocId)
  //       .collection(tableCollectionName);
  //
  //   try {
  //     await firestore.runTransaction((transaction) async {
  //       // get last table (highest number)
  //       final querySnap =
  //           await tableCollectionRef.orderBy(FieldPath.documentId, descending: true).limit(1).get();
  //
  //       // calculate next number and convert to string
  //       int tableNumber = querySnap.docs.isEmpty ? 1 : int.parse(querySnap.docs.first.id) + 1;
  //       final tableNumberString = tableNumber.toString().padLeft(3, '0');
  //
  //       // create new table doc with default values
  //       transaction.set(
  //         tableCollectionRef.doc(tableNumberString),
  //         const Table().toJson(),
  //       );
  //     });
  //   } catch (e) {
  //     print('Transaction failed: $e');
  //   }
  // }
  //
  // /// Remove a new table to the tables collection of a specific experiment
  // Future<void> removeTable({
  //   required String experimentDocId,
  // }) async {
  //   // reference to the table collection of current experiment
  //   final tableCollectionRef = firestore
  //       .collection(experimentCollectionName)
  //       .doc(experimentDocId)
  //       .collection(tableCollectionName);
  //
  //   await firestore.runTransaction((transaction) async {
  //     final querySnap =
  //         await tableCollectionRef.orderBy(FieldPath.documentId, descending: true).limit(1).get();
  //     if (querySnap.docs.isNotEmpty) {
  //       final docSnap = await transaction.get(querySnap.docs.first.reference);
  //       // TODO: CHECK IF ANYONE HAS PLAYED/SIGNED IN ALREADY AT THE TABLE
  //       transaction.delete(docSnap.reference);
  //     }
  //   });
  // }

  /// get query that returns all tables for an experiment
  Query<Table> getTablesOfExperimentQuery({required String experimentDocId}) {
    return _getTablesCollectionRef(experimentDocId)
        .orderBy(FieldPath.documentId, descending: false)
        .withConverter(
          fromFirestore: (snapshot, _) => Table.fromJson(snapshot.data()!),
          toFirestore: (table, _) => table.toJson(),
        );
  }
}

final firestoreTableRepositoryProvider = Provider<FirestoreTableRepository>((ref) {
  return FirestoreTableRepository(ref.watch(firestoreInstanceProvider));
});
