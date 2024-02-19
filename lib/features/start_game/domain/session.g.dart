// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SessionImpl _$$SessionImplFromJson(Map<String, dynamic> json) =>
    _$SessionImpl(
      player1: json['player1'] as String,
      player2: json['player2'] as String,
      status: json['status'] as String,
      createdOn:
          const TimestampConverter().fromJson(json['createdOn'] as Timestamp),
      endedOn:
          const TimestampConverter().fromJson(json['endedOn'] as Timestamp),
    );

Map<String, dynamic> _$$SessionImplToJson(_$SessionImpl instance) =>
    <String, dynamic>{
      'player1': instance.player1,
      'player2': instance.player2,
      'status': instance.status,
      'createdOn': const TimestampConverter().toJson(instance.createdOn),
      'endedOn': const TimestampConverter().toJson(instance.endedOn),
    };
