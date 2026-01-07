import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hashtag_app/screens/ScreenA.dart';
import 'package:hashtag_app/screens/ScreenB.dart';
import 'package:hashtag_app/screens/ScreenC.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/a',
  routes: [
    GoRoute(
      path: '/a',
      builder: (_, __) => const ScreenA(),
      routes: [
        GoRoute(
          path: 'b',
          builder: (_, state) => ScreenB(data: state.extra as Map<String, dynamic>?),
          routes: [
            GoRoute(
              path: 'c',
              builder: (_, __) => const ScreenC(),
            ),
          ],
        ),
      ],
    ),
  ],
);
