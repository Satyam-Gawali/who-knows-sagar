import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:whoknowssagar/providers/player_provider.dart';
import 'core/theme/theme.dart';
import 'core/router/app_router.dart';
import 'providers/admin_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAANlfG82EembQLETC5lqolloxTaXhjnaU",
      authDomain: "who-knows-sagar.firebaseapp.com",
      databaseURL: "https://who-knows-sagar-default-rtdb.firebaseio.com",
      projectId: "who-knows-sagar",
      storageBucket: "who-knows-sagar.firebasestorage.app",
      messagingSenderId: "279924491371",
      appId: "1:279924491371:web:f3ab651c33cc3ce451dd2e",
      measurementId: "G-FYXQB093EG",
    ),
  );

  runApp(const WhoKnowsSagarApp());
}

class WhoKnowsSagarApp extends StatelessWidget {
  const WhoKnowsSagarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()..loadLocalProfile()), // 👈 Added here
      ],
      child: MaterialApp.router(
        title: 'Who Knows Sagar?',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}