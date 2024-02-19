import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants.dart';
import '../../../firestore/firestore_instance_provider.dart';
import '../domain/table.dart';

class FirestoreTableRepository {
  FirestoreTableRepository({required this.firestore});
  final FirebaseFirestore firestore;

  /// Add a new table to the tables collection of a specific experiment
  Future<void> addTable({
    required String experimentDocId,
  }) async {
    // reference to the table collection of current experiment
    final tableCollectionRef = firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(tableCollectionName);

    try {
      await firestore.runTransaction((transaction) async {
        // get last table (highest number)
        final querySnap =
            await tableCollectionRef.orderBy(FieldPath.documentId, descending: true).limit(1).get();

        // calculate next number and convert to string
        int tableNumber = querySnap.docs.isEmpty ? 1 : int.parse(querySnap.docs.first.id) + 1;
        final tableNumberString = tableNumber.toString().padLeft(3, '0');

        // create new table doc with default values
        transaction.set(
          tableCollectionRef.doc(tableNumberString),
          const Table().toJson(),
        );
      });
    } catch (e) {
      print('Transaction failed: $e');
    }
  }

  /// Remove a new table to the tables collection of a specific experiment
  Future<void> removeTable({
    required String experimentDocId,
  }) async {
    // reference to the table collection of current experiment
    final tableCollectionRef = firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(tableCollectionName);

    await firestore.runTransaction((transaction) async {
      final querySnap =
          await tableCollectionRef.orderBy(FieldPath.documentId, descending: true).limit(1).get();
      if (querySnap.docs.isNotEmpty) {
        final docSnap = await transaction.get(querySnap.docs.first.reference);
        // TODO: CHECK IF ANYONE HAS PLAYED/SIGNED IN ALREADY AT THE TABLE
        transaction.delete(docSnap.reference);
      }
    });
  }

  /// get query that returns all tables for an experiment
  Query<Map<String, dynamic>> getTablesOfExperimentQuery({required String experimentDocId}) {
    return firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(tableCollectionName)
        .orderBy(FieldPath.documentId, descending: false);
  }
}

final firestoreTableRepositoryProvider = Provider<FirestoreTableRepository>((ref) {
  return FirestoreTableRepository(firestore: ref.watch(firestoreInstanceProvider));
});
