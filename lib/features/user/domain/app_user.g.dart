// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      firstName: json['firstName'] as String,
      uid: json['uid'] as String,
      colorCode: json['colorCode'] as String,
      experimentDocId: json['experimentDocId'] as String,
      currentTableNumber: (json['currentTableNumber'] as num?)?.toInt(),
      survey: json['survey'] == null
          ? null
          : Survey.fromJson(json['survey'] as Map<String, dynamic>),
      surveySubmitted: json['surveySubmitted'] as bool? ?? false,
      showSurvey: json['showSurvey'] as bool? ?? false,
      createdOn:
          const TimestampConverter().fromJson(json['createdOn'] as Timestamp),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'uid': instance.uid,
      'colorCode': instance.colorCode,
      'experimentDocId': instance.experimentDocId,
      'currentTableNumber': instance.currentTableNumber,
      'survey': instance.survey?.toJson(),
      'surveySubmitted': instance.surveySubmitted,
      'showSurvey': instance.showSurvey,
      'createdOn': const TimestampConverter().toJson(instance.createdOn),
    };
