import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/game_state.dart';
import '../../../core/models/card_model.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/deck_loader_service.dart';
import '../../game/engines/e1_judge_engine.dart';
import '../../game/engines/e2_voting_engine.dart';
import '../../game/engines/e3_task_engine.dart';

class LobbyScreen extends StatefulWidget {
  final String roomCode;
  final Player player;

  const LobbyScreen({super.key, required this.roomCode, required this.player});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late SupabaseService _supabaseService;
  StreamSubscription? _gameStateSubscription;
  DeckModel? _selectedDeck;
  List<DeckModel> _availableDecks = [];

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(Supabase.instance.client);
    _loadDecks();
    _subscribeToGameState();
  }

  @override
  void dispose() {
    _gameStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadDecks() async {
    final decks = await DeckLoaderService.loadAllDecks();
    if (mounted) {
      setState(() {
        _availableDecks = decks;
        if (decks.isNotEmpty) _selectedDeck = decks.first;
      });
    }
  }

  void _subscribeToGameState() {
    _gameStateSubscription = _supabaseService.subscribeToGameState(widget.roomCode, (gameState) {
      if (gameState.phase == GamePhase.playing && mounted) {
        context.go('/game/${widget.roomCode}', extra: {
          'player': widget.player,
          'initialState': gameState,
        });
      }
    });
  }

  Future<void> _startGame(GameState currentState) async {
    if (_selectedDeck == null) return;
    
    try {
      final newState = currentState.copyWith(
        phase: GamePhase.playing,
        activeDeck: _selectedDeck, 
        currentCardIndex: 0,
      );

      GameState initializedState;
      switch (_selectedDeck!.engineType) {
        case 'E1_JUDGE':
          initializedState = E1JudgeEngine().initializeGame(newState);
          break;
        case 'E2_VOTING':
          initializedState = E2VotingEngine().initializeGame(newState);
          break;
        case 'E3_TASK':
        default:
          initializedState = E3TaskEngine().initializeGame(newState);
          break;
      }

      await _supabaseService.updateGameState(widget.roomCode, initializedState);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to start game: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Stack(
        children: [
          // Ambient Background
          Positioned.fill(child: _buildAmbientBackground()),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(),
                
                // Room Code Display
                _buildRoomCodeSection(),
                
                // Players Grid
                Expanded(
                  child: StreamBuilder<GameState>(
                    stream: _supabaseService.getGameStateStream(widget.roomCode),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.primaryCyan));
                      }
                      
                      final gameState = snapshot.data!;
                      final isHost = widget.player.isHost;
                      
                      return Column(
                        children: [
                          // Players Section
                          Expanded(child: _buildPlayersGrid(gameState.players)),
                          
                          // Deck Selection (Host only)
                          if (isHost) _buildDeckSelector(),
                          
                          // Start/Waiting Section
                          _buildActionSection(isHost, gameState),
                        ],
                      );
                    },
                  ),
                ),
                
                // Native Ad Banner
                _buildNativeAdBanner(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientBackground() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.primaryCyan.withValues(alpha: 0.05),
                AppTheme.backgroundBlack,
                AppTheme.backgroundBlack,
              ],
            ),
          ),
        ),
        // Grid Pattern
        Positioned.fill(
          child: Opacity(
            opacity: 0.1,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/grid_pattern.png'),
                  repeat: ImageRepeat.repeat,
                  opacity: 0.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Text(
            'PARTYDECK // LOBBY',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings, color: Colors.white.withValues(alpha: 0.5)),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCodeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Room Code
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.roomCode.split('').map((char) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryCyan.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Text(
                  char,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.primaryCyan,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              );
            }).toList(),
          ).animate().fadeIn(duration: 500.ms).shimmer(duration: 2000.ms, color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          // Share Button
          GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: widget.roomCode));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Room code copied!')),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.share, color: Colors.white.withValues(alpha: 0.8), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'SHARE CODE',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersGrid(List<Player> players) {
    const maxSlots = 8;
    final slots = List<Player?>.generate(maxSlots, (i) => i < players.length ? players[i] : null);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: maxSlots,
        itemBuilder: (context, index) {
          final player = slots[index];
          if (player != null) {
            return _buildPlayerSlot(player, index);
          }
          return _buildEmptySlot();
        },
      ),
    );
  }

  Widget _buildPlayerSlot(Player player, int index) {
    final colors = [
      AppTheme.primaryCyan,
      Colors.orange,
      Colors.purple,
      AppTheme.secondaryPink,
      Colors.green,
      Colors.amber,
      Colors.blue,
      Colors.red,
    ];
    final playerColor = colors[index % colors.length];
    
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: playerColor, width: 3),
            boxShadow: [
              BoxShadow(color: playerColor.withValues(alpha: 0.4), blurRadius: 15),
            ],
          ),
          child: Center(
            child: Text(player.avatarUrl ?? '😎', style: const TextStyle(fontSize: 28)),
          ),
        ).animate().scale(delay: (100 * index).ms, duration: 300.ms, curve: Curves.elasticOut),
        const SizedBox(height: 8),
        Text(
          player.nickname,
          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        if (player.isHost)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.accentYellow,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'HOST',
              style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptySlot() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: Center(
            child: Icon(Icons.person_add, color: Colors.white.withValues(alpha: 0.2), size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Waiting...',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildDeckSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SELECT DECK',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableDecks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final deck = _availableDecks[index];
                  final isSelected = _selectedDeck?.deckId == deck.deckId;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDeck = deck),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryCyan : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          deck.title,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection(bool isHost, GameState gameState) {
    if (isHost) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => _startGame(gameState),
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
                Icon(Icons.play_arrow, color: AppTheme.backgroundBlack, size: 28),
                const SizedBox(width: 8),
                Text(
                  'START GAME',
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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(AppTheme.primaryCyan),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Waiting for Host to start...',
            style: TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.w500),
          ),
        ],
      ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2000.ms, color: AppTheme.primaryCyan.withValues(alpha: 0.5)),
    );
  }

  Widget _buildNativeAdBanner() {
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          // Ad Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.local_bar, color: Colors.blue.shade300),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Sponsored',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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
                Text(
                  'Play the sponsored deck for free!',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
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
              'UNLOCK',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
