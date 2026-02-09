import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/mock_decks.dart';
import '../models/card_model.dart';

class DeckService {
  static const String _customDecksKey = 'custom_decks';

  Future<List<DeckModel>> getDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final customDecksJson = prefs.getStringList(_customDecksKey) ?? [];
    
    final customDecks = customDecksJson.map((jsonString) {
      try {
        return DeckModel.fromJson(jsonDecode(jsonString));
      } catch (e) {
        // Skip corrupt deck data gracefully
        return null;
      }
    }).whereType<DeckModel>().toList();

    return [
      ...MockDecks.getAllDecks(),
      ...customDecks,
    ];
  }

  Future<void> saveDeck(DeckModel deck) async {
    final prefs = await SharedPreferences.getInstance();
    final customDecksJson = prefs.getStringList(_customDecksKey) ?? [];
    
    // Check if updating existing or adding new (simplified: always append or replace by ID?)
    // For now, let's just append. If ID exists, we should replace.
    

    // Filter out built-ins from "saving" logic? No, we only save to the custom list.
    
    // We need to read only the custom part again to avoid duplicating built-ins into local storage logic if we were mixing them up.
    // Actually, `getDecks` returns combined.
    // Let's just manage the Custom List strictly.
    
    final existingCustoms = customDecksJson.map((s) => DeckModel.fromJson(jsonDecode(s))).toList();
    
    // Remove existing with same ID
    existingCustoms.removeWhere((d) => d.deckId == deck.deckId);
    
    // Add new
    existingCustoms.add(deck);
    
    // Save back
    final newJsonList = existingCustoms.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_customDecksKey, newJsonList);
  }

  Future<void> deleteDeck(String deckId) async {
    final prefs = await SharedPreferences.getInstance();
    final customDecksJson = prefs.getStringList(_customDecksKey) ?? [];
    
    final existingCustoms = customDecksJson.map((s) => DeckModel.fromJson(jsonDecode(s))).toList();
    existingCustoms.removeWhere((d) => d.deckId == deckId);
    
    final newJsonList = existingCustoms.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList(_customDecksKey, newJsonList);
  }
}
