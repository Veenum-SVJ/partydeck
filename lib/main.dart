import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_theme.dart';
import 'core/models/game_state.dart';
import 'features/game/screens/game_screen.dart';
import 'features/game/screens/round_results_screen.dart';
import 'features/lobby/screens/home_screen.dart';
import 'features/lobby/screens/lobby_screen.dart';
import 'features/lobby/screens/game_setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://ongxfnjchcxujcrexqau.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9uZ3hmbmpjaGN4dWpjcmV4cWF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3MTU0NjcsImV4cCI6MjA4MzI5MTQ2N30.EntCNXBmb5YTT_Iil-RexDb29rVKiymsxSQkdZyNYmM',
  );

  runApp(const ProviderScope(child: PartyDeckApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    // Home Screen
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    // Game Setup Screen (Host only)
    GoRoute(
      path: '/setup/:roomCode',
      builder: (context, state) {
        final roomCode = state.pathParameters['roomCode']!;
        final player = state.extra as Player;
        return GameSetupScreen(roomCode: roomCode, player: player);
      },
    ),
    // Lobby Screen
    GoRoute(
      path: '/lobby/:roomCode',
      builder: (context, state) {
        final roomCode = state.pathParameters['roomCode']!;
        final player = state.extra as Player;
        return LobbyScreen(roomCode: roomCode, player: player);
      },
    ),
    // Game Screen
    GoRoute(
      path: '/game/:roomCode',
      builder: (context, state) {
        final roomCode = state.pathParameters['roomCode']!;
        final extras = state.extra as Map<String, dynamic>;
        final player = extras['player'] as Player;
        final initialState = extras['initialState'] as GameState;
        return GameScreen(
          roomCode: roomCode, 
          player: player,
          initialState: initialState,
        );
      },
    ),
    // Round Results Screen
    GoRoute(
      path: '/results/:roomCode',
      builder: (context, state) {
        final roomCode = state.pathParameters['roomCode']!;
        final extras = state.extra as Map<String, dynamic>;
        final gameState = extras['gameState'] as GameState;
        final player = extras['player'] as Player;
        return RoundResultsScreen(
          gameState: gameState,
          player: player,
          onNextRound: () => context.pop(),
          onEndGame: () => context.go('/'),
        );
      },
    ),
  ],
);

class PartyDeckApp extends StatelessWidget {
  const PartyDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PartyDeck',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
