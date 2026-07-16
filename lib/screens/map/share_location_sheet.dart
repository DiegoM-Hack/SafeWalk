import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/emergency_contact_model.dart';
import '../../models/location_share_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_share_provider.dart';

/// Paso 1 del flujo: A elige un contacto (ya vinculado a SafeWalk) y
/// presiona "Compartir ubicación". Se abre como `showModalBottomSheet`
/// desde `contacts_screen.dart`.
///
/// Mientras la hoja está abierta, refleja en vivo el estado de la sesión
/// (pendiente -> activa) y permite presionar "Dejar de compartir".
class ShareLocationSheet extends StatefulWidget {
  final EmergencyContactModel contact;
  const ShareLocationSheet({super.key, required this.contact});

  @override
  State<ShareLocationSheet> createState() => _ShareLocationSheetState();
}

class _ShareLocationSheetState extends State<ShareLocationSheet> {
  int _selectedMinutes = 30;
  bool _requestSent = false;

  Future<void> _send() async {
    final provider = context.read<LocationShareProvider>();
    final myName = context.read<AuthProvider>().user?.name ?? 'Un usuario de SafeWalk';

    final shareId = await provider.sendRequest(
      toUid: widget.contact.linkedUid!,
      fromName: myName,
      durationMinutes: _selectedMinutes,
    );

    if (shareId != null && mounted) {
      setState(() => _requestSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationShareProvider = context.watch<LocationShareProvider>();
    final share = locationShareProvider.outgoingShare;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Compartir ubicación', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Con ${widget.contact.name}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          if (!_requestSent) ...[
            Text('¿Por cuánto tiempo?', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              children: [15, 30, 60].map((minutes) {
                final selected = _selectedMinutes == minutes;
                return ChoiceChip(
                  label: Text('$minutes min'),
                  selected: selected,
                  selectedColor: AppColors.teal.withValues(alpha: 0.18),
                  onSelected: (_) => setState(() => _selectedMinutes = minutes),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: locationShareProvider.isSendingRequest ? null : _send,
                child: locationShareProvider.isSendingRequest
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Compartir ubicación'),
              ),
            ),
          ] else
            _StatusView(share: share),
        ],
      ),
    );
  }
}

class _StatusView extends StatelessWidget {
  final LocationShareModel? share;
  const _StatusView({required this.share});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (share == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    switch (share!.status) {
      case LocationShareStatus.pending:
        return _InfoBanner(
          icon: Icons.hourglass_top,
          color: AppColors.teal,
          text: 'Esperando a que tu contacto acepte…',
        );
      case LocationShareStatus.active:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _InfoBanner(
              icon: Icons.my_location,
              color: AppColors.success,
              text: 'Tu ubicación se está compartiendo en tiempo real.',
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                context.read<LocationShareProvider>().stopSharingMine();
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Dejar de compartir'),
            ),
          ],
        );
      case LocationShareStatus.rejected:
        return _InfoBanner(
          icon: Icons.block,
          color: AppColors.danger,
          text: 'Tu contacto rechazó la solicitud.',
        );
      case LocationShareStatus.stopped:
      case LocationShareStatus.expired:
        return _InfoBanner(
          icon: Icons.check_circle_outline,
          color: theme.textTheme.bodyMedium?.color ?? Colors.grey,
          text: 'Dejaste de compartir tu ubicación.',
        );
    }
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _InfoBanner({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
