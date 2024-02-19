import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/experiments/presentation/widgets/app_bar.dart';
import 'package:pencil_game_admin/features/experiments/presentation/widgets/user_count_widget.dart';
import 'package:pencil_game_admin/features/tables/data/firestore_table_repository.dart';

import '../../../style/color_palette.dart';
import '../../experiments/domain/experiment.dart';
import '../../user/presentation/add_user_screen.dart';

class TablesScreen extends ConsumerWidget {
  const TablesScreen({
    super.key,
    required this.experiment,
    required this.docId,
  });

  final Experiment experiment;
  final String docId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: ColorPalette().background,
      appBar: const CustomAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 10),
          SizedBox(
            height: 30,
            child: Text('${experiment.name} - ${experiment.location}'),
          ),
          SizedBox(
            height: 30,
            child: UserCountWidget(experimentDocId: docId),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await ref
                      .read(firestoreTableRepositoryProvider)
                      .removeTable(experimentDocId: docId);
                },
                child: const Text('REMOVE TABLE'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(firestoreTableRepositoryProvider).addTable(experimentDocId: docId);
                },
                child: const Text('ADD TABLE'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return AddUserScreen(
                          experiment: experiment,
                          docId: docId,
                        );
                      },
                    ),
                  );
                },
                child: const Text('ADD USERS'),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Expanded(
            child: Container(
              color: Colors.yellow,
              child: FirestoreListView.separated(
                query: ref
                    .read(firestoreTableRepositoryProvider)
                    .getTablesOfExperimentQuery(experimentDocId: docId),
                itemBuilder: (context, snapshot) {
                  final tableNumber = int.parse(snapshot.id);
                  return Container(
                    height: 75,
                    color: Colors.blue,
                    child: Text('Table $tableNumber'),
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 20);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
