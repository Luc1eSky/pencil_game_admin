import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/progress/domain/experiment_progress.dart';

import '../../../../constants.dart';
import '../../../progress/data/firestore_progress_repository.dart';
import '../../../user/domain/simple_user.dart';
import '../../data/functions_repository.dart';
import '../../data/realtime_database_repository.dart';
import '../../domain/realtime_table.dart';
import 'pen_indicator.dart';
import 'table_player_widget.dart';

class TableCard extends ConsumerWidget {
  const TableCard({
    super.key,
    required this.table,
    required this.experimentDocId,
    required this.progress,
  });

  final RealtimeTable table;
  final String experimentDocId;
  final ExperimentProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        leading: Text(
          table.tableNumber.toString(),
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TablePlayerWidget(
                    user: table.assignedUsers.first,
                    userIsPresent: table.firstUserIsPresent,
                    status: table.status,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 4,
                  child: TablePlayerWidget(
                    user: table.assignedUsers.last,
                    userIsPresent: table.secondUserIsPresent,
                    status: table.status,
                  ),
                ),
              ],
            ),
            // show buttons only when at least one user is present and table status is waiting
            if ((inDebuggingMode || table.firstUserIsPresent || table.secondUserIsPresent) &&
                table.status == TableStatus.waiting)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // show cancel button
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await ref.read(realtimeDatabaseRepositoryProvider).removeUsersFromTable(
                                experimentDocId: experimentDocId,
                                tableNumber: table.tableNumber,
                              );
                        } catch (e) {
                          //TODO: ERROR HANDLING
                          debugPrint(e.toString());
                        }
                      },
                      child: const Text('Cancel'),
                    ),

                    // show start button if all users are present
                    if (table.hasCorrectUsers || inDebuggingMode)
                      Padding(
                        padding: const EdgeInsets.only(left: 50.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              // TODO: MOVE TO SERVICE
                              // start the table
                              final tableStarted =
                                  await ref.read(realtimeDatabaseRepositoryProvider).startTable(
                                        experimentDocId: experimentDocId,
                                        tableNumber: table.tableNumber,
                                      );
                              // exit if table could not be started
                              if (!tableStarted) {
                                return;
                              }

                              // start cloud function that finishes the game after certain time
                              await ref.read(functionsRepositoryProvider).delayedClosingGame(
                                    experimentDocId: experimentDocId,
                                    tableNumber: table.tableNumber,
                                    waitTimeInSeconds: gameTimeInSeconds + startTimeInSeconds + 1,
                                  );

                              // set progress to indicate a round has started
                              await ref.read(firestoreProgressRepositoryProvider).startRound(
                                    experimentDocId: experimentDocId,
                                    currentStatus: progress.status,
                                  );
                            } catch (e) {
                              //TODO: ERROR HANDLING
                              debugPrint(e.toString());
                            }
                          },
                          child: const Text('Start'),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 20.0),
            // show pen indicator while playing
            //if (table.status == TableStatus.playing)
            SizedBox(
              height: 30,
              child: FractionallySizedBox(
                heightFactor: 1.0,
                child: Row(
                  children: [
                    // TODO: ADD TIMER BACK IN (FIX NULL ERROR!)
                    // Expanded(
                    //   flex: 2,
                    //   child: Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: FittedBox(
                    //       child: TimerWidget(
                    //         experimentDocId: experimentDocId,
                    //         table: table,
                    //         databaseOffset: ref.watch(databaseTimeOffsetRepositoryProvider),
                    //         size: 100,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: 0.9,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            child: NumberCountWidget(
                              table: table,
                              user: table.assignedUsers.first,
                              size: 50,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: PenIndicator(realtimeTable: table),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          child: NumberCountWidget(
                            table: table,
                            user: table.assignedUsers.last,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                    // Expanded(
                    //   flex: 2,
                    //   child: Align(
                    //     alignment: Alignment.centerRight,
                    //     child: Container(
                    //       decoration: const BoxDecoration(
                    //         shape: BoxShape.circle,
                    //         color: Colors.red,
                    //       ),
                    //       child: IconButton(
                    //         color: Colors.white,
                    //         onPressed: () {},
                    //         icon: const FittedBox(
                    //           child: Icon(
                    //             Icons.close,
                    //             size: 50,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NumberCountWidget extends StatelessWidget {
  const NumberCountWidget({
    super.key,
    required this.table,
    required this.user,
    required this.size,
  });

  final RealtimeTable table;
  final SimpleUser user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final totalNumberCount = table.getUsersNumberCopyResult(user)?.numbersCount ?? 0;

    return Text(
      totalNumberCount.toString(),
      style: TextStyle(fontSize: size),
    );
  }
}
