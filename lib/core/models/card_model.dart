import 'package:json_annotation/json_annotation.dart';

part 'card_model.g.dart';

@JsonSerializable()
class CardModel {
  final String id;
  final String text;
  final String? category;
  final String? penalty;
  
  // Sponsored card fields
  @JsonKey(name: 'is_sponsored')
  final bool isSponsored;
  @JsonKey(name: 'sponsor_logo')
  final String? sponsorLogo;
  @JsonKey(name: 'sponsor_name')
  final String? sponsorName;
  @JsonKey(name: 'sponsor_cta')
  final String? sponsorCta;

  CardModel({
    required this.id,
    required this.text,
    this.category,
    this.penalty,
    this.isSponsored = false,
    this.sponsorLogo,
    this.sponsorName,
    this.sponsorCta,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) => _$CardModelFromJson(json);
  Map<String, dynamic> toJson() => _$CardModelToJson(this);

  /// Create a copy with modified fields
  CardModel copyWith({
    String? id,
    String? text,
    String? category,
    String? penalty,
    bool? isSponsored,
    String? sponsorLogo,
    String? sponsorName,
    String? sponsorCta,
  }) {
    return CardModel(
      id: id ?? this.id,
      text: text ?? this.text,
      category: category ?? this.category,
      penalty: penalty ?? this.penalty,
      isSponsored: isSponsored ?? this.isSponsored,
      sponsorLogo: sponsorLogo ?? this.sponsorLogo,
      sponsorName: sponsorName ?? this.sponsorName,
      sponsorCta: sponsorCta ?? this.sponsorCta,
    );
  }
}

@JsonSerializable()
class DeckModel {
  @JsonKey(name: 'deck_id')
  final String deckId;
  final String title;
  final String? description;
  @JsonKey(name: 'engine_type')
  final String engineType;
  final List<CardModel> content;
  
  // Deck metadata
  @JsonKey(name: 'card_count')
  final int? cardCount;
  @JsonKey(name: 'is_premium')
  final bool isPremium;
  @JsonKey(name: 'is_sponsored')
  final bool isSponsored;
  @JsonKey(name: 'sponsor_frequency')
  final int sponsorFrequency; // Show sponsored card every N cards
  final String? category;
  @JsonKey(name: 'accent_color')
  final String? accentColor;
  @JsonKey(name: 'icon_name')
  final String? iconName;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  DeckModel({
    required this.deckId,
    required this.title,
    this.description,
    required this.engineType,
    required this.content,
    this.cardCount,
    this.isPremium = false,
    this.isSponsored = false,
    this.sponsorFrequency = 5,
    this.category,
    this.accentColor,
    this.iconName,
    this.createdAt,
    this.updatedAt,
  });

  factory DeckModel.fromJson(Map<String, dynamic> json) => _$DeckModelFromJson(json);
  Map<String, dynamic> toJson() => _$DeckModelToJson(this);

  /// Get card count from content if not explicitly set
  int get totalCards => cardCount ?? content.length;
}
