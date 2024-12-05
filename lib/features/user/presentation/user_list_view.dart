import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pencil_game_admin/features/progress/data/firestore_progress_repository.dart';

import '../../progress/domain/experiment_progress.dart';
import '../data/firestore_user_repository.dart';
import 'delete_user_dialog.dart';

class UserListView extends ConsumerWidget {
  const UserListView({super.key, required this.experimentDocId});

  final String experimentDocId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
        stream: ref
            .read(firestoreProgressRepositoryProvider)
            .getProgressDocStream(experimentDocId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Progress doc snapshot error.!');
            return const Text('Progress doc snapshot error.');
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          ExperimentProgress progress;
          try {
            progress = snapshot.data!.data()!;
          } catch (e) {
            return const Text('Progress object conversion error.');
          }
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: FirestoreListView.separated(
              query: ref
                  .read(firestoreUserRepositoryProvider)
                  .getUsersQuery(experimentDocId),
              errorBuilder: (context, error, stacktrace) =>
                  Text('Error: $error'),
              itemBuilder: (context, docSnap) {
                final user = docSnap.data();
                return Card(
                  color: (user.surveySubmitted == true)
                      ? Colors.green
                      : Colors.grey,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    leading: Text(
                      user.colorCode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          user.firstName,
                          style: const TextStyle(fontSize: 18),
                        ),
                        Text(
                          DateFormat('MM-dd-yy\nhh:mm a')
                              .format(user.createdOn),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: !progress.canCreateSchedule
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (context) => DeleteUserDialog(
                                  user: user,
                                  experimentDocId: experimentDocId,
                                ),
                              );
                            },
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 10),
            ),
          );
        });
  }
}
