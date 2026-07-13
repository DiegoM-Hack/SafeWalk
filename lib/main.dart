import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/sos_provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/contact_provider.dart';
import 'providers/location_provider.dart';
import 'providers/trip_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/history_provider.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SOSProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ContactProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => TripProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(),
        ),
      ],
      child: const App(),
    ),
  );
}

