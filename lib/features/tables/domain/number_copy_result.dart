import 'package:freezed_annotation/freezed_annotation.dart';

import '../../user/domain/simple_user.dart';
import 'number_input.dart';

part 'number_copy_result.freezed.dart';
part 'number_copy_result.g.dart';

@freezed
class NumberCopyResult with _$NumberCopyResult {
  const NumberCopyResult._();
  const factory NumberCopyResult({
    required SimpleUser user,
    required List<NumberInput> numberInputs,
  }) = _NumberCopyResult;

  factory NumberCopyResult.fromJson(Map<String, dynamic> json) => _$NumberCopyResultFromJson(json);

  int get numbersCount => numberInputs.length;
  int get correctAnswersCount =>
      numberInputs.where((numberInput) => numberInput.wasCorrect == true).length;
}
