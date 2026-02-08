import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/game_state.dart';

enum GameCategory { judge, vote, task, drawing }
enum DeckSource { base, spicy, imported }

class GameSetupScreen extends StatefulWidget {
  final Player player;
  final String roomCode;

  const GameSetupScreen({
    super.key,
    required this.player,
    required this.roomCode,
  });

  @override
  State<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends State<GameSetupScreen> {
  GameCategory _selectedCategory = GameCategory.vote;
  DeckSource _selectedDeckSource = DeckSource.base;
  bool _brandedContentEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Column(
        children: [
          // Top App Bar
          _buildAppBar(),
          
          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Selection
                  _buildCategorySection(),
                  
                  const SizedBox(height: 32),
                  
                  // Deck Source
                  _buildDeckSourceSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Sponsor Toggle
                  _buildSponsorToggle(),
                ],
              ),
            ),
          ),
          
          // Bottom Action Button
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 16,
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
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              shape: const CircleBorder(),
            ),
          ),
          // Title
          Text(
            'PARTYDECK // HOST',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          // Help Button
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.help_outline, color: AppTheme.primaryCyan),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Protocol',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(4),
                color: AppTheme.primaryCyan.withValues(alpha: 0.1),
              ),
              child: Text(
                'MODE: ACTIVE',
                style: TextStyle(
                  color: AppTheme.primaryCyan,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 2x2 Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildCategoryCard(
              category: GameCategory.judge,
              title: 'Judge',
              subtitle: 'Make the call.',
              icon: Icons.gavel,
            ),
            _buildCategoryCard(
              category: GameCategory.vote,
              title: 'Vote',
              subtitle: 'Majority rules.',
              icon: Icons.how_to_vote,
            ),
            _buildCategoryCard(
              category: GameCategory.task,
              title: 'Task',
              subtitle: 'Do or drink.',
              icon: Icons.priority_high,
            ),
            _buildCategoryCard(
              category: GameCategory.drawing,
              title: 'Drawing',
              subtitle: 'Sketch it out.',
              icon: Icons.brush,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required GameCategory category,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedCategory == category;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryCyan : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppTheme.neonCyanGlow : null,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isSelected 
                ? AppTheme.primaryCyan.withValues(alpha: 0.2) 
                : Colors.transparent,
              Colors.black.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Content
            Positioned(
              bottom: 16,
              left: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    icon,
                    color: AppTheme.primaryCyan,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Check Badge
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryCyan,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: Colors.black, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckSourceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deck Source',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              _buildDeckSourceButton(DeckSource.base, 'Base'),
              _buildDeckSourceButton(DeckSource.spicy, 'Spicy'),
              _buildDeckSourceButton(DeckSource.imported, 'Imported'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeckSourceButton(DeckSource source, String label) {
    final isSelected = _selectedDeckSource == source;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDeckSource = source),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryCyan : Colors.transparent,
            borderRadius: BorderRadius.circular(50),
            boxShadow: isSelected 
              ? [BoxShadow(color: AppTheme.primaryCyan.withValues(alpha: 0.4), blurRadius: 15)]
              : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSponsorToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.secondaryPink.withValues(alpha: 0.3)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryPink.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Branded Content',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryPink,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'FREE XP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Enable sponsored challenges for free play',
                  style: TextStyle(
                    color: AppTheme.secondaryPink.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _brandedContentEnabled,
            onChanged: (v) => setState(() => _brandedContentEnabled = v),
            activeColor: AppTheme.secondaryPink,
            activeTrackColor: AppTheme.secondaryPink.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
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
      child: GestureDetector(
        onTap: () {
          // Navigate to lobby with selected settings
          context.push('/lobby/${widget.roomCode}', extra: widget.player);
        },
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.primaryCyan,
            borderRadius: BorderRadius.circular(50),
            boxShadow: AppTheme.neonCyanGlow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rocket_launch, color: AppTheme.backgroundBlack),
              const SizedBox(width: 8),
              Text(
                'INITIALIZE GAME',
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
