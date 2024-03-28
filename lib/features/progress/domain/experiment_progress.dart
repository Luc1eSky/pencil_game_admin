import 'package:freezed_annotation/freezed_annotation.dart';

part 'experiment_progress.freezed.dart';
part 'experiment_progress.g.dart';

@freezed
class ExperimentProgress with _$ExperimentProgress {
  const ExperimentProgress._();
  const factory ExperimentProgress({
    required int currentRoundNumber,
    required ExperimentStatus status,
  }) = _ExperimentProgress;

  factory ExperimentProgress.fromJson(Map<String, dynamic> json) =>
      _$ExperimentProgressFromJson(json);

  // can only create schedules when there is no schedule or
  // when there is a schedule but it is not locked
  bool get canCreateSchedule =>
      status == ExperimentStatus.noSchedule || status == ExperimentStatus.scheduled;

  // show switch to toggle lock in state of schedule
  // only when a schedule exists and play has not yet started
  bool get showScheduleSwitch =>
      status == ExperimentStatus.scheduled || status == ExperimentStatus.lockedSchedule;

  // show live view only after a schedule has been locked in
  bool get showLiveView =>
      status != ExperimentStatus.noSchedule && status != ExperimentStatus.scheduled;

  // admin can only increase the round number when a round has been finished
  bool get canIncreaseRoundNumber => status == ExperimentStatus.roundFinished;
}

enum ExperimentStatus {
  noSchedule,
  scheduled,
  lockedSchedule,
  roundPlaying,
  roundFinished,
  roundWaiting,
  experimentFinished,
}
