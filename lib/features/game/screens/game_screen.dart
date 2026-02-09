import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/game_state.dart';
import '../../../core/services/supabase_service.dart';
import '../engines/e1_game_widget.dart';
import '../engines/e1_judge_engine.dart';
import '../engines/e2_game_widget.dart';
import '../engines/e2_voting_engine.dart';
import '../engines/e3_game_widget.dart';
import '../engines/game_engine.dart';
import '../engines/e3_task_engine.dart';

class GameScreen extends StatefulWidget {
  final String roomCode;
  final Player player;
  final GameState initialState;

  const GameScreen({
    super.key,
    required this.roomCode,
    required this.player,
    required this.initialState,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late SupabaseService _supabaseService;
  late Stream<GameState> _gameStream;
  
  // Registry of engines
  final Map<String, GameEngine> _engines = {
    'E3_TASK': E3TaskEngine(),
    'E1_JUDGE': E1JudgeEngine(),
    'E2_VOTING': E2VotingEngine(),
  };

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(Supabase.instance.client);
    _gameStream = _supabaseService.subscribeToRoom(widget.roomCode);
  }

  Future<void> _handleAction(GameState currentState, Map<String, dynamic> action) async {
    final engineId = currentState.activeDeck?.engineType ?? 'E3_TASK';
    final engine = _engines[engineId];
    
    if (engine != null) {
      final newState = engine.processAction(currentState, action);
      await _supabaseService.updateGameState(widget.roomCode, newState);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: StreamBuilder<GameState>(
        initialData: widget.initialState,
        stream: _gameStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryCyan),
            );
          }
          
          final state = snapshot.data!;
          final currentDeck = state.activeDeck;
          final engineId = currentDeck?.engineType ?? 'E3_TASK';

          // Get current card safely
          final deckContent = currentDeck?.content ?? [];
          final cardIndex = state.currentCardIndex;
          final card = (deckContent.isNotEmpty && cardIndex < deckContent.length)
              ? deckContent[cardIndex]
              : null;

          if (card == null) {
            return _buildEmptyState();
          }

          // Render specific engine UI
          switch (engineId) {
            case 'E3_TASK':
              return E3GameWidget(
                card: card,
                gameState: state,
                player: widget.player,
                onNextCard: () => _handleAction(state, {'type': 'next_card'}),
                onSuccess: () => _handleAction(state, {
                  'type': 'task_result',
                  'player_id': widget.player.id,
                  'success': true,
                }),
                onFail: () => _handleAction(state, {
                  'type': 'task_result',
                  'player_id': widget.player.id,
                  'success': false,
                }),
              );

            case 'E1_JUDGE':
              return E1GameWidget(
                gameState: state,
                player: widget.player,
                promptCard: card,
                onSubmit: (cardId) => _handleAction(state, {
                  'type': 'submit_card',
                  'player_id': widget.player.id,
                  'card_id': cardId,
                }),
                onPickWinner: (winnerId) => _handleAction(state, {
                  'type': 'pick_winner',
                  'winner_id': winnerId,
                }),
              );

            case 'E2_VOTING':
              return E2GameWidget(
                gameState: state,
                player: widget.player,
                promptCard: card,
                onVote: (targetId) => _handleAction(state, {
                  'type': 'cast_vote',
                  'player_id': widget.player.id,
                  'target_player_id': targetId,
                }),
                onNextRound: () => _handleAction(state, {'type': 'next_round'}),
              );

            default:
              return Center(
                child: Text(
                  'Unknown Engine: $engineId',
                  style: TextStyle(color: Colors.white),
                ),
              );
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          Text(
            'No cards available',
            style: TextStyle(color: Colors.white54, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
