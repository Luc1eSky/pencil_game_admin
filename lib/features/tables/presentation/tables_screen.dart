import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../progress/data/firestore_progress_repository.dart';
import '../../progress/domain/experiment_progress.dart';
import '../data/realtime_database_repository.dart';
import '../domain/realtime_table.dart';
import 'widgets/table_card.dart';

class TablesScreen extends ConsumerWidget {
  const TablesScreen({
    super.key,
    required this.experimentDocId,
  });

  final String experimentDocId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<DocumentSnapshot<ExperimentProgress>>(
      stream: ref.read(firestoreProgressRepositoryProvider).getProgressDocStream(experimentDocId),
      builder: (context, progressSnap) {
        if (progressSnap.hasError) {
          return Text('Snapshot error ${progressSnap.error.toString()}');
        }
        if (!progressSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        ExperimentProgress progress;
        try {
          progress = progressSnap.data!.data()!;
        } catch (e) {
          return Text('Progress object error: $e');
        }
        return !progress.showLiveView
            ? Container()
            : Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FittedBox(
                          child: Text(
                            'Round: ${progress.currentRoundNumber.toString()}',
                            style: const TextStyle(fontSize: 200),
                          ),
                        ),
                        if (progress.status == ExperimentStatus.roundFinished)
                          Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                print('next round');
                              },
                              child: const Text('Next Round'),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: StreamBuilder(
                        stream: ref
                            .read(realtimeDatabaseRepositoryProvider)
                            .getTablesStream(experimentDocId),
                        builder: (context, realtimeSnap) {
                          if (realtimeSnap.hasError) {
                            return Text('Snapshot error ${realtimeSnap.error.toString()}');
                          }
                          if (!realtimeSnap.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final dataSnap = realtimeSnap.data?.snapshot;
                          if (dataSnap?.value == null) {
                            return const Text('Error - No data!');
                          }

                          List<RealtimeTable> tables;
                          try {
                            // convert list of maps to list of realtime tables
                            tables = dataSnap!.children
                                .map((t) => RealtimeTable.fromJson(t.value as Map<String, dynamic>))
                                .toList();
                          } catch (e) {
                            return Text('Realtime table object error: $e');
                          }

                          return ListView.separated(
                            itemCount: tables.length,
                            itemBuilder: (context, index) {
                              final table = tables[index];
                              return TableCard(
                                table: table,
                                experimentDocId: experimentDocId,
                                progress: progress,
                              );
                            },
                            separatorBuilder: (context, index) => const SizedBox(height: 20),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
      },
    );
  }
}
