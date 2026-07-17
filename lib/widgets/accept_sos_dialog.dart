import 'package:flutter/material.dart';

class AcceptSOSDialog extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const AcceptSOSDialog({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.red,
        size: 40,
      ),
      title: const Text("Alerta SOS"),
      content: const Text(
        "Uno de tus contactos de emergencia necesita ayuda.\n\n¿Deseas seguir su ubicación y abrir el chat?",
      ),
      actions: [

        TextButton(
          onPressed: onReject,
          child: const Text("Rechazar"),
        ),

        FilledButton.icon(
          onPressed: onAccept,
          icon: const Icon(Icons.location_on),
          label: const Text("Aceptar"),
        ),
        
      ],
    );
  }
}