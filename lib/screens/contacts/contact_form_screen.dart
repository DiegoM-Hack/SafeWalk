import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/emergency_contact_model.dart';
import '../../providers/contact_provider.dart';

class ContactFormScreen extends StatefulWidget {
  /// Si viene un [contact], la pantalla funciona en modo edición.
  /// Si es null, funciona en modo creación.
  final EmergencyContactModel? contact;

  const ContactFormScreen({super.key, this.contact});

  bool get isEditing => contact != null;

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _relationshipController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name);
    _phoneController = TextEditingController(text: widget.contact?.phone);
    _relationshipController =
        TextEditingController(text: widget.contact?.relationship);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<ContactProvider>();
    bool success;

    if (widget.isEditing) {
      final updated = widget.contact!.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        relationship: _relationshipController.text.trim(),
      );
      success = await provider.updateContact(updated);
    } else {
      success = await provider.addContact(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        relationship: _relationshipController.text.trim(),
      );
    }

    if (!mounted) return;

    setState(() => _isSaving = false);

    if (success) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? "Ocurrió un error inesperado.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? "Editar contacto" : "Nuevo contacto",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nombre completo",
                ),
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "El nombre es obligatorio.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Teléfono",
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "El teléfono es obligatorio.";
                  }
                  final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                  if (digitsOnly.length < 7) {
                    return "Ingresa un teléfono válido.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _relationshipController,
                decoration: const InputDecoration(
                  labelText: "Relación (ej. Madre, Hermano, Amigo)",
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "La relación es obligatoria.";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.isEditing ? "Guardar cambios" : "Agregar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
