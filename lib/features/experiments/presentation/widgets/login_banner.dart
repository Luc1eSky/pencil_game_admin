import 'package:flutter/material.dart';

class LoginBanner extends StatelessWidget {
  const LoginBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        color: Colors.green,
        child: const Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(child: Text('ProsperPlay')),
            ),
            Expanded(
              child: Center(
                child: Text('Pencil Game Admin Console'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
