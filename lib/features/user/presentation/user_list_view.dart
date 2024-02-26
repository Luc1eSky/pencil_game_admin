import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/firestore_user_repository.dart';

class UserListView extends ConsumerWidget {
  const UserListView({super.key, required this.experimentDocId});

  final String experimentDocId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: FirestoreListView.separated(
        query: ref.read(firestoreUserRepositoryProvider).getUsersQuery(experimentDocId),
        errorBuilder: (context, error, stacktrace) => Text('Error: $error'),
        itemBuilder: (context, docSnap) {
          final user = docSnap.data();
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              leading: Text(
                user.colorCode,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              title: Text(
                '${user.firstName} ${user.lastName}',
                style: const TextStyle(fontSize: 18),
              ),
              trailing: Text(
                DateFormat('MM-dd-yyyy\nhh:mm a').format(user.createdOn),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(height: 10),
      ),
    );
  }
}
