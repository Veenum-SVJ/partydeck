import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/card_model.dart';
import '../../../core/services/deck_service.dart';

class DeckImportScreen extends StatefulWidget {
  const DeckImportScreen({super.key});

  @override
  State<DeckImportScreen> createState() => _DeckImportScreenState();
}

class _DeckImportScreenState extends State<DeckImportScreen> {
  final _jsonController = TextEditingController();
  final _deckService = DeckService();
  String? _errorMessage;

  Future<void> _importDeck() async {
    setState(() => _errorMessage = null);
    
    try {
      final jsonString = _jsonController.text.trim();
      if (jsonString.isEmpty) throw Exception('Please paste JSON content.');

      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      final deck = DeckModel.fromJson(jsonMap);

      await _deckService.saveDeck(deck);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deck "${deck.title}" imported successfully!')),
        );
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    }
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Custom Deck')),
      body: Container(
         padding: const EdgeInsets.all(16),
         color: AppTheme.backgroundBlack,
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.stretch,
           children: [
             const Text(
               'Paste your Deck JSON below:',
               style: TextStyle(color: Colors.white, fontSize: 16),
             ),
             const SizedBox(height: 16),
             Expanded(
               child: TextField(
                 controller: _jsonController,
                 maxLines: null,
                 expands: true,
                 style: const TextStyle(color: Colors.white, fontFamily: 'Courier'),
                 decoration: InputDecoration(
                   filled: true,
                   fillColor: AppTheme.surfaceGrey,
                   hintText: '{\n  "id": "my_deck",\n  "title": "My Fun Deck",\n  ... \n}',
                   hintStyle: const TextStyle(color: Colors.white24),
                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                 ),
               ),
             ),
             if (_errorMessage != null) ...[
               const SizedBox(height: 16),
               Text(
                 _errorMessage!,
                 style: const TextStyle(color: AppTheme.secondaryPink),
               ),
             ],
             const SizedBox(height: 16),
             ElevatedButton(
               onPressed: _importDeck,
               style: ElevatedButton.styleFrom(
                 backgroundColor: AppTheme.primaryCyan,
                 foregroundColor: Colors.black,
                 padding: const EdgeInsets.all(16),
               ),
               child: const Text('IMPORT DECK'),
             ),
           ],
         ),
      ),
    );
  }
}
