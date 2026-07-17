import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes/app_routes.dart';
import '../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/location_share_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final theme = Theme.of(context);
    // NUEVO: cantidad de solicitudes de ubicación pendientes, para el
    // badge junto al ítem del drawer.
    final pendingCount = context.watch<LocationShareProvider>().pendingRequests.length;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.12,
                    ),
                    backgroundImage:
                        (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                        ? Icon(Icons.person, color: theme.colorScheme.primary)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? 'Usuario SafeWalk',
                          style: theme.textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.email ?? '',
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: theme.dividerColor, height: 1),
            const SizedBox(height: 8),
            _DrawerItem(
              icon: Icons.map_outlined,
              label: 'Mapa y rutas',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.map);
              },
            ),
            _DrawerItem(
              icon: Icons.contacts_outlined,
              label: 'Contactos de emergencia',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.contacts);
              },
            ),
            _DrawerItem(
              icon: Icons.history,
              label: 'Historial',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.history);
              },
            ),
            _DrawerItem(
              icon: Icons.location_on_outlined,
              label: pendingCount > 0
                  ? 'Ubicaciones compartidas ($pendingCount)'
                  : 'Ubicaciones compartidas',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.incomingShares);
              },
            ),
            _DrawerItem(
              icon: Icons.person_outline,
              label: 'Perfil',
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushNamed(AppRoutes.profile);
              },
            ),
            const Spacer(),
            Divider(color: theme.dividerColor, height: 1),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Cerrar sesión',
              color: AppColors.danger,
              onTap: () async {
                Navigator.pop(context);
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                }
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.textTheme.bodyLarge?.color;

    return ListTile(
      leading: Icon(icon, color: effectiveColor),
      title: Text(
        label,
        style: TextStyle(color: effectiveColor, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
