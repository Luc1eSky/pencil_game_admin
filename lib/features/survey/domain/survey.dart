import 'package:freezed_annotation/freezed_annotation.dart';

part 'survey.freezed.dart';
part 'survey.g.dart';

@freezed
class Survey with _$Survey {
  const factory Survey({
    required String surveyLink,
    required bool showSurvey,
  }) = _Survey;

  factory Survey.fromJson(Map<String, dynamic> json) => _$SurveyFromJson(json);
}
