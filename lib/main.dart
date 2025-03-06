import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', ''),
      supportedLocales: const [Locale('es', '')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purpleAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

// 📌 Manejo del estado de autenticación
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }
        if (snapshot.hasData) {
          return const ProfileScreen();
        }
        return const SignInScreen();
      },
    );
  }
}

// 🌟 Pantalla de carga con animación
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade900,
      body: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

// 🌟 Pantalla de inicio de sesión
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: _buildAuthCard(
              context,
              "Login",
              "Accede a tu cuenta",
              "INICIAR SESIÓN",
              () => _signIn(context, emailController.text, passwordController.text),
              "¿No tienes cuenta?",
              () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const RegisterScreen(),
                ));
              },
              emailController,
              passwordController,
            ),
          ),
        ],
      ),
    );
  }
}

// 🌟 Pantalla de registro con el mismo estilo
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: _buildAuthCard(
              context,
              "Crear Cuenta",
              "Regístrate para empezar",
              "REGISTRARSE",
              () => _signUp(context, emailController.text, passwordController.text),
              "¿Ya tienes cuenta?",
              () {
                Navigator.of(context).pop();
              },
              emailController,
              passwordController,
            ),
          ),
        ],
      ),
    );
  }
}

// 🌟 Pantalla de perfil con diseño estilizado
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Perfil"),
        backgroundColor: Colors.purpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const SignInScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: Card(
              elevation: 10,
              color: Colors.white.withOpacity(0.9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_circle, size: 100, color: Colors.purpleAccent),
                    const SizedBox(height: 10),
                    Text(
                      user?.email ?? "Usuario",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Bienvenido a tu perfil",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🌟 Función para iniciar sesión en Firebase
Future<void> _signIn(BuildContext context, String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
    );
  }
}

// 🌟 Función para registrar usuario en Firebase
Future<void> _signUp(BuildContext context, String email, String password) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
    );
  }
}

// 🌟 Fondo ilustrado
Widget _buildBackground() {
  return Positioned.fill(
    child: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/mountains_background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    ),
  );
}

// 🌟 Tarjeta de login y registro
Widget _buildAuthCard(
  BuildContext context,
  String title,
  String subtitle,
  String buttonText,
  VoidCallback onButtonPressed,
  String secondaryText,
  VoidCallback onSecondaryPressed,
  TextEditingController emailController,
  TextEditingController passwordController,
) {
  return Card(
    elevation: 10,
    color: Colors.white.withOpacity(0.9),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: emailController, decoration: const InputDecoration(labelText: "Correo")),
          TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Contraseña"), obscureText: true),
          ElevatedButton(onPressed: onButtonPressed, child: Text(buttonText)),
          TextButton(onPressed: onSecondaryPressed, child: Text(secondaryText)),
        ],
      ),
    ),
  );
}
