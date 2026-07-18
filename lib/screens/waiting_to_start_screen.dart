import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_database/firebase_database.dart';
import '../core/router/app_router.dart';
import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../widgets/app_text.dart';
import '../widgets/flower_shower_background.dart';
import '../core/firebase/firebase_service.dart'; // 👑 Firebase Service चा इम्पोर्ट

class WaitingToStartScreen extends StatefulWidget {
  final String playerName;
  const WaitingToStartScreen({super.key, required this.playerName});

  @override
  State<WaitingToStartScreen> createState() => _WaitingToStartScreenState();
}

class _WaitingToStartScreenState extends State<WaitingToStartScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  StreamSubscription<DatabaseEvent>? _gameStreamSubscription;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _setupGameLiveListener();
  }

  void _setupGameLiveListener() {
    _gameStreamSubscription = FirebaseService.instance.gameStream.listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> gameData = event.snapshot.value as Map;
        final bool isStarted = gameData['isStarted'] ?? false;

        if (isStarted && mounted) {
          context.go(AppRouter.question);
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _gameStreamSubscription?.cancel(); // 👑 मेमरी लीक टाळण्यासाठी स्ट्रीम बंद करणे
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlowerShowerBackground(
        child: Stack(
          children: [
            Positioned(
              top: -100,
              left: -100,
              child: CircleAvatar(
                radius: 160,
                backgroundColor: AppColors.tertiaryContainer.withValues(alpha: 0.4),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -80,
              child: CircleAvatar(
                radius: 140,
                backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.3),
              ),
            ),

            // मुख्य कंटेंट
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryContainer,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2),
                            ),
                            child: const Text('💛', style: TextStyle(fontSize: 52)),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              AppText("Player: ${widget.playerName} ✨", style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppText('तुम्ही यशस्वीरीत्या जॉईन झालात! 🎉', style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        AppText('सागरबद्दलचे मजेशीर प्रश्न लवकरच तुमच्या स्क्रीनवर येतील. तोपर्यंत जरा धीर धरा आणि screen चालू ठेवा! 😉', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.subText, height: 1.5), textAlign: TextAlign.center),
                        const SizedBox(height: 40),
                        GestureDetector(
                          onTap: () {
                            context.go(AppRouter.question);
                          },
                          child: const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}