import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/schedule/domain/round.dart';
import 'package:pencil_game_admin/features/tables/data/database_time_offset_provider.dart';

import '../../../constants.dart';
import '../domain/realtime_table.dart';

class RealtimeDatabaseRepository {
  RealtimeDatabaseRepository({
    required this.realtimeDatabase,
    required this.databaseOffset,
  });

  final FirebaseDatabase realtimeDatabase;
  final Duration databaseOffset;

  /// get stream to experiment node
  Stream<DatabaseEvent> getExperimentGameStream(String experimentDocId) {
    return realtimeDatabase.ref(experimentDocId).onValue;
  }

  /// get stream to tables node of specific experiment
  Stream<DatabaseEvent> getTablesStream(String experimentDocId) {
    return realtimeDatabase.ref(experimentDocId).child('tables').onValue;
  }

  /// add tables to experiment in the RTDB
  Future<void> addTablesToDatabase({
    required String experimentDocId,
    required Round round,
  }) async {
    // get tables ref in RTDB
    final tablesRef = realtimeDatabase.ref(experimentDocId).child('tables');

    // remove current tables
    await tablesRef.remove();

    // go through all games and add tables
    for (var game in round.games) {
      // create realtime table object from game
      final table = RealtimeTable(
        tableNumber: game.tableNumber,
        assignedUsers: game.assignedUsers,
        //usersAtTable: {},
        //uidThatHasPen: 'someOne',
        //currentClicks: [],
        // status: default is waiting
      );

      // add to RTDB
      await tablesRef.child('table${game.tableNumber}').set(table.toJson());
    }
  }

  /// remove all users that are currently at a table
  Future<void> removeUsersFromTable({
    required String experimentDocId,
    required int tableNumber,
  }) async {
    // get tables ref in RTDB
    final tableRef =
        realtimeDatabase.ref(experimentDocId).child('tables').child('table$tableNumber');
    // create table object from data
    final tableSnap = await tableRef.get();
    final table = RealtimeTable.fromJson(tableSnap.value as Map<String, dynamic>);
    // create updated table with no users
    final updatedTable = table.copyWith(usersAtTable: null);
    // update data in RTDB
    await tableRef.update(updatedTable.toJson());
  }

  /// start game at table
  Future<void> startTable({
    required String experimentDocId,
    required int tableNumber,
  }) async {
    // get tables ref in RTDB
    final tableRef =
        realtimeDatabase.ref(experimentDocId).child('tables').child('table$tableNumber');

    await tableRef.runTransaction((Object? tableValue) {
      // exit in case there is no table
      if (tableValue == null) {
        return Transaction.abort();
      }

      // convert data to table object
      final table = RealtimeTable.fromJson(tableValue as Map<String, dynamic>);

      // exit in case any user dropped out
      if (!table.hasCorrectUsers) {
        return Transaction.abort();
      }

      // exit in case table was already started
      if (table.status != TableStatus.waiting) {
        return Transaction.abort();
      }

      // set starting time to a few seconds from now including server clock difference
      final serverTimeNow = DateTime.now().add(databaseOffset);
      final serverStartTime = serverTimeNow.add(const Duration(seconds: startTimeInSeconds));
      final serverEndTime = serverStartTime.add(const Duration(seconds: gameTimeInSeconds));

      // create updated table with status "playing" and start time and end time
      final updatedTable = table.copyWith(
        status: TableStatus.playing,
        startedOn: serverStartTime,
        endedOn: serverEndTime,
      );

      // update data in database
      return Transaction.success(updatedTable.toJson());
    });
  }

  /// get table
  Future<RealtimeTable> getTable({
    required String experimentDocId,
    required int tableNumber,
  }) async {
    try {
      // get tables ref in RTDB
      final tableRef =
          realtimeDatabase.ref(experimentDocId).child('tables').child('table$tableNumber');

      // create table object from data
      final tableSnap = await tableRef.get();
      final table = RealtimeTable.fromJson(tableSnap.value as Map<String, dynamic>);

      return table;
    } catch (e) {
      throw Exception("Error. Could not get table from Realtime Database.\n$e");
    }
  }

  /// set table status to finished
  Future<void> setTableToFinished({
    required String experimentDocId,
    required int tableNumber,
  }) async {
    try {
      // get tables ref in RTDB
      final tableRef =
          realtimeDatabase.ref(experimentDocId).child('tables').child('table$tableNumber');

      // create table object from data
      final tableSnap = await tableRef.get();
      final table = RealtimeTable.fromJson(tableSnap.value as Map<String, dynamic>);
      final updatedTable = table.copyWith(status: TableStatus.finished);
      await tableRef.update(updatedTable.toJson());
    } catch (e) {
      throw Exception("Error. Could not set table to finished.\n$e");
    }
  }

  /// check if all tables have status "finished"
  Future<bool> checkIfAllTablesAreFinished({
    required String experimentDocId,
  }) async {
    try {
      print('HERE3!');
      // get tables ref in RTDB
      final tablesRef = realtimeDatabase.ref(experimentDocId).child('tables');
      // get snapshot of data
      final tablesSnap = await tablesRef.get();
      // get map of data
      final tablesMap = tablesSnap.value as Map<String, dynamic>;
      // convert to list of table objects
      final listOfTables = tablesMap.entries
          .map((entry) => RealtimeTable.fromJson(entry.value as Map<String, dynamic>))
          .toList();
      // check if all tables have been finished
      final allTablesFinished = listOfTables.every((table) => table.status == TableStatus.finished);
      return allTablesFinished;
    } catch (e) {
      throw Exception("Error. Could not check if tables were finished.\n$e");
    }
  }
}

final realtimeDatabaseRepositoryProvider = Provider<RealtimeDatabaseRepository>((ref) {
  return RealtimeDatabaseRepository(
    realtimeDatabase: FirebaseDatabase.instance,
    databaseOffset: ref.watch(databaseTimeOffsetRepositoryProvider),
  );
});
