import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/card_model.dart';
import '../../../core/models/game_state.dart';

class E3GameWidget extends StatefulWidget {
  final CardModel card;
  final GameState gameState;
  final Player player;
  final VoidCallback onNextCard;
  final VoidCallback onSuccess;
  final VoidCallback onFail;

  const E3GameWidget({
    super.key,
    required this.card,
    required this.gameState,
    required this.player,
    required this.onNextCard,
    required this.onSuccess,
    required this.onFail,
  });

  @override
  State<E3GameWidget> createState() => _E3GameWidgetState();
}

class _E3GameWidgetState extends State<E3GameWidget> with SingleTickerProviderStateMixin {
  bool _isFlipped = false;
  late AnimationController _scanlineController;

  @override
  void initState() {
    super.initState();
    _scanlineController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _scanlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSponsored = widget.card.id.hashCode % 5 == 0;
    final currentPlayer = widget.gameState.players.isNotEmpty
      ? widget.gameState.players[widget.gameState.currentCardIndex % widget.gameState.players.length]
      : widget.player;

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
          // Header
          _buildHeader(currentPlayer),
          
          // Progress Bar
          _buildProgressBar(),
          
          // Main Card
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isFlipped = !_isFlipped);
                },
                child: _buildTaskCard(isSponsored),
              ),
            ),
          ),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader(Player currentPlayer) {
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
          // Back Button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          // Title with Glitch Effect
          _buildGlitchTitle(),
          // Settings
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert, color: Colors.white.withValues(alpha: 0.5)),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlitchTitle() {
    return Stack(
      children: [
        // Glitch offset 1
        Transform.translate(
          offset: const Offset(-2, 0),
          child: Text(
            'TASK_MODE',
            style: TextStyle(
              color: AppTheme.primaryCyan.withValues(alpha: 0.5),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ),
        // Glitch offset 2
        Transform.translate(
          offset: const Offset(2, 0),
          child: Text(
            'TASK_MODE',
            style: TextStyle(
              color: AppTheme.secondaryPink.withValues(alpha: 0.5),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
            ),
          ),
        ),
        // Main text
        Text(
          'TASK_MODE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final deckLength = widget.gameState.activeDeck?.content.length ?? 1;
    final progress = (widget.gameState.currentCardIndex + 1) / deckLength;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Current Player
          Row(
            children: [
              Text(
                widget.player.avatarUrl ?? '👤',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Text(
                widget.player.nickname,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Progress
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(color: AppTheme.neonGreen.withValues(alpha: 0.5), blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${widget.gameState.currentCardIndex + 1}/$deckLength',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(bool isSponsored) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Container(
          key: ValueKey(widget.card.id + _isFlipped.toString()),
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: isSponsored ? const Color(0xFF0A2A1A) : AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSponsored ? AppTheme.neonGreen : Colors.white.withValues(alpha: 0.1),
              width: isSponsored ? 2 : 1,
            ),
            boxShadow: isSponsored 
              ? AppTheme.neonGreenGlow
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 30)],
          ),
          child: Stack(
            children: [
              // Scanline Effect
              AnimatedBuilder(
                animation: _scanlineController,
                builder: (context, child) {
                  return Positioned(
                    top: _scanlineController.value * 400,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.primaryCyan.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Card Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Sponsored Badge
                    if (isSponsored)
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.neonGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.black, size: 12),
                              const SizedBox(width: 4),
                              Text('SPONSORED', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Category
                    if (widget.card.category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryCyan.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.card.category!.toUpperCase(),
                          style: TextStyle(
                            color: AppTheme.primaryCyan,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Task Text
                    Text(
                      widget.card.text,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    // OR Separator with Penalty
                    if (widget.card.penalty != null) ...[
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.white24)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('OR', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(child: Divider(color: Colors.white24)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryPink.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: AppTheme.secondaryPink.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          widget.card.penalty!,
                          style: TextStyle(
                            color: AppTheme.secondaryPink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Sponsor info
                    if (isSponsored)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_pizza, color: Colors.amber, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Sponsored by Pizza Hut',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ).animate(key: ValueKey(widget.card.id)).fadeIn(duration: 300.ms).slideY(begin: 0.05),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      child: Row(
        children: [
          // Fail Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                widget.onFail();
                widget.onNextCard();
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.secondaryPink, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.local_bar, color: AppTheme.secondaryPink),
                    const SizedBox(width: 8),
                    Text(
                      'FAIL / DRINK',
                      style: TextStyle(
                        color: AppTheme.secondaryPink,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Success Button
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onSuccess();
                widget.onNextCard();
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.neonGreenGlow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      'SUCCESS',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 2000.ms, color: Colors.white24),
            ),
          ),
        ],
      ),
    );
  }
}
