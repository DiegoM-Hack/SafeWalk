import 'package:flutter/material.dart';

import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
//import '../../screens/auth/splash_screen.dart';
import '../../screens/home/home_screen.dart';
//import '../../screens/profile/profile_screen.dart';
import '../../screens/contacts/contacts_screen.dart';

class AppRoutes {
  // Nombres de las rutas
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String contacts = '/contacts';

  /// Rutas de la aplicación
  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const LoginScreen(),
    //splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    //profile: (context) => const ProfileScreen(),
    contacts: (context) => const ContactsScreen(),
  };
}