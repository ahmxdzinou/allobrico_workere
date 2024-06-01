import 'package:allobrico_worker/screens/home_screen.dart'; // Écran principal de l'application
import 'package:allobrico_worker/provider/auth_provider.dart'; // Provider pour la gestion de l'authentification
import 'package:allobrico_worker/screens/worker_information_screen.dart'; // Écran pour les informations des travailleurs
import 'package:allobrico_worker/utils/utils.dart'; // Utilitaires divers
import 'package:allobrico_worker/widgets/custom_button.dart'; // Bouton personnalisé
import 'package:flutter/material.dart'; // Composants Material Design pour Flutter
import 'package:pinput/pinput.dart'; // Widget pour la saisie de code PIN
import 'package:provider/provider.dart'; // Gestionnaire d'état pour Flutter

class OtpScreen extends StatefulWidget {
  final String verificationId;
  const OtpScreen({super.key, required this.verificationId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? otpCode; // Code OTP saisi par l'utilisateur

  @override
  Widget build(BuildContext context) {
    // Obtention de l'état de chargement depuis AuthProvider
    final isLoading = Provider.of<AuthProvider>(context, listen: true).isLoading;
    return Scaffold(
      body: SafeArea(
        child: isLoading == true
            ? const Center(
                // Affichage d'un indicateur de chargement si isLoading est vrai
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(251, 53, 105, 1),
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(), // Retour à l'écran précédent
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                      Container(
                        width: 200,
                        height: 200,
                        padding: const EdgeInsets.all(20.0),
                        child: Image.asset(
                          "assets/image3.png", // Image de vérification
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Vérification",
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Entrez le code envoyé à votre numéro de téléphone",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black38,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Widget pour la saisie du code OTP
                      Pinput(
                        length: 6,
                        showCursor: true,
                        defaultPinTheme: PinTheme(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Color.fromRGBO(251, 53, 105, 1),
                            ),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onCompleted: (value) {
                          setState(() {
                            otpCode = value;
                          });
                        },
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        // Bouton personnalisé pour vérifier le code OTP
                        child: CustomButton(
                          text: "Vérifier",
                          onPressed: () {
                            if (otpCode != null) {
                              verifyOtp(context, otpCode!);
                            } else {
                              showSnackBar(context, "Entrez le code à 6 chiffres");
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Vous n'avez reçu aucun code ?",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Renvoyer un nouveau code",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(251, 53, 105, 1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Méthode pour vérifier le code OTP
  void verifyOtp(BuildContext context, String userOtp) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    ap.verifyOtp(
      context: context,
      verificationId: widget.verificationId,
      userOtp: userOtp,
      onSuccess: () {
        // Vérification si l'utilisateur existe dans la base de données
        ap.checkExistingUser().then(
          (value) async {
            if (value == true) {
              // L'utilisateur existe dans l'application
              ap.getDataFromFirestore().then(
                    (value) => ap.saveUserDataToSP().then(
                          (value) => ap.setSignIn().then(
                                (value){
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                              ),
                        ),
                  );
            } else {
              // Nouvel utilisateur
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserInformationScreen()),
                  (route) => false);
            }
          },
        );
      },
    );
  }
}
