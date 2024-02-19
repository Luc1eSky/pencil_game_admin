// hide EmailAuthProvider, so that EmailAuthProvider of ui_auth package can be used
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pencil_game_admin/features/authorize/data/firebase_auth_repository.dart';

import '../../admin/presentation/enter_admin_data_screen.dart';
import '../../experiments/presentation/home_screen.dart';
import '../../experiments/presentation/widgets/login_banner.dart';
import '../data/firebase_auth_instance_provider.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  void callBackFunction() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return StreamBuilder(
            stream: ref.watch(firebaseAuthRepositoryProvider).getUserStream(),
            builder: (context, snapshot) {
              /// if user has not yet been authorized, show sign in / register screen
              if (!snapshot.hasData) {
                return SignInScreen(
                  providers: [EmailAuthProvider()],
                  headerBuilder: (context, constraints, shrinkOffset) {
                    return const LoginBanner();
                  },
                  sideBuilder: (context, shrinkOffset) {
                    return const LoginBanner();
                  },
                );
              }

              final user = snapshot.data!;

              /// if email has not been verified yet, send email and show verification screen
              if (!user.emailVerified) {
                return EmailVerificationScreen(
                  actions: [
                    EmailVerifiedAction(() async {
                      // IMPORTANT: NEEDED TO UPDATE TOKEN TO AVOID ANOTHER SIGN IN!
                      await ref.read(firebaseAuthInstanceProvider).currentUser!.getIdToken(true);
                      setState(() {});
                    }),
                    AuthCancelledAction((context) => FirebaseUIAuth.signOut(context: context)),
                  ],
                );
              }

              /// if user has not entered a name yet, show name entering screen
              if (user.displayName == null) {
                return EnterAdminDataScreen(
                  user: user,
                  callBackFunction: callBackFunction,
                );
              }

              /// if user is signed in, has a verified email, and has entered name
              /// show home screen of app
              return const HomeScreen();
            });
      },
    );
  }
}
