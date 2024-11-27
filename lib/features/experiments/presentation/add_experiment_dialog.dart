import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/experiments/application/experiment_service.dart';
import 'package:pencil_game_admin/features/experiments/domain/experiment.dart';
import 'package:pencil_game_admin/style/color_palette.dart';

import '../../authorize/data/firebase_auth_instance_provider.dart';

final _formKey = GlobalKey<FormState>();

class AddExperimentDialog extends StatefulWidget {
  const AddExperimentDialog({super.key});

  @override
  State<AddExperimentDialog> createState() => _AddExperimentDialogState();
}

class _AddExperimentDialogState extends State<AddExperimentDialog> {
  final nameController = TextEditingController();
  final locationController = TextEditingController();
  Treatment? selectedTreatment;
  bool buttonIsActive = true;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    locationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //title: Text('Add Experiment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter experiment details',
              style: TextStyle(fontSize: 25),
            ),
            const SizedBox(height: 30),
            TextFormField(
              controller: nameController,
              maxLength: 30,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter experiment name';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'e.g. Pen Experiment Fall 2024',
                labelText: 'Experiment Name',
                //icon: Icon(Icons.person),
              ),
            ),
            TextFormField(
              controller: locationController,
              maxLength: 30,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'e.g. USFCA',
                labelText: 'Experiment Location',
                //icon: Icon(Icons.person),
              ),
            ),
            DropdownButtonFormField<Treatment>(
              value: selectedTreatment,
              onChanged: (Treatment? newValue) {
                setState(() {
                  selectedTreatment = newValue;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a treatment';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'select a treatment',
                labelText: 'Experiment Treatment',
                //icon: Icon(Icons.person),
              ),
              items: Treatment.values.map((Treatment treatment) {
                return DropdownMenuItem<Treatment>(
                  value: treatment,
                  child: Text(
                    treatment.name,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: !buttonIsActive
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        Consumer(
          builder: (context, ref, child) {
            return ElevatedButton(
              onPressed: !buttonIsActive
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          buttonIsActive = false;
                        });
                        final experimentName = nameController.text;
                        final experimentLocation = locationController.text;
                        try {
                          await ref
                              .read(experimentServiceProvider)
                              .addNewExperiment(
                                experimentName: experimentName,
                                experimentLocation: experimentLocation,
                                treatment: selectedTreatment!,
                                adminUid: ref
                                    .read(firebaseAuthInstanceProvider)
                                    .currentUser!
                                    .uid,
                                showSurvey: false,
                              );
                        } catch (error) {
                          debugPrint(error.toString());
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: ColorPalette().snackBarError,
                                content: const Text(
                                    'An error occurred while trying to create a new experiment.'),
                              ),
                            );
                          }
                        }

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
              child: const Text('Add'),
            );
          },
        ),
      ],
    );
  }

  // Future<void> addExperiment(
  //     String experimentName, String experimentLocation, String experimentTableCount) async {
  //   // Reference to the Firestore collection
  //   CollectionReference collectionRef = FirebaseFirestore.instance.collection('experiments');
  //   // Use a transaction to handle the race condition
  //   await FirebaseFirestore.instance.runTransaction((transaction) async {
  //     // Get the last added document
  //     QuerySnapshot querySnapshot =
  //         await collectionRef.orderBy('createdOn', descending: true).limit(1).get();
  //
  //     // Determine the new ID
  //     int newId = 1; // Default value if no documents exist
  //     if (querySnapshot.docs.isNotEmpty) {
  //       newId = querySnapshot.docs.first['experimentID'] + 1;
  //     }
  //
  //     final uid = FirebaseAuth.instance.currentUser!.uid;
  //
  //     final newExp = Experiment(
  //       experimentID: newId,
  //       name: experimentName,
  //       location: experimentLocation,
  //       createdByUID: uid,
  //       createdOn: DateTime.now(),
  //       tableCount: int.parse(experimentTableCount),
  //       status: ExperimentStatus.scheduled,
  //       sharedWithUIDList: [uid],
  //     );
  //
  //     final experimentMap = newExp.toJson();
  //
  //     // Add a new document with the incremented ID
  //     collectionRef.add(experimentMap);
  //   });
  // }
}
