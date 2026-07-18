import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../core/firebase/firebase_service.dart';

class PlayerProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _playerId;
  String? get playerId => _playerId;

  String? _playerName;
  String? get playerName => _playerName;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Registers the player in Firebase and caches local session variables
  Future<void> joinGame(String name) async {
    _setLoading(true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Check for an existing session or construct a clean identifier
      String uId = prefs.getString('player_id') ?? const Uuid().v4();
      final String trimmedName = name.trim();

      await FirebaseService.instance.registerPlayer(
        playerId: uId,
        name: trimmedName,
      );

      // Cache state elements locally
      await prefs.setString('player_id', uId);
      await prefs.setString('player_name', trimmedName);

      _playerId = uId;
      _playerName = trimmedName;
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Load profile credentials if hot-restarting or returning to screen state
  Future<void> loadLocalProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _playerId = prefs.getString('player_id');
    _playerName = prefs.getString('player_name');
    if (_playerId != null) {
      notifyListeners();
    }
  }
}