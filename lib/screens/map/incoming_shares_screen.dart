import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/location_share_model.dart';
import '../../providers/location_share_provider.dart';
import 'shared_location_screen.dart';

/// Pantalla accesible desde el drawer ("Ubicaciones compartidas"): agrupa
/// las solicitudes pendientes que me enviaron y las sesiones activas que
/// otras personas están compartiendo conmigo en este momento.
class IncomingSharesScreen extends StatelessWidget {
  const IncomingSharesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LocationShareProvider>();
    final theme = Theme.of(context);

    final hasContent =
        provider.pendingRequests.isNotEmpty || provider.incomingActive.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Ubicaciones compartidas')),
      body: !hasContent
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'Por ahora nadie está compartiendo su ubicación contigo.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (provider.pendingRequests.isNotEmpty) ...[
                  Text('Solicitudes pendientes', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  ...provider.pendingRequests.map(
                    (r) => _PendingTile(request: r),
                  ),
                  const SizedBox(height: 20),
                ],
                if (provider.incomingActive.isNotEmpty) ...[
                  Text('Compartiendo contigo ahora', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  ...provider.incomingActive.map(
                    (s) => _ActiveTile(share: s),
                  ),
                ],
              ],
            ),
    );
  }
}

class _PendingTile extends StatelessWidget {
  final LocationShareModel request;
  const _PendingTile({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.hourglass_top, color: AppColors.teal),
        title: Text(request.fromName),
        subtitle: Text('Quiere compartir su ubicación por ${request.durationMinutes} min'),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.danger),
              onPressed: () => context
                  .read<LocationShareProvider>()
                  .respondToRequest(shareId: request.id, accept: false),
            ),
            IconButton(
              icon: const Icon(Icons.check, color: AppColors.success),
              onPressed: () => context
                  .read<LocationShareProvider>()
                  .respondToRequest(shareId: request.id, accept: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveTile extends StatelessWidget {
  final LocationShareModel share;
  const _ActiveTile({required this.share});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const Icon(Icons.my_location, color: AppColors.success),
        title: Text(share.fromName),
        subtitle: const Text('Compartiendo su ubicación en tiempo real'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SharedLocationScreen(initialShare: share),
            ),
          );
        },
      ),
    );
  }
}
