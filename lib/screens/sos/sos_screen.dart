import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/sos_provider.dart';
import '../../services/notification_service.dart';
import '../../services/contact_service.dart'; // 👈 nuevo import, ajusta el path si hace falta
import '../chat/chat_screen.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _alertSubscription;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<LocationProvider>().loadCurrentLocation();
      }
    });
  }

  @override
  void dispose() {
    _alertSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sosProvider = context.watch<SOSProvider>();
    final locationProvider = context.watch<LocationProvider>();
    final authProvider = context.read<AuthProvider>();
    final theme = Theme.of(context);

    final position = locationProvider.currentPosition;

    return Scaffold(
      appBar: AppBar(title: const Text("SafeWalk"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              "EMERGENCIA",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Si te encuentras en una situación de riesgo, presiona el botón para enviar una alerta.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.danger),
                    const SizedBox(width: 12),
                    Expanded(
                      child: position == null
                          ? Text(
                              "Obteniendo ubicación...",
                              style: theme.textTheme.bodyMedium,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Ubicación actual",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Lat: ${position.latitude.toStringAsFixed(6)}",
                                ),
                                Text(
                                  "Lng: ${position.longitude.toStringAsFixed(6)}",
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            if (sosProvider.isLoading)
              const CircularProgressIndicator()
            else if (!sosProvider.isEmergencyActive)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                ),
                icon: const Icon(Icons.sos),
                label: const Text("ENVIAR ALERTA SOS"),
                onPressed: () async {
                  final confirmar = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Confirmar"),
                      content: const Text("¿Deseas enviar una alerta SOS?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Cancelar"),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Enviar"),
                        ),
                      ],
                    ),
                  );

                  if (confirmar != true) return;
                  if (position == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("No se pudo obtener la ubicación."),
                      ),
                    );
                    return;
                  }

                  final firebaseUser = FirebaseAuth.instance.currentUser;
                  final uid = authProvider.user?.uid ?? firebaseUser?.uid;

                  if (uid == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppColors.danger,
                        content: Text("Debes iniciar sesión."),
                      ),
                    );
                    return;
                  }

                  final ok = await sosProvider.sendSOS(
                    userId: uid,
                    latitude: position.latitude,
                    longitude: position.longitude,
                    message: "Necesito ayuda",
                    // usamos el nombre guardado en Firestore (UserModel), no el de FirebaseAuth
                    userName:
                        authProvider.user?.name ??
                        firebaseUser?.email ??
                        "Contacto de Emergencia",
                    userPhoto: authProvider.user?.photoUrl ?? "",
                  );

                  if (!mounted) return;

                  if (ok) {
                    final alertId = sosProvider.currentAlertId!;

                    // traemos los contactos vinculados frescos, sin depender del caché del provider
                    final contactService = ContactService();
                    final linkedContacts = await contactService
                        .getLinkedContacts();

                    debugPrint(
                      "Contactos vinculados encontrados: ${linkedContacts.length}",
                    );

                    for (final contact in linkedContacts) {
                      if (contact.linkedUid == null) continue;
                      await NotificationService.instance.sendNotification(
                        receiverUid: contact.linkedUid!,
                        senderUid: uid,
                        alertId: alertId,
                      );
                    }

                    locationProvider.startTracking(
                      onPositionUpdate: (newPosition) async {
                        await sosProvider.updateLocation(
                          latitude: newPosition.latitude,
                          longitude: newPosition.longitude,
                        );
                      },
                    );

                    _alertSubscription?.cancel();
                    _alertSubscription = sosProvider
                        .listenAlert(alertId)
                        .listen((doc) {
                          if (!doc.exists) return;
                          final data = doc.data();
                          if (data == null || data["status"] != "accepted")
                            return;

                          _alertSubscription?.cancel();
                          if (!mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ChatScreen(alertId: alertId, uid: uid),
                            ),
                          );
                        });
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: ok
                          ? AppColors.success
                          : AppColors.danger,
                      content: Text(
                        ok
                            ? "Alerta enviada correctamente"
                            : sosProvider.errorMessage ?? "Error",
                      ),
                    ),
                  );
                },
              )
            else
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                ),
                icon: const Icon(Icons.check),
                label: const Text("FINALIZAR SOS"),
                onPressed: () async {
                  locationProvider.stopTracking();
<<<<<<< HEAD
                  await sosProvider.finishSOS();
=======

                  final ok = await sosProvider.finishSOS();

>>>>>>> b7b26ef65e4fd123a52165e174304e319f87b7d3
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
                    const SnackBar(content: Text("Emergencia finalizada.")),
=======
                    SnackBar(
                      backgroundColor:
                          ok ? AppColors.success : AppColors.danger,
                      content: Text(
                        ok
                            ? "Emergencia finalizada."
                            : sosProvider.errorMessage ??
                                "No se pudo finalizar la emergencia.",
                      ),
                    ),
>>>>>>> b7b26ef65e4fd123a52165e174304e319f87b7d3
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
