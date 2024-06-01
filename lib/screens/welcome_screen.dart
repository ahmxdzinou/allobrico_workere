import 'package:allobrico_worker/screens/home_screen.dart'; // Écran d'accueil
import 'package:allobrico_worker/screens/register_screen.dart'; // Écran d'inscription
import 'package:allobrico_worker/widgets/custom_button.dart'; // Bouton personnalisé
import 'package:flutter/material.dart'; // Composants Material Design pour Flutter
import 'package:provider/provider.dart'; // Gestionnaire d'état pour Flutter
import 'package:allobrico_worker/provider/auth_provider.dart'; // Provider pour la gestion de l'authentification

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Récupération du provider d'authentification
    final ap = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Affichage de l'image du logo
                Image.asset(
                  "assets/image1.png",
                  height: 300,
                ),
                const SizedBox(height: 20),
                // Titre de l'application
                const Text(
                  "Allo Brico Worker",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Description de l'application
                const Text(
                  "Rejoignez une communauté dynamique de travailleurs",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black38,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Bouton personnalisé
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: CustomButton(
                    // Action lors de l'appui sur le bouton
                    onPressed: () async {
                      if (ap.isSignedIn == true) {
                        // Si l'utilisateur est déjà connecté, récupérer les données et rediriger vers l'écran d'accueil
                        await ap.getDataFromSP().whenComplete(
                              () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                            );
                      } else {
                        // Sinon, rediriger vers l'écran d'inscription
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      }
                    },
                    text: "Get started", // Texte du bouton
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
