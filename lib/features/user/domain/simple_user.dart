import 'package:freezed_annotation/freezed_annotation.dart';

part 'simple_user.freezed.dart';
part 'simple_user.g.dart';

@freezed
class SimpleUser with _$SimpleUser {
  const SimpleUser._();
  const factory SimpleUser({
    required String firstName,
    required String uid,
    required String colorCode,
    @Default(false) bool surveySubmitted,
  }) = _SimpleUser;

  factory SimpleUser.fromJson(Map<String, dynamic> json) =>
      _$SimpleUserFromJson(json);
}
