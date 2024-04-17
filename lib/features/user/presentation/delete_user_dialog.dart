import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/user/data/firestore_user_repository.dart';
import 'package:pencil_game_admin/features/user/domain/app_user.dart';

class DeleteUserDialog extends StatelessWidget {
  const DeleteUserDialog({
    super.key,
    required this.user,
    required this.experimentDocId,
  });

  final AppUser user;
  final String experimentDocId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete User'),
      content: Text('Delete user ${user.firstName} (${user.colorCode})?'),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('cancel'),
        ),
        Consumer(
          builder: (context, ref, child) {
            return ElevatedButton(
              onPressed: () async {
                await ref.read(firestoreUserRepositoryProvider).deleteUser(
                      experimentDocId: experimentDocId,
                      user: user,
                    );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('yes'),
            );
          },
        )
      ],
    );
  }
}
