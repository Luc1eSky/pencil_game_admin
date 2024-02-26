import 'package:freezed_annotation/freezed_annotation.dart';

import 'round.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

@freezed
class Schedule with _$Schedule {
  const Schedule._();
  const factory Schedule({
    required int currentRoundNumber,
    required int tableCount,
    required int numberOfRounds,
    required List<Round> rounds,
    required List<String> playerColorCodes,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);

  int get userCount => playerColorCodes.length;
}
