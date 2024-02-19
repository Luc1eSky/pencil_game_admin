// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TableImpl _$$TableImplFromJson(Map<String, dynamic> json) => _$TableImpl(
      player1: json['player1'] as String?,
      player2: json['player2'] as String?,
      status: $enumDecodeNullable(_$TableStatusEnumMap, json['status']) ??
          TableStatus.empty,
    );

Map<String, dynamic> _$$TableImplToJson(_$TableImpl instance) =>
    <String, dynamic>{
      'player1': instance.player1,
      'player2': instance.player2,
      'status': _$TableStatusEnumMap[instance.status]!,
    };

const _$TableStatusEnumMap = {
  TableStatus.empty: 'empty',
  TableStatus.waiting: 'waiting',
  TableStatus.ready: 'ready',
  TableStatus.playing: 'playing',
};
