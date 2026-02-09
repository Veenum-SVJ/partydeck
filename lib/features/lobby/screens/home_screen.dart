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
        id: const Uuid().v4(),
        nickname: _nicknameController.text,
        isHost: true,
        avatarUrl: _selectedAvatar,
      );
      
      final roomCode = await _supabaseService.createRoom(host);
      
      if (mounted) {
        // Navigate to game setup screen so host can select a deck
        context.push('/setup/$roomCode', extra: host);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to create room';
        if (e.toString().contains('SocketException') || e.toString().contains('host lookup')) {
          errorMessage = 'No internet connection. Please check your network.';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Connection timed out. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.secondaryPink,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
      body: Stack(
        children: [
          // Ambient Background Pattern
          Positioned.fill(
            child: _buildAmbientBackground(),
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                _buildTopBar(),
                
                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        
                        // Player Setup (Nickname + Avatar)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildPlayerSetup(),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Main Action Buttons
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildActionButtons(),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Helper Text
                        Text(
                          'Tap to start your session',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.4),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Featured Decks Carousel
                        _buildFeaturedDecks(),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientBackground() {
    return Stack(
      children: [
        // Grid Pattern
        Positioned.fill(
          child: Opacity(
            opacity: 0.2,
            child: CustomPaint(
              painter: _GridPatternPainter(),
            ),
          ),
        ),
        // Glowing Orb - Top Left
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryCyan.withValues(alpha: 0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Glowing Orb - Bottom Right
        Positioned(
          bottom: 100,
          right: -80,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.purple.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48), // Spacer
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.gamepad,
                color: AppTheme.primaryCyan,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                'PARTYDECK',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Profile Button with Online Status
          GestureDetector(
            onTap: () => _showProfileDialog(),
            child: Stack(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Icon(Icons.person, color: Colors.white.withValues(alpha: 0.8)),
                ),
                // Online Status Dot
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.shade400,
                      border: Border.all(color: AppTheme.backgroundBlack, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade400.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSetup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHO ARE YOU?',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nicknameController,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter Nickname',
            prefixIcon: Icon(Icons.edit, color: Colors.white.withValues(alpha: 0.5)),
          ),
        ),
        const SizedBox(height: 16),
        // Avatar Selection
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
                    color: isSelected ? AppTheme.primaryCyan : AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(30),
                    border: isSelected 
                      ? Border.all(color: Colors.white, width: 2) 
                      : Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    boxShadow: isSelected ? AppTheme.neonCyanGlow : null,
                  ),
                  child: Center(
                    child: Text(avatar, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // JOIN PARTY Button - Primary Neon Cyan
        GestureDetector(
          onTap: _isLoading ? null : () => _showJoinDialog(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 96,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.neonCyanGlow,
            ),
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.black))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.login, color: AppTheme.backgroundBlack, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'JOIN PARTY',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.backgroundBlack,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
          ),
        ),
        const SizedBox(height: 16),
        // HOST PARTY Button - Outlined White
        GestureDetector(
          onTap: _isLoading ? null : _createGame,
          child: Container(
            height: 96,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Text(
                  'HOST PARTY',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppTheme.surfaceGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'ENTER ROOM CODE',
          style: TextStyle(color: Colors.white, letterSpacing: 2),
          textAlign: TextAlign.center,
        ),
        content: TextField(
          controller: _roomCodeController,
          style: const TextStyle(color: Colors.white, letterSpacing: 8, fontSize: 32),
          textCapitalization: TextCapitalization.characters,
          textAlign: TextAlign.center,
          maxLength: 4,
          decoration: InputDecoration(
            hintText: 'ABCD',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
            counterText: '',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryCyan),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryCyan, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text('CANCEL', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              _joinGame();
            },
            child: const Text('JOIN'),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppTheme.surfaceGrey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Text(_selectedAvatar, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _nicknameController.text.isEmpty ? 'Guest' : _nicknameController.text,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'Online',
                  style: TextStyle(color: Colors.green.shade400, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProfileOption(Icons.history, 'Game History', 'Coming soon'),
            _buildProfileOption(Icons.star, 'Achievements', 'Coming soon'),
            _buildProfileOption(Icons.settings, 'Settings', 'Coming soon'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text('CLOSE', style: TextStyle(color: AppTheme.primaryCyan)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryCyan),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showAllDecksDialog() {
    context.push('/decks');
  }

  Widget _buildFeaturedDecks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryCyan,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryCyan,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FEATURED DECKS',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _showAllDecksDialog(),
                child: Text(
                  'VIEW ALL',
                  style: TextStyle(
                    color: AppTheme.primaryCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 280,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildDeckCard(
                title: 'Cyber City Pack',
                subtitle: 'Futuristic scenarios & prompts',
                category: 'Sci-Fi',
                categoryIcon: Icons.bolt,
                accentColor: AppTheme.primaryCyan,
                isNew: true,
              ),
              const SizedBox(width: 16),
              _buildDeckCard(
                title: 'Retro Wave Edition',
                subtitle: 'Nostalgia & neon dreams',
                category: '80s Synth',
                categoryIcon: Icons.headphones,
                accentColor: Colors.purple,
              ),
              const SizedBox(width: 16),
              _buildSponsoredDeckCard(),
              const SizedBox(width: 16),
              _buildDeckCard(
                title: 'Late Night Talks',
                subtitle: 'Secrets & stories',
                category: 'Deep Talk',
                categoryIcon: Icons.nightlight,
                accentColor: Colors.pink,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeckCard({
    required String title,
    required String subtitle,
    required String category,
    required IconData categoryIcon,
    required Color accentColor,
    bool isNew = false,
  }) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Image Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                color: AppTheme.surfaceDark,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accentColor.withValues(alpha: 0.3),
                    AppTheme.backgroundBlack,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Category Badge
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Row(
                      children: [
                        Icon(categoryIcon, color: accentColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          category,
                          style: TextStyle(color: accentColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // NEW Badge
                  if (isNew)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentYellow,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentYellow.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Card Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsoredDeckCard() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
        color: AppTheme.surfaceGrey,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.amber.withValues(alpha: 0.2),
                    AppTheme.surfaceGrey,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.local_bar,
                      color: Colors.amber.withValues(alpha: 0.5),
                      size: 64,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Ad',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The Miller Lite Deck',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap to unlock exclusive cards.',
                  style: TextStyle(color: Colors.amber, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Grid Pattern
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const gridSize = 40.0;
    
    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    
    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
