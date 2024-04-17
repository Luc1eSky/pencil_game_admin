import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/constants.dart';

import '../../../style/color_palette.dart';
import '../../authorize/data/firebase_auth_instance_provider.dart';
import 'add_experiment_dialog.dart';
import 'join_experiment_dialog.dart';
import 'new_or_join_dialog.dart';
import 'widgets/app_bar.dart';
import 'widgets/experiments_list_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette().background,
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: FittedBox(
                      child: Consumer(
                        builder: (context, ref, child) {
                          return Text(
                            'Hello, ${ref.watch(firebaseAuthInstanceProvider).currentUser!.displayName}',
                            style: const TextStyle(fontSize: 50),
                          );
                        },
                      ),
                    ),
                  ),
                  FittedBox(
                    child: IconButton(
                      icon: const Icon(
                        Icons.person,
                        size: 70,
                      ),
                      onPressed: () {
                        print('pressed');
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: cardMaxWidth,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: ExperimentsListView(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          return FloatingActionButton(
            backgroundColor: ColorPalette().floatingActionButton,
            onPressed: () async {
              // await ref.read(firebaseAuthInstanceProvider).currentUser!.getIdToken(true);
              // // TODO: CHECK IF ADMIN EXISTS?
              // print(ref.read(firebaseAuthInstanceProvider).currentUser!.emailVerified);
              // final uid = ref.watch(firebaseAuthInstanceProvider).currentUser!.uid;
              // ref.read(firestoreAdminRepositoryProvider).createAdmin(
              //       adminUid: uid,
              //       firstName: 'TestName',
              //       lastName: 'LastName',
              //     );

              // show dialog to choose join vs new
              final result = await showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return const NewOrJoinDialog(); //const AddExperimentDialog();
                },
              );
              // if new was selected open add experiment dialog
              if (result == 'new' && context.mounted) {
                await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return const AddExperimentDialog();
                  },
                );
              }
              // if new was selected open join experiment dialog
              if (result == 'join' && context.mounted) {
                await showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return const JoinExperimentDialog();
                  },
                );
              }
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
