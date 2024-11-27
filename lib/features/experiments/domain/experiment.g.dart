// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'experiment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExperimentImpl _$$ExperimentImplFromJson(Map<String, dynamic> json) =>
    _$ExperimentImpl(
      name: json['name'] as String,
      location: json['location'] as String,
      createdByUid: json['createdByUid'] as String,
      createdOn:
          const TimestampConverter().fromJson(json['createdOn'] as Timestamp),
      status: $enumDecode(_$ExperimentStatusEnumMap, json['status']),
      showSurvey: json['showSurvey'] as bool,
      treatment: $enumDecode(_$TreatmentEnumMap, json['treatment']),
    );

Map<String, dynamic> _$$ExperimentImplToJson(_$ExperimentImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'location': instance.location,
      'createdByUid': instance.createdByUid,
      'createdOn': const TimestampConverter().toJson(instance.createdOn),
      'status': _$ExperimentStatusEnumMap[instance.status]!,
      'showSurvey': instance.showSurvey,
      'treatment': _$TreatmentEnumMap[instance.treatment]!,
    };

const _$ExperimentStatusEnumMap = {
  ExperimentStatus.scheduled: 'scheduled',
  ExperimentStatus.started: 'started',
  ExperimentStatus.deleted: 'deleted',
  ExperimentStatus.completed: 'completed',
};

const _$TreatmentEnumMap = {
  Treatment.faceToface: 'faceToface',
  Treatment.blind: 'blind',
  Treatment.talk: 'talk',
};
