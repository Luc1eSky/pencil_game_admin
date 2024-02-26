import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/schedule/data/firestore_schedule_repository.dart';
import 'package:pencil_game_admin/style/color_palette.dart';

import '../domain/schedule.dart';
import 'widgets/count_incrementer.dart';
import 'widgets/parameter_count_widget.dart';

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

    return StreamBuilder(
        stream:
            ref.read(firestoreScheduleRepositoryProvider).getScheduleStream(widget.experimentDocId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Snapshot error!');
            return const Text('error');
          }
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }
          int userCount;
          int tableCount;
          int numberOfRounds;
          try {
            final schedule = Schedule.fromJson(snapshot.data!.data()!);
            userCount = schedule.userCount;
            tableCount = schedule.tableCount;
            numberOfRounds = schedule.numberOfRounds;

            return Column(
              children: [
                SizedBox(
                  height: 100,
                  child: Row(
                    children: [
                      Expanded(
                        child: ParameterCountWidget(
                          text: 'Users',
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
                          child: CountIncrementer(
                            isBlocked: isCalculating,
                            count: tableCount,
                            subtract: getCountChangeMethod(widget.experimentDocId, subtract: true),
                            add: getCountChangeMethod(widget.experimentDocId),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ParameterCountWidget(
                          text: 'Rounds',
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
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ElevatedButton(
                    onPressed: isCalculating
                        ? null
                        : () async {
                            setState(() {
                              isCalculating = true;
                            });
                            //await Future.delayed(const Duration(milliseconds: 2000));
                            // returns a bool to see if it was successful and a
                            final success =
                                await ref.read(firestoreScheduleRepositoryProvider).calculateRounds(
                                      experimentDocId: widget.experimentDocId,
                                    );

                            // show error if it was not a success
                            if (success == false && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: ColorPalette().snackBarError,
                                  content:
                                      const Text('An error occurred while calculating schedule.'),
                                ),
                              );
                            }

                            setState(() {
                              isCalculating = false;
                            });
                          },
                    child: const Text('Create Schedule'),
                  ),
                ),
                Expanded(
                  child: isCalculating
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Center(
                          child: ListView.builder(
                            itemCount: schedule.rounds.length,
                            itemBuilder: (context, index) {
                              final currentRound = schedule.rounds[index];
                              final currentListOfGames = currentRound.games;
                              final currentPausingPlayers = currentRound.pausingPlayers;

                              final listOfTableTexts = currentListOfGames
                                  .map((game) => Text('Table ${game.tableNumber.toString()}: '
                                      '${game.playerPair.first} - ${game.playerPair.last}'))
                                  .toList();
                              final textOfPausingPlayers =
                                  Text('Pausing: ${currentPausingPlayers.join(', ')}');
                              return Card(
                                child: ListTile(
                                  title: Text('Round ${currentRound.roundNumber.toString()} :'),
                                  subtitle: Column(
                                    children: [
                                      ...listOfTableTexts,
                                      if (currentPausingPlayers.isNotEmpty) textOfPausingPlayers
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            );
          } catch (e) {
            debugPrint(e.toString());
            return Text(e.toString());
          }
        });
  }
}
