import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../utils/utils.dart';

part 'number_input.freezed.dart';
part 'number_input.g.dart';

@freezed
class NumberInput with _$NumberInput {
  const NumberInput._();
  const factory NumberInput({
    required String solution,
    required String input,
    @DatetimeToMillisecondsConverter() required DateTime timestamp,
  }) = _NumberInput;

  factory NumberInput.fromJson(Map<String, dynamic> json) => _$NumberInputFromJson(json);

  bool get wasCorrect => solution == input;
}
