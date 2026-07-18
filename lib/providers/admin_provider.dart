import 'package:flutter/material.dart';
import '../core/firebase/firebase_service.dart';

class AdminProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // 1. Explicit Start Quiz Method with Safety Check
  Future<void> startGame() async {
    _setLoading(true);
    try {
      final totalQuestions = await FirebaseService.instance.getQuestionCount();
      if (totalQuestions == 0) {
        throw Exception('Please add questions first.');
      }
      await FirebaseService.instance.startGame();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 2. Explicit End Quiz Method
  Future<void> endGame() async {
    _setLoading(true);
    try {
      await FirebaseService.instance.endGame();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 3. Calculate and Publish Results Together
  Future<void> showResults() async {
    _setLoading(true);
    try {
      await FirebaseService.instance.calculateResults();
      await FirebaseService.instance.publishResult();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 4. Clean Unpublish via Service Layer
  Future<void> unpublishResults() async {
    _setLoading(true);
    try {
      await FirebaseService.instance.unpublishResult();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 5. Reset All Match States
  Future<void> resetGame() async {
    _setLoading(true);
    try {
      await FirebaseService.instance.resetGame();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // 6. Clean Add/Overwrite Question with Complete Map & String Trimming
  Future<void> addQuestion({
    required int order,
    required String question,
    required List<String> options,
    required int correctOption,
    required int points,
  }) async {
    _setLoading(true);
    try {
      final String qId = 'q$order';

      // Sanitizing inputs using modern functional approach
      final String trimmedQuestion = question.trim();
      final List<String> trimmedOptions = options.map((e) => e.trim()).toList();

      await FirebaseService.instance.addQuestion(
        questionId: qId,
        question: trimmedQuestion,
        options: trimmedOptions,
        correctOption: correctOption,
        points: points,
        order: order,
      );
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}