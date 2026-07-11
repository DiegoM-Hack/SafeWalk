// Smoke test de SafeWalk.
//
// Verifica que la pantalla de inicio de sesión se construya
// correctamente y muestre sus elementos principales.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:safewalk/providers/auth_provider.dart';
import 'package:safewalk/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen muestra los campos y el botón de inicio de sesión',
      (WidgetTester tester) async {
    // Construimos solo LoginScreen (no App completo), envuelto en su
    // Provider necesario, para no depender de Firebase.initializeApp()
    // ni del sistema de rutas durante el test.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Verifica que el título y los campos del formulario existan.
    expect(find.text('SafeWalk'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);

    // Intenta enviar el formulario vacío y verifica que aparezcan
    // los mensajes de validación.
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pump();

    expect(find.text('Ingrese su correo'), findsOneWidget);
    expect(find.text('Ingrese su contraseña'), findsOneWidget);
  });
}