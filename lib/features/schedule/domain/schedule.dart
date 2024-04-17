import 'package:freezed_annotation/freezed_annotation.dart';

import 'round.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

@freezed
class Schedule with _$Schedule {
  const Schedule._();
  const factory Schedule({
    required List<Round> rounds,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);

  // get maximum round number (length of list of rounds)
  int get maxRoundNumber => rounds.length;
}
