import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../style/color_palette.dart';
import '../data/firestore_experiment_repository.dart';

class InviteCodeDialog extends ConsumerStatefulWidget {
  const InviteCodeDialog({
    super.key,
    required this.docId,
  });

  final String docId;

  @override
  ConsumerState<InviteCodeDialog> createState() => _InviteCodeDialogState();
}

class _InviteCodeDialogState extends ConsumerState<InviteCodeDialog> {
  String? shareCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      shareCode =
          await ref.read(firestoreExperimentRepositoryProvider).getOrCreateCode(widget.docId);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentTextStyle: const TextStyle(
        fontSize: 35,
      ),
      title: const Text('Invite code'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: ColorPalette().experimentCardOwned,
              borderRadius: BorderRadius.circular(10),
            ),
            height: 75,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: FittedBox(
                child: shareCode == null ? const CircularProgressIndicator() : Text(shareCode!),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('close'),
          ),
        ],
      ),
    );
  }
}
