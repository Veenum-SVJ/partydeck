import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_theme.dart';
import '../../../core/models/game_state.dart';
import '../../../core/services/supabase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nicknameController = TextEditingController();
  final _roomCodeController = TextEditingController();
  bool _isLoading = false;
  String _selectedAvatar = '😎';

  final List<String> _avatars = [
    '😎', '🤡', '👻', '👾', '🤖',
    '💩', '🦄', '🦁', '🐶', '🐱',
    '🦊', '🐭', '🐹', '🐰', '🐻',
  ];

  late SupabaseService _supabaseService;

  @override
  void initState() {
    super.initState();
    // In a real app, use Riverpod to providing this
    _supabaseService = SupabaseService(Supabase.instance.client);
  }

  Future<void> _createGame() async {
    if (_nicknameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a nickname')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final host = Player(
        id: const Uuid().v4(), // Placeholder until we have Auth
        nickname: _nicknameController.text,
        isHost: true,
        avatarUrl: _selectedAvatar,
      );
      
      final roomCode = await _supabaseService.createRoom(host);
      
      if (mounted) {
        context.push('/lobby/$roomCode', extra: host);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _joinGame() async {
    if (_nicknameController.text.isEmpty || _roomCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter nickname and room code')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final player = Player(
        id: const Uuid().v4(),
        nickname: _nicknameController.text,
        isHost: false,
        avatarUrl: _selectedAvatar,
      );

      await _supabaseService.joinRoom(_roomCodeController.text.toUpperCase(), player);
      
      if (mounted) {
        context.push('/lobby/${_roomCodeController.text.toUpperCase()}', extra: player);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PARTYDECK',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryCyan,
                      letterSpacing: 1.5,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: AppTheme.surfaceGrey,
                    child: Icon(Icons.person, color: AppTheme.primaryCyan),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Input Section (Nickname + Avatar)
                    Text('WHO ARE YOU?', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nicknameController,
                      style: Theme.of(context).textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Enter Nickname',
                        hintStyle: TextStyle(color: Colors.white24),
                        filled: true,
                        fillColor: AppTheme.surfaceGrey,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.edit, color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 60,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _avatars.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final avatar = _avatars[index];
                          final isSelected = avatar == _selectedAvatar;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedAvatar = avatar),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 60,
                              decoration: BoxDecoration(
                                color: isSelected ? AppTheme.primaryCyan : AppTheme.surfaceGrey,
                                borderRadius: BorderRadius.circular(30),
                                border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                              ),
                              child: Center(
                                child: Text(
                                  avatar,
                                  style: const TextStyle(fontSize: 30),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 48),

                    // Main Actions
                    SizedBox(
                      height: 80,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () {
                           // Show Join Dialog/Input
                           showDialog(
                             context: context,
                             builder: (c) => _buildJoinDialog(c),
                           );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryCyan,
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text('JOIN PARTY', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 80,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _createGame,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('HOST PARTY', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 48),
                    
                    // Featured Decks Carousel (with Ad Injection)
                    Text('FEATURED DECKS', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildDeckCard('Base Set', Colors.purple, 'The classic experience.'),
                          const SizedBox(width: 16),
                          _buildDeckCard('Filthy Blanks', Colors.red, 'Not for kids.'),
                          const SizedBox(width: 16),
                          // Ad Injection
                          _buildAdCard('Sponsored: The Chili\'s Deck', Colors.orange),
                          const SizedBox(width: 16),
                          _buildDeckCard('Voting Pack', Colors.blue, 'Judge your friends.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinDialog(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceGrey,
      title: const Text('ENTER ROOM CODE', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: _roomCodeController,
        style: const TextStyle(color: Colors.white, letterSpacing: 5, fontSize: 24),
        textCapitalization: TextCapitalization.characters,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          hintText: 'ABCD',
          hintStyle: TextStyle(color: Colors.white24),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryCyan)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryCyan, width: 2)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            _joinGame();
          },
          child: const Text('JOIN'),
        ),
      ],
    );
  }

  Widget _buildDeckCard(String title, Color color, String subtitle) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(50),      
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withAlpha(50), shape: BoxShape.circle),
            child: Icon(Icons.style, color: color),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildAdCard(String title, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceGrey,      
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withAlpha(100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.star, color: Colors.amber, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                child: const Text('Ad', style: TextStyle(color: Colors.white, fontSize: 10)),
              )
            ],
          ),
          const Spacer(),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('Tap to unlock exclusive cards.', style: TextStyle(color: Colors.amber, fontSize: 12)),
        ],
      ),
    );
  }
}

