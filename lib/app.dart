import 'package:flutter/material.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // Notifica el nombre de la ruta activa para saber cuándo mostrar/ocultar
  // el botón SOS flotante, sin tener que tocar cada pantalla.
  final ValueNotifier<String?> _currentRoute = ValueNotifier<String?>(null);

  // El SOS flotante SOLO se muestra en Home. En otras pantallas (Mapa,
  // Contactos, etc.) ya tienen su propio FloatingActionButton y se pisaban
  // entre sí, además de duplicarse con el SOS que ya vive dentro del Home.
  static const Set<String> _visibleRoutes = {AppRoutes.home};

  @override
  void dispose() {
    _currentRoute.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeWalk',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      navigatorKey: _navigatorKey,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      navigatorObservers: [_SosRouteObserver(_currentRoute)],
      builder: (context, child) {
        return Stack(
          children: [
            if (child != null) child,
            ValueListenableBuilder<String?>(
              valueListenable: _currentRoute,
              builder: (context, routeName, _) {
                final show =
                    routeName != null && _visibleRoutes.contains(routeName);

                if (!show) return const SizedBox.shrink();

                return Positioned(
                  right: 16,
                  bottom: 24,
                  child: SafeArea(
                    child: _GlobalSosButton(
                      onTap: () {
                        // Evita apilar la pantalla de SOS si ya se está
                        // navegando hacia allá.
                        _navigatorKey.currentState?.pushNamed(AppRoutes.sos);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

/// Observa la navegación para saber qué ruta está activa y así
/// mostrar/ocultar el SOS flotante global.
class _SosRouteObserver extends NavigatorObserver {
  final ValueNotifier<String?> currentRoute;
  _SosRouteObserver(this.currentRoute);

  @override
  void didPush(Route route, Route? previousRoute) {
    currentRoute.value = route.settings.name;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    currentRoute.value = previousRoute?.settings.name;
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    currentRoute.value = newRoute?.settings.name;
  }
}

/// Botón SOS flotante, persistente sobre cualquier pantalla habilitada.
class _GlobalSosButton extends StatelessWidget {
  final VoidCallback onTap;
  const _GlobalSosButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'global_sos_fab',
      backgroundColor: AppColors.danger,
      elevation: 4,
      onPressed: onTap,
      child: const Icon(Icons.sos, color: Colors.white),
    );
  }
}
