import '../../../core/models/game_state.dart';

/// Abstract base class for all Game Engines.
/// Each engine (E1-E6) must implement this interface.
abstract class GameEngine {
  /// The unique ID of the engine (e.g., 'E1_JUDGE', 'E3_TASK').
  String get id;

  /// Returns the UI widget for determining interaction.
  /// Not directly used here, but implies the implementation will have a corresponding UI.
  
  /// Called when a player performs an action (e.g., clicks 'Next', submits a card).
  /// [action] is a Map representing the payload.
  /// Returns the updated GameState.
  GameState processAction(GameState currentState, Map<String, dynamic> action);

  /// Called to initialize the game state for this specific engine.
  GameState initializeGame(GameState currentState);
}
