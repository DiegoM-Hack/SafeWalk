import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento SafeWalk'),
      ),
      body: Consumer<LocationProvider>(
        builder: (context, provider, _) {
          final position = provider.currentPosition;
          final points = provider.routePoints;

          final markers = <Marker>{};
          if (position != null) {
            markers.add(
              Marker(
                markerId: const MarkerId('current'),
                position: LatLng(position.latitude, position.longitude),
                infoWindow: const InfoWindow(title: 'Tu ubicación'),
              ),
            );
          }

          final polylinePoints = points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();

          return Column(
            children: [
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(20.6597, -103.3496),
                    zoom: 15,
                  ),
                  markers: markers,
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: polylinePoints,
                      color: Colors.blue,
                      width: 4,
                    ),
                  },
                  onMapCreated: (controller) {
                    if (position != null) {
                      controller.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(position.latitude, position.longitude),
                        ),
                      );
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.isTracking
                            ? provider.stopTracking
                            : () => provider.startTracking(),
                        icon: Icon(provider.isTracking ? Icons.stop : Icons.play_arrow),
                        label: Text(provider.isTracking ? 'Detener' : 'Iniciar seguimiento'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
