import 'package:freezed_annotation/freezed_annotation.dart';

import 'detailed_round.dart';

part 'detailed_schedule.freezed.dart';
part 'detailed_schedule.g.dart';

@freezed
class DetailedSchedule with _$DetailedSchedule {
  const factory DetailedSchedule({
    required List<DetailedRound> rounds,
  }) = _DetailedSchedule;

  factory DetailedSchedule.fromJson(Map<String, dynamic> json) => _$DetailedScheduleFromJson(json);
}
