import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_database/firebase_database.dart';
import '../core/router/app_router.dart';
import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../widgets/app_text.dart';
import '../widgets/flower_shower_background.dart';
import '../core/firebase/firebase_service.dart';

class ResultWaitingScreen extends StatefulWidget {
  const ResultWaitingScreen({super.key});

  @override
  State<ResultWaitingScreen> createState() => _ResultWaitingScreenState();
}

class _ResultWaitingScreenState extends State<ResultWaitingScreen> with SingleTickerProviderStateMixin {
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

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _setupResultListener();
  }

  void _setupResultListener() {
    _gameStreamSubscription = FirebaseService.instance.gameStream.listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> gameData = event.snapshot.value as Map;
        final bool isResultPublished = gameData['isResultPublished'] ?? false;

        if (isResultPublished && mounted) {
          context.go(AppRouter.leaderboard);
        }
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _gameStreamSubscription?.cancel(); // मेमरी सुरक्षित करण्यासाठी सबस्क्रिप्शन बंद
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlowerShowerBackground(
        child: Stack(
          children: [
            // बॅकग्राउंड डेकोरेशन सर्कल्स
            Positioned(
              top: -100,
              right: -100,
              child: CircleAvatar(
                radius: 160,
                backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.3),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: CircleAvatar(
                radius: 140,
                backgroundColor: AppColors.tertiaryContainer.withValues(alpha: 0.4),
              ),
            ),

            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // १. पल्सिंग ट्रॉफी आयकॉन विझेट
                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.outline.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: const Text('🏆', style: TextStyle(fontSize: 56)),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // २. मुख्य माहिती कार्ड (ग्लासमॉर्फिक फील)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.outline.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  AppText(
                                    'उत्तर सबमिट झालंय! 🥳',
                                    style: AppTextStyles.headlineMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.text,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  // 🎯 रिफाइंड सोपा आणि कडक मराठी मेसेज
                                  AppText(
                                    'तुमची सर्व उत्तरे सुरक्षितपणे सेव्ह झाली आहेत! 🥳 आता स्टेजकडे लक्ष ठेवा, काहीच वेळात फायनल निकाल जाहीर होईल! 👑',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      color: AppColors.subText,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 44),

                        // ३. सिंपल लोडर आणि वेटिंग स्टेटस संदेश
                        Column(
                          children: [
                            const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppText(
                              'निकाल जाहीर होण्याची प्रतीक्षा करत आहे... ⏳',
                              style: AppTextStyles.labelLarge.copyWith(
                                color: AppColors.subText,
                              ),
                            ),
                          ],
                        ),
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