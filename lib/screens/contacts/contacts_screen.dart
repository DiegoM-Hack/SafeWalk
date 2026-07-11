import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/emergency_contact_model.dart';
import '../../providers/contact_provider.dart';
import 'contact_form_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contactos de emergencia"),
      ),
      body: Consumer<ContactProvider>(
        builder: (context, contactProvider, _) {
          if (contactProvider.isLoading && contactProvider.contacts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (contactProvider.errorMessage != null) {
            return Center(
              child: Text(contactProvider.errorMessage!),
            );
          }

          if (contactProvider.contacts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "Aún no tienes contactos de emergencia.\n"
                  "Toca el botón + para agregar el primero.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: contactProvider.contacts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final contact = contactProvider.contacts[index];
              return _ContactTile(contact: contact);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const ContactFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final EmergencyContactModel contact;

  const _ContactTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text(contact.name),
      subtitle: Text("${contact.relationship} · ${contact.phone}"),
      trailing: PopupMenuButton<String>(
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
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, EmergencyContactModel contact) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Eliminar contacto"),
        content: Text(
          "¿Seguro que quieres eliminar a ${contact.name} de tus contactos "
          "de emergencia?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final provider = context.read<ContactProvider>();
              await provider.deleteContact(contact.id);
              navigator.pop();
            },
            child: const Text(
              "Eliminar",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}