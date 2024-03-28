import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../utils/utils.dart';
import 'click.dart';
import 'number_copy_result.dart';

part 'firestore_result.freezed.dart';
part 'firestore_result.g.dart';

@freezed
class FirestoreResult with _$FirestoreResult {
  //const FirestoreResult._();
  const factory FirestoreResult({
    required int roundNumber,
    required int tableNumber,
    @TimestampConverter() required DateTime startedOn,
    @TimestampConverter() required DateTime endedOn,
    required List<Click> clicks,
    required List<NumberCopyResult> numberCopyResults,
  }) = _FirestoreResult;

  factory FirestoreResult.fromJson(Map<String, dynamic> json) => _$FirestoreResultFromJson(json);
}
