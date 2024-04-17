import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/style/navigation_bar_theme.dart';

import 'constants.dart';
import 'features/authorize/presentation/auth_gate.dart';
import 'features/tables/data/database_time_offset_provider.dart';
import 'firebase_options.dart';

Future<void> setupEmulators() async {
  await FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
  FirebaseFunctions.instance.useFunctionsEmulator('127.0.0.1', 5001);
  FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
  FirebaseDatabase.instance.useDatabaseEmulator('127.0.0.1', 9000);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (inDebuggingMode) {
    await setupEmulators();
  }
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // initialize listener to keep track of database delay
    // this is important to compensate for different clocks
    final container = ProviderScope.containerOf(context);
    container.read(databaseTimeOffsetRepositoryProvider.notifier).listenToDatabaseOffset();

    return MaterialApp(
      debugShowCheckedModeBanner: inDebuggingMode,
      title: appName,
      theme: ThemeData(
        navigationBarTheme: navigationBarTheme,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
