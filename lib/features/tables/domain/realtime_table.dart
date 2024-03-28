import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../utils/utils.dart';
import '../../user/domain/simple_user.dart';
import 'click.dart';
import 'number_copy_result.dart';

part 'realtime_table.freezed.dart';
part 'realtime_table.g.dart';

@freezed
class RealtimeTable with _$RealtimeTable {
  const RealtimeTable._();
  const factory RealtimeTable({
    required Set<SimpleUser> assignedUsers,
    Set<SimpleUser>? usersAtTable,
    required int tableNumber,
    @Default(TableStatus.waiting) TableStatus status,
    @DatetimeToMillisecondsConverter() DateTime? startedOn,
    @DatetimeToMillisecondsConverter() DateTime? endedOn,
    String? uidThatHasPen,
    Click? lastClick,
    List<Click>? archivedClicks,
    List<NumberCopyResult>? numberCopyResults,
  }) = _RealtimeTable;

  factory RealtimeTable.fromJson(Map<String, dynamic> json) => _$RealtimeTableFromJson(json);

  // needed to show who is at the table already
  bool get firstUserIsPresent => usersAtTable?.contains(assignedUsers.elementAt(0)) ?? false;
  bool get secondUserIsPresent => usersAtTable?.contains(assignedUsers.elementAt(1)) ?? false;
  // flag that signals if table is ready
  bool get hasCorrectUsers => setEquals(assignedUsers, usersAtTable);

  // check which player has pen
  bool get player1HasPen => uidThatHasPen == assignedUsers.elementAt(0).uid;
  bool get player2HasPen => uidThatHasPen == assignedUsers.elementAt(1).uid;
  bool get someOneHasPen => uidThatHasPen != null;

  bool userHasPen(SimpleUser user) {
    return uidThatHasPen == user.uid;
  }

  // check if user is currently at table
  bool userIsAtTable(SimpleUser user) {
    return usersAtTable?.contains(user) ?? false;
  }

  // check if user has already clicked
  bool userHasClicked(SimpleUser user) {
    return lastClick?.user == user;
  }

  // return result of user or null
  NumberCopyResult? getUsersNumberCopyResult(SimpleUser user) {
    return numberCopyResults?.firstWhereOrNull((result) => result.user == user);
  }
}

enum TableStatus {
  waiting,
  playing,
  finished,
  aborted,
}
