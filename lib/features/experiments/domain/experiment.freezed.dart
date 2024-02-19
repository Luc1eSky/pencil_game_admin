// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'experiment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Experiment _$ExperimentFromJson(Map<String, dynamic> json) {
  return _Experiment.fromJson(json);
}

/// @nodoc
mixin _$Experiment {
  String get name => throw _privateConstructorUsedError;
  String get location => throw _privateConstructorUsedError;
  String get createdByUid => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdOn => throw _privateConstructorUsedError;
  ExperimentStatus get status => throw _privateConstructorUsedError;
  int get userCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExperimentCopyWith<Experiment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExperimentCopyWith<$Res> {
  factory $ExperimentCopyWith(
          Experiment value, $Res Function(Experiment) then) =
      _$ExperimentCopyWithImpl<$Res, Experiment>;
  @useResult
  $Res call(
      {String name,
      String location,
      String createdByUid,
      @TimestampConverter() DateTime createdOn,
      ExperimentStatus status,
      int userCount});
}

/// @nodoc
class _$ExperimentCopyWithImpl<$Res, $Val extends Experiment>
    implements $ExperimentCopyWith<$Res> {
  _$ExperimentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? location = null,
    Object? createdByUid = null,
    Object? createdOn = null,
    Object? status = null,
    Object? userCount = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      createdByUid: null == createdByUid
          ? _value.createdByUid
          : createdByUid // ignore: cast_nullable_to_non_nullable
              as String,
      createdOn: null == createdOn
          ? _value.createdOn
          : createdOn // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ExperimentStatus,
      userCount: null == userCount
          ? _value.userCount
          : userCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExperimentImplCopyWith<$Res>
    implements $ExperimentCopyWith<$Res> {
  factory _$$ExperimentImplCopyWith(
          _$ExperimentImpl value, $Res Function(_$ExperimentImpl) then) =
      __$$ExperimentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String location,
      String createdByUid,
      @TimestampConverter() DateTime createdOn,
      ExperimentStatus status,
      int userCount});
}

/// @nodoc
class __$$ExperimentImplCopyWithImpl<$Res>
    extends _$ExperimentCopyWithImpl<$Res, _$ExperimentImpl>
    implements _$$ExperimentImplCopyWith<$Res> {
  __$$ExperimentImplCopyWithImpl(
      _$ExperimentImpl _value, $Res Function(_$ExperimentImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? location = null,
    Object? createdByUid = null,
    Object? createdOn = null,
    Object? status = null,
    Object? userCount = null,
  }) {
    return _then(_$ExperimentImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      location: null == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String,
      createdByUid: null == createdByUid
          ? _value.createdByUid
          : createdByUid // ignore: cast_nullable_to_non_nullable
              as String,
      createdOn: null == createdOn
          ? _value.createdOn
          : createdOn // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ExperimentStatus,
      userCount: null == userCount
          ? _value.userCount
          : userCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExperimentImpl extends _Experiment {
  const _$ExperimentImpl(
      {required this.name,
      required this.location,
      required this.createdByUid,
      @TimestampConverter() required this.createdOn,
      required this.status,
      required this.userCount})
      : super._();

  factory _$ExperimentImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExperimentImplFromJson(json);

  @override
  final String name;
  @override
  final String location;
  @override
  final String createdByUid;
  @override
  @TimestampConverter()
  final DateTime createdOn;
  @override
  final ExperimentStatus status;
  @override
  final int userCount;

  @override
  String toString() {
    return 'Experiment(name: $name, location: $location, createdByUid: $createdByUid, createdOn: $createdOn, status: $status, userCount: $userCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExperimentImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.createdByUid, createdByUid) ||
                other.createdByUid == createdByUid) &&
            (identical(other.createdOn, createdOn) ||
                other.createdOn == createdOn) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.userCount, userCount) ||
                other.userCount == userCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, location, createdByUid, createdOn, status, userCount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExperimentImplCopyWith<_$ExperimentImpl> get copyWith =>
      __$$ExperimentImplCopyWithImpl<_$ExperimentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExperimentImplToJson(
      this,
    );
  }
}

abstract class _Experiment extends Experiment {
  const factory _Experiment(
      {required final String name,
      required final String location,
      required final String createdByUid,
      @TimestampConverter() required final DateTime createdOn,
      required final ExperimentStatus status,
      required final int userCount}) = _$ExperimentImpl;
  const _Experiment._() : super._();

  factory _Experiment.fromJson(Map<String, dynamic> json) =
      _$ExperimentImpl.fromJson;

  @override
  String get name;
  @override
  String get location;
  @override
  String get createdByUid;
  @override
  @TimestampConverter()
  DateTime get createdOn;
  @override
  ExperimentStatus get status;
  @override
  int get userCount;
  @override
  @JsonKey(ignore: true)
  _$$ExperimentImplCopyWith<_$ExperimentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
