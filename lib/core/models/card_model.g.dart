// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardModel _$CardModelFromJson(Map<String, dynamic> json) => CardModel(
  id: json['id'] as String,
  text: json['text'] as String,
  category: json['category'] as String?,
  penalty: json['penalty'] as String?,
);

Map<String, dynamic> _$CardModelToJson(CardModel instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'category': instance.category,
  'penalty': instance.penalty,
};

DeckModel _$DeckModelFromJson(Map<String, dynamic> json) => DeckModel(
  deckId: json['deck_id'] as String,
  title: json['title'] as String,
  engineType: json['engine_type'] as String,
  content: (json['content'] as List<dynamic>)
      .map((e) => CardModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DeckModelToJson(DeckModel instance) => <String, dynamic>{
  'deck_id': instance.deckId,
  'title': instance.title,
  'engine_type': instance.engineType,
  'content': instance.content,
};
