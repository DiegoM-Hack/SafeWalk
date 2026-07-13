import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/history_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Inicia la petición a Firebase de forma segura al renderizar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadTripHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Historial de Rutas")),
      body: historyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyProvider.trips.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Aún no registras ningún recorrido en SafeWalk.",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: historyProvider.trips.length,
              itemBuilder: (context, index) {
                final trip = historyProvider.trips[index];

                // Formatear la fecha y hora de inicio de forma amigable
                final dateStr =
                    "${trip.startTime.day}/${trip.startTime.month}/${trip.startTime.year}";
                final hourStr =
                    "${trip.startTime.hour.toString().padLeft(2, '0')}:${trip.startTime.minute.toString().padLeft(2, '0')}";

                return Card(
                  margin: const EdgeInsets.bottom(12.0),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.directions_walk, color: Colors.white),
                    ),
                    title: Text(
                      "Recorrido del $dateStr",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "Hora de inicio: $hourStr\nDistancia: ${trip.distance.toStringAsFixed(2)} km",
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Tiempo",
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        Text(
                          "${trip.duration.toStringAsFixed(0)} min",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
