import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/sos_provider.dart';

class SOSScreen extends StatelessWidget {
  const SOSScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sosProvider = Provider.of<SOSProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('SafeWalk'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.danger,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Emergencia', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  Text(
                    'Si te encuentras en una situación de riesgo, presiona el botón para enviar una alerta con tu ubicación.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
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
                  const SizedBox(height: 32),
                  sosProvider.isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 58),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radius,
                                ),
                              ),
                            ),
                            onPressed: () async {
                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radius,
                                    ),
                                  ),
                                  title: const Text('Confirmar alerta'),
                                  content: const Text(
                                    '¿Estás seguro de enviar una alerta SOS?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        dialogContext,
                                      ).pop(false),
                                      child: const Text('Cancelar'),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppColors.danger,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      child: const Text('Enviar'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmar != true) return;

                              // TODO (Persona 4): reemplazar por coordenadas reales de LocationProvider.
                              final ok = await sosProvider.sendSOS(
                                userId: 'usuario_prueba',
                                latitude: -0.229,
                                longitude: -78.524,
                                message: 'Necesito ayuda',
                              );

                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: ok
                                      ? AppColors.success
                                      : AppColors.danger,
                                  content: Text(
                                    ok
                                        ? 'Alerta enviada correctamente'
                                        : 'Error:\n${sosProvider.errorMessage}',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.sos),
                            label: const Text('ENVIAR ALERTA SOS'),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
