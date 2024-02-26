import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/firestore/firestore_instance_provider.dart';

import '../../../constants.dart';
import '../domain/game.dart';
import '../domain/participant_pair.dart';
import '../domain/round.dart';
import '../domain/schedule.dart';

class FirestoreScheduleRepository {
  FirestoreScheduleRepository(this._firestore);
  final FirebaseFirestore _firestore;

  /// get stream to a schedule of a specific experiment
  Stream<DocumentSnapshot<Map<String, dynamic>>> getScheduleStream(String docId) {
    return _firestore
        .collection(experimentCollectionName)
        .doc(docId)
        .collection(scheduleCollectionName)
        .doc(scheduleDocName)
        .snapshots();
  }

  /// returns a function that increases or decreases either the table count
  /// or the number of rounds
  Future<void> Function() getCountChangeFunction(String experimentDocId,
      {bool subtract = false, bool isTable = true}) {
    return () async {
      // get doc ref to schedule
      final scheduleDocRef = _firestore
          .collection(experimentCollectionName)
          .doc(experimentDocId)
          .collection(scheduleCollectionName)
          .doc(scheduleDocName);

      // runa  transaction to avoid race condition
      _firestore.runTransaction((transaction) async {
        try {
          // get schedule object from schedule document
          final scheduleDocSnap = await transaction.get(scheduleDocRef);
          final Schedule schedule = Schedule.fromJson(scheduleDocSnap.data()!);

          // calculate new count based on current data
          final oldCount = isTable ? schedule.tableCount : schedule.numberOfRounds;
          final newCount = subtract ? max(0, oldCount - 1) : oldCount + 1;

          // create updated schedule object
          final updatedSchedule = isTable
              ? schedule.copyWith(tableCount: newCount)
              : schedule.copyWith(numberOfRounds: newCount);

          // update document in firestore
          transaction.update(scheduleDocRef, updatedSchedule.toJson());
        } catch (e) {
          debugPrint(e.toString());
          return;
        }
      });
    };
  }

  /// calculate schedule
  Future<bool> calculateRounds({
    required String experimentDocId,
  }) async {
    try {
      // reference to schedule of current experiment
      final scheduleRef = _firestore
          .collection(experimentCollectionName)
          .doc(experimentDocId)
          .collection(scheduleCollectionName)
          .doc(scheduleDocName);

      return _firestore.runTransaction((transaction) async {
        // get experiment document
        final scheduleDoc = await transaction.get(scheduleRef);

        // exit if it does not exist
        if (!scheduleDoc.exists) {
          throw Exception('Schedule document for experiment $experimentDocId does not exist.');
        }
        // exit if there is no data
        if (scheduleDoc.data() == null) {
          throw Exception('Schedule document for experiment $experimentDocId has no data.');
        }

        // get current schedule
        final currentSchedule = Schedule.fromJson(scheduleDoc.data()!);

        // get user count and inputs for table count and number of rounds
        final userCount = currentSchedule.userCount;
        final maxTables = currentSchedule.tableCount;
        final maxRounds = currentSchedule.numberOfRounds;

        // get list of color codes of active players
        final playerColorCodes = currentSchedule.playerColorCodes;

        // exit if any of the input values is 0 or negative
        if (userCount <= 0 || maxTables <= 0 || maxRounds <= 0) {
          debugPrint('Error - Cannot calculate schedule with a 0 or negative value.');
          return false;
        }
        // set of integers {0,1,2,3,4,...}
        final allUsers = List.generate(userCount, (index) => index).toSet();

        // calculate all possible pairs
        Set<ParticipantPair> allPossiblePairs = {};

        // go through copy of user list
        final allUsersCopy = [...allUsers];
        for (int i = 0; i < userCount; i++) {
          // get first entry in list and remove
          final currentUser = allUsersCopy.removeAt(0);
          // create all possible user pairs
          for (var otherUser in allUsersCopy) {
            final pair = ParticipantPair(currentUser, otherUser);
            allPossiblePairs.add(pair);
          }
        }

        // Map that saves result in integers
        // Map<roundNumber, Map<tableNumber, Set<playerNumbers>>>
        Map<int, Map<int, Set<int>>> resultMap = {};

        // calculate max combinations, table count and number of rounds
        final possibleCombinationCount = allPossiblePairs.length;
        final tableCount = min(maxTables, userCount ~/ 2);
        final rounds = min(maxRounds, possibleCombinationCount ~/ tableCount);

        int maxRoundRetriesOfLastRun = 0;
        int tryCount = 1;
        bool retryFromStart = true;
        while (retryFromStart == true && tryCount <= maxTriesFromStart) {
          final random = Random();
          // reset max round retries
          maxRoundRetriesOfLastRun = 0;
          // keeps track which pairs played over whole experiment (multiple rounds)
          Set<ParticipantPair> pairsAlreadyPlayed = {};
          // go through all rounds
          for (int r = 1; r <= rounds; r++) {
            int roundTryCount = 1;
            bool retryRound = true;
            while (retryRound == true && roundTryCount <= maxRoundTries) {
              // by default, do not retry
              retryFromStart = false;
              retryRound = false;
              resultMap[r] = {};
              // all pairs minus the once that had already played in previous rounds
              Set<ParticipantPair> possiblePairs = allPossiblePairs.difference(pairsAlreadyPlayed);
              // update pairsAlreadyPlayed after round was a success with the pairs of that round
              Set<ParticipantPair> pairsThisRound = {};
              // keep track, so no user plays twice in the same round
              Set<int> usersPlayingThisRound = {};
              // keep track of who has to pause
              Set<int> usersPausingThisRound = {};
              // go through all available tables
              for (int t = 1; t <= tableCount; t++) {
                // remove all pairs of players who already played this round from possible pair list
                for (int user in usersPlayingThisRound) {
                  possiblePairs =
                      possiblePairs.where((pair) => !pair.participantIsInPair(user)).toSet();
                }

                // check if there are still options available
                if (possiblePairs.isEmpty) {
                  maxRoundRetriesOfLastRun = max(maxRoundRetriesOfLastRun, roundTryCount);
                  roundTryCount++;
                  retryRound = true;
                  retryFromStart = true;
                  break;
                }

                // randomly select a pair from the set of possible pairs
                final randomNumber = random.nextInt(possiblePairs.length);
                final randomPair = possiblePairs.elementAt(randomNumber);

                resultMap[r]![t] = randomPair.toSet();
                // add to pairsThisRound
                pairsThisRound.add(randomPair);
                // add to usersPlayingThisRound
                usersPlayingThisRound.addAll([
                  randomPair.participant1,
                  randomPair.participant2,
                ]);
              }

              // if no retry is needed, calculate users that are pausing
              // and update the pairs that have already played with the ones that played this round
              if (retryRound == false) {
                usersPausingThisRound = allUsers.difference(usersPlayingThisRound);
                resultMap[r]![0] = usersPausingThisRound;

                // add all pairs from this round to set of already played pairs
                pairsAlreadyPlayed.addAll(pairsThisRound);
              }
            }
            if (retryFromStart == true) {
              tryCount++;
              break;
            }
          }
        }

        // check if calculation was successful
        // (results were found without exceeding max retries)
        if (tryCount <= maxTriesFromStart) {
          // convert into list of rounds
          List<Round> rounds = [];
          // Map<int, Map<int, Set<int>>>
          resultMap.forEach((roundNumber, tableMap) {
            //print('roundNumber: $roundNumber');
            List<Game> listOfGames = [];
            Set<String> setOfPausingPlayers = {};
            tableMap.forEach((tableNumber, playerNumbers) {
              //print('tableNumber: $tableNumber: playerNumbers: $playerNumbers');
              // convert player numbers to color codes
              final playerColors = playerNumbers.map((n) => playerColorCodes[n]).toSet();

              // add pausing player color codes
              if (tableNumber == 0) {
                setOfPausingPlayers.addAll(playerColors);
              }
              // add playing player color codes
              else {
                listOfGames.add(
                  Game(
                    tableNumber: tableNumber,
                    playerPair: playerColors,
                  ),
                );
              }
            });
            // add round to list of rounds
            rounds.add(
              Round(
                roundNumber: roundNumber,
                games: listOfGames,
                pausingPlayers: setOfPausingPlayers,
              ),
            );
          });

          // create updated schedule
          final updatedSchedule = currentSchedule.copyWith(rounds: rounds);

          // update schedule doc with new user count and color color code list
          transaction.update(scheduleRef, updatedSchedule.toJson());

          debugPrint(
              '\nCOMPLETED SUCCESSFULLY AFTER $tryCount RUNS AND $maxRoundRetriesOfLastRun MAX ROUND RETRIES');
          return true;
        } else {
          debugPrint(
              '\nFAILED AFTER ${tryCount - 1} RUNS AND $maxRoundRetriesOfLastRun MAX ROUND RETRIES');
          return false;
        }
      });
    } catch (error) {
      print('ERROR!!!');
      debugPrint(error.toString());
      return false;
    }
  }
}

final firestoreScheduleRepositoryProvider = Provider<FirestoreScheduleRepository>((ref) {
  return FirestoreScheduleRepository(ref.watch(firestoreInstanceProvider));
});
