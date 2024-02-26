import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/experiments/presentation/experiment_details_screen.dart';

import '../../../../style/color_palette.dart';
import '../../../authorize/data/firebase_auth_instance_provider.dart';
import '../../domain/experiment.dart';
import '../../domain/experiment_status.dart';
import '../invite_code_dialog.dart';

class ExperimentCard extends ConsumerWidget {
  const ExperimentCard({
    super.key,
    required this.experiment,
    required this.docId,
  });

  final Experiment experiment;
  final String docId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(firebaseAuthInstanceProvider).currentUser?.uid;
    final userIsOwner = experiment.userIsOwner(uid);

    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor:
            userIsOwner ? ColorPalette().experimentCardOwned : ColorPalette().experimentCardShared,
        contentPadding: const EdgeInsets.all(20),
        titleTextStyle: const TextStyle(fontSize: 18),
        leadingAndTrailingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        leading: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Icon(experiment.status.icon),

          //Text(status.name),
        ),
        title: Text(experiment.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location: ${experiment.location}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            //if (shareCoded != null) Text('Invite via code: $shareCoded'),
          ],
        ),
        trailing: !userIsOwner
            ? null
            : IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  if (context.mounted) {
                    await showDialog(
                      //barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return InviteCodeDialog(docId: docId);
                      },
                    );
                  }
                  // check if code already exists
                },
              ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return ExperimentDetailsScreen(experiment: experiment, docId: docId);
                //return TablesScreen(experiment: experiment, docId: docId);
              },
            ),
          );
        },
      ),
    );
  }
}
