import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../style/color_palette.dart';
import '../../authorize/data/firebase_auth_instance_provider.dart';
import '../data/firestore_experiment_repository.dart';

final _formKey = GlobalKey<FormState>();

class JoinExperimentDialog extends StatefulWidget {
  const JoinExperimentDialog({super.key});

  @override
  State<JoinExperimentDialog> createState() => _JoinExperimentDialogState();
}

class _JoinExperimentDialogState extends State<JoinExperimentDialog> {
  final experimentCodeController = TextEditingController();
  bool buttonIsActive = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AlertDialog(
        title: const Text('Join Experiment'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: experimentCodeController,
            maxLength: 6,
            keyboardType: TextInputType.text,
            style: const TextStyle(fontSize: 35),
            inputFormatters: [UpperCaseTextFormatter()],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter experiment code';
              }
              if (value.length != 6) {
                return 'Please enter 6 letter code';
              }
              return null;
            },
            decoration: const InputDecoration(
              hintText: 'e.g. ABTEXU',
              labelText: 'Experiment Code',
              //icon: Icon(Icons.person),
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: !buttonIsActive
                ? null
                : () {
                    Navigator.of(context).pop();
                  },
            child: const Text('cancel'),
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
                          // get code from input
                          final shareCode = experimentCodeController.text;

                          // try to join experiment via a share code
                          final status = await ref
                              .read(firestoreExperimentRepositoryProvider)
                              .tryToJoinExperiment(
                                code: shareCode,
                                uid: ref.watch(firebaseAuthInstanceProvider).currentUser?.uid,
                              );

                          // handle the result of trying to join
                          if (context.mounted) {
                            switch (status) {
                              // show error when code was not found
                              case JoinStatus.notFound:
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: ColorPalette().snackBarError,
                                      content:
                                          Text('Could not find experiment with code $shareCode.'),
                                    ),
                                  );
                                  setState(() => buttonIsActive = true);
                                  return;
                                }
                              // show warning when user is already admin
                              case JoinStatus.alreadyAdmin:
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: ColorPalette().snackBarWarning,
                                      content: const Text(
                                          'You are already an admin for this experiment.'),
                                    ),
                                  );
                                  setState(() => buttonIsActive = true);
                                  return;
                                }
                              // show error when an error occurred while trying to join
                              case JoinStatus.error:
                                {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: ColorPalette().snackBarError,
                                      content: Text(
                                          'Error - could not join experiment with code $shareCode.'),
                                    ),
                                  );
                                  setState(() => buttonIsActive = true);
                                  return;
                                }
                              // close window if user joined successfully
                              case JoinStatus.success:
                                {
                                  Navigator.of(context).pop();
                                  return;
                                }
                            }
                          }

                          // final experimentToJoinDocSnap = await ref
                          //     .read(firestoreRepositoryProvider)
                          //     .getExperimentByCode(shareCode);
                          //
                          // // experiment with code could not be found, show error
                          // if (!experimentToJoinDocSnap.exists ||
                          //     experimentToJoinDocSnap.data() == null) {
                          //   if (context.mounted) {
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBar(
                          //         backgroundColor: ColorPalette().snackBarError,
                          //         content: Text('Could not find experiment with code $shareCode.'),
                          //       ),
                          //     );
                          //   }
                          //   setState(() {
                          //     buttonIsActive = true;
                          //   });
                          //   return;
                          // }
                          //
                          // // a code was found, get experiment data
                          // final experimentToJoin =
                          //     Experiment.fromJson(experimentToJoinDocSnap.data()!);
                          // final uid = ref.watch(firebaseAuthProvider).currentUser?.uid;
                          //
                          // // if uid is already in experiment show warning and don't join
                          // if (experimentToJoin.sharedWithUIDList.contains(uid)) {
                          //   if (context.mounted) {
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBar(
                          //         backgroundColor: ColorPalette().snackBarWarning,
                          //         content:
                          //             const Text('You are already an admin for this experiment.'),
                          //       ),
                          //     );
                          //   }
                          //   setState(() {
                          //     buttonIsActive = true;
                          //   });
                          //   return;
                          // }
                          //
                          // // if uid is not yet in experiment, join it
                          // final experimentDocRef = experimentToJoinDocSnap.reference;
                          //
                          // // Update the document
                          // try {
                          //   FieldPath arrayFieldPath = FieldPath(const [sharedAdminListName]);
                          //   await experimentDocRef.update({
                          //     arrayFieldPath: FieldValue.arrayUnion([uid]),
                          //   });
                          //   if (context.mounted) {
                          //     Navigator.of(context).pop();
                          //     return;
                          //   }
                          // } catch (e) {
                          //   if (context.mounted) {
                          //     ScaffoldMessenger.of(context).showSnackBar(
                          //       SnackBar(
                          //         backgroundColor: ColorPalette().snackBarError,
                          //         content: Text(
                          //             'Error - could not join experiment with code $shareCode.'),
                          //       ),
                          //     );
                          //     return;
                          //   }
                          // }
                          //
                          // setState(() {
                          //   buttonIsActive = true;
                          // });
                        }
                      },
                child: const Text('join'),
              );
            },
          ),
        ],
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
