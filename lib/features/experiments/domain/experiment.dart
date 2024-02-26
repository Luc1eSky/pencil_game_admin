import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../utils/utils.dart';
import 'experiment_status.dart';

part 'experiment.freezed.dart';
part 'experiment.g.dart';

@freezed
class Experiment with _$Experiment {
  const Experiment._();
  const factory Experiment({
    required String name,
    required String location,
    required String createdByUid,
    @TimestampConverter() required DateTime createdOn,
    required ExperimentStatus status,
    // required int userCount,
    // required int tableCount,
    // required int numberOfRounds,
  }) = _Experiment;

  factory Experiment.fromJson(Map<String, dynamic> json) => _$ExperimentFromJson(json);

  bool userIsOwner(String? uid) {
    return createdByUid == uid;
  }

  // String getSharedWithString(String? uid) {
  //   return sharedWithCount == 0
  //       ? 'Currently not shared'
  //       : sharedWithCount == 1
  //           ? userIsOwner(uid)
  //               ? 'Shared with 1 other admin'
  //               : 'Shared with you'
  //           : userIsOwner(uid)
  //               ? 'Shared with $sharedWithCount other admin(s)'
  //               : 'Shared with you and ${sharedWithCount - 1} other admin(s)';
  // }
}
