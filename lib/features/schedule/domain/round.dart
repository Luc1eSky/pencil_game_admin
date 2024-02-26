import 'package:freezed_annotation/freezed_annotation.dart';

import 'game.dart';

part 'round.freezed.dart';
part 'round.g.dart';

@freezed
class Round with _$Round {
  const factory Round({
    required int roundNumber,
    required List<Game> games,
    required Set<String> pausingPlayers, // list of color codes
  }) = _Round;

  factory Round.fromJson(Map<String, dynamic> json) => _$RoundFromJson(json);
}
