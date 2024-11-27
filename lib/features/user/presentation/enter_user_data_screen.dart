import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/user/data/firestore_user_repository.dart';
import 'package:pencil_game_admin/features/user/presentation/qr_code_screen.dart';

import '../../../style/color_palette.dart';
import '../../experiments/domain/experiment.dart';

final _formKey = GlobalKey<FormState>();

class EnterUserDataScreen extends StatefulWidget {
  const EnterUserDataScreen({
    super.key,
    required this.experiment,
    required this.experimentDocId,
  });

  final Experiment experiment;
  final String experimentDocId;

  @override
  State<EnterUserDataScreen> createState() => _EnterUserDataScreenState();
}

class _EnterUserDataScreenState extends State<EnterUserDataScreen> {
  final firstNameController = TextEditingController();
  bool buttonIsActive = true;

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette().userLoginBackground,
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: FittedBox(
                child: Text(
                  '${widget.experiment.name} - ${widget.experiment.location}',
                  style: const TextStyle(fontSize: 100),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Stack(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Please enter your name',
                              style: TextStyle(
                                fontSize: 30,
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              controller: firstNameController,
                              maxLength: 30,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                              decoration: const InputDecoration(
                                hintText: 'Enter first name',
                                labelText: 'First Name',
                                //icon: Icon(Icons.person),
                              ),
                            ),
                            // TextFormField(
                            //   controller: lastNameController,
                            //   maxLength: 30,
                            //   validator: (value) {
                            //     if (value == null || value.isEmpty) {
                            //       return 'Please enter your last name';
                            //     }
                            //     return null;
                            //   },
                            //   decoration: const InputDecoration(
                            //     hintText: 'Enter last name',
                            //     labelText: 'Last Name',
                            //     //icon: Icon(Icons.person),
                            //   ),
                            // ),
                            // const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: !buttonIsActive
                                      ? null
                                      : () {
                                          Navigator.of(context).pop();
                                        },
                                  child: const Text('Cancel'),
                                ),
                                const SizedBox(width: 20),
                                Consumer(
                                  builder: (context, ref, child) {
                                    return ElevatedButton(
                                      onPressed: !buttonIsActive
                                          ? null
                                          : () async {
                                              // only proceed if form entries are valid
                                              if (!_formKey.currentState!
                                                  .validate()) {
                                                return;
                                              }
                                              // deactivate buttons to prevent multiple clicks
                                              setState(
                                                  () => buttonIsActive = false);

                                              // try to create share code
                                              try {
                                                final userShareCode = await ref
                                                    .read(
                                                        firestoreUserRepositoryProvider)
                                                    .createUserShareCodeEntry(
                                                      experimentDocId: widget
                                                          .experimentDocId,
                                                      firstName:
                                                          firstNameController
                                                              .text,
                                                    );
                                                if (userShareCode == null) {
                                                  throw 'Could not create share code.';
                                                }
                                                // if successful move to QR code screen
                                                if (context.mounted) {
                                                  Navigator.of(context)
                                                      .pushReplacement(
                                                    MaterialPageRoute(
                                                      builder: (context) {
                                                        return QrCodeScreen(
                                                          userShareCode:
                                                              userShareCode,
                                                        );
                                                      },
                                                    ),
                                                  );
                                                  return;
                                                }
                                              }
                                              // if an error occurs: show error, activate buttons
                                              // and allow retry
                                              catch (error) {
                                                debugPrint(
                                                    'Error while trying to create user '
                                                    'share code entry.');
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          ColorPalette()
                                                              .snackBarError,
                                                      content: const Text(
                                                        'Error while trying to create user '
                                                        'share code.',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }

                                              setState(
                                                  () => buttonIsActive = true);
                                            },
                                      child: const Text('Submit'),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // while loading show loading indicator and prevent click
                      if (!buttonIsActive)
                        Container(
                          color: Colors.transparent,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
