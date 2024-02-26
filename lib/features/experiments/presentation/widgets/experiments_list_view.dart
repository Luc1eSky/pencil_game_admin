import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/admin/data/firestore_admin_repository.dart';

import '../../../../constants.dart';
import '../../../authorize/data/firebase_auth_instance_provider.dart';
import '../../domain/experiment.dart';
import 'experiment_card.dart';

class ExperimentsListView extends ConsumerStatefulWidget {
  const ExperimentsListView({super.key});

  @override
  ConsumerState<ExperimentsListView> createState() => _ExperimentsListViewState();
}

class _ExperimentsListViewState extends ConsumerState<ExperimentsListView> {
  int retries = 0;

  void retryAfterError() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      retries++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = ref.watch(firebaseAuthInstanceProvider);

    return StreamBuilder(
        stream: ref
            .read(firestoreAdminRepositoryProvider)
            .getAdminQuery(firebaseAuth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error} Try to reload page.');
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            //snapshot.data!.docs.isEmpty) {
            return const Text('Admin does not exist');
          }

          // Access the array field from the document
          List<dynamic> experimentNames =
              snapshot.data!['experiments']; //.docs.first['experiments'];
          // convert to list of Strings
          List<String> experimentNameStrings = experimentNames.map((e) => e.toString()).toList();

          return experimentNameStrings.isEmpty
              ? Container()
              : StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(experimentCollectionName)
                      .where(FieldPath.documentId, whereIn: experimentNameStrings)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      if (retries < 3) {
                        retryAfterError();
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        return Text('Error: ${snapshot.error}. Try to reload page.');
                      }
                    }

                    retries = 0;
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('No documents found');
                    }

                    // get unsorted lists of experiments and document IDs
                    final listOfExperiments =
                        snapshot.data!.docs.map((doc) => Experiment.fromJson(doc.data())).toList();
                    final listOfDocIds = snapshot.data!.docs.map((doc) => doc.id).toList();

                    // sort both lists by createOn timestamp
                    final (sortedExperimentList, sortedIdList) = sortLists(
                      listOfExperiments: listOfExperiments,
                      listOfDocIds: listOfDocIds,
                    );

                    return ListView.separated(
                      itemCount: listOfDocIds.length,
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 20);
                      },
                      itemBuilder: (context, index) {
                        return ExperimentCard(
                          experiment: sortedExperimentList[index],
                          docId: sortedIdList[index],
                        );
                      },
                    );
                  },
                );

          // return FirestoreListView<Experiment>.separated(
          //   query: firestoreRepository.getExperimentsOfAdminQuery(
          //       listOfExperimentDocs: experimentNameStrings),
          //   errorBuilder: (context, error, stacktrace) {
          //     if (retries < 3) {
          //       retryAfterError();
          //       return const Center(child: CircularProgressIndicator());
          //     } else {
          //       return Text('Error: ${snapshot.error}');
          //     }
          //   },
          //   itemBuilder: (context, doc) {
          //     final experiment = doc.data();
          //     return ExperimentCard(experiment: experiment, docId: doc.id);
          //   },
          //   separatorBuilder: (context, index) {
          //     return const SizedBox(height: 20);
          //   },
          // );
        });
  }
}

(List<Experiment>, List<String>) sortLists({
  required List<Experiment> listOfExperiments,
  required List<String> listOfDocIds,
}) {
  // combine both lists via a map for each entry
  List<Map<String, dynamic>> combinedList = [];
  for (int i = 0; i < listOfExperiments.length; i++) {
    combinedList.add({'experiment': listOfExperiments[i], 'docId': listOfDocIds[i]});
  }

  // sort list of combined maps (descending by createdOn timestamp)
  combinedList.sort(
    (a, b) => (b['experiment'] as Experiment)
        .createdOn
        .compareTo((a['experiment'] as Experiment).createdOn),
  );

  // get individual lists that are sorted
  List<Experiment> sortedExperiments =
      combinedList.map((map) => map['experiment'] as Experiment).toList();
  List<String> sortedIds = combinedList.map((map) => map['docId'] as String).toList();

  // return lists as a record
  return (sortedExperiments, sortedIds);
}
