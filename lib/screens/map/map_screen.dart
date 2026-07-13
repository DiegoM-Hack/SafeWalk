import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/location_provider.dart';
import '../../providers/trip_provider.dart';
import '../../services/directions_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final DirectionsService _directionsService = DirectionsService();
  final TextEditingController _destinationController =
      TextEditingController();

  GoogleMapController? _mapController;

  LatLng? _destination;
  String _destinationAddress = '';
  Set<Polyline> _routePolylines = {};
  bool _isSearchingRoute = false;

  // Posición de respaldo mientras se obtiene el GPS real (Quito, Ecuador).
  static const LatLng _fallbackPosition = LatLng(-0.1807, -78.4678);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initLocation());
  }

  Future<void> _initLocation() async {
    final locationProvider = context.read<LocationProvider>();
    await locationProvider.loadCurrentLocation();

    final current = locationProvider.currentPosition;
    if (current != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(current, 16),
      );
    }
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _searchRoute() async {
    final locationProvider = context.read<LocationProvider>();
    final origin = locationProvider.currentPosition;

    if (origin == null) {
      _showMessage('Aún no se detecta tu ubicación actual.');
      return;
    }

    final address = _destinationController.text.trim();
    if (address.isEmpty) {
      _showMessage('Escribe una dirección de destino.');
      return;
    }

    setState(() => _isSearchingRoute = true);

    try {
      final geocoding = Geocoding();
      final locations = await geocoding.locationFromAddress(address);

      if (locations.isEmpty) {
        _showMessage('No se encontró esa dirección.');
        return;
      }

      final destination = LatLng(
        locations.first.latitude,
        locations.first.longitude,
      );

      final route = await _directionsService.getWalkingRoute(
        origin: origin,
        destination: destination,
      );

      setState(() {
        _destination = destination;
        _destinationAddress = address;
        _routePolylines = {
          Polyline(
            polylineId: const PolylineId('ruta_sugerida'),
            points: route,
            color: Colors.blue,
            width: 5,
          ),
        };
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(_boundsFor([origin, ...route]), 60),
      );
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSearchingRoute = false);
    }
  }

  LatLngBounds _boundsFor(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _toggleTracking() {
    final locationProvider = context.read<LocationProvider>();
    final tripProvider = context.read<TripProvider>();

    if (!locationProvider.isTracking) {
      final origin = locationProvider.currentPosition;
      if (origin == null) {
        _showMessage('Aún no se detecta tu ubicación actual.');
        return;
      }

      tripProvider.startTrip(
        origin: origin,
        originAddress: 'Ubicación actual',
        destinationAddress:
            _destinationAddress.isEmpty ? 'Sin destino' : _destinationAddress,
      );

      locationProvider.startTracking(
        onPositionUpdate: (position) {
          tripProvider.addRoutePoint(position);
          _mapController?.animateCamera(CameraUpdate.newLatLng(position));
        },
      );
    } else {
      locationProvider.stopTracking();
      final distance = tripProvider.distanceKm;
      final duration = tripProvider.elapsed;

      tripProvider.finishTrip();
      _showSummary(distance, duration);
    }

    setState(() {});
  }

  void _showSummary(double distanceKm, Duration duration) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Recorrido finalizado'),
        content: Text(
          'Distancia: ${distanceKm.toStringAsFixed(2)} km\n'
          'Duración: ${duration.inMinutes} min',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider = context.watch<LocationProvider>();
    final tripProvider = context.watch<TripProvider>();

    final current = locationProvider.currentPosition;

    final markers = <Marker>{
      if (_destination != null)
        Marker(
          markerId: const MarkerId('destino'),
          position: _destination!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
          infoWindow: const InfoWindow(title: 'Destino'),
        ),
    };

    final polylines = {..._routePolylines};
    if (tripProvider.routePoints.length > 1) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('recorrido_en_vivo'),
          points: tripProvider.routePoints,
          color: Colors.green,
          width: 5,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mapa y rutas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _destinationController,
                    decoration: const InputDecoration(
                      labelText: 'Destino',
                      hintText: 'Escribe una dirección',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isSearchingRoute ? null : _searchRoute,
                  icon: _isSearchingRoute
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.directions_walk),
                ),
              ],
            ),
          ),
          if (locationProvider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 12, right: 12),
              child: Text(
                locationProvider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (tripProvider.isTripActive)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Rastreando: ${tripProvider.distanceKm.toStringAsFixed(2)} km · '
                '${tripProvider.elapsed.inMinutes} min',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: current ?? _fallbackPosition,
                zoom: 15,
              ),
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: markers,
              polylines: polylines,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleTracking,
        icon: Icon(
          locationProvider.isTracking ? Icons.stop : Icons.play_arrow,
        ),
        label: Text(
          locationProvider.isTracking ? 'Detener' : 'Iniciar seguimiento',
        ),
        backgroundColor:
            locationProvider.isTracking ? Colors.red : Colors.blue,
      ),
    );
  }
}
