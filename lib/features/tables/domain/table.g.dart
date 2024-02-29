// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TableImpl _$$TableImplFromJson(Map<String, dynamic> json) => _$TableImpl(
      tableNumber: json['tableNumber'] as int,
      assignedUsers: (json['assignedUsers'] as List<dynamic>)
          .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
          .toSet(),
      signedInUsers: (json['signedInUsers'] as List<dynamic>)
          .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
          .toSet(),
      status: $enumDecodeNullable(_$TableStatusEnumMap, json['status']) ??
          TableStatus.waiting,
    );

Map<String, dynamic> _$$TableImplToJson(_$TableImpl instance) =>
    <String, dynamic>{
      'tableNumber': instance.tableNumber,
      'assignedUsers': instance.assignedUsers.map((e) => e.toJson()).toList(),
      'signedInUsers': instance.signedInUsers.map((e) => e.toJson()).toList(),
      'status': _$TableStatusEnumMap[instance.status]!,
    };

const _$TableStatusEnumMap = {
  TableStatus.waiting: 'waiting',
  TableStatus.ready: 'ready',
  TableStatus.playing: 'playing',
  TableStatus.finished: 'finished',
  TableStatus.aborted: 'aborted',
};
