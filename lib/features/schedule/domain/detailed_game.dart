import 'package:freezed_annotation/freezed_annotation.dart';

import '../../user/domain/app_user.dart';

part 'detailed_game.freezed.dart';
part 'detailed_game.g.dart';

@freezed
class DetailedGame with _$DetailedGame {
  const factory DetailedGame({
    required int tableNumber,
    required Set<AppUser> userPair,
  }) = _DetailedGame;

  factory DetailedGame.fromJson(Map<String, dynamic> json) => _$DetailedGameFromJson(json);
}
