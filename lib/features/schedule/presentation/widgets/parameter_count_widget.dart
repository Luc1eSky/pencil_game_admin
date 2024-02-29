import 'package:flutter/material.dart';

class ParameterCountWidget extends StatelessWidget {
  const ParameterCountWidget({
    super.key,
    required this.text,
    required this.child,
    required this.hasChanged,
  });

  final String text;
  final Widget child;
  final bool hasChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: FittedBox(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 100,
                color: hasChanged ? Colors.red : Colors.black,
              ),
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
