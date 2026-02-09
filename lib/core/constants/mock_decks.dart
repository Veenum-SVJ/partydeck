import '../models/card_model.dart';

/// Mock decks with extensive card lists for all game engines.
/// In production, these would be loaded from Supabase or remote JSON.
class MockDecks {
  /// E3 Task Engine - Truths, Dares & Tasks
  static final DeckModel e3Drill = DeckModel(
    deckId: 'mock_e3_001',
    title: 'Truths & Dares: Classic',
    engineType: 'E3_TASK',
    description: 'The original party classic with 30+ wild prompts',
    content: [
      // TRUTHS
      CardModel(id: 't1', text: 'What is your biggest fear?', category: 'TRUTH', penalty: 'Drink 1'),
      CardModel(id: 't2', text: 'Who in this room would you date?', category: 'TRUTH', penalty: 'Drink 2'),
      CardModel(id: 't3', text: 'What is your most embarrassing moment?', category: 'TRUTH', penalty: 'Drink 1'),
      CardModel(id: 't4', text: 'Have you ever cheated on someone?', category: 'TRUTH', penalty: 'Finish Drink'),
      CardModel(id: 't5', text: 'What is your body count?', category: 'TRUTH', penalty: 'Drink 3'),
      CardModel(id: 't6', text: 'Who was your first kiss?', category: 'TRUTH', penalty: 'Drink 1'),
      CardModel(id: 't7', text: 'What is your biggest regret?', category: 'TRUTH', penalty: 'Drink 2'),
      CardModel(id: 't8', text: 'Have you ever stolen something?', category: 'TRUTH', penalty: 'Drink 1'),
      CardModel(id: 't9', text: 'What is your weirdest fantasy?', category: 'TRUTH', penalty: 'Drink 3'),
      CardModel(id: 't10', text: 'Who in this room is the most attractive?', category: 'TRUTH', penalty: 'Drink 2'),
      CardModel(id: 't11', text: 'What is something you have never told anyone?', category: 'TRUTH', penalty: 'Finish Drink'),
      CardModel(id: 't12', text: 'What is your guilty pleasure?', category: 'TRUTH', penalty: 'Drink 1'),
      
      // DARES
      CardModel(id: 'd1', text: 'Do 10 pushups right now.', category: 'DARE', penalty: 'Drink 2'),
      CardModel(id: 'd2', text: 'Let the person to your left slap you.', category: 'DARE', penalty: 'Drink 3'),
      CardModel(id: 'd3', text: 'Send a risky text to your crush.', category: 'DARE', penalty: 'Drink 3'),
      CardModel(id: 'd4', text: 'Take a shot blindfolded.', category: 'DARE', penalty: 'Drink 2'),
      CardModel(id: 'd5', text: 'Let someone go through your phone for 1 minute.', category: 'DARE', penalty: 'Drink 3'),
      CardModel(id: 'd6', text: 'Do your best impression of someone in this room.', category: 'DARE', penalty: 'Drink 1'),
      CardModel(id: 'd7', text: 'Call your ex and say "I miss you."', category: 'DARE', penalty: 'Finish Drink'),
      CardModel(id: 'd8', text: 'Eat a spoonful of hot sauce.', category: 'DARE', penalty: 'Drink 2'),
      CardModel(id: 'd9', text: 'Let someone draw on your face with marker.', category: 'DARE', penalty: 'Drink 3'),
      CardModel(id: 'd10', text: 'Post an embarrassing photo on your story.', category: 'DARE', penalty: 'Drink 3'),
      CardModel(id: 'd11', text: 'Dance with no music for 30 seconds.', category: 'DARE', penalty: 'Drink 1'),
      CardModel(id: 'd12', text: 'Give someone here a lap dance.', category: 'DARE', penalty: 'Drink 3'),
      
      // TASKS
      CardModel(id: 'k1', text: 'Tell a joke. If no one laughs, drink.', category: 'TASK'),
      CardModel(id: 'k2', text: 'Everyone must compliment you. If someone refuses, they drink.', category: 'TASK'),
      CardModel(id: 'k3', text: 'Arm wrestle the person to your right. Loser drinks.', category: 'TASK'),
      CardModel(id: 'k4', text: 'Everyone who has the same zodiac sign as you drinks.', category: 'TASK'),
      CardModel(id: 'k5', text: 'Thumb war! Loser finishes their drink.', category: 'TASK'),
      CardModel(id: 'k6', text: 'Staring contest with the person across from you.', category: 'TASK'),
    ],
  );

  /// E3 Task Engine - Spicy Edition
  static final DeckModel e3Spicy = DeckModel(
    deckId: 'mock_e3_002',
    title: 'Truths & Dares: Spicy 🔥',
    engineType: 'E3_TASK',
    description: 'For adults only - explicit content',
    content: [
      CardModel(id: 's1', text: 'Describe your last intimate encounter in detail.', category: 'TRUTH', penalty: 'Finish Drink'),
      CardModel(id: 's2', text: 'What is your biggest turn on?', category: 'TRUTH', penalty: 'Drink 2'),
      CardModel(id: 's3', text: 'Have you ever had a one night stand?', category: 'TRUTH', penalty: 'Drink 2'),
      CardModel(id: 's4', text: 'What is the craziest place you have done it?', category: 'TRUTH', penalty: 'Drink 3'),
      CardModel(id: 's5', text: 'Would you ever try a threesome?', category: 'TRUTH', penalty: 'Drink 2'),
      CardModel(id: 's6', text: 'What is your biggest kink?', category: 'TRUTH', penalty: 'Drink 3'),
      CardModel(id: 's7', text: 'Have you ever sent nudes?', category: 'TRUTH', penalty: 'Drink 2'),
      CardModel(id: 's8', text: 'What is the longest you have gone without it?', category: 'TRUTH', penalty: 'Drink 1'),
      CardModel(id: 's9', text: 'Give someone a 10-second massage.', category: 'DARE', penalty: 'Drink 2'),
      CardModel(id: 's10', text: 'Whisper something dirty in someone\'s ear.', category: 'DARE', penalty: 'Drink 3'),
      CardModel(id: 's11', text: 'Remove an article of clothing.', category: 'DARE', penalty: 'Finish Drink'),
      CardModel(id: 's12', text: 'Let someone sit on your lap for the next round.', category: 'DARE', penalty: 'Drink 2'),
      CardModel(id: 's13', text: 'Text your most recent match "You up?"', category: 'DARE', penalty: 'Drink 3'),
      CardModel(id: 's14', text: 'Do your best moan sound.', category: 'DARE', penalty: 'Drink 2'),
      CardModel(id: 's15', text: 'Demonstrate your favorite position using a pillow.', category: 'DARE', penalty: 'Finish Drink'),
    ],
  );

  /// E1 Judge Engine - Cards Against Humanity style
  static final DeckModel e1Standard = DeckModel(
    deckId: 'mock_e1_001',
    title: 'Filthy Fill-Ins',
    engineType: 'E1_JUDGE',
    description: 'Cards Against Humanity style prompts',
    content: [
      // PROMPTS
      CardModel(id: 'p1', text: 'Why am I sticky?', category: 'PROMPT'),
      CardModel(id: 'p2', text: 'What is Batman\'s guilty pleasure?', category: 'PROMPT'),
      CardModel(id: 'p3', text: '___: Good to the last drop.', category: 'PROMPT'),
      CardModel(id: 'p4', text: 'What ended my last relationship?', category: 'PROMPT'),
      CardModel(id: 'p5', text: 'What is hiding under my bed?', category: 'PROMPT'),
      CardModel(id: 'p6', text: 'The secret ingredient to my grandma\'s recipe is ___.', category: 'PROMPT'),
      CardModel(id: 'p7', text: 'What makes my Tinder profile unique?', category: 'PROMPT'),
      CardModel(id: 'p8', text: 'What do I think about during meetings?', category: 'PROMPT'),
      CardModel(id: 'p9', text: 'My therapist says I should stop ___.', category: 'PROMPT'),
      CardModel(id: 'p10', text: 'What is the key to a happy marriage?', category: 'PROMPT'),
      
      // ANSWERS
      CardModel(id: 'a1', text: 'A bucket of fish heads.', category: 'ANSWER'),
      CardModel(id: 'a2', text: 'Grandma\'s heavy flow.', category: 'ANSWER'),
      CardModel(id: 'a3', text: 'Being a dick.', category: 'ANSWER'),
      CardModel(id: 'a4', text: 'Coat hanger abortions.', category: 'ANSWER'),
      CardModel(id: 'a5', text: 'A sad handjob.', category: 'ANSWER'),
      CardModel(id: 'a6', text: 'Chunks of dead hitchhiker.', category: 'ANSWER'),
      CardModel(id: 'a7', text: 'My ex-wife.', category: 'ANSWER'),
      CardModel(id: 'a8', text: 'Glory holes.', category: 'ANSWER'),
      CardModel(id: 'a9', text: 'Daddy issues.', category: 'ANSWER'),
      CardModel(id: 'a10', text: 'Farting and walking away.', category: 'ANSWER'),
      CardModel(id: 'a11', text: 'Erectile dysfunction.', category: 'ANSWER'),
      CardModel(id: 'a12', text: 'A tiny horse.', category: 'ANSWER'),
      CardModel(id: 'a13', text: 'Poor life choices.', category: 'ANSWER'),
      CardModel(id: 'a14', text: 'Several small children in a trenchcoat.', category: 'ANSWER'),
      CardModel(id: 'a15', text: 'The gay agenda.', category: 'ANSWER'),
      CardModel(id: 'a16', text: 'Aggressive cuddling.', category: 'ANSWER'),
      CardModel(id: 'a17', text: 'Surprise colonoscopy.', category: 'ANSWER'),
      CardModel(id: 'a18', text: 'An uncomfortable amount of cheese.', category: 'ANSWER'),
      CardModel(id: 'a19', text: 'Thoughts and prayers.', category: 'ANSWER'),
      CardModel(id: 'a20', text: 'A balanced diet.', category: 'ANSWER'),
    ],
  );

  /// E2 Voting Engine - Who is Most Likely
  static final DeckModel e2MostLikely = DeckModel(
    deckId: 'mock_e2_001',
    title: 'Who is Most Likely',
    engineType: 'E2_VOTING',
    description: 'Vote on who fits the description best',
    content: [
      CardModel(id: 'v1', text: 'Who is most likely to join a cult?', category: 'VOTE'),
      CardModel(id: 'v2', text: 'Who is most likely to kill someone by accident?', category: 'VOTE'),
      CardModel(id: 'v3', text: 'Who will die first in a horror movie?', category: 'VOTE'),
      CardModel(id: 'v4', text: 'Who is most likely to marry for money?', category: 'VOTE'),
      CardModel(id: 'v5', text: 'Who is secretly a furry?', category: 'VOTE'),
      CardModel(id: 'v6', text: 'Who would survive the longest in a zombie apocalypse?', category: 'VOTE'),
      CardModel(id: 'v7', text: 'Who is most likely to become famous?', category: 'VOTE'),
      CardModel(id: 'v8', text: 'Who would make the worst parent?', category: 'VOTE'),
      CardModel(id: 'v9', text: 'Who is most likely to go to jail?', category: 'VOTE'),
      CardModel(id: 'v10', text: 'Who talks the most trash?', category: 'VOTE'),
      CardModel(id: 'v11', text: 'Who would sell you out for \$100?', category: 'VOTE'),
      CardModel(id: 'v12', text: 'Who is the biggest drama queen?', category: 'VOTE'),
      CardModel(id: 'v13', text: 'Who has the worst taste in music?', category: 'VOTE'),
      CardModel(id: 'v14', text: 'Who is most likely to cry at a movie?', category: 'VOTE'),
      CardModel(id: 'v15', text: 'Who would win in a fight?', category: 'VOTE'),
      CardModel(id: 'v16', text: 'Who has the biggest ego?', category: 'VOTE'),
      CardModel(id: 'v17', text: 'Who is most likely to get lost?', category: 'VOTE'),
      CardModel(id: 'v18', text: 'Who is the worst liar?', category: 'VOTE'),
      CardModel(id: 'v19', text: 'Who has the most embarrassing search history?', category: 'VOTE'),
      CardModel(id: 'v20', text: 'Who would be the first to betray the group?', category: 'VOTE'),
    ],
  );

  /// E2 Voting Engine - Never Have I Ever
  static final DeckModel e2NeverHaveI = DeckModel(
    deckId: 'mock_e2_002',
    title: 'Never Have I Ever',
    engineType: 'E2_VOTING',
    description: 'Classic drinking game - drink if you have done it',
    content: [
      CardModel(id: 'n1', text: 'Never have I ever cheated on a test.', category: 'VOTE'),
      CardModel(id: 'n2', text: 'Never have I ever been in a fight.', category: 'VOTE'),
      CardModel(id: 'n3', text: 'Never have I ever sent a text to the wrong person.', category: 'VOTE'),
      CardModel(id: 'n4', text: 'Never have I ever lied to get out of work.', category: 'VOTE'),
      CardModel(id: 'n5', text: 'Never have I ever stalked an ex on social media.', category: 'VOTE'),
      CardModel(id: 'n6', text: 'Never have I ever ghosted someone.', category: 'VOTE'),
      CardModel(id: 'n7', text: 'Never have I ever cried in public.', category: 'VOTE'),
      CardModel(id: 'n8', text: 'Never have I ever been arrested.', category: 'VOTE'),
      CardModel(id: 'n9', text: 'Never have I ever pretended not to see someone.', category: 'VOTE'),
      CardModel(id: 'n10', text: 'Never have I ever snooped through someone\'s phone.', category: 'VOTE'),
      CardModel(id: 'n11', text: 'Never have I ever blamed my fart on someone else.', category: 'VOTE'),
      CardModel(id: 'n12', text: 'Never have I ever eaten food from the trash.', category: 'VOTE'),
      CardModel(id: 'n13', text: 'Never have I ever lied about my age.', category: 'VOTE'),
      CardModel(id: 'n14', text: 'Never have I ever been kicked out of a bar.', category: 'VOTE'),
      CardModel(id: 'n15', text: 'Never have I ever regifted a present.', category: 'VOTE'),
    ],
  );

  /// Get all available decks
  static List<DeckModel> getAllDecks() {
    return [
      e3Drill,
      e3Spicy,
      e1Standard,
      e2MostLikely,
      e2NeverHaveI,
    ];
  }
}
