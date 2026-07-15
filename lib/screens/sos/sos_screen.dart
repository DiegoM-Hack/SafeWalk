import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sos_provider.dart';

class SOSScreen extends StatelessWidget {
  const SOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sosProvider = Provider.of<SOSProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("SafeWalk"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
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
                "Si te encuentras en una situación de riesgo, presiona el botón para enviar una alerta de emergencia con tu ubicación.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 30),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.danger,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ubicación',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Esperando información del GPS...',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              sosProvider.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text("Confirmar alerta"),
                              content: const Text(
                                "¿Estás seguro de enviar una alerta SOS?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(false);
                                  },
                                  child: const Text("Cancelar"),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop(true);
                                  },
                                  child: const Text("Enviar"),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmar != true) return;

                        final authProvider = context.read<AuthProvider>();
                        final uid = authProvider.user?.uid;

                        if (uid == null) {
                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppColors.danger,
                              content: Text(
                                "Debes iniciar sesión para enviar una alerta SOS.",
                              ),
                            ),
                          );

                          return;
                        }

                        final ok = await sosProvider.sendSOS(
                          userId: uid,
                          latitude: -0.229,
                          longitude: -78.524,
                          message: "Necesito ayuda",
                        );

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor:
                                ok ? AppColors.success : AppColors.danger,
                            content: Text(
                              ok
                                  ? "Alerta enviada correctamente"
                                  : "Error:\n${sosProvider.errorMessage}",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.sos),
                      label: const Text("ENVIAR ALERTA SOS"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
