import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_theme.dart';
import 'core/models/game_state.dart';
import 'features/game/screens/game_screen.dart';
import 'features/lobby/screens/home_screen.dart';
import 'features/lobby/screens/lobby_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  // TODO: Replace with real credentials from env
  await Supabase.initialize(
    url: 'https://ongxfnjchcxujcrexqau.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9uZ3hmbmpjaGN4dWpjcmV4cWF1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc3MTU0NjcsImV4cCI6MjA4MzI5MTQ2N30.EntCNXBmb5YTT_Iil-RexDb29rVKiymsxSQkdZyNYmM',
  );

  runApp(const ProviderScope(child: PartyDeckApp()));
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/lobby/:roomCode',
      builder: (context, state) {
        final roomCode = state.pathParameters['roomCode']!;
        final player = state.extra as Player;
        return LobbyScreen(roomCode: roomCode, player: player);
      },
    ),
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
