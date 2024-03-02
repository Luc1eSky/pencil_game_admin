import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../progress/data/firestore_progress_repository.dart';
import '../../progress/domain/experiment_progress.dart';
import '../../user/domain/app_user.dart';
import '../data/firestore_table_repository.dart';

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
                final tableDocRef = docSnap.reference;

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
                                user: firstUser,
                                userIsPresent: table.firstUserIsPresent,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(),
                            ),
                            Expanded(
                              flex: 4,
                              child: TablePlayerWidget(
                                user: secondUser,
                                userIsPresent: table.secondUserIsPresent,
                              ),
                            ),
                          ],
                        ),
                        if (table.firstUserIsPresent || table.secondUserIsPresent)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await ref
                                        .read(firestoreTableRepositoryProvider)
                                        .removePlayersFromTable(tableDocRef);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                if (table.hasCorrectUsers)
                                  ElevatedButton(
                                    onPressed: () {},
                                    child: const Text('Start'),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
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

class TablePlayerWidget extends StatelessWidget {
  const TablePlayerWidget({
    super.key,
    required this.user,
    required this.userIsPresent,
  });

  final AppUser user;
  final bool userIsPresent;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: userIsPresent ? Colors.green : Colors.grey,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            FittedBox(
              child: Text(
                user.colorCode,
                style: const TextStyle(
                  fontSize: 24,
                  //fontWeight: FontWeight.bold,
                ),
              ),
            ),
            FittedBox(
              child: Text(
                user.shortNameString,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
