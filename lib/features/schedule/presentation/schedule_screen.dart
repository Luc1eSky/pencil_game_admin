import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/schedule/application/schedule_service.dart';
import 'package:pencil_game_admin/features/tables/data/firestore_results_repository.dart';

import '../../../style/color_palette.dart';
import '../../progress/data/firestore_progress_repository.dart';
import '../../progress/domain/experiment_progress.dart';
import '../../progress/presentation/lock_schedule_switch.dart';
import '../data/firestore_schedule_repository.dart';
import '../domain/schedule.dart';
import '../domain/schedule_parameters.dart';
import '../presentation/widgets/count_incrementer.dart';
import '../presentation/widgets/parameter_count_widget.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key, required this.experimentDocId});

  final String experimentDocId;

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  bool isCalculating = false;
  bool isExporting = false;

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
          ref.read(firestoreScheduleRepositoryProvider).getParameterStream(widget.experimentDocId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Snapshot error ${snapshot.error.toString()}');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        ScheduleParameters parameters;
        try {
          // create parameter object from data
          parameters = snapshot.data!.data()!;
        } catch (e) {
          return Text('Parameter object error: $e');
        }

        // get last input values and check if anything has changed
        final userCount = parameters.userCount;
        final userCountHasChanged = parameters.userCountHasChanged;
        final tableCount = parameters.tableCount;
        final tableCountHasChanged = parameters.tableCountHasChanged;
        final numberOfRounds = parameters.numberOfRounds;
        final numberOfRoundsHasChanged = parameters.numberOfRoundsHasChanged;

        return StreamBuilder(
          stream: ref
              .read(firestoreProgressRepositoryProvider)
              .getProgressDocStream(widget.experimentDocId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Snapshot error ${snapshot.error.toString()}');
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            ExperimentProgress progress;
            try {
              progress = snapshot.data!.data()!;
            } catch (e) {
              return Text('Progress conversion error: $e');
            }
            //return Container();
            final buttonsAreActive = !isCalculating && progress.canCreateSchedule;

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
                            isActive: buttonsAreActive,
                            count: tableCount,
                            subtract: getCountChangeMethod(widget.experimentDocId, subtract: true),
                            add: getCountChangeMethod(widget.experimentDocId),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ParameterCountWidget(
                          text: 'Rounds',
                          hasChanged: numberOfRoundsHasChanged,
                          child: CountIncrementer(
                            isActive: buttonsAreActive,
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
                Row(
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
                                  await ref
                                      .read(scheduleServiceProvider)
                                      .createSchedule(experimentDocId: widget.experimentDocId);
                                } catch (error) {
                                  print(error);
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
                    LockScheduleSwitch(experimentDocId: widget.experimentDocId),
                    if (progress.status == ExperimentProgressStatus.surveyLinkDisplayed)
                      ElevatedButton(
                        onPressed: isExporting
                            ? null
                            : () async {
                                setState(() {
                                  isExporting = true;
                                });

                                await ref
                                    .read(firestoreResultsRepositoryProvider)
                                    .exportToExcel(experimentDocId: widget.experimentDocId);
                                setState(() {
                                  isExporting = false;
                                });
                              },
                        child: const Text('Export Data'),
                      ),
                  ],
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: ref
                        .read(firestoreScheduleRepositoryProvider)
                        .getScheduleStream(widget.experimentDocId),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('Snapshot error ${snapshot.error.toString()}');
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      Schedule schedule;
                      try {
                        // create schedule object from data
                        schedule = snapshot.data!.data()!;
                      } catch (e) {
                        return Text('Schedule conversion error: $e');
                      }
                      final rounds = schedule.rounds;

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
                                        g.assignedUsers.map((p) => p.colorCode).join(' - ');
                                    return Text(
                                      'Table ${g.tableNumber}: $colorPairString',
                                      style: const TextStyle(fontSize: 16),
                                    );
                                  }).toList();
                                  final pausingPlayersString =
                                      round.pausingUsers.map((p) => p.colorCode).toSet().join(', ');
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      side: progress.currentRoundNumber == round.roundNumber
                                          ? const BorderSide(
                                              color: Colors.black,
                                              width: 2.0,
                                            )
                                          : BorderSide.none,
                                    ),
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
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
