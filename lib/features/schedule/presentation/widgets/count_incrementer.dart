import 'package:flutter/material.dart';

import '../../../../style/color_palette.dart';

class CountIncrementer extends StatelessWidget {
  const CountIncrementer({
    super.key,
    required this.count,
    required this.subtract,
    required this.add,
    required this.isBlocked,
  });

  final int? count;
  final Function subtract;
  final Function add;
  final bool isBlocked;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorPalette().iconButtonColor,
          ),
          child: IconButton(
            onPressed: isBlocked
                ? null
                : () {
                    subtract();
                  },
            icon: const Icon(Icons.remove),
          ),
        ),
        const SizedBox(width: 10),
        FittedBox(
          child: Text(
            count?.toString() ?? ' ',
            style: const TextStyle(fontSize: 100),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorPalette().iconButtonColor,
          ),
          child: IconButton(
            onPressed: isBlocked
                ? null
                : () async {
                    await add();
                  },
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
