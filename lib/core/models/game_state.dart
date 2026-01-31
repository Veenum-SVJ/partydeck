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

  /// Map of PlayerID -> List<Card> (Hand) for E1.
  @JsonKey(name: 'player_hands')
  final Map<String, List<CardModel>>? playerHands;

  GameState({
    required this.roomCode,
    this.phase = GamePhase.waiting,
    this.players = const [],
    this.currentCardIndex = 0,
    this.activeDeck,
    this.judgeId,
    this.submissions,
    this.playerHands,
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
    );
  }
}
