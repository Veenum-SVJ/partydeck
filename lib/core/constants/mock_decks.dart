import '../models/card_model.dart';


class MockDecks {
  static final DeckModel e3Drill = DeckModel(
    deckId: 'mock_e3_001',
    title: 'Truths & Dares',
    engineType: 'E3_TASK',
    content: [
      CardModel(id: 'c1', text: 'What is your biggest fear?', category: 'TRUTH', penalty: 'Drink 1'),
      CardModel(id: 'c2', text: 'Do 10 pushups.', category: 'DARE', penalty: 'Drink 2'),
      CardModel(id: 'c3', text: 'Who in this room would you date?', category: 'TRUTH', penalty: 'Finish Drink'),
      CardModel(id: 'c4', text: 'Let the person to your left slap you.', category: 'DARE', penalty: 'Drink 3'),
      CardModel(id: 'c5', text: 'Tell a joke. If no one laughs, drink.', category: 'TASK'),
    ],
  );

  static final DeckModel e1Standard = DeckModel(
    deckId: 'mock_e1_001',
    title: 'Filthy Fill-Ins',
    engineType: 'E1_JUDGE',
    content: [
      // PROMPTS
      CardModel(id: 'p1', text: 'Why am I sticky?', category: 'PROMPT'),
      CardModel(id: 'p2', text: 'What is Batman\'s guilty pleasure?', category: 'PROMPT'),
      CardModel(id: 'p3', text: '___: Good to the last drop.', category: 'PROMPT'),
      
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
    ],
  );

  static final DeckModel e2MostLikely = DeckModel(
    deckId: 'mock_e2_001',
    title: 'Who is Most Likely',
    engineType: 'E2_VOTING',
    content: [
      CardModel(id: 'v1', text: 'Who is most likely to join a cult?', category: 'VOTE'),
      CardModel(id: 'v2', text: 'Who is most likely to kill someone by accident?', category: 'VOTE'),
      CardModel(id: 'v3', text: 'Who will die first in a horror movie?', category: 'VOTE'),
      CardModel(id: 'v4', text: 'Who is most likely to marry for money?', category: 'VOTE'),
      CardModel(id: 'v5', text: 'Who is secretly a furry?', category: 'VOTE'),
    ],
  );
}
