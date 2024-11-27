import 'package:freezed_annotation/freezed_annotation.dart';

part 'survey.freezed.dart';
part 'survey.g.dart';

/// Enum for treatment
@JsonEnum(alwaysCreate: true)
enum Gender { male, female, other, preferNotToAnswer }

@freezed
class Survey with _$Survey {
  const factory Survey({
    //required bool showSurvey,
    required Gender gender,
  }) = _Survey;

  factory Survey.fromJson(Map<String, dynamic> json) => _$SurveyFromJson(json);
}
