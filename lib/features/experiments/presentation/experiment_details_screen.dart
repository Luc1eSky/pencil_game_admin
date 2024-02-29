import 'package:flutter/material.dart';
import 'package:pencil_game_admin/constants.dart';
import 'package:pencil_game_admin/features/experiments/presentation/widgets/app_bar.dart';
import 'package:pencil_game_admin/features/schedule/presentation/schedule_screen.dart';
import 'package:pencil_game_admin/features/tables/presentation/tables_screen.dart';

import '../../../style/color_palette.dart';
import '../../user/presentation/add_user_screen.dart';
import '../../user/presentation/user_list_view.dart';
import '../domain/experiment.dart';

class ExperimentDetailsScreen extends StatefulWidget {
  const ExperimentDetailsScreen({super.key, required this.experiment, required this.docId});
  final Experiment experiment;
  final String docId;

  @override
  State<ExperimentDetailsScreen> createState() => _ExperimentDetailsScreenState();
}

class _ExperimentDetailsScreenState extends State<ExperimentDetailsScreen> {
  int pageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette().background,
      appBar: CustomAppBar(text: widget.experiment.name),
      bottomNavigationBar: NavigationBar(
        backgroundColor: ColorPalette().appBarBackground,
        indicatorColor: ColorPalette().appBarIndicator,
        onDestinationSelected: (index) {
          // for second entry, go to add user screen
          if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return AddUserScreen(
                    experiment: widget.experiment,
                    docId: widget.docId,
                  );
                },
              ),
            );
          } else {
            setState(() {
              pageIndex = index;
            });
          }
        },
        //indicatorColor: Colors.green,
        selectedIndex: pageIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.social_distance), label: 'Live View'),
          NavigationDestination(icon: Icon(Icons.schedule), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.group), label: 'Users'),
          NavigationDestination(icon: Icon(Icons.person_add), label: 'Add User'),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: cardMaxWidth),
          child: [
            TablesScreen(docId: widget.docId),
            ScheduleScreen(experimentDocId: widget.docId),
            UserListView(experimentDocId: widget.docId),
            Container(),
          ][pageIndex],
        ),
      ),
    );
  }
}
