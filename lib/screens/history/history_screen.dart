import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HistoryProvider>().loadTripHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = context.watch<HistoryProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de rutas')),
      body: historyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyProvider.trips.isEmpty
          ? _EmptyState(theme: theme)
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: historyProvider.trips.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final trip = historyProvider.trips[index];
                      final dateStr =
                          '${trip.startTime.day}/${trip.startTime.month}/${trip.startTime.year}';
                      final hourStr =
                          '${trip.startTime.hour.toString().padLeft(2, '0')}:${trip.startTime.minute.toString().padLeft(2, '0')}';

                      // Texto de origen -> destino, con fallback por si
                      // algún recorrido viejo no tiene estos campos guardados.
                      final hasRoute =
                          trip.originAddress.isNotEmpty &&
                          trip.destinationAddress.isNotEmpty;
                      final routeStr = hasRoute
                          ? '${trip.originAddress} → ${trip.destinationAddress}'
                          : 'Recorrido sin direcciones registradas';

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                height: 46,
                                width: 46,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.directions_walk,
                                  color: theme.colorScheme.primary,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      routeStr,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Recorrido del $dateStr',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Inicio $hourStr · ${trip.distance.toStringAsFixed(2)} km',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Tiempo',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    '${trip.duration.toStringAsFixed(0)} min',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ThemeData theme;
  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 84,
              width: 84,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_toggle_off,
                size: 40,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Aún no registras ningún recorrido',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Cuando inicies un recorrido desde el mapa, aparecerá aquí.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
