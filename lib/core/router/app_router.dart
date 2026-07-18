import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/welcome_screen.dart';
import '../../screens/waiting_to_start_screen.dart';
import '../../screens/question_screen.dart';
import '../../screens/admin_screen.dart';
import '../../screens/leaderboard_screen.dart';
import '../../screens/result_waiting_screen.dart'; // 👑 निकाल प्रतीक्षा स्क्रीनचा इम्पोर्ट जोडला

class AppRouter {
  AppRouter._();

  static const String welcome = '/';
  static const String lobby = '/lobby';
  static const String question = '/question';
  static const String admin = '/admin';
  static const String leaderboard = '/leaderboard';
  static const String resultWaiting = '/result-waiting'; // 👑 स्क्रीनसाठी कॉन्स्टंट पाथ

  static final GoRouter router = GoRouter(
    initialLocation: welcome,
    routes: [
      GoRoute(
        path: welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: lobby,
        builder: (context, state) {
          final playerName = state.uri.queryParameters['name'] ?? 'Guest';
          return WaitingToStartScreen(playerName: playerName);
        },
      ),
      GoRoute(
        path: question,
        builder: (context, state) => const QuestionScreen(),
      ),
      GoRoute(
        path: admin,
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: leaderboard,
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: resultWaiting,
        builder: (context, state) => const ResultWaitingScreen(),
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Page not found!'),
      ),
    ),
  );
}