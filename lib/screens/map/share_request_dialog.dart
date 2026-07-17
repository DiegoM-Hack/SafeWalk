import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/location_share_model.dart';
import '../../providers/location_share_provider.dart';

/// Paso 2 del flujo: "📍 Diego quiere compartir su ubicación contigo."
/// Se muestra desde `app.dart` (a nivel global) cada vez que aparece una
/// solicitud pendiente nueva, y también se puede abrir manualmente desde
/// la lista de solicitudes en `incoming_shares_screen.dart`.
class ShareRequestDialog extends StatelessWidget {
  final LocationShareModel request;
  const ShareRequestDialog({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      title: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.teal,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Solicitud de ubicación',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: Text(
        '${request.fromName} quiere compartir su ubicación contigo durante '
        '${request.durationMinutes} minutos.',
      ),
      actions: [
        TextButton(
          onPressed: () => _respond(context, accept: false),
          child: const Text('Rechazar', style: TextStyle(color: AppColors.danger)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.teal),
          onPressed: () => _respond(context, accept: true),
          child: const Text('Aceptar'),
        ),
      ],
    );
  }

  void _respond(BuildContext context, {required bool accept}) {
    context.read<LocationShareProvider>().respondToRequest(
          shareId: request.id,
          accept: accept,
        );
    Navigator.of(context).pop();
  }
}
