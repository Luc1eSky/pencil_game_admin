// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppUser _$AppUserFromJson(Map<String, dynamic> json) {
  return _AppUser.fromJson(json);
}

/// @nodoc
mixin _$AppUser {
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String get uid => throw _privateConstructorUsedError;
  String get colorCode => throw _privateConstructorUsedError;
  String get experimentDocId => throw _privateConstructorUsedError;
  int? get currentTableNumber => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime get createdOn => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppUserCopyWith<AppUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppUserCopyWith<$Res> {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) then) =
      _$AppUserCopyWithImpl<$Res, AppUser>;
  @useResult
  $Res call(
      {String firstName,
      String lastName,
      String uid,
      String colorCode,
      String experimentDocId,
      int? currentTableNumber,
      @TimestampConverter() DateTime createdOn});
}

/// @nodoc
class _$AppUserCopyWithImpl<$Res, $Val extends AppUser>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? uid = null,
    Object? colorCode = null,
    Object? experimentDocId = null,
    Object? currentTableNumber = freezed,
    Object? createdOn = null,
  }) {
    return _then(_value.copyWith(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      colorCode: null == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
              as String,
      experimentDocId: null == experimentDocId
          ? _value.experimentDocId
          : experimentDocId // ignore: cast_nullable_to_non_nullable
              as String,
      currentTableNumber: freezed == currentTableNumber
          ? _value.currentTableNumber
          : currentTableNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      createdOn: null == createdOn
          ? _value.createdOn
          : createdOn // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppUserImplCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$$AppUserImplCopyWith(
          _$AppUserImpl value, $Res Function(_$AppUserImpl) then) =
      __$$AppUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String firstName,
      String lastName,
      String uid,
      String colorCode,
      String experimentDocId,
      int? currentTableNumber,
      @TimestampConverter() DateTime createdOn});
}

/// @nodoc
class __$$AppUserImplCopyWithImpl<$Res>
    extends _$AppUserCopyWithImpl<$Res, _$AppUserImpl>
    implements _$$AppUserImplCopyWith<$Res> {
  __$$AppUserImplCopyWithImpl(
      _$AppUserImpl _value, $Res Function(_$AppUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? uid = null,
    Object? colorCode = null,
    Object? experimentDocId = null,
    Object? currentTableNumber = freezed,
    Object? createdOn = null,
  }) {
    return _then(_$AppUserImpl(
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      colorCode: null == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
              as String,
      experimentDocId: null == experimentDocId
          ? _value.experimentDocId
          : experimentDocId // ignore: cast_nullable_to_non_nullable
              as String,
      currentTableNumber: freezed == currentTableNumber
          ? _value.currentTableNumber
          : currentTableNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      createdOn: null == createdOn
          ? _value.createdOn
          : createdOn // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppUserImpl extends _AppUser {
  const _$AppUserImpl(
      {required this.firstName,
      required this.lastName,
      required this.uid,
      required this.colorCode,
      required this.experimentDocId,
      required this.currentTableNumber,
      @TimestampConverter() required this.createdOn})
      : super._();

  factory _$AppUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppUserImplFromJson(json);

  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String uid;
  @override
  final String colorCode;
  @override
  final String experimentDocId;
  @override
  final int? currentTableNumber;
  @override
  @TimestampConverter()
  final DateTime createdOn;

  @override
  String toString() {
    return 'AppUser(firstName: $firstName, lastName: $lastName, uid: $uid, colorCode: $colorCode, experimentDocId: $experimentDocId, currentTableNumber: $currentTableNumber, createdOn: $createdOn)';
  }

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      __$$AppUserImplCopyWithImpl<_$AppUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppUserImplToJson(
      this,
    );
  }
}

abstract class _AppUser extends AppUser {
  const factory _AppUser(
      {required final String firstName,
      required final String lastName,
      required final String uid,
      required final String colorCode,
      required final String experimentDocId,
      required final int? currentTableNumber,
      @TimestampConverter() required final DateTime createdOn}) = _$AppUserImpl;
  const _AppUser._() : super._();

  factory _AppUser.fromJson(Map<String, dynamic> json) = _$AppUserImpl.fromJson;

  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String get uid;
  @override
  String get colorCode;
  @override
  String get experimentDocId;
  @override
  int? get currentTableNumber;
  @override
  @TimestampConverter()
  DateTime get createdOn;
  @override
  @JsonKey(ignore: true)
  _$$AppUserImplCopyWith<_$AppUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
