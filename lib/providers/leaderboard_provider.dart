import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import '../core/firebase/firebase_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  String? _currentPlayerId;
  String? get currentPlayerId => _currentPlayerId;

  int _totalQuestions = 3; // Default backup count
  int get totalQuestions => _totalQuestions;

  List<MapEntry<dynamic, dynamic>> _sortedPlayers = [];
  List<MapEntry<dynamic, dynamic>> get sortedPlayers => _sortedPlayers;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // स्ट्रीम्सचे सब्सक्रिप्शन मॅनेज करण्यासाठी
  StreamSubscription<DatabaseEvent>? _gameSubscription;
  StreamSubscription<DatabaseEvent>? _playersSubscription;

  LeaderboardProvider() {
    _initLeaderboardPipeline();
  }

  // 🚀 संपूर्ण रिअल-टाइम डेटा पाईपलाईन सेट करणे
  Future<void> _initLeaderboardPipeline() async {
    // १. लोकल SharedPreferences मधून स्वतःचा प्लेयर आयडी शोधणे
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentPlayerId = prefs.getString('player_id');
    notifyListeners();

    // २. Game Stream ऐकणे (अचूक प्रश्नांचा संख्या काऊंट मिळवण्यासाठी)
    _gameSubscription = FirebaseService.instance.gameStream.listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> gameData = event.snapshot.value as Map;
        _totalQuestions = gameData['totalQuestions'] ?? 3;
        _isLoading = false;
        notifyListeners();
      }
    });

    // ३. Players Stream ऐकणे (पॉइंट्स आणि रँक सॉर्ट करण्यासाठी)
    _playersSubscription = FirebaseService.instance.playersStream.listen((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> rawPlayers = event.snapshot.value as Map;

        // रँकच्या आधारे अचूक क्रमाने खेळाडूंची यादी सॉर्ट करणे
        _sortedPlayers = rawPlayers.entries.toList()
          ..sort((a, b) {
            final int rankA = a.value['rank'] ?? 999;
            final int rankB = b.value['rank'] ?? 999;
            return rankA.compareTo(rankB);
          });

        _isLoading = false;
        notifyListeners();
      } else {
        _sortedPlayers = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // लोकल प्रोफाइल पुन्हा मॅन्युअली रीलोड करायची असल्यास बॅकअप मेथड
  Future<void> loadCurrentPlayer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentPlayerId = prefs.getString('player_id');
    notifyListeners();
  }

  @override
  void dispose() {
    // मेमरी लीक टाळण्यासाठी दोन्ही स्ट्रीम्स सुरक्षितपणे बंद करणे
    _gameSubscription?.cancel();
    _playersSubscription?.cancel();
    super.dispose();
  }
}