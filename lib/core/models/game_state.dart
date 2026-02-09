import 'package:json_annotation/json_annotation.dart';
import 'card_model.dart';

part 'game_state.g.dart';

enum GamePhase {
  @JsonValue('waiting')
  waiting,
  @JsonValue('playing')
  playing,
  @JsonValue('judging')
  judging,
  @JsonValue('revealing')
  revealing,
  @JsonValue('finished')
  finished,
}

@JsonSerializable()
class Player {
  final String id;
  final String nickname;
  @JsonKey(name: 'is_host')
  final bool isHost;
  final int score;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;

  Player({
    required this.id,
    required this.nickname,
    this.isHost = false,
    this.score = 0,
    this.avatarUrl,
  });

  factory Player.fromJson(Map<String, dynamic> json) => _$PlayerFromJson(json);
  Map<String, dynamic> toJson() => _$PlayerToJson(this);

  Player copyWith({
    String? id,
    String? nickname,
    bool? isHost,
    int? score,
    String? avatarUrl,
  }) {
    return Player(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      isHost: isHost ?? this.isHost,
      score: score ?? this.score,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

@JsonSerializable()
class GameState {
  @JsonKey(name: 'room_code')
  final String roomCode;
  
  final GamePhase phase;
  
  final List<Player> players;
  
  @JsonKey(name: 'current_card_index')
  final int currentCardIndex;
  
  @JsonKey(name: 'active_deck')
  final DeckModel? activeDeck;

  /// ID of the player currently judging (E1).
  @JsonKey(name: 'judge_id')
  final String? judgeId;

  /// Map of PlayerID -> CardID (Answer) for E1.
  final Map<String, String>? submissions;

  /// Map of PlayerID -> List of Cards (Hand) for E1.
  @JsonKey(name: 'player_hands')
  final Map<String, List<CardModel>>? playerHands;

  /// Current round number (1-indexed)
  @JsonKey(name: 'current_round')
  final int currentRound;

  /// Total number of rounds in the game
  @JsonKey(name: 'total_rounds')
  final int totalRounds;

  /// Winner of the current round (Player ID)
  @JsonKey(name: 'round_winner_id')
  final String? roundWinnerId;

  /// Timestamp when round started
  @JsonKey(name: 'round_start_time')
  final DateTime? roundStartTime;

  /// Timer duration in seconds
  @JsonKey(name: 'timer_duration')
  final int timerDuration;

  GameState({
    required this.roomCode,
    this.phase = GamePhase.waiting,
    this.players = const [],
    this.currentCardIndex = 0,
    this.activeDeck,
    this.judgeId,
    this.submissions,
    this.playerHands,
    this.currentRound = 1,
    this.totalRounds = 10,
    this.roundWinnerId,
    this.roundStartTime,
    this.timerDuration = 60,
  });

  factory GameState.fromJson(Map<String, dynamic> json) => _$GameStateFromJson(json);
  Map<String, dynamic> toJson() => _$GameStateToJson(this);

  GameState copyWith({
    String? roomCode,
    GamePhase? phase,
    List<Player>? players,
    int? currentCardIndex,
    DeckModel? activeDeck,
    String? judgeId,
    Map<String, String>? submissions,
    Map<String, List<CardModel>>? playerHands,
    int? currentRound,
    int? totalRounds,
    String? roundWinnerId,
    DateTime? roundStartTime,
    int? timerDuration,
  }) {
    return GameState(
      roomCode: roomCode ?? this.roomCode,
      phase: phase ?? this.phase,
      players: players ?? this.players,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
      activeDeck: activeDeck ?? this.activeDeck,
      judgeId: judgeId ?? this.judgeId,
      submissions: submissions ?? this.submissions,
      playerHands: playerHands ?? this.playerHands,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      roundWinnerId: roundWinnerId ?? this.roundWinnerId,
      roundStartTime: roundStartTime ?? this.roundStartTime,
      timerDuration: timerDuration ?? this.timerDuration,
    );
  }

  /// Get the current round winner Player object
  Player? get roundWinner => roundWinnerId != null 
    ? players.cast<Player?>().firstWhere((p) => p?.id == roundWinnerId, orElse: () => null)
    : null;

  /// Check if game is complete
  bool get isGameComplete => currentRound > totalRounds || phase == GamePhase.finished;

  /// Get leaderboard sorted by score
  List<Player> get leaderboard => List<Player>.from(players)
    ..sort((a, b) => b.score.compareTo(a.score));
}
