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
  isSponsored: json['is_sponsored'] as bool? ?? false,
  sponsorLogo: json['sponsor_logo'] as String?,
  sponsorName: json['sponsor_name'] as String?,
  sponsorCta: json['sponsor_cta'] as String?,
);

Map<String, dynamic> _$CardModelToJson(CardModel instance) => <String, dynamic>{
  'id': instance.id,
  'text': instance.text,
  'category': instance.category,
  'penalty': instance.penalty,
  'is_sponsored': instance.isSponsored,
  'sponsor_logo': instance.sponsorLogo,
  'sponsor_name': instance.sponsorName,
  'sponsor_cta': instance.sponsorCta,
};

DeckModel _$DeckModelFromJson(Map<String, dynamic> json) => DeckModel(
  deckId: json['deck_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  engineType: json['engine_type'] as String,
  content: (json['content'] as List<dynamic>)
      .map((e) => CardModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  cardCount: (json['card_count'] as num?)?.toInt(),
  isPremium: json['is_premium'] as bool? ?? false,
  isSponsored: json['is_sponsored'] as bool? ?? false,
  sponsorFrequency: (json['sponsor_frequency'] as num?)?.toInt() ?? 5,
  category: json['category'] as String?,
  accentColor: json['accent_color'] as String?,
  iconName: json['icon_name'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$DeckModelToJson(DeckModel instance) => <String, dynamic>{
  'deck_id': instance.deckId,
  'title': instance.title,
  'description': instance.description,
  'engine_type': instance.engineType,
  'content': instance.content,
  'card_count': instance.cardCount,
  'is_premium': instance.isPremium,
  'is_sponsored': instance.isSponsored,
  'sponsor_frequency': instance.sponsorFrequency,
  'category': instance.category,
  'accent_color': instance.accentColor,
  'icon_name': instance.iconName,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
