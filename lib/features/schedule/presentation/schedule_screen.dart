import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/progress/data/firestore_progress_repository.dart';
import 'package:pencil_game_admin/features/schedule/data/firestore_schedule_repository.dart';
import 'package:pencil_game_admin/features/schedule/domain/detailed_schedule.dart';
import 'package:pencil_game_admin/features/schedule/presentation/widgets/count_incrementer.dart';
import 'package:pencil_game_admin/features/schedule/presentation/widgets/parameter_count_widget.dart';

import '../../../style/color_palette.dart';
import '../../progress/domain/experiment_progress.dart';
import '../../progress/presentation/lock_schedule_switch.dart';
import '../domain/schedule_parameters.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key, required this.experimentDocId});

  final String experimentDocId;

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  bool isCalculating = false;

  @override
  Widget build(BuildContext context) {
    /// define method to return 4 different functions for adding and subtracting
    /// to/from table count or number of rounds
    Future<void> Function() getCountChangeMethod(
      String experimentDocId, {
      bool subtract = false,
      bool isTable = true,
    }) {
      // return function that modifies firestore data
      return ref.read(firestoreScheduleRepositoryProvider).getCountChangeFunction(
            experimentDocId,
            subtract: subtract,
            isTable: isTable,
          );
    }

    return Column(
      children: [
        StreamBuilder(
            stream: ref
                .read(firestoreScheduleRepositoryProvider)
                .getParameterStream(widget.experimentDocId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('Parameter doc snapshot error.');
                return const Text('Parameter doc snapshot error.');
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docData = snapshot.data?.data();
              if (docData == null) {
                debugPrint('Document has no data!');
                return const Text('Error - document has no data.');
              }

              try {
                // create parameter object from data
                final parameters = ScheduleParameters.fromJson(docData);
                // get last input values and check if anything has changed
                final userCount = parameters.userCount;
                final userCountHasChanged = parameters.userCountHasChanged;
                final tableCount = parameters.tableCount;
                final tableCountHasChanged = parameters.tableCountHasChanged;
                final numberOfRounds = parameters.numberOfRounds;
                final numberOfRoundsHasChanged = parameters.numberOfRoundsHasChanged;
                final anythingHasChanged = parameters.anythingHasChanged;

                return Column(
                  children: [
                    SizedBox(
                      height: 80,
                      child: Row(
                        children: [
                          Expanded(
                            child: ParameterCountWidget(
                              text: 'Users',
                              hasChanged: userCountHasChanged,
                              child: FittedBox(
                                child: Text(
                                  userCount.toString(),
                                  style: const TextStyle(fontSize: 100),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ParameterCountWidget(
                              text: 'Tables',
                              hasChanged: tableCountHasChanged,
                              child: CountIncrementer(
                                isBlocked: isCalculating,
                                count: tableCount,
                                subtract:
                                    getCountChangeMethod(widget.experimentDocId, subtract: true),
                                add: getCountChangeMethod(widget.experimentDocId),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ParameterCountWidget(
                              text: 'Rounds',
                              hasChanged: numberOfRoundsHasChanged,
                              child: CountIncrementer(
                                isBlocked: isCalculating,
                                count: numberOfRounds,
                                subtract: getCountChangeMethod(widget.experimentDocId,
                                    subtract: true, isTable: false),
                                add: getCountChangeMethod(widget.experimentDocId, isTable: false),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder(
                        stream: ref
                            .read(firestoreProgressRepositoryProvider)
                            .getProgressDocStream(widget.experimentDocId),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            debugPrint('Progress doc snapshot error.!');
                            return const Text('Progress doc snapshot error.');
                          }
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final docData = snapshot.data?.data();
                          if (docData == null) {
                            debugPrint('Document has no data!');
                            return const Text('Error - document has no data.');
                          }

                          try {
                            final progress = ExperimentProgress.fromJson(docData);

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: ElevatedButton(
                                    onPressed: isCalculating ||
                                            !parameters.canCreateSchedule ||
                                            !progress.canCreateSchedule
                                        ? null
                                        : () async {
                                            setState(() {
                                              isCalculating = true;
                                            });
                                            try {
                                              // calculate schedule (null if there was an error)
                                              final schedule = await ref
                                                  .read(firestoreScheduleRepositoryProvider)
                                                  .calculateSchedule(
                                                    experimentDocId: widget.experimentDocId,
                                                  );

                                              if (schedule == null) {
                                                throw Exception(
                                                    'Error - Could not calculate schedule.');
                                              }

                                              // update schedule documents
                                              await ref
                                                  .read(firestoreScheduleRepositoryProvider)
                                                  .updateSchedules(
                                                    experimentDocId: widget.experimentDocId,
                                                    schedule: schedule,
                                                  );

                                              // set status to "scheduled"
                                              await ref
                                                  .read(firestoreProgressRepositoryProvider)
                                                  .changeStatus(
                                                      experimentDocId: widget.experimentDocId,
                                                      newStatus: ExperimentStatus.scheduled);
                                            } catch (error) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: ColorPalette().snackBarError,
                                                    content: Text(error.toString()),
                                                  ),
                                                );
                                              }
                                            }

                                            setState(() {
                                              isCalculating = false;
                                            });
                                          },
                                    child: const Text('Create Schedule'),
                                  ),
                                ),
                                LockScheduleSwitch(
                                  experimentDocId: widget.experimentDocId,
                                ),
                              ],
                            );
                          } catch (error) {
                            debugPrint(error.toString());
                            return Text(error.toString());
                          }
                        }),
                  ],
                );
              } catch (error) {
                debugPrint(error.toString());
                return Text(error.toString());
              }
            }),
        Expanded(
          child: StreamBuilder(
            stream: ref
                .read(firestoreScheduleRepositoryProvider)
                .getDetailedScheduleStream(widget.experimentDocId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                debugPrint('Snapshot error!');
                return const Text('error');
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              try {
                // create parameter object from data
                final detailedSchedule = DetailedSchedule.fromJson(snapshot.data!.data()!);
                final rounds = detailedSchedule.rounds;

                // if no schedule has been created yet, show empty screen
                if (rounds.isEmpty) {
                  return Container();
                }

                int playersPausingEachRound = rounds.first.pausingUsers.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 35,
                        child: Text(
                          '${rounds.length} rounds total / '
                          '$playersPausingEachRound player(s) pausing each round',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          itemCount: rounds.length,
                          itemBuilder: (context, index) {
                            final round = rounds[index];
                            final listOfTableTexts = round.games.map((g) {
                              final colorPairString =
                                  g.userPair.map((p) => p.colorCode).join(' - ');
                              return Text(
                                'Table ${g.tableNumber}: $colorPairString',
                                style: const TextStyle(fontSize: 16),
                              );
                            }).toList();
                            final pausingPlayersString =
                                round.pausingUsers.map((p) => p.colorCode).toSet().join(', ');
                            return Card(
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                                titleTextStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                title: Text('Round ${round.roundNumber}'),
                                subtitle: Align(
                                  alignment: Alignment.centerRight,
                                  child: FractionallySizedBox(
                                    widthFactor: 0.72,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ...listOfTableTexts,
                                        if (pausingPlayersString.isNotEmpty)
                                          Text(
                                            'Pausing: $pausingPlayersString',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                        ),
                      ),
                    ],
                  ),
                );
              } catch (error) {
                debugPrint(error.toString());
                return Text(error.toString());
              }
              return Container(
                color: Colors.blue,
              );
            },
          ),
        ),
      ],
    );

    // return StreamBuilder(
    //     stream:
    //         ref.read(firestoreScheduleRepositoryProvider).getScheduleStream(widget.experimentDocId),
    //     builder: (context, snapshot) {
    //       if (snapshot.hasError) {
    //         debugPrint('Snapshot error!');
    //         return const Text('error');
    //       }
    //       if (!snapshot.hasData) {
    //         return const CircularProgressIndicator();
    //       }
    //       int userCount;
    //       int tableCount;
    //       int numberOfRounds;
    //       try {
    //         final schedule = Schedule.fromJson(snapshot.data!.data()!);
    //         return Container();
    //
    //         // userCount = schedule.userCount;
    //         // tableCount = schedule.tableCount;
    //         // numberOfRounds = schedule.numberOfRounds;
    //
    //         // return Column(
    //         //   children: [
    //         //     SizedBox(
    //         //       height: 100,
    //         //       child: Row(
    //         //         children: [
    //         //           Expanded(
    //         //             child: ParameterCountWidget(
    //         //               text: 'Users',
    //         //               child: FittedBox(
    //         //                 child: Text(
    //         //                   userCount.toString(),
    //         //                   style: const TextStyle(fontSize: 100),
    //         //                 ),
    //         //               ),
    //         //             ),
    //         //           ),
    //         //           Expanded(
    //         //             child: ParameterCountWidget(
    //         //               text: 'Tables',
    //         //               child: CountIncrementer(
    //         //                 isBlocked: isCalculating,
    //         //                 count: tableCount,
    //         //                 subtract: getCountChangeMethod(widget.experimentDocId, subtract: true),
    //         //                 add: getCountChangeMethod(widget.experimentDocId),
    //         //               ),
    //         //             ),
    //         //           ),
    //         //           Expanded(
    //         //             child: ParameterCountWidget(
    //         //               text: 'Rounds',
    //         //               child: CountIncrementer(
    //         //                 isBlocked: isCalculating,
    //         //                 count: numberOfRounds,
    //         //                 subtract: getCountChangeMethod(widget.experimentDocId,
    //         //                     subtract: true, isTable: false),
    //         //                 add: getCountChangeMethod(widget.experimentDocId, isTable: false),
    //         //               ),
    //         //             ),
    //         //           ),
    //         //         ],
    //         //       ),
    //         //     ),
    //         //     Padding(
    //         //       padding: const EdgeInsets.all(15.0),
    //         //       child: ElevatedButton(
    //         //         onPressed: isCalculating
    //         //             ? null
    //         //             : () async {
    //         //                 setState(() {
    //         //                   isCalculating = true;
    //         //                 });
    //         //                 //await Future.delayed(const Duration(milliseconds: 2000));
    //         //                 // returns a bool to see if it was successful and a
    //         //                 final success =
    //         //                     await ref.read(firestoreScheduleRepositoryProvider).calculateRounds(
    //         //                           experimentDocId: widget.experimentDocId,
    //         //                         );
    //         //
    //         //                 // show error if it was not a success
    //         //                 if (success == false && context.mounted) {
    //         //                   ScaffoldMessenger.of(context).showSnackBar(
    //         //                     SnackBar(
    //         //                       backgroundColor: ColorPalette().snackBarError,
    //         //                       content:
    //         //                           const Text('An error occurred while calculating schedule.'),
    //         //                     ),
    //         //                   );
    //         //                 }
    //         //
    //         //                 setState(() {
    //         //                   isCalculating = false;
    //         //                 });
    //         //               },
    //         //         child: const Text('Create Schedule'),
    //         //       ),
    //         //     ),
    //         //     Expanded(
    //         //       child: isCalculating
    //         //           ? const Center(
    //         //               child: CircularProgressIndicator(),
    //         //             )
    //         //           : Center(
    //         //               child: ListView.builder(
    //         //                 itemCount: schedule.rounds.length,
    //         //                 itemBuilder: (context, index) {
    //         //                   final currentRound = schedule.rounds[index];
    //         //                   final currentListOfGames = currentRound.games;
    //         //                   final currentPausingPlayers = currentRound.pausingPlayers;
    //         //
    //         //                   final listOfTableTexts = currentListOfGames
    //         //                       .map((game) => Text('Table ${game.tableNumber.toString()}: '
    //         //                           '${game.playerPair.first} - ${game.playerPair.last}'))
    //         //                       .toList();
    //         //                   final textOfPausingPlayers =
    //         //                       Text('Pausing: ${currentPausingPlayers.join(', ')}');
    //         //                   return Card(
    //         //                     child: ListTile(
    //         //                       title: Text('Round ${currentRound.roundNumber.toString()} :'),
    //         //                       subtitle: Column(
    //         //                         children: [
    //         //                           ...listOfTableTexts,
    //         //                           if (currentPausingPlayers.isNotEmpty) textOfPausingPlayers
    //         //                         ],
    //         //                       ),
    //         //                     ),
    //         //                   );
    //         //                 },
    //         //               ),
    //         //             ),
    //         //     ),
    //         //   ],
    //         // );
    //       } catch (e) {
    //         debugPrint(e.toString());
    //         return Text(e.toString());
    //       }
    //     });
  }
}
