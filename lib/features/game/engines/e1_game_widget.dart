import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/card_model.dart';
import '../../../core/models/game_state.dart';

class E1GameWidget extends StatelessWidget {
  final GameState gameState;
  final Player player;
  final CardModel promptCard;
  final Function(String) onSubmit;
  final Function(String) onPickWinner;

  const E1GameWidget({
    super.key,
    required this.gameState,
    required this.player,
    required this.promptCard,
    required this.onSubmit,
    required this.onPickWinner,
  });

  @override
  Widget build(BuildContext context) {
    final isJudge = gameState.judgeId == player.id;
    final isJudgingPhase = gameState.phase == GamePhase.judging;

    return Column(
      children: [
        // Prompt Card Area
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          color: Colors.black, // Stark black for contrast
          child: Column(
            children: [
              Text(
                'JUDGE: ${gameState.players.firstWhere((p) => p.id == gameState.judgeId).nickname}',
                style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                promptCard.text,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              // Sponsored Bar Injection
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                     Icon(Icons.local_bar, color: Colors.amber, size: 14),
                     SizedBox(width: 8),
                     Text('Sponsored by The Local Pub', style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Container(
            color: AppTheme.surfaceGrey,
            child: _buildContent(context, isJudge, isJudgingPhase),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, bool isJudge, bool isJudgingPhase) {
    // 1. JUDGING PHASE (Judge picks winner)
    if (isJudgingPhase) {
      if (!isJudge) {
        return const Center(child: Text('Judge is picking a winner...', style: TextStyle(color: Colors.white)));
      }

      // Show anonymous submissions
      final submissionList = gameState.submissions?.entries.toList() ?? [];
      
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: submissionList.length,
        itemBuilder: (context, index) {
          final entry = submissionList[index];
          final playerId = entry.key; // Winner ID
          final cardId = entry.value; 
          
          final cardText = gameState.activeDeck?.content.firstWhere((c) => c.id == cardId, orElse: () => CardModel(id: '', text: '???')).text ?? 'Unknown';

          return GestureDetector(
            onTap: () async {
               await HapticFeedback.mediumImpact();
               onPickWinner(playerId);
            },
            child: Container(
               margin: const EdgeInsets.only(bottom: 16),
               padding: const EdgeInsets.all(24),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(16),
               ),
               child: Text(
                 cardText,
                 style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
               ),
            ),
          ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.2, end: 0);
        },
      );
    }

    // 2. SUBMITTING PHASE
    if (isJudge) {
      return const Center(
        child: Text(
          'Waiting for players to submit...',
          style: TextStyle(color: Colors.white54, fontSize: 18),
        ),
      );
    }

    // Player View: Show Hand
    final hand = gameState.playerHands?[player.id] ?? [];
    final hasSubmitted = gameState.submissions?.containsKey(player.id) ?? false;

    if (hasSubmitted) {
      return const Center(child: Text('Submitted! Waiting for others...', style: TextStyle(color: AppTheme.secondaryPink)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: hand.length,
      itemBuilder: (context, index) {
        final card = hand[index];
        return GestureDetector(
          onTap: () async {
             await HapticFeedback.lightImpact(); 
             onSubmit(card.id);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                card.text,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ).animate().scale(delay: (50 * index).ms);
      },
    );
  }
}
