import 'package:json_annotation/json_annotation.dart';

part 'card_model.g.dart';

@JsonSerializable()
class CardModel {
  final String id;
  final String text;
  final String? category;
  final String? penalty;

  CardModel({
    required this.id,
    required this.text,
    this.category,
    this.penalty,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => _$CardModelFromJson(json);
  Map<String, dynamic> toJson() => _$CardModelToJson(this);
}

@JsonSerializable()
class DeckModel {
  @JsonKey(name: 'deck_id')
  final String deckId;
  final String title;
  @JsonKey(name: 'engine_type')
  final String engineType;
  final List<CardModel> content;

  DeckModel({
    required this.deckId,
    required this.title,
    required this.engineType,
    required this.content,
  });

  factory DeckModel.fromJson(Map<String, dynamic> json) => _$DeckModelFromJson(json);
  Map<String, dynamic> toJson() => _$DeckModelToJson(this);
}
