import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../utils/utils.dart';

part 'session.freezed.dart';
part 'session.g.dart';

@freezed
class Session with _$Session {
  //const Session._();
  const factory Session({
    required String player1,
    required String player2,
    required String status,
    @TimestampConverter() required DateTime createdOn,
    @TimestampConverter() required DateTime endedOn,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) => _$SessionFromJson(json);
}
