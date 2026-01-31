import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/card_model.dart';
import '../../../core/models/game_state.dart';

class E2GameWidget extends StatelessWidget {
  final GameState gameState;
  final Player player;
  final CardModel promptCard;
  final Function(String) onVote;
  final VoidCallback onNextRound;

  const E2GameWidget({
    super.key,
    required this.gameState,
    required this.player,
    required this.promptCard,
    required this.onVote,
    required this.onNextRound,
  });

  @override
  Widget build(BuildContext context) {
    // Phase check
    if (gameState.phase == GamePhase.revealing) {
      return _buildResultsView(context);
    }
    return _buildVotingView(context);
  }

  Widget _buildVotingView(BuildContext context) {
    final hasVoted = gameState.submissions?.containsKey(player.id) ?? false;

    return Column(
      children: [
        // Prompt
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          color: Colors.black,
          child: Text(
            promptCard.text,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryCyan,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        if (hasVoted)
          const Expanded(
            child: Center(
              child: Text(
                'Waiting for others to vote...',
                style: TextStyle(color: AppTheme.primaryCyan, fontSize: 20),
              ),
            ),
          )
        else
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: gameState.players.length,
              itemBuilder: (context, index) {
                final p = gameState.players[index];
                return GestureDetector(
                  onTap: () => onVote(p.id),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGrey,
                      border: Border.all(color: AppTheme.primaryCyan.withAlpha(100)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.secondaryPink,
                          child: Text(
                             p.avatarUrl ?? p.nickname[0].toUpperCase(),
                             style: TextStyle(
                               fontSize: p.avatarUrl != null ? 30 : 20, 
                               fontWeight: FontWeight.bold
                             ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p.nickname,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().scale(delay: (50 * index).ms);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildResultsView(BuildContext context) {
    // Calculate Winner
    final votes = gameState.submissions ?? {};
    final voteCounts = <String, int>{};
    
    for (var targetId in votes.values) {
      voteCounts[targetId] = (voteCounts[targetId] ?? 0) + 1;
    }

    // Sort by votes
    final sortedIds = voteCounts.keys.toList()
      ..sort((a, b) => voteCounts[b]!.compareTo(voteCounts[a]!));
    
    final winnerId = sortedIds.isNotEmpty ? sortedIds.first : null;
    final winner = winnerId != null 
        ? gameState.players.firstWhere((p) => p.id == winnerId, orElse: () => Player(id: '', nickname: 'Unknown')) 
        : null;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'THE GROUP VOTED:',
          style: TextStyle(color: Colors.white54, letterSpacing: 2),
        ),
        const SizedBox(height: 24),
        if (winner != null) ...[
          CircleAvatar(
            radius: 60,
            backgroundColor: AppTheme.secondaryPink,
              child: Text(
               winner.avatarUrl ?? winner.nickname[0].toUpperCase(),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
          const SizedBox(height: 16),
          Text(
            winner.nickname,
            style: const TextStyle(
              color: AppTheme.primaryCyan,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Received ${voteCounts[winnerId]} votes',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
        const SizedBox(height: 48),
        if (player.isHost)
          ElevatedButton.icon(
            onPressed: onNextRound,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('NEXT ROUND'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryCyan,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          )
        else
          const Text('Waiting for Host...', style: TextStyle(color: Colors.white54)),
      ],
    );
  }
}
