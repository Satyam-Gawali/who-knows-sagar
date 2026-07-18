import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import '../core/firebase/firebase_service.dart';
import '../providers/leaderboard_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LeaderboardProvider()..loadCurrentPlayer(),
      child: const _LeaderboardContent(),
    );
  }
}

class _LeaderboardContent extends StatelessWidget {
  const _LeaderboardContent();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LeaderboardProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Final Leaderboard'),
        centerTitle: true,
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseService.instance.gameStream, // 👑 आधी गेमच्या मुख्य डेटावर लक्ष ठेवू
        builder: (context, gameSnapshot) {

          return StreamBuilder<DatabaseEvent>(
            stream: FirebaseService.instance.playersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                return const Center(
                  child: Text('No players joined yet.', style: TextStyle(color: Colors.grey)),
                );
              }

              final Map<dynamic, dynamic> rawPlayers = snapshot.data!.snapshot.value as Map;
              final List<MapEntry<dynamic, dynamic>> sortedPlayers = rawQuestionsList(rawPlayers);

              // 👑 🎯 फिक्स: डेटाबेसमधून अचूक प्रश्नांचा काऊंट आणणे
              int totalQuestionsCount = 3; // डीफॉल्ट बॅकअप ३ ठेऊ
              if (gameSnapshot.hasData && gameSnapshot.data!.snapshot.value != null) {
                final Map<dynamic, dynamic> gameData = gameSnapshot.data!.snapshot.value as Map;
                totalQuestionsCount = gameData['totalQuestions'] ?? sortedPlayers.length;
              }

              final Map<String, dynamic>? firstPlace = sortedPlayers.isNotEmpty ? Map<String, dynamic>.from(sortedPlayers[0].value) : null;
              final Map<String, dynamic>? secondPlace = sortedPlayers.length > 1 ? Map<String, dynamic>.from(sortedPlayers[1].value) : null;
              final Map<String, dynamic>? thirdPlace = sortedPlayers.length > 2 ? Map<String, dynamic>.from(sortedPlayers[2].value) : null;

              return Column(
                children: [
                  // विभाग १: टॉप ३ विजेत्यांचे पोडियम
                  if (sortedPlayers.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      color: colorScheme.surfaceContainerLow,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (secondPlace != null)
                            _buildPodiumUser(secondPlace['name'] ?? 'Player', '2', Colors.grey[400]!, 65, secondPlace['score'] ?? 0),
                          if (firstPlace != null)
                            _buildPodiumUser(firstPlace['name'] ?? 'Player', '1', Colors.amber, 85, firstPlace['score'] ?? 0, isFirst: true),
                          if (thirdPlace != null)
                            _buildPodiumUser(thirdPlace['name'] ?? 'Player', '3', Colors.brown[400]!, 55, thirdPlace['score'] ?? 0),
                        ],
                      ),
                    ),

                  // 👑 🎯 बदललेला मथळा: इथे आता अचूक प्रश्नांची संख्या दिसेल (उदा. ३ प्रश्न)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '🎯 STANDINGS (TOTAL QUESTIONS: $totalQuestionsCount)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                  ),

                  // विभाग २: बाकीच्या प्लेअर्सची लिस्ट
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: sortedPlayers.length,
                      itemBuilder: (context, index) {
                        final String pKey = sortedPlayers[index].key;
                        final Map<dynamic, dynamic> pValue = sortedPlayers[index].value as Map;

                        final String name = pValue['name'] ?? 'Guest';
                        final int score = pValue['score'] ?? 0;
                        final int rank = pValue['rank'] ?? (index + 1);

                        final bool isMe = provider.currentPlayerId == pKey;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          elevation: isMe ? 3 : 1,
                          color: isMe ? colorScheme.primaryContainer.withOpacity(0.4) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            // border: Border.all(
                            //   color: isMe ? colorScheme.primary : Colors.grey[300]!,
                            //   width: isMe ? 1.5 : 1,
                            // ),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getRankColor(rank, colorScheme),
                              child: Text(
                                '$rank',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: rank <= 3 ? Colors.white : colorScheme.onSurface,
                                ),
                              ),
                            ),
                            title: Text(
                              name + (isMe ? ' (You) ✨' : ''),
                              style: TextStyle(
                                fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            trailing: Text(
                              '$score Pts',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  List<MapEntry<dynamic, dynamic>> rawQuestionsList(Map<dynamic, dynamic> players) {
    return players.entries.toList()
      ..sort((a, b) {
        final int rankA = a.value['rank'] ?? 999;
        final int rankB = b.value['rank'] ?? 999;
        return rankA.compareTo(rankB);
      });
  }

  Color _getRankColor(int rank, ColorScheme scheme) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey[400]!;
    if (rank == 3) return Colors.brown[400]!;
    return scheme.surfaceContainerHighest;
  }

  Widget _buildPodiumUser(String name, String rank, Color color, double height, int score, {bool isFirst = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFirst) const Text('👑', style: TextStyle(fontSize: 28)),
        CircleAvatar(
          radius: isFirst ? 28 : 24,
          backgroundColor: color.withOpacity(0.2),
          child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'P', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text('$score Pts', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              rank,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ),
      ],
    );
  }
}