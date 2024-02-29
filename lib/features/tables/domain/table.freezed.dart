// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'table.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Table _$TableFromJson(Map<String, dynamic> json) {
  return _Table.fromJson(json);
}

/// @nodoc
mixin _$Table {
  int get tableNumber => throw _privateConstructorUsedError;
  Set<AppUser> get assignedUsers => throw _privateConstructorUsedError;
  Set<AppUser> get signedInUsers => throw _privateConstructorUsedError;
  TableStatus get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TableCopyWith<Table> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TableCopyWith<$Res> {
  factory $TableCopyWith(Table value, $Res Function(Table) then) =
      _$TableCopyWithImpl<$Res, Table>;
  @useResult
  $Res call(
      {int tableNumber,
      Set<AppUser> assignedUsers,
      Set<AppUser> signedInUsers,
      TableStatus status});
}

/// @nodoc
class _$TableCopyWithImpl<$Res, $Val extends Table>
    implements $TableCopyWith<$Res> {
  _$TableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tableNumber = null,
    Object? assignedUsers = null,
    Object? signedInUsers = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      tableNumber: null == tableNumber
          ? _value.tableNumber
          : tableNumber // ignore: cast_nullable_to_non_nullable
              as int,
      assignedUsers: null == assignedUsers
          ? _value.assignedUsers
          : assignedUsers // ignore: cast_nullable_to_non_nullable
              as Set<AppUser>,
      signedInUsers: null == signedInUsers
          ? _value.signedInUsers
          : signedInUsers // ignore: cast_nullable_to_non_nullable
              as Set<AppUser>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TableStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TableImplCopyWith<$Res> implements $TableCopyWith<$Res> {
  factory _$$TableImplCopyWith(
          _$TableImpl value, $Res Function(_$TableImpl) then) =
      __$$TableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int tableNumber,
      Set<AppUser> assignedUsers,
      Set<AppUser> signedInUsers,
      TableStatus status});
}

/// @nodoc
class __$$TableImplCopyWithImpl<$Res>
    extends _$TableCopyWithImpl<$Res, _$TableImpl>
    implements _$$TableImplCopyWith<$Res> {
  __$$TableImplCopyWithImpl(
      _$TableImpl _value, $Res Function(_$TableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tableNumber = null,
    Object? assignedUsers = null,
    Object? signedInUsers = null,
    Object? status = null,
  }) {
    return _then(_$TableImpl(
      tableNumber: null == tableNumber
          ? _value.tableNumber
          : tableNumber // ignore: cast_nullable_to_non_nullable
              as int,
      assignedUsers: null == assignedUsers
          ? _value._assignedUsers
          : assignedUsers // ignore: cast_nullable_to_non_nullable
              as Set<AppUser>,
      signedInUsers: null == signedInUsers
          ? _value._signedInUsers
          : signedInUsers // ignore: cast_nullable_to_non_nullable
              as Set<AppUser>,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TableStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TableImpl extends _Table with DiagnosticableTreeMixin {
  const _$TableImpl(
      {required this.tableNumber,
      required final Set<AppUser> assignedUsers,
      required final Set<AppUser> signedInUsers,
      this.status = TableStatus.waiting})
      : _assignedUsers = assignedUsers,
        _signedInUsers = signedInUsers,
        super._();

  factory _$TableImpl.fromJson(Map<String, dynamic> json) =>
      _$$TableImplFromJson(json);

  @override
  final int tableNumber;
  final Set<AppUser> _assignedUsers;
  @override
  Set<AppUser> get assignedUsers {
    if (_assignedUsers is EqualUnmodifiableSetView) return _assignedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_assignedUsers);
  }

  final Set<AppUser> _signedInUsers;
  @override
  Set<AppUser> get signedInUsers {
    if (_signedInUsers is EqualUnmodifiableSetView) return _signedInUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_signedInUsers);
  }

  @override
  @JsonKey()
  final TableStatus status;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Table(tableNumber: $tableNumber, assignedUsers: $assignedUsers, signedInUsers: $signedInUsers, status: $status)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Table'))
      ..add(DiagnosticsProperty('tableNumber', tableNumber))
      ..add(DiagnosticsProperty('assignedUsers', assignedUsers))
      ..add(DiagnosticsProperty('signedInUsers', signedInUsers))
      ..add(DiagnosticsProperty('status', status));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TableImpl &&
            (identical(other.tableNumber, tableNumber) ||
                other.tableNumber == tableNumber) &&
            const DeepCollectionEquality()
                .equals(other._assignedUsers, _assignedUsers) &&
            const DeepCollectionEquality()
                .equals(other._signedInUsers, _signedInUsers) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      tableNumber,
      const DeepCollectionEquality().hash(_assignedUsers),
      const DeepCollectionEquality().hash(_signedInUsers),
      status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TableImplCopyWith<_$TableImpl> get copyWith =>
      __$$TableImplCopyWithImpl<_$TableImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TableImplToJson(
      this,
    );
  }
}

abstract class _Table extends Table {
  const factory _Table(
      {required final int tableNumber,
      required final Set<AppUser> assignedUsers,
      required final Set<AppUser> signedInUsers,
      final TableStatus status}) = _$TableImpl;
  const _Table._() : super._();

  factory _Table.fromJson(Map<String, dynamic> json) = _$TableImpl.fromJson;

  @override
  int get tableNumber;
  @override
  Set<AppUser> get assignedUsers;
  @override
  Set<AppUser> get signedInUsers;
  @override
  TableStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$TableImplCopyWith<_$TableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
