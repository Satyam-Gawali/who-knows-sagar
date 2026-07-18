import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/firebase/firebase_service.dart';
import '../providers/admin_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return const _AdminScreenContent();
  }
}

class _AdminScreenContent extends StatefulWidget {
  const _AdminScreenContent();

  @override
  State<_AdminScreenContent> createState() => _AdminScreenContentState();
}

class _AdminScreenContentState extends State<_AdminScreenContent> {
  final _questionController = TextEditingController();
  final _opt0Controller = TextEditingController();
  final _opt1Controller = TextEditingController();
  final _opt2Controller = TextEditingController();
  final _opt3Controller = TextEditingController();
  final _correctController = TextEditingController();
  final _pointsController = TextEditingController(text: "10");
  final _orderController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _questionController.dispose();
    _opt0Controller.dispose();
    _opt1Controller.dispose();
    _opt2Controller.dispose();
    _opt3Controller.dispose();
    _correctController.dispose();
    _pointsController.dispose();
    _orderController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _populateFormForEdit(Map<dynamic, dynamic> qValue) {
    setState(() {
      _orderController.text = (qValue['order'] ?? '').toString();
      _pointsController.text = (qValue['points'] ?? '10').toString();
      _questionController.text = qValue['question'] ?? '';

      final List<dynamic> options = qValue['options'] ?? [];
      _opt0Controller.text = options.isNotEmpty ? options[0].toString() : '';
      _opt1Controller.text = options.length > 1 ? options[1].toString() : '';
      _opt2Controller.text = options.length > 2 ? options[2].toString() : '';
      _opt3Controller.text = options.length > 3 ? options[3].toString() : '';

      _correctController.text = (qValue['correctOption'] ?? '').toString();
    });

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Question No. ${_orderController.text} loaded to edit! ✏️')),
    );
  }

  void _showResetConfirmation(BuildContext context, AdminProvider provider, ColorScheme colorScheme) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: Icon(Icons.delete_forever_rounded, color: colorScheme.error, size: 40),
          title: const Text('Delete Everything?'),
          content: const Text(
              'Are you sure you want to delete all questions and reset player points?\n\n'
                  'This will clear the entire game database!'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('No, Cancel', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await provider.resetGame();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🧹 Database cleared successfully!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('❌ Reset failed!')),
                    );
                  }
                }
              },
              child: const Text('Yes, Wipe Data'),
            ),
          ],
        );
      },
    );
  }

  void _submitQuestion(AdminProvider provider) async {
    if (_questionController.text.isEmpty || _orderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Please fill Question No. and Title!')),
      );
      return;
    }

    try {
      final int parsedOrder = int.parse(_orderController.text.trim());
      final int parsedPoints = int.parse(_pointsController.text.trim());
      final int parsedCorrect = int.parse(_correctController.text.trim());

      await provider.addQuestion(
        order: parsedOrder,
        question: _questionController.text.trim(),
        options: [
          _opt0Controller.text.trim(),
          _opt1Controller.text.trim(),
          _opt2Controller.text.trim(),
          _opt3Controller.text.trim(),
        ],
        correctOption: parsedCorrect,
        points: parsedPoints,
      );

      _questionController.clear();
      _opt0Controller.clear();
      _opt1Controller.clear();
      _opt2Controller.clear();
      _opt3Controller.clear();
      _correctController.clear();
      _orderController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🚀 Question saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error saving question! Please check numbers.')),
        );
      }
    }
  }

  // 👑 रँक कलर्स मॅपिंग हेल्पर
  Color _getRankColor(int rank, ColorScheme scheme) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey[400]!;
    if (rank == 3) return Colors.brown[400]!;
    return scheme.surfaceContainerHighest;
  }

  // 👑 पोडियम युझर विजेट बिल्डर
  Widget _buildAdminPodiumUser(String name, String rank, Color color, double height, int score, {bool isFirst = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFirst) const Text('👑', style: TextStyle(fontSize: 22)),
        CircleAvatar(
          radius: isFirst ? 24 : 20,
          backgroundColor: color.withValues(alpha: 0.2),
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'P',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text('$score Pts', style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          width: 50,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
          ),
          child: Center(
            child: Text(
              rank,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Haldi Quiz - Admin Panel'),
        centerTitle: true,
        bottom: adminProvider.isLoading
            ? PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(color: colorScheme.primary),
        )
            : null,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseService.instance.gameStream,
        builder: (context, snapshot) {
          Map<dynamic, dynamic> gameData = {};
          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            gameData = snapshot.data!.snapshot.value as Map;
          }

          final bool isStarted = gameData['isStarted'] ?? false;
          final bool isPublished = gameData['isResultPublished'] ?? false;
          final bool gameEnded = gameData['gameEnded'] ?? false;
          final int totalQuestions = gameData['totalQuestions'] ?? 0;

          return StreamBuilder<DatabaseEvent>(
            stream: FirebaseService.instance.playersStream,
            builder: (context, playersSnapshot) {
              Map<dynamic, dynamic> globalPlayers = {};
              int completedCount = 0;
              int activeCount = 0;

              if (playersSnapshot.hasData && playersSnapshot.data!.snapshot.value != null) {
                globalPlayers = playersSnapshot.data!.snapshot.value as Map;
                for (var p in globalPlayers.values) {
                  if (p is Map) {
                    if (p['isCompleted'] == true) {
                      completedCount++;
                    } else {
                      activeCount++;
                    }
                  }
                }
              }

              final int totalPlayers = completedCount + activeCount;

              final List<MapEntry<dynamic, dynamic>> sortedPlayers = globalPlayers.entries.toList()
                ..sort((a, b) {
                  final int rankA = (a.value as Map)['rank'] ?? 999;
                  final int rankB = (b.value as Map)['rank'] ?? 999;
                  return rankA.compareTo(rankB);
                });

              return SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SECTION 1: GAME STATUS
                    const Text('📊 GAME STATUS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 2,
                      color: Colors.grey[200],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Quiz Active:', style: TextStyle(fontSize: 15)),
                                Text(
                                  isStarted ? '🔴 LIVE' : '⚪ OFF',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isStarted ? Colors.green : Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Result Published:', style: TextStyle(fontSize: 15)),
                                Text(
                                  isPublished ? '📢 SHOWN' : '🔒 HIDDEN',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isPublished ? Colors.purple : Colors.orange),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Game Ended Status:', style: TextStyle(fontSize: 15)),
                                Text(
                                  gameEnded ? 'TERMINATED' : 'RUNNING',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: gameEnded ? Colors.red : Colors.teal),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Questions Counter:', style: TextStyle(fontSize: 15)),
                                Text(
                                  '$totalQuestions',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 2: SMART CONTROLS
                    const Text('🕹️ SMART CONTROLS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: isStarted ? Colors.red : Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: (adminProvider.isLoading || isPublished)
                                ? null
                                : () async {
                              if (isStarted) {
                                await adminProvider.endGame();
                              } else {
                                await adminProvider.startGame();
                              }
                            },
                            icon: Icon(isStarted ? Icons.stop : Icons.play_arrow),
                            label: Text(isStarted ? 'Stop Quiz' : 'Start Quiz', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: isPublished ? Colors.deepPurple : Colors.orange[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: (adminProvider.isLoading || !isStarted)
                                ? null
                                : () async {
                              if (isPublished) {
                                await adminProvider.unpublishResults();
                              } else {
                                await adminProvider.showResults();
                              }
                            },
                            icon: Icon(isPublished ? Icons.visibility_off : Icons.emoji_events),
                            label: Text(isPublished ? 'Hide Result' : 'Show Result', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.error),
                          foregroundColor: colorScheme.error,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: adminProvider.isLoading
                            ? null
                            : () => _showResetConfirmation(context, adminProvider, colorScheme),
                        icon: const Icon(Icons.refresh),
                        label: const Text('RESET ALL GAME DATA', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // SECTION: LIVE QUIZ PROGRESS OVERVIEW
                    const Text('🍰 LIVE QUIZ PROGRESS TRACKER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 14),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
                        child: totalPlayers == 0
                            ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No active players to graph... 📈', style: TextStyle(color: Colors.grey)),
                          ),
                        )
                            : Row(
                          children: [
                            SizedBox(
                              width: 110,
                              height: 110,
                              child: PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 25,
                                  sections: [
                                    PieChartSectionData(
                                      color: Colors.green,
                                      value: completedCount.toDouble(),
                                      title: completedCount > 0 ? '$completedCount' : '',
                                      radius: 25,
                                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    PieChartSectionData(
                                      color: Colors.orange,
                                      value: activeCount.toDouble(),
                                      title: activeCount > 0 ? '$activeCount' : '',
                                      radius: 25,
                                      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Registered: $totalPlayers', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Container(width: 10, height: 10, color: Colors.green),
                                      const SizedBox(width: 6),
                                      Text('Done: $completedCount Players', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(width: 10, height: 10, color: Colors.orange),
                                      const SizedBox(width: 6),
                                      Text('Playing Live: $activeCount Players', style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // ----------------------------------------
                    // 👑 👑 👑 👑 SECTION 3: THE FINAL LEADERBOARD STYLE FOR ADMIN 👑 👑 👑 👑
                    // ----------------------------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('🏆 LIVE LEADERBOARD CONTENT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(6)),
                          child: Text('Live Update', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    Builder(
                      builder: (context) {
                        if (globalPlayers.isEmpty) {
                          return const Card(
                            // width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No players joined yet.', style: TextStyle(color: Colors.grey), textAlign: TextAlign.center),
                            ),
                          );
                        }

                        final Map<String, dynamic>? firstPlace = sortedPlayers.isNotEmpty ? Map<String, dynamic>.from(sortedPlayers[0].value as Map) : null;
                        final Map<String, dynamic>? secondPlace = sortedPlayers.length > 1 ? Map<String, dynamic>.from(sortedPlayers[1].value as Map) : null;
                        final Map<String, dynamic>? thirdPlace = sortedPlayers.length > 2 ? Map<String, dynamic>.from(sortedPlayers[2].value as Map) : null;

                        return Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (secondPlace != null)
                                    _buildAdminPodiumUser(secondPlace['name'] ?? 'Player', '2', Colors.grey[400]!, 50, secondPlace['score'] ?? 0),
                                  if (firstPlace != null)
                                    _buildAdminPodiumUser(firstPlace['name'] ?? 'Player', '1', Colors.amber, 70, firstPlace['score'] ?? 0, isFirst: true),
                                  if (thirdPlace != null)
                                    _buildAdminPodiumUser(thirdPlace['name'] ?? 'Player', '3', Colors.brown[400]!, 40, thirdPlace['score'] ?? 0),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 👑 २. बाकी खेळाडूंची देखणी रँक लिस्ट
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: sortedPlayers.length,
                              itemBuilder: (context, index) {
                                final Map<dynamic, dynamic> pValue = sortedPlayers[index].value as Map;
                                final String name = pValue['name'] ?? 'Guest';
                                final int score = pValue['score'] ?? 0;
                                final int rank = pValue['rank'] ?? (index + 1);
                                final bool isDone = pValue['isCompleted'] ?? false;

                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  elevation: 1,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey[200]!, width: 1),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      backgroundColor: _getRankColor(rank, colorScheme),
                                      child: Text(
                                        '$rank',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: rank <= 3 ? Colors.white : colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    subtitle: Text(
                                      isDone ? '✅ Submissions Closed' : '⏳ Playing Live...',
                                      style: TextStyle(fontSize: 11, color: isDone ? Colors.green : Colors.orange[800]),
                                    ),
                                    trailing: Text(
                                      '$score Pts',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.blueGrey),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // SECTION 4: ADD / EDIT QUESTION FORM
                    const Text('➕ ADD / EDIT QUESTION', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text(
                      'To edit, use the same Question No. and rewrite fields.',
                      style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _orderController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Question No.', border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _pointsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Points', border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _questionController,
                      decoration: const InputDecoration(labelText: 'Question Title', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _opt0Controller,
                      decoration: const InputDecoration(labelText: 'Option 0', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _opt1Controller,
                      decoration: const InputDecoration(labelText: 'Option 1', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _opt2Controller,
                      decoration: const InputDecoration(labelText: 'Option 2', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _opt3Controller,
                      decoration: const InputDecoration(labelText: 'Option 3', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _correctController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Correct Index (0-3)', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: (adminProvider.isLoading || isPublished) ? null : () => _submitQuestion(adminProvider),
                        icon: const Icon(Icons.save),
                        label: const Text('Save / Overwrite Question 💾', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // SECTION 5: QUESTION ARCHIVE LIST WITH LIVE OPTION CHARTS
                    const Text('📚 SAVED QUESTIONS LIST & LIVE ANALYSIS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    StreamBuilder<DatabaseEvent>(
                      stream: FirebaseService.instance.questionsStream,
                      builder: (context, qSnapshot) {
                        if (qSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!qSnapshot.hasData || qSnapshot.data!.snapshot.value == null) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Text('No questions added yet.', style: TextStyle(color: Colors.grey)),
                          );
                        }

                        final Map<dynamic, dynamic> rawQuestions = qSnapshot.data!.snapshot.value as Map;

                        final List<MapEntry<dynamic, dynamic>> sortedList = rawQuestions.entries.toList()
                          ..sort((a, b) {
                            final int orderA = a.value['order'] ?? 0;
                            final int orderB = b.value['order'] ?? 0;
                            return orderA.compareTo(orderB);
                          });

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sortedList.length,
                          itemBuilder: (context, index) {
                            final String questionId = sortedList[index].key.toString();
                            final qValue = sortedList[index].value as Map;
                            final List<dynamic> options = qValue['options'] ?? [];
                            final int correctIndex = qValue['correctOption'] ?? 0;

                            List<int> optionCounts = [0, 0, 0, 0];
                            int totalAnswersForThisQuestion = 0;

                            for (var p in globalPlayers.values) {
                              if (p is Map && p.containsKey('answers')) {
                                final Map<dynamic, dynamic>? playerAnswers = p['answers'] is Map ? p['answers'] as Map : null;
                                if (playerAnswers != null && playerAnswers.containsKey(questionId)) {
                                  final Map<dynamic, dynamic>? specificAnswer = playerAnswers[questionId] is Map ? playerAnswers[questionId] as Map : null;
                                  if (specificAnswer != null && specificAnswer.containsKey('answerIndex')) {
                                    final int selectedIndex = specificAnswer['answerIndex'] ?? -1;
                                    if (selectedIndex >= 0 && selectedIndex < 4) {
                                      optionCounts[selectedIndex]++;
                                      totalAnswersForThisQuestion++;
                                    }
                                  }
                                }
                              }
                            }

                            final List<Color> chartColors = [Colors.blue, Colors.purple, Colors.teal, Colors.amber];

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              elevation: 1,
                              child: ExpansionTile(
                                leading: CircleAvatar(
                                  backgroundColor: colorScheme.primaryContainer,
                                  child: Text('${qValue['order'] ?? index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onPrimaryContainer)),
                                ),
                                title: Text(qValue['question'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Points: ${qValue['points'] ?? 10} • Responses: $totalAnswersForThisQuestion'),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (totalAnswersForThisQuestion > 0) ...[
                                          const Text('📊 वऱ्हाडी पाहुण्यांचा कल (Response Analysis):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 80,
                                                height: 80,
                                                child: PieChart(
                                                  PieChartData(
                                                    sectionsSpace: 1,
                                                    centerSpaceRadius: 15,
                                                    sections: [
                                                      for (int i = 0; i < 4; i++)
                                                        if (optionCounts[i] > 0)
                                                          PieChartSectionData(
                                                            color: chartColors[i],
                                                            value: optionCounts[i].toDouble(),
                                                            title: '$optionCounts[i]',
                                                            radius: 20,
                                                            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                                                          ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              Expanded(
                                                child: Wrap(
                                                  spacing: 8,
                                                  runSpacing: 4,
                                                  children: [
                                                    for (int i = 0; i < options.length; i++)
                                                      if (optionCounts[i] > 0)
                                                        Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Container(
                                                                width: 8,
                                                                height: 8,
                                                                color: chartColors[i]
                                                            ),
                                                            const SizedBox(width: 4),
                                                            Text('Opt $i (${optionCounts[i]})', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                                                          ],
                                                        ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                        ],

                                        for (int i = 0; i < options.length; i++)
                                          Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.symmetric(vertical: 2),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: i == correctIndex ? Colors.green[50] : Colors.grey[50],
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: i == correctIndex ? Colors.green : Colors.grey[300]!,
                                                width: i == correctIndex ? 1.5 : 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    'Option $i: ${options[i]} ${i == correctIndex ? "✅" : ""}',
                                                    style: TextStyle(
                                                      fontWeight: i == correctIndex ? FontWeight.bold : FontWeight.normal,
                                                      color: i == correctIndex ? Colors.green[800] : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                      color: chartColors[i].withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(4)
                                                  ),
                                                  child: Text('${optionCounts[i]} मतं', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: chartColors[i])),
                                                ),
                                              ],
                                            ),
                                          ),
                                        const SizedBox(height: 10),
                                        SizedBox(
                                          width: double.infinity,
                                          child: OutlinedButton.icon(
                                            onPressed: isPublished ? null : () => _populateFormForEdit(qValue),
                                            icon: const Icon(Icons.edit),
                                            label: const Text('Edit This Question'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}