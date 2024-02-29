import 'package:freezed_annotation/freezed_annotation.dart';

import '../../user/domain/app_user.dart';
import 'detailed_game.dart';

part 'detailed_round.freezed.dart';
part 'detailed_round.g.dart';

@freezed
class DetailedRound with _$DetailedRound {
  const factory DetailedRound({
    required int roundNumber,
    required List<DetailedGame> games,
    required Set<AppUser> pausingUsers,
  }) = _DetailedRound;

  factory DetailedRound.fromJson(Map<String, dynamic> json) => _$DetailedRoundFromJson(json);
}
