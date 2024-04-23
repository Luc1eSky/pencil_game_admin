import 'dart:convert';
import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/experiments/domain/experiment.dart';
import 'package:pencil_game_admin/features/tables/domain/firestore_result.dart';
import 'package:pencil_game_admin/features/tables/domain/realtime_table.dart';
import 'package:pencil_game_admin/firestore/firestore_instance_provider.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

import '../../../constants.dart';
import '../domain/click.dart';
import '../domain/number_copy_result.dart';
import '../domain/number_input.dart';

class FirestoreResultsRepository {
  FirestoreResultsRepository(this._firestore);
  final FirebaseFirestore _firestore;

  // /// get stream to results of a specific experiment document
  // Stream<DocumentSnapshot<Map<String, dynamic>>> getExperimentStream(String docId) {
  //   return _firestore.collection(experimentCollectionName).doc(docId).snapshots();
  // }

  /// add a new result to a specific experiment
  Future<void> addResultToExperiment({
    required experimentDocId,
    required int roundNumber,
    required RealtimeTable table,
  }) async {
    // get reference to new result doc with auto id
    final resultsCollectionRef = _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(resultsCollectionName);

    final startedOn = table.startedOn;
    final endedOn = table.endedOn;
    if (startedOn == null || endedOn == null) {
      throw Exception('Error - startedOn or endedOn was null (expected DateTime).');
    }

    final newResult = FirestoreResult(
      users: table.usersAtTable,
      roundNumber: roundNumber,
      tableNumber: table.tableNumber,
      startedOn: startedOn,
      endedOn: endedOn,
      clicks: table.archivedClicks ?? [],
      numberCopyResults: table.numberCopyResults ?? [],
    );

    await resultsCollectionRef.add(newResult.toJson());
    return;
  }

  /// export all results to an excel document
  Future<void> exportToExcel({required String experimentDocId}) async {
    await Future.delayed(const Duration(seconds: 5));
    // Create a new Excel Document.
    final Workbook workbook = Workbook();
    // Accessing worksheet via index.
    final Worksheet sheet = workbook.worksheets[0];

    // Set the header values for columns in excel

    // experiment info
    sheet.getRangeByIndex(1, 1).setText('ExperimentName');
    sheet.getRangeByIndex(1, 2).setText('ExperimentLocation');
    sheet.getRangeByIndex(1, 3).setText('ExperimentCreatedOn');

    // game info
    sheet.getRangeByIndex(1, 4).setText('roundNumber');
    sheet.getRangeByIndex(1, 5).setText('tableNumber');
    sheet.getRangeByIndex(1, 6).setText('gameStartedOn');
    sheet.getRangeByIndex(1, 7).setText('gameEndedOn');

    // action info
    sheet.getRangeByIndex(1, 8).setText('playerUID');
    sheet.getRangeByIndex(1, 9).setText('playerColorCode');
    sheet.getRangeByIndex(1, 10).setText('actionType'); // click or number copy
    sheet.getRangeByIndex(1, 11).setText('actionTimeStamp');

    // only for numberCopy action
    sheet.getRangeByIndex(1, 12).setText('shownNumber');
    sheet.getRangeByIndex(1, 13).setText('enteredNumber');
    sheet.getRangeByIndex(1, 14).setText('numberWasCorrect');

    // connect to Firestore db
    FirebaseFirestore db = FirebaseFirestore.instance;

    // get experiment document reference
    DocumentReference experimentDocRef =
        db.collection(experimentCollectionName).doc(experimentDocId);

    // get experiment document snapshot
    final experimentDocSnap = await experimentDocRef.get();

    // convert data to experiment class
    final experiment = Experiment.fromJson(experimentDocSnap.data() as Map<String, dynamic>);

    // get results collection reference
    CollectionReference resultsCollectionRef = db
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(resultsCollectionName);

    // snapshot of collection reference
    QuerySnapshot resultsQuerySnapshot =
        await resultsCollectionRef.orderBy('roundNumber').orderBy('tableNumber').get();

    // start in second row (first is headers)
    int row = 2;

    // go through all documents in results snapshot
    for (QueryDocumentSnapshot testDocSnap in resultsQuerySnapshot.docs) {
      // convert data to result class
      final result = FirestoreResult.fromJson(testDocSnap.data() as Map<String, dynamic>);

      for (Click click in result.clicks) {
        // add experiment info
        sheet.getRangeByIndex(row, 1).setText(experiment.name);
        sheet.getRangeByIndex(row, 2).setText(experiment.location);
        sheet.getRangeByIndex(row, 3).setDateTime(experiment.createdOn);
        sheet.getRangeByIndex(row, 3).numberFormat = 'm/d/yy h:mm:ss AM/PM';

        // add game info
        sheet.getRangeByIndex(row, 4).setNumber(result.roundNumber.toDouble());
        sheet.getRangeByIndex(row, 5).setNumber(result.tableNumber.toDouble());
        sheet.getRangeByIndex(row, 6).setDateTime(result.startedOn);
        sheet.getRangeByIndex(row, 6).numberFormat = 'm/d/yy h:mm:ss AM/PM';
        sheet.getRangeByIndex(row, 7).setDateTime(result.endedOn);
        sheet.getRangeByIndex(row, 7).numberFormat = 'm/d/yy h:mm:ss AM/PM';

        // add action info
        sheet.getRangeByIndex(row, 8).setText(click.user.uid);
        sheet.getRangeByIndex(row, 9).setText(click.user.colorCode);
        sheet.getRangeByIndex(row, 10).setText(click.type.name);
        sheet.getRangeByIndex(row, 11).setDateTime(click.timestamp);
        sheet.getRangeByIndex(row, 11).numberFormat = 'm/d/yy h:mm:ss AM/PM';

        row++;
      }

      for (NumberCopyResult numberCopyResult in result.numberCopyResults) {
        for (NumberInput numberInput in numberCopyResult.numberInputs) {
          // add experiment info
          sheet.getRangeByIndex(row, 1).setText(experiment.name);
          sheet.getRangeByIndex(row, 2).setText(experiment.location);
          sheet.getRangeByIndex(row, 3).setDateTime(experiment.createdOn);
          sheet.getRangeByIndex(row, 3).numberFormat = 'm/d/yy h:mm:ss AM/PM';

          // add game info
          sheet.getRangeByIndex(row, 4).setNumber(result.roundNumber.toDouble());
          sheet.getRangeByIndex(row, 5).setNumber(result.tableNumber.toDouble());
          sheet.getRangeByIndex(row, 6).setDateTime(result.startedOn);
          sheet.getRangeByIndex(row, 6).numberFormat = 'm/d/yy h:mm:ss AM/PM';
          sheet.getRangeByIndex(row, 7).setDateTime(result.endedOn);
          sheet.getRangeByIndex(row, 7).numberFormat = 'm/d/yy h:mm:ss AM/PM';

          // add action info
          sheet.getRangeByIndex(row, 8).setText(numberCopyResult.user.uid);
          sheet.getRangeByIndex(row, 9).setText(numberCopyResult.user.colorCode);
          sheet.getRangeByIndex(row, 10).setText('copyNumber');
          sheet.getRangeByIndex(row, 11).setDateTime(numberInput.timestamp);
          sheet.getRangeByIndex(row, 11).numberFormat = 'm/d/yy h:mm:ss AM/PM';

          // only for numberCopy action
          sheet.getRangeByIndex(row, 12).setText(numberInput.solution);
          sheet.getRangeByIndex(row, 13).setText(numberInput.input);
          final wasCorrectText = numberInput.solution == numberInput.input ? 'true' : 'false';
          sheet.getRangeByIndex(row, 14).setText(wasCorrectText);

          row++;
        }
      }
    }

    // Save and dispose the document.
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    // Download the output file in web.
    AnchorElement(
        href: "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
      ..setAttribute("download", "output.xlsx")
      ..click();
  }
}

final firestoreResultsRepositoryProvider = Provider<FirestoreResultsRepository>((ref) {
  return FirestoreResultsRepository(ref.watch(firestoreInstanceProvider));
});
