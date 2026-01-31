import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/card_model.dart';
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
  
  // Registry of engines (Move to a provider later)
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
    // For E1, anyone can submit. For E3, only host controls flow.
    // Ideally, the Engine validates internally.
    // We pass the action to the engine, get new state, and push.
    // In real app: Edge Function should validate. Here: Client trust.

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
      body: Container(
         decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2A0033),
              AppTheme.backgroundBlack,
            ],
          ),
        ),
        child: StreamBuilder<GameState>(
          initialData: widget.initialState,
          stream: _gameStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            
            final state = snapshot.data!;
            final currentDeck = state.activeDeck;
            final engineId = currentDeck?.engineType ?? 'E3_TASK'; // Default to E3 for testing

            // Render specific engine UI
            if (engineId == 'E3_TASK') {
               // Safe access to card
              final deckContent = currentDeck?.content ?? [];
              final cardIndex = state.currentCardIndex;
              final card = (deckContent.isNotEmpty && cardIndex < deckContent.length)
                  ? deckContent[cardIndex]
                  : null;

              if (card == null) {
                return Center(child: Text('Empty Deck or Invalid Index', style: TextStyle(color: Colors.white)));
              }

              return E3GameWidget(
                card: card,
                isHost: widget.player.isHost,
                onNextCard: () => _handleAction(state, {'type': 'next_card'}),
              );
            }



            if (engineId == 'E1_JUDGE') {
              // Find the prompt card (Active card pointer)
              final deckContent = currentDeck?.content ?? [];
              // Safe access for prototype
              final cardIndex = state.currentCardIndex;
               final card = (deckContent.isNotEmpty && cardIndex < deckContent.length)
                  ? deckContent[cardIndex]
                  : CardModel(id: 'err', text: 'Error: Card Index OOB', category: 'PROMPT');
              
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
            }

            if (engineId == 'E2_VOTING') {
              final deckContent = currentDeck?.content ?? [];
              final cardIndex = state.currentCardIndex;
              final card = (deckContent.isNotEmpty && cardIndex < deckContent.length)
                  ? deckContent[cardIndex]
                  : CardModel(id: 'err', text: 'Error: Card Index OOB', category: 'VOTE');

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
            }

            return Center(child: Text('Unknown Engine: $engineId'));
          },
        ),
      ),
    );
  }
}
