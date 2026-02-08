import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/game_state.dart';

class RoundResultsScreen extends StatelessWidget {
  final GameState gameState;
  final Player player;
  final VoidCallback onNextRound;
  final VoidCallback onEndGame;

  const RoundResultsScreen({
    super.key,
    required this.gameState,
    required this.player,
    required this.onNextRound,
    required this.onEndGame,
  });

  @override
  Widget build(BuildContext context) {
    // Sort players by score
    final sortedPlayers = List<Player>.from(gameState.players)
      ..sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));
    
    final winner = sortedPlayers.isNotEmpty ? sortedPlayers.first : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Stack(
        children: [
          // Confetti Background
          _buildConfettiOverlay(),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(context),
                
                // Winner Spotlight
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (winner != null) _buildWinnerSpotlight(context, winner),
                        const SizedBox(height: 32),
                        
                        // Native Ad Banner
                        _buildNativeAdBanner(),
                        const SizedBox(height: 24),
                        
                        // Leaderboard
                        _buildLeaderboard(context, sortedPlayers),
                      ],
                    ),
                  ),
                ),
                
                // Action Button
                _buildActionButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfettiOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: List.generate(20, (index) {
            final colors = [
              AppTheme.primaryCyan,
              AppTheme.secondaryPink,
              AppTheme.accentYellow,
              AppTheme.neonGreen,
            ];
            return Positioned(
              left: (index * 37) % 400,
              top: -50,
              child: Container(
                width: 8 + (index % 3) * 4,
                height: 8 + (index % 3) * 4,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(2),
                ),
              ).animate(
                onPlay: (c) => c.repeat(),
              ).slideY(
                begin: -1,
                end: 20,
                duration: Duration(milliseconds: 3000 + (index * 200)),
                curve: Curves.linear,
              ).rotate(
                begin: 0,
                end: index % 2 == 0 ? 2 : -2,
                duration: Duration(milliseconds: 3000 + (index * 200)),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Text(
            'ROUND ${gameState.currentCardIndex + 1} COMPLETE',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildWinnerSpotlight(BuildContext context, Player winner) {
    return Column(
      children: [
        // 1ST PLACE Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.accentYellow,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '1ST PLACE',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ).animate().fadeIn().slideY(begin: -0.5),
        const SizedBox(height: 24),
        
        // Winner Avatar
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.accentYellow, width: 4),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentYellow.withValues(alpha: 0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 64,
            backgroundColor: AppTheme.surfaceDark,
            child: Text(
              winner.avatarUrl ?? winner.nickname[0].toUpperCase(),
              style: const TextStyle(fontSize: 56),
            ),
          ),
        ).animate().scale(curve: Curves.elasticOut, duration: 800.ms),
        const SizedBox(height: 16),
        
        // Winner Name
        Text(
          winner.nickname.toUpperCase(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        
        // Points
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primaryCyan.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
          ),
          child: Text(
            '+${winner.score ?? 0} PTS',
            style: TextStyle(
              color: AppTheme.primaryCyan,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNativeAdBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Ad Image
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.shopping_bag, color: Colors.blue.shade300, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Special Offer',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Ad',
                        style: TextStyle(color: Colors.white54, fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Unlock premium decks - 50% off!',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'VIEW',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, List<Player> sortedPlayers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LEADERBOARD',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),
        ...sortedPlayers.asMap().entries.map((entry) {
          final index = entry.key;
          final player = entry.value;
          final rankColors = [AppTheme.accentYellow, Colors.grey.shade400, Colors.orange.shade700];
          final rankColor = index < 3 ? rankColors[index] : Colors.white24;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: index == 0 
                ? AppTheme.accentYellow.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: index == 0 ? AppTheme.accentYellow.withValues(alpha: 0.3) : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                // Rank Badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: rankColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: rankColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Avatar
                Text(player.avatarUrl ?? '😎', style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                // Name
                Expanded(
                  child: Text(
                    player.nickname,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                // Score
                Text(
                  '${player.score ?? 0} pts',
                  style: TextStyle(
                    color: index == 0 ? AppTheme.accentYellow : AppTheme.primaryCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1);
        }),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      child: GestureDetector(
        onTap: onNextRound,
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
    );
  }
}
