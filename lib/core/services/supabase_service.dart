import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/game_state.dart';
import 'package:uuid/uuid.dart';

class SupabaseService {
  final SupabaseClient _client;

  SupabaseService(this._client);

  /// Creates a new room with a random 4-letter code.
  /// Returns the Room Code.
  Future<String> createRoom(Player host) async {
    // Generate a random 4-letter code
    // In a real app, check for collisions.
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final code = List.generate(4, (index) => chars[DateTime.now().microsecond % chars.length]).join();

    // Create initial game state
    final initialState = GameState(
      roomCode: code,
      phase: GamePhase.waiting,
      players: [host],
    );

    // Insert into Supabase table 'rooms'
    // Assuming a table 'rooms' with columns: code (text, PK), state (jsonb)
    try {
      await _client.from('rooms').insert({
        'code': code,
        'state': initialState.toJson(),
        'created_at': DateTime.now().toIso8601String(),
      });
      return code;
    } catch (e) {
      throw Exception('Failed to create room: $e');
    }
  }

  /// Joins an existing room.
  /// Returns the current GameState.
  Future<GameState> joinRoom(String code, Player player) async {
    try {
      final response = await _client
          .from('rooms')
          .select()
          .eq('code', code)
          .single();

      final currentGameState = GameState.fromJson(response['state']);

      // Check if player already exists
      if (currentGameState.players.any((p) => p.id == player.id)) {
        return currentGameState;
      }

      // Add player
      final updatedPlayers = List<Player>.from(currentGameState.players)..add(player);
      final updatedState = currentGameState.copyWith(players: updatedPlayers);

      // Update Remote
      await _client
          .from('rooms')
          .update({'state': updatedState.toJson()})
          .eq('code', code);

      return updatedState;
    } catch (e) {
      throw Exception('Failed to join room: $e');
    }
  }

  /// Subscribes to room updates.
  Stream<GameState> subscribeToRoom(String code) {
    return _client
        .from('rooms')
        .stream(primaryKey: ['code'])
        .eq('code', code)
        .map((event) {
          if (event.isEmpty) {
            throw Exception('Room closed');
          }
          return GameState.fromJson(event.first['state']);
        });
  }


  /// Updates the game state for a specific room.
  Future<void> updateGameState(String roomCode, GameState newState) async {
    try {
      await _client
          .from('rooms')
          .update({'state': newState.toJson()})
          .eq('code', roomCode);
    } catch (e) {
      throw Exception('Failed to update game state: $e');
    }
  }
}
