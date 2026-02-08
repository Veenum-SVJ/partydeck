// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) => Player(
  id: json['id'] as String,
  nickname: json['nickname'] as String,
  isHost: json['is_host'] as bool? ?? false,
  score: (json['score'] as num?)?.toInt() ?? 0,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'id': instance.id,
  'nickname': instance.nickname,
  'is_host': instance.isHost,
  'score': instance.score,
  'avatar_url': instance.avatarUrl,
};

GameState _$GameStateFromJson(Map<String, dynamic> json) => GameState(
  roomCode: json['room_code'] as String,
  phase:
      $enumDecodeNullable(_$GamePhaseEnumMap, json['phase']) ??
      GamePhase.waiting,
  players:
      (json['players'] as List<dynamic>?)
          ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  currentCardIndex: (json['current_card_index'] as num?)?.toInt() ?? 0,
  activeDeck: json['active_deck'] == null
      ? null
      : DeckModel.fromJson(json['active_deck'] as Map<String, dynamic>),
  judgeId: json['judge_id'] as String?,
  submissions: (json['submissions'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  playerHands: (json['player_hands'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>)
          .map((e) => CardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  ),
  currentRound: (json['current_round'] as num?)?.toInt() ?? 1,
  totalRounds: (json['total_rounds'] as num?)?.toInt() ?? 10,
  roundWinnerId: json['round_winner_id'] as String?,
  roundStartTime: json['round_start_time'] == null
      ? null
      : DateTime.parse(json['round_start_time'] as String),
  timerDuration: (json['timer_duration'] as num?)?.toInt() ?? 60,
);

Map<String, dynamic> _$GameStateToJson(GameState instance) => <String, dynamic>{
  'room_code': instance.roomCode,
  'phase': _$GamePhaseEnumMap[instance.phase]!,
  'players': instance.players,
  'current_card_index': instance.currentCardIndex,
  'active_deck': instance.activeDeck,
  'judge_id': instance.judgeId,
  'submissions': instance.submissions,
  'player_hands': instance.playerHands,
  'current_round': instance.currentRound,
  'total_rounds': instance.totalRounds,
  'round_winner_id': instance.roundWinnerId,
  'round_start_time': instance.roundStartTime?.toIso8601String(),
  'timer_duration': instance.timerDuration,
};

const _$GamePhaseEnumMap = {
  GamePhase.waiting: 'waiting',
  GamePhase.playing: 'playing',
  GamePhase.judging: 'judging',
  GamePhase.revealing: 'revealing',
  GamePhase.finished: 'finished',
};
