import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("SafeWalk"),
      ),

      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.map);
              },
              icon: const Icon(Icons.map),
              label: const Text("Mapa y rutas"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.contacts);
              },
              icon: const Icon(Icons.contacts),
              label: const Text("Contactos de emergencia"),
            ),
          ],
        ),
      ),

    );

  }

}
