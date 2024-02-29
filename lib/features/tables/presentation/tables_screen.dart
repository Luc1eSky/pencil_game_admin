import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/progress/data/firestore_progress_repository.dart';
import 'package:pencil_game_admin/features/progress/domain/experiment_progress.dart';
import 'package:pencil_game_admin/features/tables/data/firestore_table_repository.dart';

class TablesScreen extends ConsumerWidget {
  const TablesScreen({
    super.key,
    required this.docId,
  });

  final String docId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: StreamBuilder(
              stream: ref.read(firestoreProgressRepositoryProvider).getProgressDocStream(docId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Progress doc snapshot error.');
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
                final progress = ExperimentProgress.fromJson(docData);
                return FittedBox(
                  child: Text(
                    'Round: ${progress.currentRoundNumber.toString()}',
                    style: const TextStyle(fontSize: 200),
                  ),
                );
              }),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: FirestoreListView.separated(
              query: ref
                  .read(firestoreTableRepositoryProvider)
                  .getTablesOfExperimentQuery(experimentDocId: docId),
              errorBuilder: (context, error, stacktrace) => Text('Error: $error'),
              itemBuilder: (context, docSnap) {
                final table = docSnap.data();
                final assignedUsers = table.assignedUsers;
                final firstUser = assignedUsers.first;
                final secondUser = assignedUsers.last;

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
                    // title: Text(
                    //   '${firstUser.colorCode} vs. ${secondUser.colorCode} ',
                    //   style: const TextStyle(fontSize: 18),
                    // ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                firstUser.colorCode,
                                style: const TextStyle(fontSize: 25),
                              ),
                              Text(
                                '${firstUser.firstName} ${firstUser.lastName}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                'ready: ${table.firstUserIsPresent}',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                secondUser.colorCode,
                                style: const TextStyle(fontSize: 25),
                              ),
                              Text(
                                '${secondUser.firstName} ${secondUser.lastName}',
                                style: const TextStyle(fontSize: 15),
                              ),
                              Text(
                                'ready: ${table.secondUserIsPresent}',
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // trailing: Text(
                    //   DateFormat('MM-dd-yyyy\nhh:mm a').format(user.createdOn),
                    //   style: const TextStyle(fontSize: 14),
                    // ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
            ),
          ),
        ),
      ],
    );
  }
}
