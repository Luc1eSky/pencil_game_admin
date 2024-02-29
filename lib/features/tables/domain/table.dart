import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../user/domain/app_user.dart';

part 'table.freezed.dart';
part 'table.g.dart';

@freezed
class Table with _$Table {
  const Table._();
  const factory Table({
    required int tableNumber,
    required Set<AppUser> assignedUsers,
    required Set<AppUser> signedInUsers,
    @Default(TableStatus.waiting) TableStatus status,
  }) = _Table;

  factory Table.fromJson(Map<String, dynamic> json) => _$TableFromJson(json);

  bool get firstUserIsPresent => signedInUsers.contains(assignedUsers.elementAt(0));
  bool get secondUserIsPresent => signedInUsers.contains(assignedUsers.elementAt(1));
  bool get hasCorrectUsers => setEquals(assignedUsers, signedInUsers);
}

enum TableStatus {
  waiting,
  ready,
  playing,
  finished,
  aborted,
}
