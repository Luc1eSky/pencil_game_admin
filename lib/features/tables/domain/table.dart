import 'package:freezed_annotation/freezed_annotation.dart';

part 'table.freezed.dart';
part 'table.g.dart';

@freezed
class Table with _$Table {
  const factory Table({
    String? player1,
    String? player2,
    @Default(TableStatus.empty) TableStatus status,
  }) = _Table;

  factory Table.fromJson(Map<String, dynamic> json) => _$TableFromJson(json);
}

enum TableStatus {
  empty,
  waiting,
  ready,
  playing,
}
