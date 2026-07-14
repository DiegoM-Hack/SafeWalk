import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeWalk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.map);
              },
              icon: const Icon(Icons.map),
              label: const Text('Mapa y rutas'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.contacts);
              },
              icon: const Icon(Icons.contacts),
              label: const Text('Contactos de emergencia'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.history);
              },
              icon: const Icon(Icons.history),
              label: const Text('Historial'),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.sos);
              },
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('Emergencia SOS'),
            ),
            
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.profile);
              },
              icon: const Icon(Icons.person),
              label: const Text('Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}

