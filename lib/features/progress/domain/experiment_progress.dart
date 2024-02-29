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

  // can only create schedules when not already playing, waiting, or finished
  bool get canCreateSchedule =>
      status == ExperimentStatus.noSchedule || status == ExperimentStatus.scheduled;

  // can only lock in schedule if there has been one created and not started yet
  bool get canLockInSchedule => status == ExperimentStatus.scheduled;

  // can only unlock schedule if nobody has started playing yet
  bool get canUnlockSchedule => status == ExperimentStatus.lockedSchedule;

  // admin can only increase the round number when a round has been finished
  bool get canIncreaseRoundNumber => status == ExperimentStatus.roundFinished;

  // only give user round number (to show to which table to go to) when waiting
  bool get canShowRoundNumberToUser =>
      status == ExperimentStatus.lockedSchedule || status == ExperimentStatus.roundWaiting;
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
