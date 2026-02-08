import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/card_model.dart';
import '../../../core/models/game_state.dart';

class E2GameWidget extends StatefulWidget {
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
  State<E2GameWidget> createState() => _E2GameWidgetState();
}

class _E2GameWidgetState extends State<E2GameWidget> {
  String? _selectedPlayerId;

  @override
  Widget build(BuildContext context) {
    if (widget.gameState.phase == GamePhase.revealing) {
      return _buildResultsView(context);
    }
    return _buildVotingView(context);
  }

  Widget _buildVotingView(BuildContext context) {
    final hasVoted = widget.gameState.submissions?.containsKey(widget.player.id) ?? false;

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
          _buildHeader(),
          
          // Question Card
          _buildQuestionCard(),
          
          // Voting Grid or Waiting
          Expanded(
            child: hasVoted
              ? _buildWaitingState()
              : _buildVotingGrid(),
          ),
          
          // Lock In Button
          if (!hasVoted && _selectedPlayerId != null)
            _buildLockInButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          // Round Counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.layers, color: AppTheme.primaryCyan, size: 16),
                const SizedBox(width: 6),
                Text(
                  'ROUND ${widget.gameState.currentCardIndex + 1}',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                ),
              ],
            ),
          ),
          // Title
          Text(
            'WHO WOULD...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.secondaryPink.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.secondaryPink.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, color: AppTheme.secondaryPink, size: 16),
                const SizedBox(width: 6),
                Text('0:30', style: TextStyle(color: AppTheme.secondaryPink, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(color: AppTheme.primaryCyan.withValues(alpha: 0.2), blurRadius: 30),
          ],
        ),
        child: Text(
          widget.promptCard.text,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.primaryCyan,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
        ),
      ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
    );
  }

  Widget _buildVotingGrid() {
    final otherPlayers = widget.gameState.players.where((p) => p.id != widget.player.id).toList();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TAP TO SELECT',
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: otherPlayers.length,
              itemBuilder: (context, index) {
                final p = otherPlayers[index];
                final isSelected = _selectedPlayerId == p.id;
                
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedPlayerId = p.id);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? AppTheme.primaryCyan.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryCyan : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected ? AppTheme.neonCyanGlow : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Avatar
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.white : Colors.grey.shade800,
                            border: isSelected 
                              ? Border.all(color: AppTheme.primaryCyan, width: 2)
                              : null,
                          ),
                          child: Center(
                            child: Text(
                              p.avatarUrl ?? p.nickname[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: p.avatarUrl != null ? 28 : 20,
                                color: isSelected ? AppTheme.backgroundBlack : Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          p.nickname,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ).animate().scale(delay: (50 * index).ms, duration: 200.ms),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, color: AppTheme.primaryCyan, size: 64),
          ),
          const SizedBox(height: 24),
          Text(
            'Vote Locked In!',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Waiting for others...',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildLockInButton() {
    final selectedPlayer = _selectedPlayerId != null
      ? widget.gameState.players.firstWhere((p) => p.id == _selectedPlayerId, orElse: () => widget.player)
      : null;
      
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      child: GestureDetector(
        onTap: () {
          if (_selectedPlayerId != null) {
            HapticFeedback.mediumImpact();
            widget.onVote(_selectedPlayerId!);
          }
        },
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryCyan,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.neonCyanGlow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, color: AppTheme.backgroundBlack, size: 20),
              const SizedBox(width: 8),
              Text(
                'LOCK IN VOTE FOR ${selectedPlayer?.nickname.toUpperCase() ?? ""}',
                style: TextStyle(
                  color: AppTheme.backgroundBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn().slideY(begin: 0.2),
    );
  }

  Widget _buildResultsView(BuildContext context) {
    final votes = widget.gameState.submissions ?? {};
    final voteCounts = <String, int>{};
    
    for (var targetId in votes.values) {
      voteCounts[targetId] = (voteCounts[targetId] ?? 0) + 1;
    }

    final sortedIds = voteCounts.keys.toList()
      ..sort((a, b) => voteCounts[b]!.compareTo(voteCounts[a]!));
    
    final winnerId = sortedIds.isNotEmpty ? sortedIds.first : null;
    final winner = winnerId != null 
        ? widget.gameState.players.firstWhere((p) => p.id == winnerId, orElse: () => Player(id: '', nickname: 'Unknown')) 
        : null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppTheme.surfaceDark, AppTheme.backgroundBlack],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'THE GROUP VOTED:',
              style: TextStyle(color: Colors.white54, letterSpacing: 3, fontSize: 12),
            ),
            const SizedBox(height: 32),
            if (winner != null) ...[
              // Winner Spotlight
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryCyan, width: 4),
                  boxShadow: AppTheme.neonCyanGlow,
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppTheme.surfaceDark,
                  child: Text(
                    winner.avatarUrl ?? winner.nickname[0].toUpperCase(),
                    style: const TextStyle(fontSize: 50),
                  ),
                ),
              ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
              const SizedBox(height: 24),
              Text(
                winner.nickname,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${voteCounts[winnerId]} VOTES',
                  style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
              ),
            ],
            const SizedBox(height: 48),
            if (widget.player.isHost)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: GestureDetector(
                  onTap: widget.onNextRound,
                  child: Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryCyan,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.neonCyanGlow,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward, color: AppTheme.backgroundBlack),
                        const SizedBox(width: 8),
                        Text(
                          'NEXT ROUND',
                          style: TextStyle(
                            color: AppTheme.backgroundBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              Text('Waiting for Host...', style: TextStyle(color: Colors.white54)),
          ],
        ),
      ),
    );
  }
}
