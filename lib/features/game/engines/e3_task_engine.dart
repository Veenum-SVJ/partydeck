import '../../../core/models/game_state.dart';
import 'game_engine.dart';

class E3TaskEngine implements GameEngine {
  @override
  String get id => 'E3_TASK';

  @override
  GameState initializeGame(GameState currentState) {
    // E3 is simple: Just start at card 0.
    return currentState.copyWith(
      phase: GamePhase.playing,
      currentCardIndex: 0,
    );
  }

  @override
  GameState processAction(GameState currentState, Map<String, dynamic> action) {
    final type = action['type'] as String?;

    if (type == 'next_card') {
      // Loop back to 0 if end of deck (or finish game)
      // For now, let's just increment or loop.
      final deckSize = currentState.activeDeck?.content.length ?? 0;
      if (deckSize == 0) return currentState;

      final nextIndex = (currentState.currentCardIndex + 1) % deckSize;
      return currentState.copyWith(currentCardIndex: nextIndex);
    }

    return currentState;
  }
}
