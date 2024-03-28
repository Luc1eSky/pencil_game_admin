import 'package:freezed_annotation/freezed_annotation.dart';

import '../../user/domain/app_user.dart';
import '../../user/domain/simple_user.dart';

part 'schedule_parameters.freezed.dart';
part 'schedule_parameters.g.dart';

@freezed
class ScheduleParameters with _$ScheduleParameters {
  const ScheduleParameters._();
  const factory ScheduleParameters({
    required Set<SimpleUser> allActiveUsers,
    required int tableCount,
    required int numberOfRounds,
    required int? lastUserCount,
    required int? lastTableCount,
    required int? lastNumberOfRounds,
  }) = _ScheduleParameters;

  factory ScheduleParameters.fromJson(Map<String, dynamic> json) =>
      _$ScheduleParametersFromJson(json);

  int get userCount => allActiveUsers.length;

  bool get userCountHasChanged => userCount != lastUserCount;
  bool get tableCountHasChanged => tableCount != lastTableCount;
  bool get numberOfRoundsHasChanged => numberOfRounds != lastNumberOfRounds;

  bool get anythingHasChanged =>
      userCountHasChanged || tableCountHasChanged || numberOfRoundsHasChanged;

  bool get canCreateSchedule => userCount > 1 && tableCount > 0 && numberOfRounds > 0;

  bool get scheduleWasCreated =>
      lastUserCount != null && lastTableCount != null && lastNumberOfRounds != null;
}
