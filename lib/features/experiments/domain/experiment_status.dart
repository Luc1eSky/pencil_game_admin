import 'package:flutter/material.dart';

enum ExperimentStatus {
  scheduled,
  started,
  deleted,
  completed,
}

extension IconExtension on ExperimentStatus {
  IconData get icon {
    switch (this) {
      case ExperimentStatus.scheduled:
        return Icons.calendar_month_outlined;
      case ExperimentStatus.started:
        return Icons.keyboard;
      case ExperimentStatus.deleted:
        return Icons.delete_forever;
      case ExperimentStatus.completed:
        return Icons.done_outline;
    }
  }
}
