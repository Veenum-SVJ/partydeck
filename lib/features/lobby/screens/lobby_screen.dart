import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/constants/mock_decks.dart';
import '../../../core/models/card_model.dart';
import '../../../core/models/game_state.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/deck_service.dart';
import '../../game/engines/e1_judge_engine.dart';
import '../../game/engines/e2_voting_engine.dart';
import '../../game/engines/e3_task_engine.dart';
import 'deck_import_screen.dart';

class LobbyScreen extends StatefulWidget {
  final String roomCode;
  final Player player;

  const LobbyScreen({
    super.key,
    required this.roomCode,
    required this.player,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late SupabaseService _supabaseService;
  late Stream<GameState> _gameStream;
  final DeckService _deckService = DeckService();
  
  List<DeckModel> _availableDecks = [];
  DeckModel? _selectedDeck;
  bool _isLoadingDecks = true;

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(Supabase.instance.client);
    _gameStream = _supabaseService.subscribeToRoom(widget.roomCode);
    _loadDecks();
  }

  Future<void> _loadDecks() async {
    final decks = await _deckService.getDecks();
    if (mounted) {
      setState(() {
        _availableDecks = decks;
        _selectedDeck = decks.isNotEmpty ? decks.first : null;
        _isLoadingDecks = false;
      });
    }
  }


  Future<void> _startGame(GameState currentState) async {
    if (_selectedDeck == null) return;
    
    try {
      final newState = currentState.copyWith(
        phase: GamePhase.playing,
        activeDeck: _selectedDeck, 
        currentCardIndex: 0,
      );

      // Initialize Engine based on Deck Type
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
      appBar: AppBar(
        title: Text(widget.roomCode, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<GameState>(
        stream: _gameStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red)));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryCyan));
          }

          final gameState = snapshot.data!;
          final players = gameState.players;

          // Navigation Check
          if (gameState.phase == GamePhase.playing) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
               if (mounted && GoRouter.of(context).routerDelegate.currentConfiguration.matches.last.matchedLocation != '/game/${widget.roomCode}') {
                 context.go('/game/${widget.roomCode}', extra: {
                   'player': widget.player,
                   'initialState': gameState,
                 });
               }
            });
          }

          return Column(
            children: [
              Text(
                '${players.length} PLAYERS CONNECTED',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.primaryCyan),
              ),
              const SizedBox(height: 20),
              
              // Avatar Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final isMe = player.id == widget.player.id;
                    
                    return Column(
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: isMe ? AppTheme.primaryCyan.withAlpha(50) : AppTheme.surfaceGrey,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isMe ? AppTheme.primaryCyan : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              player.avatarUrl ?? '?',
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          player.nickname,
                          style: Theme.of(context).textTheme.labelLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (player.isHost)
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                      ],
                    );
                  },
                ),
              ),

              // Host Controls
              if (widget.player.isHost) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceGrey,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                       if (_isLoadingDecks)
                         const Center(child: CircularProgressIndicator())
                       else ...[
                         DropdownButtonFormField<DeckModel>(
                           value: _selectedDeck,
                           dropdownColor: AppTheme.surfaceGrey,
                           decoration: const InputDecoration(
                             labelText: 'Select Deck',
                             labelStyle: TextStyle(color: AppTheme.primaryCyan),
                             border: OutlineInputBorder(),
                           ),
                           items: _availableDecks.map((deck) {
                             return DropdownMenuItem(
                               value: deck,
                               child: Text(deck.title, style: const TextStyle(color: Colors.white)),
                             );
                           }).toList(),
                           onChanged: (val) => setState(() => _selectedDeck = val),
                         ),
                       ],
                       const SizedBox(height: 16),
                       SizedBox(
                         width: double.infinity,
                         height: 60,
                         child: ElevatedButton(
                           onPressed: () => _startGame(gameState),
                           style: ElevatedButton.styleFrom(
                             backgroundColor: AppTheme.primaryCyan, // Cyan for startup
                             foregroundColor: Colors.black,
                           ),
                           child: const Text('START GAME'),
                         ),
                       ),
                    ],
                  ),
                ),
              ] else ...[
                 Container(
                   width: double.infinity,
                   padding: const EdgeInsets.all(24),
                   color: AppTheme.surfaceGrey,
                   child: const Text(
                     'Waiting for host to start...',
                     style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
                     textAlign: TextAlign.center,
                   ),
                 ),
              ],
              
              // Bottom Ad Banner
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.black,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Ad', style: TextStyle(color: Colors.white24, fontSize: 10)),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Waiting for players? Order drinks on UberEats.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
