import 'package:flutter/material.dart';

import '../../../style/color_palette.dart';
import '../../experiments/domain/experiment.dart';
import 'enter_user_data_screen.dart';

class AddUserScreen extends StatelessWidget {
  const AddUserScreen({
    super.key,
    required this.experiment,
    required this.userDocId,
  });

  final Experiment experiment;
  final String userDocId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette().userLoginBackground,
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    print('Pressed');
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FittedBox(
                      child: Text(
                        '${experiment.name} - ${experiment.location}',
                        style: const TextStyle(fontSize: 100),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return EnterUserDataScreen(
                            experiment: experiment,
                            experimentDocId: userDocId,
                          );
                        },
                      ),
                    );
                  },
                  child: const FittedBox(
                    child: Icon(
                      Icons.add,
                      size: 150,
                    ),
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
