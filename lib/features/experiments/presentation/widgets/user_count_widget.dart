import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/experiments/data/firestore_experiment_repository.dart';

import '../../domain/experiment.dart';

class UserCountWidget extends ConsumerWidget {
  const UserCountWidget({super.key, required this.experimentDocId});
  final String experimentDocId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder(
        stream:
            ref.read(firestoreExperimentRepositoryProvider).getExperimentStream(experimentDocId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container();
          }
          if (!snapshot.hasData) {
            return Container();
          }
          final experiment = Experiment.fromJson(snapshot.data!.data()!);
          return const Text('Users: 0'); // ${experiment.userCount.toString()}');
          // TODO: UPDATE TO READ FROM SCHEDULE
        });
  }
}
