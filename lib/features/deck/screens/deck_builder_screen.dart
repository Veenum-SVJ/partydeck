import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/card_model.dart';

class DeckBuilderScreen extends StatefulWidget {
  const DeckBuilderScreen({super.key});

  @override
  State<DeckBuilderScreen> createState() => _DeckBuilderScreenState();
}

class _DeckBuilderScreenState extends State<DeckBuilderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _urlController = TextEditingController();
  final _jsonController = TextEditingController();
  List<DeckModel> _localDecks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLocalDecks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _loadLocalDecks() async {
    final prefs = await SharedPreferences.getInstance();
    final decksJson = prefs.getStringList('local_decks') ?? [];
    setState(() {
      _localDecks = decksJson
          .map((json) => DeckModel.fromJson(jsonDecode(json)))
          .toList();
    });
  }

  Future<void> _saveDeck(DeckModel deck) async {
    final prefs = await SharedPreferences.getInstance();
    _localDecks.add(deck);
    final decksJson = _localDecks.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList('local_decks', decksJson);
    setState(() {});
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deck "${deck.title}" saved!'),
          backgroundColor: AppTheme.neonGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteDeck(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _localDecks.removeAt(index);
    final decksJson = _localDecks.map((d) => jsonEncode(d.toJson())).toList();
    await prefs.setStringList('local_decks', decksJson);
    setState(() {});
  }

  Future<void> _importFromUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      _showError('Please enter a URL');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // In a real app, you'd fetch the JSON from the URL
      // For now, show a placeholder message
      await Future.delayed(const Duration(seconds: 1));
      _showError('URL import requires server connectivity. Use JSON paste instead.');
    } catch (e) {
      _showError('Failed to import: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importFromJson() async {
    final jsonText = _jsonController.text.trim();
    if (jsonText.isEmpty) {
      _showError('Please paste JSON content');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final json = jsonDecode(jsonText);
      
      // Support both single deck and array of cards
      DeckModel deck;
      if (json is Map<String, dynamic>) {
        if (json.containsKey('content') || json.containsKey('cards')) {
          // Full deck format
          deck = DeckModel.fromJson({
            'deck_id': json['deck_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
            'title': json['title'] ?? 'Imported Deck',
            'engine_type': json['engine_type'] ?? 'E3_TASK',
            'content': json['content'] ?? json['cards'] ?? [],
          });
        } else {
          // Single card
          deck = DeckModel(
            deckId: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Imported Deck',
            engineType: 'E3_TASK',
            content: [CardModel.fromJson(json)],
          );
        }
      } else if (json is List) {
        // Array of cards
        deck = DeckModel(
          deckId: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Imported Deck (${json.length} cards)',
          engineType: 'E3_TASK',
          content: json.map((c) => CardModel.fromJson(c as Map<String, dynamic>)).toList(),
        );
      } else {
        throw FormatException('Invalid JSON format');
      }

      await _saveDeck(deck);
      _jsonController.clear();
      _tabController.animateTo(2); // Switch to My Decks tab
      
    } catch (e) {
      _showError('Invalid JSON: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.secondaryPink,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: Column(
        children: [
          _buildHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUrlImportTab(),
                _buildJsonPasteTab(),
                _buildMyDecksTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DECK BUILDER',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Import and manage your custom decks',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.surfaceDark,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryCyan,
        indicatorWeight: 3,
        labelColor: AppTheme.primaryCyan,
        unselectedLabelColor: Colors.white54,
        tabs: const [
          Tab(icon: Icon(Icons.link), text: 'URL'),
          Tab(icon: Icon(Icons.code), text: 'JSON'),
          Tab(icon: Icon(Icons.folder), text: 'My Decks'),
        ],
      ),
    );
  }

  Widget _buildUrlImportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryCyan.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primaryCyan),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Paste a URL to a JSON file containing your deck data',
                    style: TextStyle(color: AppTheme.primaryCyan),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),
          const SizedBox(height: 24),
          
          // URL Input
          Text(
            'DECK URL',
            style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _urlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'https://example.com/deck.json',
              prefixIcon: Icon(Icons.link, color: Colors.white54),
              filled: true,
              fillColor: AppTheme.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryCyan),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Import Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _importFromUrl,
              icon: _isLoading 
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.download),
              label: Text(_isLoading ? 'IMPORTING...' : 'IMPORT DECK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonPasteTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Example Format
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('JSON FORMAT', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _sampleJson));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sample copied to clipboard')),
                        );
                      },
                      icon: Icon(Icons.copy, color: AppTheme.primaryCyan, size: 18),
                      tooltip: 'Copy sample',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _sampleJson,
                  style: TextStyle(color: AppTheme.neonGreen, fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: -0.1),
          const SizedBox(height: 24),
          
          // JSON Input
          Text(
            'PASTE JSON',
            style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _jsonController,
            style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
            maxLines: 10,
            decoration: InputDecoration(
              hintText: '{\n  "title": "My Deck",\n  "cards": [...]\n}',
              hintStyle: TextStyle(color: Colors.white24),
              filled: true,
              fillColor: AppTheme.surfaceDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryCyan),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Import Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _importFromJson,
              icon: _isLoading 
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.check),
              label: Text(_isLoading ? 'IMPORTING...' : 'IMPORT JSON'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyDecksTab() {
    if (_localDecks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(
              'No custom decks yet',
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Import a deck using URL or JSON',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _localDecks.length,
      itemBuilder: (context, index) {
        final deck = _localDecks[index];
        return _buildDeckListItem(deck, index);
      },
    );
  }

  Widget _buildDeckListItem(DeckModel deck, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryCyan.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.style, color: AppTheme.primaryCyan),
        ),
        title: Text(
          deck.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${deck.totalCards} cards • ${deck.engineType}',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _showDeckPreview(deck),
              icon: Icon(Icons.visibility, color: AppTheme.primaryCyan),
            ),
            IconButton(
              onPressed: () => _confirmDelete(index),
              icon: Icon(Icons.delete_outline, color: AppTheme.secondaryPink),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1);
  }

  void _showDeckPreview(DeckModel deck) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceGrey,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (c) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  deck.title.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(c),
                  icon: Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${deck.totalCards} cards • ${deck.engineType}',
              style: TextStyle(color: AppTheme.primaryCyan, fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Text('SAMPLE CARDS', style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 2)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: deck.content.length.clamp(0, 10),
                itemBuilder: (context, index) {
                  final card = deck.content[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      card.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppTheme.surfaceGrey,
        title: const Text('Delete Deck?', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will permanently remove "${_localDecks[index].title}" from your device.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              _deleteDeck(index);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryPink),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  static const String _sampleJson = '''
{
  "title": "My Party Deck",
  "engine_type": "E3_TASK",
  "content": [
    {"id": "1", "text": "Do 10 pushups"},
    {"id": "2", "text": "Sing a song"}
  ]
}''';
}
