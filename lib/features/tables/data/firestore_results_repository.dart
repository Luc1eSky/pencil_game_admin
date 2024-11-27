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
import '../../user/domain/app_user.dart';
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
      throw Exception(
          'Error - startedOn or endedOn was null (expected DateTime).');
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
    final Worksheet sheet1 = workbook.worksheets[0];
    // add second worksheet
    final Worksheet sheet2 = workbook.worksheets.add();
    // Set the header values for columns in excel

    // experiment info
    sheet1.getRangeByIndex(1, 1).setText('ExperimentName');
    sheet1.getRangeByIndex(1, 2).setText('ExperimentLocation');
    sheet1.getRangeByIndex(1, 3).setText('ExperimentCreatedOn');
    sheet1.getRangeByIndex(1, 4).setText('treatment');

    // game info
    sheet1.getRangeByIndex(1, 5).setText('roundNumber');
    sheet1.getRangeByIndex(1, 6).setText('tableNumber');
    sheet1.getRangeByIndex(1, 7).setText('gameStartedOn');
    sheet1.getRangeByIndex(1, 8).setText('gameEndedOn');

    // action info
    sheet1.getRangeByIndex(1, 9).setText('playerUID');
    sheet1.getRangeByIndex(1, 10).setText('playerColorCode');
    sheet1.getRangeByIndex(1, 11).setText('actionType'); // click or number copy
    sheet1.getRangeByIndex(1, 12).setText('actionTimeStamp');

    // only for numberCopy action
    sheet1.getRangeByIndex(1, 13).setText('shownNumber');
    sheet1.getRangeByIndex(1, 14).setText('enteredNumber');
    sheet1.getRangeByIndex(1, 15).setText('numberWasCorrect');

    // connect to Firestore db
    FirebaseFirestore db = FirebaseFirestore.instance;

    // get experiment document reference
    DocumentReference experimentDocRef =
        db.collection(experimentCollectionName).doc(experimentDocId);

    // get experiment document snapshot
    final experimentDocSnap = await experimentDocRef.get();

    // convert data to experiment class
    final experiment =
        Experiment.fromJson(experimentDocSnap.data() as Map<String, dynamic>);

    // get results collection reference
    CollectionReference resultsCollectionRef = db
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(resultsCollectionName);

    // snapshot of collection reference
    QuerySnapshot resultsQuerySnapshot = await resultsCollectionRef
        .orderBy('roundNumber')
        .orderBy('tableNumber')
        .get();

    // start in second row (first is headers)
    int row = 2;

    // go through all documents in results snapshot
    for (QueryDocumentSnapshot testDocSnap in resultsQuerySnapshot.docs) {
      // convert data to result class
      final result =
          FirestoreResult.fromJson(testDocSnap.data() as Map<String, dynamic>);

      for (Click click in result.clicks) {
        // add experiment info
        sheet1.getRangeByIndex(row, 1).setText(experiment.name);
        sheet1.getRangeByIndex(row, 2).setText(experiment.location);
        sheet1.getRangeByIndex(row, 3).setDateTime(experiment.createdOn);
        sheet1.getRangeByIndex(row, 3).numberFormat = 'm/d/yy h:mm:ss AM/PM';
        sheet1.getRangeByIndex(row, 4).setText(experiment.treatment.name);

        // add game info
        sheet1.getRangeByIndex(row, 5).setNumber(result.roundNumber.toDouble());
        sheet1.getRangeByIndex(row, 6).setNumber(result.tableNumber.toDouble());
        sheet1.getRangeByIndex(row, 7).setDateTime(result.startedOn);
        sheet1.getRangeByIndex(row, 7).numberFormat = 'm/d/yy h:mm:ss AM/PM';
        sheet1.getRangeByIndex(row, 8).setDateTime(result.endedOn);
        sheet1.getRangeByIndex(row, 8).numberFormat = 'm/d/yy h:mm:ss AM/PM';

        // add action info
        sheet1.getRangeByIndex(row, 9).setText(click.user.uid);
        sheet1.getRangeByIndex(row, 10).setText(click.user.colorCode);
        sheet1.getRangeByIndex(row, 11).setText(click.type.name);
        sheet1.getRangeByIndex(row, 12).setDateTime(click.timestamp);
        sheet1.getRangeByIndex(row, 12).numberFormat = 'm/d/yy h:mm:ss AM/PM';

        row++;
      }

      for (NumberCopyResult numberCopyResult in result.numberCopyResults) {
        for (NumberInput numberInput in numberCopyResult.numberInputs) {
          // add experiment info
          sheet1.getRangeByIndex(row, 1).setText(experiment.name);
          sheet1.getRangeByIndex(row, 2).setText(experiment.location);
          sheet1.getRangeByIndex(row, 3).setDateTime(experiment.createdOn);
          sheet1.getRangeByIndex(row, 3).numberFormat = 'm/d/yy h:mm:ss AM/PM';
          sheet1.getRangeByIndex(row, 4).setText(experiment.treatment.name);
          // add game info
          sheet1
              .getRangeByIndex(row, 5)
              .setNumber(result.roundNumber.toDouble());
          sheet1
              .getRangeByIndex(row, 6)
              .setNumber(result.tableNumber.toDouble());
          sheet1.getRangeByIndex(row, 7).setDateTime(result.startedOn);
          sheet1.getRangeByIndex(row, 7).numberFormat = 'm/d/yy h:mm:ss AM/PM';
          sheet1.getRangeByIndex(row, 8).setDateTime(result.endedOn);
          sheet1.getRangeByIndex(row, 8).numberFormat = 'm/d/yy h:mm:ss AM/PM';

          // add action info
          sheet1.getRangeByIndex(row, 9).setText(numberCopyResult.user.uid);
          sheet1
              .getRangeByIndex(row, 10)
              .setText(numberCopyResult.user.colorCode);
          sheet1.getRangeByIndex(row, 11).setText('copyNumber');
          sheet1.getRangeByIndex(row, 12).setDateTime(numberInput.timestamp);
          sheet1.getRangeByIndex(row, 12).numberFormat = 'm/d/yy h:mm:ss AM/PM';

          // only for numberCopy action
          sheet1.getRangeByIndex(row, 13).setText(numberInput.solution);
          sheet1.getRangeByIndex(row, 14).setText(numberInput.input);
          final wasCorrectText =
              numberInput.solution == numberInput.input ? 'true' : 'false';
          sheet1.getRangeByIndex(row, 15).setText(wasCorrectText);

          row++;
        }
      }
    }

    row = 2;
    // get results collection reference
    CollectionReference userCollectionRef = db
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(userCollectionName);

    // experiment info
    sheet2.getRangeByIndex(1, 1).setText('playerUID');
    sheet2.getRangeByIndex(1, 2).setText('playerColor');
    sheet2.getRangeByIndex(1, 3).setText('Gender');

    // snapshot of collection reference
    QuerySnapshot usersQuerySnapshot = await userCollectionRef.get();

    for (QueryDocumentSnapshot userDocSnap in usersQuerySnapshot.docs) {
      // Extract user information
      if (userDocSnap.exists) {
        final user = AppUser.fromFirestore(
            userDocSnap.data() as Map<String, dynamic>, userDocSnap.id);
        if (user.survey == null) {
          continue;
        } else {
          sheet2.getRangeByIndex(row, 1).setText(user.uid);
          sheet2.getRangeByIndex(row, 2).setText(user.colorCode);
          sheet2.getRangeByIndex(row, 3).setText(user.survey?.gender.name);
        }
        //print(user);
      } else {
        sheet2.getRangeByIndex(row, 1).setText('N/A');
        sheet2.getRangeByIndex(row, 2).setText('N/A');
        sheet2.getRangeByIndex(row, 3).setText('N/A');
      }
      row++;
    }

    // Save and dispose the document.
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    // Download the output file in web.
    AnchorElement(
        href:
            "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
      ..setAttribute("download", "output.xlsx")
      ..click();
  }
}

final firestoreResultsRepositoryProvider =
    Provider<FirestoreResultsRepository>((ref) {
  return FirestoreResultsRepository(ref.watch(firestoreInstanceProvider));
});
