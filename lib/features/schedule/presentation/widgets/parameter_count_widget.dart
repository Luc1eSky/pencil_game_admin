import 'package:flutter/material.dart';

class ParameterCountWidget extends StatelessWidget {
  const ParameterCountWidget({
    super.key,
    required this.text,
    required this.child,
  });

  final String text;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: FittedBox(
            child: Text(
              text,
              style: const TextStyle(fontSize: 100),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: child,
        ),
      ],
    );
  }
}
