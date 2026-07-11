import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {

    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? "Error"),
        ),
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    final auth = context.watch<AuthProvider>();

    return Scaffold(

      appBar: AppBar(
        title: const Text("Iniciar sesión"),
        centerTitle: true,
      ),

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding: const EdgeInsets.all(24),

            child: Form(

              key: _formKey,

              child: Column(

                children: [

                  const Icon(
                    Icons.shield,
                    size: 100,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "SafeWalk",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 40),

                  TextFormField(

                    controller: _emailController,

                    keyboardType: TextInputType.emailAddress,

                    decoration: const InputDecoration(
                      labelText: "Correo electrónico",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),

                    validator: (value) {

                      if (value == null || value.isEmpty) {
                        return "Ingrese su correo";
                      }

                      return null;

                    },

                  ),

                  const SizedBox(height: 20),

                  TextFormField(

                    controller: _passwordController,

                    obscureText: _obscurePassword,

                    decoration: InputDecoration(

                      labelText: "Contraseña",

                      border: const OutlineInputBorder(),

                      prefixIcon: const Icon(Icons.lock),

                      suffixIcon: IconButton(

                        icon: Icon(

                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),

                        onPressed: () {

                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });

                        },

                      ),

                    ),

                    validator: (value) {

                      if (value == null || value.isEmpty) {
                        return "Ingrese su contraseña";
                      }

                      return null;

                    },

                  ),

                  const SizedBox(height: 30),

                  SizedBox(

                    width: double.infinity,

                    height: 50,

                    child: ElevatedButton(

                      onPressed: auth.isLoading ? null : login,

                      child: auth.isLoading
                          ? const CircularProgressIndicator()
                          : const Text(
                              "Iniciar sesión",
                            ),

                    ),

                  ),

                  const SizedBox(height: 15),

                  TextButton(

                    onPressed: () {

                      Navigator.push(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              const RegisterScreen(),

                        ),

                      );

                    },

                    child: const Text(
                      "Crear una cuenta",
                    ),

                  ),

                ],

              ),

            ),

          ),

        ),

      ),

    );

  }

}