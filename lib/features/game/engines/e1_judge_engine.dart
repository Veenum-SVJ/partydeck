import 'dart:math';
import '../../../core/models/game_state.dart';
import '../../../core/models/card_model.dart';
import 'game_engine.dart';

class E1JudgeEngine implements GameEngine {
  @override
  String get id => 'E1_JUDGE';

  @override
  GameState initializeGame(GameState currentState) {
    if (currentState.players.isEmpty) return currentState;

    final random = Random();
    final deck = currentState.activeDeck;
    if (deck == null) return currentState;

    // Separate Prompt vs Answer cards
    // Assuming category 'PROMPT' for black cards, 'ANSWER' for white cards
    // For simplicity, let's assume the deck content needs splitting or we just use one big deck.
    // Real implementation should probably have multiple decks or filtered lists.
    // For this prototype, we'll assume the 'content' list is ALL answers, and Prompts come from somewhere else?
    // OR: The DeckModel contains mixed cards. Let's filter.
    
    final promptCards = deck.content.where((c) => c.category == 'PROMPT').toList();
    final answerCards = deck.content.where((c) => c.category != 'PROMPT').toList();

    // Shuffle
    promptCards.shuffle(random);
    answerCards.shuffle(random);

    // Pick first Judge
    final judge = currentState.players[random.nextInt(currentState.players.length)];

    // Deal 7 cards to each player
    final Map<String, List<CardModel>> hands = {};
    int cardIndex = 0;

    for (var player in currentState.players) {
      final hand = <CardModel>[];
      for (int i = 0; i < 7; i++) {
        if (cardIndex < answerCards.length) {
          hand.add(answerCards[cardIndex]);
          cardIndex++;
        }
      }
      hands[player.id] = hand;
    }

    // Set Initial State
    return currentState.copyWith(
      phase: GamePhase.judging, // Using 'judging' generally for the whole loop? Or 'playing' for submitting?
      // Let's use 'playing' for "Waiting for submissions", and 'judging' for "Judge picking winner".
      // Actually, standard is: Phase 1: Submitting -> Phase 2: Judging.
      judgeId: judge.id,
      playerHands: hands,
      currentCardIndex: 0, // Used for Prompt Card index in promptCards list?
      submissions: {},
      activeDeck: deck, // We might need to store the shuffled order somewhere better strictly. 
    );
  }

  @override
  GameState processAction(GameState currentState, Map<String, dynamic> action) {
    final type = action['type'] as String?;
    final playerId = action['player_id'] as String?;

    if (type == 'submit_card') {
      final cardId = action['card_id'] as String;
      
      // Update submissions
      final newSubmissions = Map<String, String>.from(currentState.submissions ?? {});
      newSubmissions[playerId!] = cardId;

      // Remove card from hand
      final hands = Map<String, List<CardModel>>.from(currentState.playerHands ?? {});
      final playerHand = hands[playerId]?.where((c) => c.id != cardId).toList() ?? [];
      hands[playerId] = playerHand;

      // Check if everyone (except judge) has submitted
      // Note: In real app, handle players leaving/joining.
      final submittersCount = currentState.players.where((p) => p.id != currentState.judgeId).length;
      
      var newPhase = currentState.phase;
      if (newSubmissions.length >= submittersCount) {
        newPhase = GamePhase.judging;
      }

      return currentState.copyWith(
        submissions: newSubmissions,
        playerHands: hands,
        phase: newPhase,
      );
    }

    if (type == 'pick_winner') {
      final winningPlayerId = action['winner_id'] as String;
      
      // Award Point
      final players = currentState.players.map((p) {
        if (p.id == winningPlayerId) {
          // Needs a copyWith on Player, but Player is immutable and json_serializable usually doesn't generate copyWith unless requested.
          // Let's reconstruct or assume we add copyWith to Player.
          // For now, hacky reconstruction:
           return Player(
            id: p.id,
            nickname: p.nickname,
            isHost: p.isHost,
            score: p.score + 1,
            avatarUrl: p.avatarUrl,
          );
        }
        return p;
      }).toList();

      // Rotate Judge
      final currentJudgeIndex = players.indexWhere((p) => p.id == currentState.judgeId);
      final nextJudgeIndex = (currentJudgeIndex + 1) % players.length;
      final nextJudgeId = players[nextJudgeIndex].id;

      // Next Prompt
      final nextCardIndex = currentState.currentCardIndex + 1;

      // Deal replacement cards to everyone who played
      // Complex dealing logic omitted for prototype shortness, assume infinite hand or simple refill?
      // Let's just refill everyone to 7 if we can.
      // Need access to "Draw Pile" which we don't strictly track in 'activeDeck'.
      // PROTOTYPE HACK: Just keep hands as is (minus played card) for now.

      return currentState.copyWith(
        players: players,
        judgeId: nextJudgeId,
        submissions: {},
        phase: GamePhase.playing, // Back to submitting
        currentCardIndex: nextCardIndex,
      );
    }

    return currentState;
  }
}
