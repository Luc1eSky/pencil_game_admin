import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DatabaseTimeOffsetRepository extends Notifier<Duration> {
  @override
  Duration build() {
    // this will be overridden once listenToDatabaseOffset() is called
    return Duration.zero;
  }

  /// listen to offset to the connection of the firebase realtime database
  void listenToDatabaseOffset() {
    final DatabaseReference offsetRef = FirebaseDatabase.instance.ref(".info/serverTimeOffset");
    offsetRef.onValue.listen((event) {
      final databaseOffset = event.snapshot.value as int? ?? 0;
      print('DATABASE OFFSET: $databaseOffset milliseconds');
      state = Duration(milliseconds: databaseOffset);
    });
  }
}

final databaseTimeOffsetRepositoryProvider =
    NotifierProvider<DatabaseTimeOffsetRepository, Duration>(() {
  return DatabaseTimeOffsetRepository();
});
