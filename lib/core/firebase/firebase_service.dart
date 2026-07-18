import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  final FirebaseDatabase _database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: "https://who-knows-sagar-default-rtdb.firebaseio.com",
  );

  DatabaseReference get root => _database.ref();
  DatabaseReference get game => root.child('game');
  DatabaseReference get questions => root.child('questions');
  DatabaseReference get players => root.child('players');

  // Streams
  Stream<DatabaseEvent> get gameStream => game.onValue;
  Stream<DatabaseEvent> get questionsStream => questions.onValue;
  Stream<DatabaseEvent> get playersStream => players.onValue;

  // ----------------------------------------
  // Game Actions
  // ----------------------------------------
  Future<void> startGame() async {
    await game.update({
      'isStarted': true,
      'updatedAt': ServerValue.timestamp,
    });
  }

  // Refactored to act as the exact opposite of startGame
  Future<void> endGame() async {
    await game.update({
      'isStarted': false,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> publishResult() async {
    await game.update({
      'isResultPublished': true,
      'updatedAt': ServerValue.timestamp,
    });
  }

  // ✅ Added method inside Service (Keeping Provider Clean)
  Future<void> unpublishResult() async {
    await game.update({
      'isResultPublished': false,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> resetGame() async {
    await root.set({
      'game': {
        'isStarted': false,
        'isResultPublished': false,
        'totalQuestions': 0,
        'gameEnded': false,
        'updatedAt': ServerValue.timestamp,
      },
      'questions': {},
      'players': {},
    });
  }

  // ----------------------------------------
  // Players & Calculations
  // ----------------------------------------
  Future<void> registerPlayer({required String playerId, required String name}) async {
    await players.child(playerId).set({
      'name': name,
      'avatar': '',
      'score': 0,
      'rank': 0,
      'completed': false,
      'joinedAt': ServerValue.timestamp,
    });
  }

  Future<void> markCompleted(String playerId) async {
    await players.child(playerId).update({'completed': true});
  }

  Future<void> submitAnswer({required String playerId, required String questionId, required int answerIndex}) async {
    await players.child(playerId).child('answers').child(questionId).set(answerIndex);
  }

  Future<void> calculateResults() async {
    final questionsSnapshot = await questions.get();
    final playersSnapshot = await players.get();

    if (!questionsSnapshot.exists || !playersSnapshot.exists) return;

    final questionsMap = Map<String, dynamic>.from(questionsSnapshot.value as Map);
    final playersMap = Map<String, dynamic>.from(playersSnapshot.value as Map);

    Map<String, int> playerScores = {};

    for (final playerId in playersMap.keys) {
      int score = 0;
      final player = playersMap[playerId];
      final answers = Map<String, dynamic>.from(player['answers'] ?? {});

      for (final questionId in answers.keys) {
        final question = questionsMap[questionId];
        if (question == null) continue;

        final int selected = answers[questionId];
        final int correct = question['correctOption'];
        final int points = question['points'];

        if (selected == correct) {
          score += points;
        }
      }
      playerScores[playerId] = score;
    }

    final sortedPlayers = playerScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final Map<String, Map<String, dynamic>> updates = {};

    for (int i = 0; i < sortedPlayers.length; i++) {
      final playerId = sortedPlayers[i].key;
      final score = sortedPlayers[i].value;
      final rank = i + 1;

      updates[playerId] = {
        'score': score,
        'rank': rank,
      };
    }

    for (final entry in updates.entries) {
      await players.child(entry.key).update(entry.value);
    }
  }

  Future<void> addQuestion({
    required String questionId,
    required String question,
    required List<String> options,
    required int correctOption,
    required int points,
    required int order,
  }) async {
    await questions.child(questionId).set({
      'question': question,
      'options': options,
      'correctOption': correctOption,
      'points': points,
      'order': order,
    });

    final snapshot = await questions.get();
    await game.update({
      'totalQuestions': snapshot.children.length,
    });
  }

  Future<int> getQuestionCount() async {
    final snapshot = await questions.get();
    if (!snapshot.exists) return 0;
    return snapshot.children.length;
  }
}