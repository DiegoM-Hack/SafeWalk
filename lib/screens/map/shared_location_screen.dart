import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/location_share_model.dart';
import '../../providers/location_share_provider.dart';
import '../../services/location_share_service.dart';

/// Paso 3/4 del flujo, del lado de B: mapa que se actualiza automáticamente
/// mientras la sesión sigue activa, con botón para "dejar de seguir".
class SharedLocationScreen extends StatelessWidget {
  final LocationShareModel initialShare;
  const SharedLocationScreen({super.key, required this.initialShare});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ubicación de ${initialShare.fromName}')),
      body: StreamBuilder<LocationShareModel>(
        stream: LocationShareService().watchShare(initialShare.id),
        initialData: initialShare,
        builder: (context, snapshot) {
          final share = snapshot.data ?? initialShare;
          final position = share.lastPosition;

          if (!share.isActive) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  share.status == LocationShareStatus.stopped
                      ? '${share.fromName} dejó de compartir su ubicación.'
                      : 'Esta sesión ya no está activa.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          if (position == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Esperando la primera actualización de ubicación…'),
              ),
            );
          }

          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(target: position, zoom: 16),
                markers: {
                  Marker(
                    markerId: const MarkerId('shared_location'),
                    position: position,
                    infoWindow: InfoWindow(title: share.fromName),
                  ),
                },
                myLocationButtonEnabled: false,
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 20,
                child: SafeArea(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                    ),
                    onPressed: () {
                      context.read<LocationShareProvider>().stopFollowing(share.id);
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Dejar de seguir'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
