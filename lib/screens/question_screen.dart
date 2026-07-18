import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_database/firebase_database.dart';
import '../core/router/app_router.dart';
import '../core/theme/colors.dart';
import '../core/theme/text_styles.dart';
import '../widgets/app_text.dart';
import '../widgets/flower_shower_background.dart';
import '../widgets/option_tile.dart';
import '../core/firebase/firebase_service.dart';
import '../providers/player_provider.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  int _currentIndex = 0;
  int? _selectedOptionIndex;
  bool _isSubmitting = false;

  // 👑 Local Cache: डेटाबेस रीलोड होताना ब्लँक स्क्रीन येऊ नये म्हणून लोकल मेमरी होल्डर
  List<MapEntry<dynamic, dynamic>> _cachedQuestions = [];

  void _handleAnswerSubmission(
      String playerId,
      String questionId,
      int totalQuestions,
      ) async {
    if (_selectedOptionIndex == null || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // १. प्लेअरचे उत्तर थेट क्लाउडवर सिंक करणे
      await FirebaseService.instance.submitAnswer(
        playerId: playerId,
        questionId: questionId,
        answerIndex: _selectedOptionIndex!,
      );

      // २. पुढच्या प्रश्नाचा फ्लो मॅनेज करणे
      if (_currentIndex < totalQuestions - 1) {
        setState(() {
          _currentIndex++;
          _selectedOptionIndex = null;
          _isSubmitting = false;
        });
      } else {
        // ३. शेवटचा प्रश्न असल्यास प्लेअरला 'Completed' मार्क करा
        await FirebaseService.instance.markCompleted(playerId);

        if (mounted) {
          debugPrint("All questions answered! Routing player to result waiting hold...");
          // 👑 🎯 बदल: थेट लीडरबोर्डवर न जाता आधी वेटिंग स्क्रीनवर पाठवणे
          context.go('/result-waiting');
        }
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Submission failed. Check connection!')),
        );
      }
    }
  }

  void _skipQuestion(String playerId, String questionId, int totalQuestions) async {
    if (_isSubmitting) return;
    setState(() {
      _selectedOptionIndex = -1;
    });
    _handleAnswerSubmission(playerId, questionId, totalQuestions);
  }

  @override
  Widget build(BuildContext context) {
    final playerProvider = Provider.of<PlayerProvider>(context);
    final String playerId = playerProvider.playerId ?? 'anonymous_user';

    return Scaffold(
      body: FlowerShowerBackground(
        child: StreamBuilder<DatabaseEvent>(
          stream: FirebaseService.instance.questionsStream,
          builder: (context, snapshot) {
            // १. जर पहिल्यांदा डेटा येत असेल आणि कॅशे रिकामी असेल, तरच लोडर दाखवा
            if (snapshot.connectionState == ConnectionState.waiting && _cachedQuestions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // २. नवीन डेटा आल्यावर लोकल कॅशे मेमरी अपडेट करा
            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              final Map<dynamic, dynamic> rawQuestions = snapshot.data!.snapshot.value as Map;

              _cachedQuestions = rawQuestions.entries.toList()
                ..sort((a, b) {
                  final int orderA = a.value['order'] ?? 0;
                  final int orderB = b.value['order'] ?? 0;
                  return orderA.compareTo(orderB);
                });
            }

            // ३. जर डेटाबेसमध्ये अजून एकही प्रश्न नसेल आणि मेमरी पण रिकामी असेल
            if (_cachedQuestions.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Waiting for host to load questions... ⏳',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }

            final totalQuestions = _cachedQuestions.length;

            if (_currentIndex >= totalQuestions) {
              return const Center(child: Text('Synchronizing game states...'));
            }

            // डेटा थेट _cachedQuestions मधून घेतला जाईल, त्यामुळे विनाकारण पूर्ण विझेट रीबिल्ड होऊन स्क्रीन हलणार नाही
            final currentQuestionKey = _cachedQuestions[_currentIndex].key.toString();
            final currentQuestionData = _cachedQuestions[_cachedQuestions.indexWhere((element) => element.key == currentQuestionKey)].value as Map;
            final String questionText = currentQuestionData['question'] ?? '';
            final List<dynamic> options = currentQuestionData['options'] ?? [];

            return Stack(
              children: [
                Positioned(
                  top: -100,
                  right: -100,
                  child: CircleAvatar(
                    radius: 160,
                    backgroundColor: AppColors.tertiaryContainer.withValues(alpha: 0.3),
                  ),
                ),
                Positioned(
                  bottom: -80,
                  left: -80,
                  child: CircleAvatar(
                    radius: 140,
                    backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.2),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // १. प्रोग्रेस बॅज
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(
                                        color: AppColors.outline.withValues(alpha: 0.4),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: AppText(
                                      "Question ${_currentIndex + 1} / $totalQuestions",
                                      style: AppTextStyles.labelLarge.copyWith(
                                        color: AppColors.text,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            WidgetQuestionCard(questionText: questionText),
                            const SizedBox(height: 32),

                            // २. ऑप्शन्स लिस्ट
                            for (int i = 0; i < options.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: OptionTile(
                                  optionText: options[i].toString(),
                                  isSelected: _selectedOptionIndex == i,
                                  isDisabled: _isSubmitting,
                                  onTap: () {
                                    setState(() {
                                      _selectedOptionIndex = i;
                                    });
                                  },
                                ),
                              ),
                            const SizedBox(height: 24),

                            // ३. मुख्य सबमिट बटण
                            FilledButton(
                              onPressed: (_selectedOptionIndex != null && !_isSubmitting)
                                  ? () => _handleAnswerSubmission(playerId, currentQuestionKey, totalQuestions)
                                  : null,
                              child: _isSubmitting
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                                  : AppText(
                                _currentIndex == totalQuestions - 1
                                    ? 'माझं झालं! आता स्टेजकडे बघा 👑'
                                    : 'झालाय निर्णय, पुढचा घ्या! 🎯',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // ४. स्किप बटण
                            TextButton(
                              onPressed: !_isSubmitting
                                  ? () => _skipQuestion(playerId, currentQuestionKey, totalQuestions)
                                  : null,
                              child: const AppText(
                                'नो कमेंट्स, पुढचा प्रश्न! 🤫',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class WidgetQuestionCard extends StatelessWidget {
  const WidgetQuestionCard({
    super.key,
    required this.questionText,
  });

  final String questionText;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.all(28.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.outline.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: AppText(
            questionText,
            style: AppTextStyles.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.35,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}