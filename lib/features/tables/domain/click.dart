import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../utils/utils.dart';
import '../../user/domain/simple_user.dart';

part 'click.freezed.dart';
part 'click.g.dart';

@freezed
class Click with _$Click {
  //const Click._();
  const factory Click({
    required SimpleUser user,
    required ClickType type,
    @DatetimeToMillisecondsConverter() required DateTime timestamp,
  }) = _Click;

  factory Click.fromJson(Map<String, dynamic> json) => _$ClickFromJson(json);
}

enum ClickType {
  grabPenTry,
  grabPenSuccess,
  grabPenFail,
  returnPen,
}
