import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/food/presentation/food_detail_screen.dart';
import '../../features/food/presentation/food_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/scanner/presentation/scanner_screen.dart';
import '../../features/shopping/presentation/shopping_screen.dart';
import '../../features/expenses/presentation/expenses_screen.dart';
import 'main_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter({required bool initialOnboardingDone}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialOnboardingDone ? '/home' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/scanner',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ScannerScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Pestaña 1: Inicio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Pestaña 2: Comida
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/food',
                builder: (context, state) => const FoodScreen(),
                routes: [
                  GoRoute(
                    path: 'detail/:id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
                      return FoodDetailScreen(foodId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Pestaña 3: Compras
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/shopping',
                builder: (context, state) => const ShoppingScreen(),
              ),
            ],
          ),

          // Pestaña 4: Gastos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/expenses',
                builder: (context, state) => const ExpensesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
