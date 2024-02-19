import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/user/data/firestore_user_repository.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../style/color_palette.dart';

class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({
    super.key,
    required this.userShareCode,
  });

  final String userShareCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette().userLoginBackground, // TODO: QR CODE BACKGROUND?
      body: Column(
        children: [
          const SizedBox(
            height: 50,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: FittedBox(
                child: Text(
                  'Test Experiment Name (replace)',
                  style: TextStyle(fontSize: 100),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QrImageView(
                        data: 'https://pencil-game-user.firebaseapp.com/login/$userShareCode',
                        version: QrVersions.auto,
                        backgroundColor: Colors.grey,
                        //size: 200.0,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        userShareCode,
                        style: const TextStyle(fontSize: 30),
                      ),
                      const SizedBox(height: 40),
                      Consumer(
                        builder: (context, ref, child) {
                          return StreamBuilder(
                              stream: ref
                                  .read(firestoreUserRepositoryProvider)
                                  .getUserShareCodeStream(userShareCode),
                              builder: (context, snapshot) {
                                if (snapshot.hasData && !snapshot.hasError) {
                                  int? docLength = snapshot.data?.docs.length;
                                  if (docLength == 0) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      Navigator.pop(context);
                                    });
                                  }
                                }
                                return Container();
                              });
                        },
                      ),
                      const SizedBox(height: 60),
                      Container(
                        width: 100,
                        //padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[400]!,
                              blurRadius: 5.0,
                            ),
                          ],
                        ),
                        child: FittedBox(
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            color: Colors.green,
                            iconSize: 150,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.check_circle),
                          ),
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
