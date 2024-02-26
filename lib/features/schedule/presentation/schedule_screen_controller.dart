// import 'dart:math';
//
// import 'package:flutter/material.dart';
//
// import '../../../constants.dart';
// import '../domain/participant_pair.dart';
// import '../domain/round.dart';
//
// Future<(bool, Map<int, Map<int, Set<int>>>)> calculateRounds({
//   required int userCount,
//   required List<String> playerColorCodes,
//   required int maxTables,
//   required int maxRounds,
// }) async {
//   // Map that saves result in integers
//   // Map<roundNumber, Map<tableNumber, Set<playerNumbers>>>
//   Map<int, Map<int, Set<int>>> resultMap = {};
//
//   // exit if any of the input values is 0 or negative
//   if (userCount <= 0 || maxTables <= 0 || maxRounds <= 0) {
//     debugPrint('Error - Cannot calculate schedule with a 0 or negative value.');
//     return (false, resultMap);
//   }
//   // set of integers {0,1,2,3,4,...}
//   final allUsers = List.generate(userCount, (index) => index).toSet();
//
//   // calculate all possible pairs
//   Set<ParticipantPair> allPossiblePairs = {};
//
//   // go through copy of user list
//   final allUsersCopy = [...allUsers];
//   for (int i = 0; i < userCount; i++) {
//     // get first entry in list and remove
//     final currentUser = allUsersCopy.removeAt(0);
//     // create all possible user pairs
//     for (var otherUser in allUsersCopy) {
//       final pair = ParticipantPair(currentUser, otherUser);
//       allPossiblePairs.add(pair);
//     }
//   }
//
//   // calculate max combinations, table count and number of rounds
//   final possibleCombinationCount = allPossiblePairs.length;
//   final tableCount = min(maxTables, userCount ~/ 2);
//   final rounds = min(maxRounds, possibleCombinationCount ~/ tableCount);
//
//   int maxRoundRetriesOfLastRun = 0;
//   int tryCount = 1;
//   bool retryFromStart = true;
//   while (retryFromStart == true && tryCount <= maxTriesFromStart) {
//     final random = Random();
//     // reset max round retries
//     maxRoundRetriesOfLastRun = 0;
//     // keeps track which pairs played over whole experiment (multiple rounds)
//     Set<ParticipantPair> pairsAlreadyPlayed = {};
//     // go through all rounds
//     for (int r = 1; r <= rounds; r++) {
//       int roundTryCount = 1;
//       bool retryRound = true;
//       while (retryRound == true && roundTryCount <= maxRoundTries) {
//         // by default, do not retry
//         retryFromStart = false;
//         retryRound = false;
//         resultMap[r] = {};
//         // all pairs minus the once that had already played in previous rounds
//         Set<ParticipantPair> possiblePairs = allPossiblePairs.difference(pairsAlreadyPlayed);
//         // update pairsAlreadyPlayed after round was a success with the pairs of that round
//         Set<ParticipantPair> pairsThisRound = {};
//         // keep track, so no user plays twice in the same round
//         Set<int> usersPlayingThisRound = {};
//         // keep track of who has to pause
//         Set<int> usersPausingThisRound = {};
//         // go through all available tables
//         for (int t = 1; t <= tableCount; t++) {
//           // remove all pairs of players who already played this round from possible pair list
//           for (int user in usersPlayingThisRound) {
//             possiblePairs = possiblePairs.where((pair) => !pair.participantIsInPair(user)).toSet();
//           }
//
//           // check if there are still options available
//           if (possiblePairs.isEmpty) {
//             maxRoundRetriesOfLastRun = max(maxRoundRetriesOfLastRun, roundTryCount);
//             roundTryCount++;
//             retryRound = true;
//             retryFromStart = true;
//             break;
//           }
//
//           // randomly select a pair from the set of possible pairs
//           final randomNumber = random.nextInt(possiblePairs.length);
//           final randomPair = possiblePairs.elementAt(randomNumber);
//
//           resultMap[r]![t] = randomPair.toSet();
//           // add to pairsThisRound
//           pairsThisRound.add(randomPair);
//           // add to usersPlayingThisRound
//           usersPlayingThisRound.addAll([
//             randomPair.participant1,
//             randomPair.participant2,
//           ]);
//         }
//
//         // if no retry is needed, calculate users that are pausing
//         // and update the pairs that have already played with the ones that played this round
//         if (retryRound == false) {
//           usersPausingThisRound = allUsers.difference(usersPlayingThisRound);
//           resultMap[r]![0] = usersPausingThisRound;
//
//           // add all pairs from this round to set of already played pairs
//           pairsAlreadyPlayed.addAll(pairsThisRound);
//         }
//       }
//       if (retryFromStart == true) {
//         tryCount++;
//         break;
//       }
//     }
//   }
//
//   // required int roundNumber,
//   // required List<Game> games,
//   // required List<AppUser> pausingPlayers,
//
//   // check if calculation was successful
//   // (results were found without exceeding max retries)
//   if (tryCount <= maxTriesFromStart) {
//     // convert into list of rounds
//     List<Round> rounds = [];
//     //Map<int, Map<int, Set<int>>>
//     resultMap.forEach((roundNumber, tableMap) {
//       print('roundNumber: $roundNumber');
//       tableMap.forEach((tableNumber, playerNumbers) {
//         print('tableNumber: $tableNumber: playerNumbers: $playerNumbers');
//
//         //final game = Game(tableNumber: tableNumber, playerPair: playerPair);
//       });
//     });
//
//     print(resultMap);
//     debugPrint(
//         '\nCOMPLETED SUCCESSFULLY AFTER $tryCount RUNS AND $maxRoundRetriesOfLastRun MAX ROUND RETRIES');
//     return (true, resultMap);
//   } else {
//     debugPrint(
//         '\nFAILED AFTER ${tryCount - 1} RUNS AND $maxRoundRetriesOfLastRun MAX ROUND RETRIES');
//     return (false, resultMap);
//   }
// }
