import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pencil_game_admin/features/schedule/domain/detailed_schedule.dart';

import 'game.dart';
import 'round.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

@freezed
class Schedule with _$Schedule {
  //const Schedule._();
  const factory Schedule({
    required List<Round> rounds,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) => _$ScheduleFromJson(json);

  factory Schedule.fromDetailed(DetailedSchedule detailedSchedule) {
    final listOfDetailedRounds = detailedSchedule.rounds;
    final listOfRounds = listOfDetailedRounds.map((r) {
      final pausingColors = r.pausingUsers.map((u) => u.colorCode).toSet();
      final games = r.games.map((g) {
        final colorPair = g.userPair.map((p) => p.colorCode).toSet();
        return Game(tableNumber: g.tableNumber, playerPair: colorPair);
      }).toList();

      return Round(
        roundNumber: r.roundNumber,
        games: games,
        pausingPlayers: pausingColors,
      );
    }).toList();
    return Schedule(rounds: listOfRounds);
  }

  //int get userCount => playerColorCodes.length;
}
