import 'package:flutter/material.dart';

import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/map/map_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/contacts/contacts_screen.dart';
import '../../screens/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String contacts = '/contacts';
  static const String map = '/map';
  static const String history = '/history';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    home: (context) => const HomeScreen(),
    profile: (context) => const ProfileScreen(),
    contacts: (context) => const ContactsScreen(),
    map: (context) => const MapScreen(),
    history: (context) => const HistoryScreen(),
  };
}
