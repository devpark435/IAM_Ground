import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Screens
import 'screens/home_screen.dart';
import 'screens/info_input_screen.dart';
import 'screens/customization_screen.dart';
import 'screens/share_screen.dart';
import 'screens/card_list_screen.dart';
import 'screens/web_viewer_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/info',
        name: 'info',
        builder: (context, state) => const InfoInputScreen(),
      ),
      GoRoute(
        path: '/customize',
        name: 'customize',
        builder: (context, state) => const CustomizationScreen(),
      ),
      GoRoute(
        path: '/share',
        name: 'share',
        builder: (context, state) => const ShareScreen(),
      ),
      GoRoute(
        path: '/my-cards',
        name: 'my-cards',
        builder: (context, state) => const CardListScreen(),
        routes: [
          GoRoute(
            path: 'card/:id',
            name: 'web-viewer',
            builder: (context, state) {
              final cardId = state.pathParameters['id'];
              return WebViewerScreen(cardId: cardId!);
            },
          ),
        ],
      ),
    ],
    errorBuilder:
        (context, state) => Scaffold(
          body: Center(child: Text('Page not found: ${state.matchedLocation}')),
        ),
  );
});
