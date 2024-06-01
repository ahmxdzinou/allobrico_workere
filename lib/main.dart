// Importation des différents packages nécessaires au fonctionnement de l'application
import 'package:allobrico_worker/provider/auth_provider.dart'; // Provider pour la gestion de l'authentification
import 'package:allobrico_worker/screens/welcome_screen.dart'; // Écran de bienvenue
import 'package:firebase_core/firebase_core.dart'; // Initialisation de Firebase
import 'package:flutter/material.dart'; // Composants Material Design pour Flutter
import 'package:provider/provider.dart'; // Gestionnaire d'état pour Flutter

void main() async {
  // Initialisation des Widgets Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de Firebase
  await Firebase.initializeApp();
  
  // Exécution de l'application Flutter
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuration du MultiProvider pour fournir les différents providers à l'application
    return MultiProvider(
      providers: [
        // Fourniture du AuthProvider pour la gestion de l'état d'authentification
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      // Configuration de l'application MaterialApp
      child: const MaterialApp(
        debugShowCheckedModeBanner: false, // Désactive le bandeau de debug
        home: WelcomeScreen(), // Définition de l'écran d'accueil
        title: "AlloBricoWorker", // Titre de l'application
      ),
    );
  }
}
