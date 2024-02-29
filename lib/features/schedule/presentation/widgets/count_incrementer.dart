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
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 60),
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  heightFactor: 0.8,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorPalette().iconButtonColor,
                    ),
                    child: FittedBox(
                      child: IconButton(
                        iconSize: 25,
                        onPressed: isBlocked
                            ? null
                            : () async {
                                await subtract();
                              },
                        icon: const Icon(Icons.remove),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        FittedBox(
          child: Text(
            count?.toString() ?? ' ',
            style: const TextStyle(fontSize: 200),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 60),
              child: Center(
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  heightFactor: 0.8,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorPalette().iconButtonColor,
                    ),
                    child: FittedBox(
                      child: IconButton(
                        iconSize: 25,
                        onPressed: isBlocked
                            ? null
                            : () async {
                                await add();
                              },
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
