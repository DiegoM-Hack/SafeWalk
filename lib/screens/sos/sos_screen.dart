import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/sos_provider.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<LocationProvider>().loadCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sosProvider = context.watch<SOSProvider>();
    final locationProvider = context.watch<LocationProvider>();
    final authProvider = context.read<AuthProvider>();
    final theme = Theme.of(context);

    final position = locationProvider.currentPosition;

    return Scaffold(
      appBar: AppBar(
        title: const Text("SafeWalk"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 100,
            ),

            const SizedBox(height: 20),

            const Text(
              "EMERGENCIA",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Si te encuentras en una situación de riesgo, presiona el botón para enviar una alerta.",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: position == null
                          ? Text(
                              "Obteniendo ubicación...",
                              style: theme.textTheme.bodyMedium,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ubicación actual",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Lat: ${position.latitude.toStringAsFixed(6)}",
                                ),
                                Text(
                                  "Lng: ${position.longitude.toStringAsFixed(6)}",
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            if (sosProvider.isLoading)
              const CircularProgressIndicator()

            else if (!sosProvider.isEmergencyActive)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                ),
                icon: const Icon(Icons.sos),
                label: const Text("ENVIAR ALERTA SOS"),
                onPressed: () async {
                  final confirmar = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Confirmar"),
                      content: const Text(
                        "¿Deseas enviar una alerta SOS?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancelar"),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Enviar"),
                        ),
                      ],
                    ),
                  );

                  if (confirmar != true) return;

                  if (position == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "No se pudo obtener la ubicación.",
                        ),
                      ),
                    );
                    return;
                  }

                  final uid = authProvider.user?.uid;

                  if (uid == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.danger,
                        content: Text("Debes iniciar sesión."),
                      ),
                    );
                    return;
                  }

                  final ok = await sosProvider.sendSOS(
                    userId: uid,
                    latitude: position.latitude,
                    longitude: position.longitude,
                    message: "Necesito ayuda",
                  );

                  if (!mounted) return;

                  if (ok) {
                    locationProvider.startTracking(
                      onPositionUpdate: (newPosition) async {
                        await sosProvider.updateLocation(
                          latitude: newPosition.latitude,
                          longitude: newPosition.longitude,
                        );
                      },
                    );
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor:
                          ok ? AppColors.success : AppColors.danger,
                      content: Text(
                        ok
                            ? "Alerta enviada correctamente"
                            : sosProvider.errorMessage ?? "Error",
                      ),
                    ),
                  );
                },
              )

            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                ),
                icon: const Icon(Icons.check),
                label: const Text("FINALIZAR SOS"),
                onPressed: () async {
                  locationProvider.stopTracking();

                  final ok = await sosProvider.finishSOS();

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor:
                          ok ? AppColors.success : AppColors.danger,
                      content: Text(
                        ok
                            ? "Emergencia finalizada."
                            : sosProvider.errorMessage ??
                                "No se pudo finalizar la emergencia.",
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
