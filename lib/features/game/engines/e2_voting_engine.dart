import '../../../core/models/game_state.dart';
import 'game_engine.dart';

class E2VotingEngine implements GameEngine {
  @override
  String get id => 'E2_VOTING';

  @override
  GameState initializeGame(GameState currentState) {
    if (currentState.players.isEmpty) return currentState;
    
    // For E2, we just need the deck.
    // Ensure we start at index 0 or appropriate index.
    return currentState.copyWith(
      phase: GamePhase.playing, // Voting Phase
      submissions: {}, // Clear previous votes
      currentCardIndex: 0,
    );
  }

  @override
  GameState processAction(GameState currentState, Map<String, dynamic> action) {
    final type = action['type'] as String?;
    final playerId = action['player_id'] as String?;

    if (type == 'cast_vote') {
      final targetPlayerId = action['target_player_id'] as String;

      // Update votes (using submissions map: Voter -> Target)
      final newVotes = Map<String, String>.from(currentState.submissions ?? {});
      newVotes[playerId!] = targetPlayerId;

      // Check if everyone has voted
      final playersCount = currentState.players.length;
      var newPhase = currentState.phase;
      
      if (newVotes.length >= playersCount) {
        newPhase = GamePhase.revealing;
      }

      return currentState.copyWith(
        submissions: newVotes,
        phase: newPhase,
      );
    }

    if (type == 'next_round') {
      // Calculate next card index
      final nextIndex = (currentState.currentCardIndex + 1); // Loop handled by UI or Deck size?
      
      // Reset for next round
      return currentState.copyWith(
        phase: GamePhase.playing,
        currentCardIndex: nextIndex,
        submissions: {},
      );
    }

    return currentState;
  }
}
