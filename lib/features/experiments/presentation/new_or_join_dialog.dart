import 'package:flutter/material.dart';

class NewOrJoinDialog extends StatelessWidget {
  const NewOrJoinDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Experiment'),
      content: const Text('Do you want to create a new experiment or'
          ' do you want to join an existing one via invite code?'),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop('join');
          },
          child: const Text('join'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop('new');
          },
          child: const Text('new'),
        ),
      ],
    );
  }
}
