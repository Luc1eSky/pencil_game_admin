import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/firestore/firestore_instance_provider.dart';

import '../../../constants.dart';
import '../../user/domain/simple_user.dart';
import '../domain/game.dart';
import '../domain/participant_pair.dart';
import '../domain/round.dart';
import '../domain/schedule.dart';
import '../domain/schedule_parameters.dart';

class FirestoreScheduleRepository {
  FirestoreScheduleRepository(this._firestore);
  final FirebaseFirestore _firestore;

  /// add new parameter document
  Future<void> addParameterDoc(String experimentDocId) async {
    // create new parameters
    const newParameters = ScheduleParameters(
      allActiveUsers: {},
      tableCount: 0,
      numberOfRounds: 0,
      lastUserCount: null,
      lastTableCount: null,
      lastNumberOfRounds: null,
    );

    // add a new document for the schedule in sub-collection
    await _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(settingsCollectionName)
        .doc(parameterDocName)
        .set(newParameters.toJson());
  }

  /// add new detailed schedule document
  Future<void> addScheduleDocs(String experimentDocId) async {
    // create new empty schedule
    const newSchedule = Schedule(rounds: []);

    // add a new document for the detailed schedule in sub-collection
    await _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(settingsCollectionName)
        .doc(scheduleDocName)
        .set(newSchedule.toJson());
  }

  /// get stream to the parameters of a specific experiment
  Stream<DocumentSnapshot<ScheduleParameters>> getParameterStream(String experimentDocId) {
    return _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(settingsCollectionName)
        .doc(parameterDocName)
        .withConverter(
          fromFirestore: (snapshot, _) => ScheduleParameters.fromJson(snapshot.data()!),
          toFirestore: (parameters, _) => parameters.toJson(),
        )
        .snapshots();
  }

  /// get stream to a schedule of a specific experiment
  Stream<DocumentSnapshot<Schedule>> getScheduleStream(String experimentDocId) {
    return _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(settingsCollectionName)
        .doc(scheduleDocName)
        .withConverter(
          fromFirestore: (snapshot, _) => Schedule.fromJson(snapshot.data()!),
          toFirestore: (schedule, _) => schedule.toJson(),
        )
        .snapshots();
  }

  /// get a detailed round from schedule
  Future<Round> getRound(
    String experimentDocId,
    int roundNumber,
  ) async {
    final scheduleDocSnap = await _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(settingsCollectionName)
        .doc(scheduleDocName)
        .get();

    if (!scheduleDocSnap.exists) {
      throw 'Error - Detailed schedule doc does not exist!';
    }
    final scheduleData = scheduleDocSnap.data();
    if (scheduleData == null) {
      throw 'Error - Detailed schedule doc does not exist!';
    }

    final schedule = Schedule.fromJson(scheduleData);

    final detailedRound =
        schedule.rounds.firstWhere((round) => round.roundNumber == roundNumber, orElse: () {
      throw 'Error - No round $roundNumber found.';
    });

    return detailedRound;
  }

  /// returns a function that increases or decreases either the table count
  /// or the number of rounds
  Future<void> Function() getCountChangeFunction(
    String experimentDocId, {
    bool subtract = false,
    bool isTable = true,
  }) {
    return () async {
      // get ref to parameter document
      final parameterDocRef = _firestore
          .collection(experimentCollectionName)
          .doc(experimentDocId)
          .collection(settingsCollectionName)
          .doc(parameterDocName);

      // run a transaction to avoid race condition
      _firestore.runTransaction((transaction) async {
        try {
          // get parameters object from parameter document
          final parameterDocSnap = await transaction.get(parameterDocRef);
          final parameters = ScheduleParameters.fromJson(parameterDocSnap.data()!);

          // calculate new count based on current data
          final oldCount = isTable ? parameters.tableCount : parameters.numberOfRounds;
          final newCount = subtract ? max(0, oldCount - 1) : oldCount + 1;

          // create updated schedule object
          final updatedParameters = isTable
              ? parameters.copyWith(tableCount: newCount)
              : parameters.copyWith(numberOfRounds: newCount);

          // update document in firestore
          transaction.update(parameterDocRef, updatedParameters.toJson());
        } catch (e) {
          // TODO: HANDLE ERROR
          debugPrint(e.toString());
          return;
        }
      });
    };
  }

  /// calculate schedule
  Future<void> updateSchedule({
    required String experimentDocId,
    required Schedule schedule,
  }) async {
    // get settings collection reference of specific experiment
    final settingsCollectionRef = _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(settingsCollectionName);

    // update schedule document in settings collection
    await settingsCollectionRef.doc(scheduleDocName).update(schedule.toJson());
  }

  /// calculate schedule
  Future<Schedule?> calculateSchedule({
    required String experimentDocId,
  }) async {
    // reference to parameters of current experiment
    final parameterDocRef = _firestore
        .collection(experimentCollectionName)
        .doc(experimentDocId)
        .collection(settingsCollectionName)
        .doc(parameterDocName);

    return _firestore.runTransaction((transaction) async {
      // get experiment document
      final parameterDoc = await transaction.get(parameterDocRef);

      // exit if it does not exist
      if (!parameterDoc.exists) {
        return null;
        throw Exception('Schedule document for experiment $experimentDocId does not exist.');
      }
      // exit if there is no data
      if (parameterDoc.data() == null) {
        return null;
        throw Exception('Schedule document for experiment $experimentDocId has no data.');
      }

      // get current parameters
      final currentParameters = ScheduleParameters.fromJson(parameterDoc.data()!);

      // get user count and inputs for table count and number of rounds
      final userCount = currentParameters.userCount;
      final maxTables = currentParameters.tableCount;
      final maxRounds = currentParameters.numberOfRounds;

      // exit if any of the input values is 0 or negative
      if (!currentParameters.canCreateSchedule) {
        return null;
        throw Exception('Error - Cannot calculate schedule with a 0 or negative value.');
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

      final allActiveUsers = currentParameters.allActiveUsers;

      // check if calculation was successful
      // (results were found without exceeding max retries)
      if (tryCount <= maxTriesFromStart) {
        // convert result map into list of rounds
        List<Round> rounds = [];
        // Map<int, Map<int, Set<int>>>
        resultMap.forEach((roundNumber, tableMap) {
          //print('roundNumber: $roundNumber');
          List<Game> listOfGames = [];
          Set<SimpleUser> setOfPausingUsers = {};
          tableMap.forEach((tableNumber, playerNumbers) {
            // convert player numbers to app users
            final users = playerNumbers.map((n) => allActiveUsers.elementAt(n)).toSet();
            // add pausing player color codes
            if (tableNumber == 0) {
              setOfPausingUsers.addAll(users);
            }
            // add playing users
            else {
              listOfGames.add(
                Game(
                  tableNumber: tableNumber,
                  assignedUsers: users,
                ),
              );
            }
          });
          // add round to list of rounds
          rounds.add(
            Round(
              roundNumber: roundNumber,
              games: listOfGames,
              pausingUsers: setOfPausingUsers,
            ),
          );
        });

        // create updated parameters object
        final updatedParameters = currentParameters.copyWith(
          lastUserCount: userCount,
          lastTableCount: maxTables,
          lastNumberOfRounds: maxRounds,
        );

        // update parameter doc with the parameters that were used for
        // the calculation
        transaction.update(parameterDocRef, updatedParameters.toJson());

        // create updated parameters object
        final newSchedule = Schedule(rounds: rounds);

        debugPrint(
            '\nCOMPLETED SUCCESSFULLY AFTER $tryCount RUNS AND $maxRoundRetriesOfLastRun MAX ROUND RETRIES');
        return newSchedule;
      } else {
        debugPrint(
            '\nFAILED AFTER ${tryCount - 1} RUNS AND $maxRoundRetriesOfLastRun MAX ROUND RETRIES');
        return null;
      }
    });
  }
}

final firestoreScheduleRepositoryProvider = Provider<FirestoreScheduleRepository>((ref) {
  return FirestoreScheduleRepository(ref.watch(firestoreInstanceProvider));
});
