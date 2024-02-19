import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/admin/data/firestore_admin_repository.dart';

final _formKey = GlobalKey<FormState>();

class EnterAdminDataScreen extends StatefulWidget {
  const EnterAdminDataScreen({
    super.key,
    required this.user,
    required this.callBackFunction,
  });
  final User user;
  final VoidCallback callBackFunction;

  @override
  State<EnterAdminDataScreen> createState() => _EnterAdminDataScreenState();
}

class _EnterAdminDataScreenState extends State<EnterAdminDataScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  bool buttonIsActive = true;

  @override
  void dispose() {
    super.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
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
                  TextFormField(
                    controller: lastNameController,
                    maxLength: 30,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter last name',
                      labelText: 'Last Name',
                      //icon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Consumer(
                    builder: (context, ref, child) {
                      return ElevatedButton(
                        onPressed: !buttonIsActive
                            ? null
                            : () async {
                                // only proceed if form entries are valid
                                if (!_formKey.currentState!.validate()) {
                                  return;
                                }
                                setState(() => buttonIsActive = false);

                                // create admin document
                                ref.read(firestoreAdminRepositoryProvider).createAdmin(
                                      adminUid: widget.user.uid,
                                      firstName: firstNameController.text,
                                      lastName: lastNameController.text,
                                    );

                                // update auth credentials
                                final username =
                                    "${firstNameController.text} ${lastNameController.text}";
                                await widget.user.updateDisplayName(username);
                                await widget.user.reload();

                                // calls a function that calls set state in AuthGate
                                widget.callBackFunction();
                              },
                        child: const Text('Submit'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
