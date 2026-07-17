import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../models/emergency_contact_model.dart';
import '../../providers/contact_provider.dart';
import 'contact_form_screen.dart';
import '../map/share_location_sheet.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ContactProvider>().listenToContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Contactos de emergencia')),
      body: Consumer<ContactProvider>(
        builder: (context, contactProvider, _) {
          if (contactProvider.isLoading && contactProvider.contacts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (contactProvider.errorMessage != null) {
            return Center(
              child: Text(
                contactProvider.errorMessage!,
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          if (contactProvider.contacts.isEmpty) {
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
                        Icons.person_add_alt,
                        size: 38,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Aún no tienes contactos de emergencia',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Toca el botón + para agregar el primero.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: contactProvider.contacts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final contact = contactProvider.contacts[index];
                    return _ContactTile(contact: contact);
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.teal,
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ContactFormScreen()));
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final EmergencyContactModel contact;
  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(Icons.person_outline, color: theme.colorScheme.primary),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                contact.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (contact.isLinkedToSafeWalk) ...[
              const SizedBox(width: 8),
              Tooltip(
                message: 'Este contacto tiene cuenta en SafeWalk y '
                    'recibirá alertas SOS automáticamente.',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 13,
                        color: AppColors.teal,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Vinculado',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
<<<<<<< HEAD
          contact.isSafeWalkUser
              ? '${contact.relationship} · ${contact.phone} · en SafeWalk'
              : '${contact.relationship} · ${contact.phone}',
          style: theme.textTheme.bodyMedium,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Acceso directo a "Compartir ubicación" solo si el contacto
            // ya está vinculado a una cuenta real de SafeWalk.
            if (contact.isSafeWalkUser)
              IconButton(
                icon: const Icon(Icons.share_location, color: AppColors.teal),
                tooltip: 'Compartir ubicación',
                onPressed: () => _openShareSheet(context, contact),
              ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: theme.textTheme.bodyMedium?.color),
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ContactFormScreen(contact: contact),
                    ),
                  );
                } else if (value == 'delete') {
                  _confirmDelete(context, contact);
                } else if (value == 'link') {
                  _linkContact(context, contact);
                } else if (value == 'share') {
                  _openShareSheet(context, contact);
                }
              },
              itemBuilder: (_) => [
                if (contact.isSafeWalkUser)
                  const PopupMenuItem(value: 'share', child: Text('Compartir ubicación'))
                else
                  const PopupMenuItem(value: 'link', child: Text('Vincular con SafeWalk')),
                const PopupMenuItem(value: 'edit', child: Text('Editar')),
                const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
              ],
            ),
=======
          '${contact.relationship} · ${contact.phone}\n${contact.email}',
          style: theme.textTheme.bodyMedium,
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: theme.textTheme.bodyMedium?.color),
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ContactFormScreen(contact: contact),
                ),
              );
            } else if (value == 'delete') {
              _confirmDelete(context, contact);
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
>>>>>>> main
          ],
        ),
      ),
    );
  }

  void _openShareSheet(BuildContext context, EmergencyContactModel contact) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radius)),
      ),
      builder: (_) => ShareLocationSheet(contact: contact),
    );
  }

  Future<void> _linkContact(BuildContext context, EmergencyContactModel contact) async {
    final provider = context.read<ContactProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final linked = await provider.linkContactToSafeWalkUser(contact);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          linked
              ? '${contact.name} ya usa SafeWalk. Ahora puedes compartirle tu ubicación.'
              : provider.errorMessage ?? 'Ese contacto todavía no tiene cuenta en SafeWalk.',
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, EmergencyContactModel contact) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        title: const Text('Eliminar contacto'),
        content: Text(
          '¿Seguro que quieres eliminar a ${contact.name} de tus contactos de emergencia?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final provider = context.read<ContactProvider>();
              await provider.deleteContact(contact.id);
              navigator.pop();
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
