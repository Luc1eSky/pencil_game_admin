import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../utils/utils.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

@freezed
class AppUser with _$AppUser {
  const AppUser._();
  const factory AppUser({
    required String firstName,
    required String lastName,
    required String uid,
    required String colorCode,
    required String experimentDocId,
    required int? currentTableNumber,
    @TimestampConverter() required DateTime createdOn,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

  factory AppUser.fromFirestore(Map<String, dynamic> firestoreMap, String uid) {
    firestoreMap['uid'] = uid;
    return AppUser.fromJson(firestoreMap);
  }

  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> jsonMap = toJson();
    jsonMap.remove('uid');
    return jsonMap;
  }

  // TODO: REMOVE ?
  String get shortNameString => '$firstName ${lastName.substring(0, 1)}.';
  String get fullNameString => '$firstName $lastName';

  // only consider uid for equality
  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppUser && runtimeType == other.runtimeType && uid == other.uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
