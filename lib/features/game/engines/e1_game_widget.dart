import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/card_model.dart';
import '../../../core/models/game_state.dart';

class E1GameWidget extends StatefulWidget {
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
  State<E1GameWidget> createState() => _E1GameWidgetState();
}

class _E1GameWidgetState extends State<E1GameWidget> {
  int? _selectedCardIndex;

  @override
  Widget build(BuildContext context) {
    final isJudge = widget.gameState.judgeId == widget.player.id;
    final isJudgingPhase = widget.gameState.phase == GamePhase.judging;
    final judge = widget.gameState.players.firstWhere(
      (p) => p.id == widget.gameState.judgeId,
      orElse: () => widget.player,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.surfaceDark,
            AppTheme.backgroundBlack,
          ],
        ),
      ),
      child: Column(
        children: [
          // Header HUD
          _buildHeader(judge),
          
          // Prompt Card Area
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Prompt Card
                  _buildPromptCard(),
                  
                  // Content Area
                  _buildContent(isJudge, isJudgingPhase),
                ],
              ),
            ),
          ),
          
          // Player Hand (Non-Judge, Non-Judging Phase)
          if (!isJudge && !isJudgingPhase)
            _buildPlayerHand(),
        ],
      ),
    );
  }

  Widget _buildHeader(Player judge) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundBlack.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Room Code
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.meeting_room, color: Colors.white54, size: 16),
                const SizedBox(width: 6),
                Text(
                  widget.gameState.roomCode,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ],
            ),
          ),
          // Judge Indicator
          Row(
            children: [
              Text(judge.avatarUrl ?? '👤', style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('JUDGE', style: TextStyle(color: AppTheme.primaryCyan, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  Text(judge.nickname, style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ],
          ),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: AppTheme.primaryCyan, size: 16),
                const SizedBox(width: 6),
                Text('0:45', style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptCard() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.white.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 0),
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          children: [
            // Watermark
            Align(
              alignment: Alignment.topLeft,
              child: Icon(Icons.extension, color: Colors.grey.shade300, size: 24),
            ),
            const SizedBox(height: 16),
            // Prompt Text
            Text(
              widget.promptCard.text,
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Sponsor Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_bar, color: Colors.amber.shade700, size: 14),
                  const SizedBox(width: 8),
                  Text(
                    'Sponsored by The Local Pub',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }

  Widget _buildContent(bool isJudge, bool isJudgingPhase) {
    // JUDGING PHASE - Judge picks winner
    if (isJudgingPhase) {
      if (!isJudge) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.hourglass_top, color: AppTheme.primaryCyan, size: 48),
              const SizedBox(height: 16),
              Text(
                'The Judge is deciding...',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms, color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
        );
      }

      // Judge sees submissions
      final submissionList = widget.gameState.submissions?.entries.toList() ?? [];
      
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PICK THE WINNER',
              style: TextStyle(color: AppTheme.primaryCyan, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2),
            ),
            const SizedBox(height: 16),
            ...submissionList.asMap().entries.map((entry) {
              final index = entry.key;
              final submission = entry.value;
              final playerId = submission.key;
              final cardId = submission.value;
              final cardText = widget.gameState.activeDeck?.content
                  .firstWhere((c) => c.id == cardId, orElse: () => CardModel(id: '', text: '???')).text ?? '???';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () async {
                    await HapticFeedback.mediumImpact();
                    widget.onPickWinner(playerId);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      cardText,
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1),
              );
            }),
          ],
        ),
      );
    }

    // SUBMITTING PHASE - Judge waits
    if (isJudge) {
      final submittedCount = widget.gameState.submissions?.length ?? 0;
      final totalPlayers = widget.gameState.players.length - 1; // Exclude judge
      
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text(
              'Waiting for submissions...',
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$submittedCount',
                  style: TextStyle(color: AppTheme.primaryCyan, fontSize: 48, fontWeight: FontWeight.bold),
                ),
                Text(
                  ' / $totalPlayers',
                  style: TextStyle(color: Colors.white54, fontSize: 48),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'players submitted',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Player - show instructions
    final hasSubmitted = widget.gameState.submissions?.containsKey(widget.player.id) ?? false;
    if (hasSubmitted) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryCyan.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: AppTheme.primaryCyan, size: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'Card Submitted!',
              style: TextStyle(color: AppTheme.primaryCyan, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting for others...',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Text(
        'Choose a card from your hand below',
        style: TextStyle(color: Colors.white54, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPlayerHand() {
    final hand = widget.gameState.playerHands?[widget.player.id] ?? [];
    final hasSubmitted = widget.gameState.submissions?.containsKey(widget.player.id) ?? false;
    
    if (hasSubmitted || hand.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 180,
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.backgroundBlack,
          ],
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: hand.length,
        itemBuilder: (context, index) {
          final card = hand[index];
          final isSelected = _selectedCardIndex == index;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedCardIndex = index);
                HapticFeedback.lightImpact();
              },
              onDoubleTap: () async {
                await HapticFeedback.mediumImpact();
                widget.onSubmit(card.id);
              },
              child: Transform.translate(
                offset: Offset(0, isSelected ? -20.0 : 0.0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected 
                      ? Border.all(color: AppTheme.primaryCyan, width: 3)
                      : null,
                    boxShadow: isSelected
                      ? AppTheme.neonCyanGlow
                      : [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.text,
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryCyan,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'DOUBLE TAP',
                            style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: (50 * index).ms).slideY(begin: 0.2),
          );
        },
      ),
    );
  }
}
