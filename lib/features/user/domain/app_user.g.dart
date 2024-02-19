// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserImpl _$$AppUserImplFromJson(Map<String, dynamic> json) =>
    _$AppUserImpl(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      uid: json['uid'] as String,
      experimentDocId: json['experimentDocId'] as String,
      createdOn:
          const TimestampConverter().fromJson(json['createdOn'] as Timestamp),
    );

Map<String, dynamic> _$$AppUserImplToJson(_$AppUserImpl instance) =>
    <String, dynamic>{
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'uid': instance.uid,
      'experimentDocId': instance.experimentDocId,
      'createdOn': const TimestampConverter().toJson(instance.createdOn),
    };
