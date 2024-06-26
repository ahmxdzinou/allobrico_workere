import 'dart:io'; // Pour utiliser des fichiers locaux

import 'package:allobrico_worker/model/worker_model.dart'; // Modèle pour les données des travailleurs
import 'package:allobrico_worker/provider/auth_provider.dart'; // Provider pour la gestion de l'authentification
import 'package:allobrico_worker/screens/home_screen.dart'; // Écran d'accueil
import 'package:allobrico_worker/utils/utils.dart'; // Utilitaires divers
import 'package:allobrico_worker/widgets/custom_button.dart'; // Bouton personnalisé
import 'package:flutter/material.dart'; // Composants Material Design pour Flutter
import 'package:provider/provider.dart'; // Gestionnaire d'état pour Flutter

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({Key? key}) : super(key: key);

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  File? image; // Variable pour stocker l'image sélectionnée
  final nameController = TextEditingController(); // Contrôleur pour le champ du nom
  final emailController = TextEditingController(); // Contrôleur pour le champ de l'email
  final bioController = TextEditingController(); // Contrôleur pour le champ de la bio
  String? selectedWorkerType; // Variable pour stocker le type de travailleur sélectionné

  @override
  void dispose() {
    super.dispose();
    nameController.dispose(); // Dispose du contrôleur de nom
    emailController.dispose(); // Dispose du contrôleur d'email
    bioController.dispose(); // Dispose du contrôleur de bio
  }

  // Sélection de l'image
  void selectImage() async {
    image = await pickImage(context); // Appel d'une fonction pour sélectionner une image
    setState(() {}); // Met à jour l'état de l'interface utilisateur
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context, listen: true).isLoading; // Vérifie si l'application est en cours de chargement
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color.fromRGBO(251, 53, 105, 1),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 5.0),
                child: Center(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () => selectImage(),
                        child: image == null
                            ? const CircleAvatar(
                                backgroundColor: Color.fromRGBO(251, 53, 105, 1),
                                radius: 50,
                                child: Icon(
                                  Icons.account_circle,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              )
                            : CircleAvatar(
                                backgroundImage: FileImage(image!), // Affiche l'image sélectionnée
                                radius: 50,
                              ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                        margin: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            // Champ de saisie pour le nom
                            textField(
                              hintText: "John Smith",
                              icon: Icons.account_circle,
                              inputType: TextInputType.name,
                              maxLines: 1,
                              controller: nameController,
                            ),

                            // Champ de saisie pour l'email
                            textField(
                              hintText: "abc@example.com",
                              icon: Icons.email,
                              inputType: TextInputType.emailAddress,
                              maxLines: 1,
                              controller: emailController,
                            ),

                            // Champ de saisie pour la bio
                            textField(
                              hintText: "Enter your bio here",
                              icon: Icons.edit,
                              inputType: TextInputType.name,
                              maxLines: 2,
                              controller: bioController,
                            ),

                            // Sélection du type de travailleur
                            DropdownButtonFormField<String>(
                              value: selectedWorkerType,
                              onChanged: (newValue) {
                                setState(() {
                                  selectedWorkerType = newValue;
                                });
                              },
                              items: <String>['Plombier', 'Electricien', 'Peintre']
                                  .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                labelText: 'Worker Type',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.90,
                        child: CustomButton(
                          text: "Continue",
                          onPressed: () => storeData(), // Stocke les données utilisateur lors de l'appui sur le bouton
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // Widget pour les champs de saisie
  Widget textField({
    required String hintText,
    required IconData icon,
    required TextInputType inputType,
    required int maxLines,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        cursorColor: Color.fromRGBO(251, 53, 105, 1),
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromRGBO(251, 53, 105, 1),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Colors.transparent,
            ),
          ),
          hintText: hintText,
          alignLabelWithHint: true,
          border: InputBorder.none,
          fillColor: Color.fromARGB(255, 255, 230, 236),
          filled: true,
        ),
      ),
    );
  }

  // Stocke les données utilisateur dans la base de données
  void storeData() async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    if (selectedWorkerType != null) {
      WorkerModel workerModel = WorkerModel(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        bio: bioController.text.trim(),
        profilePic: "",
        createdAt: "",
        phoneNumber: "",
        uid: "",
        workerType: getWorkerTypeFromString(selectedWorkerType!), // Convertit le type de travailleur en énumération
      );
      if (image != null) {
        // Sauvegarde les données utilisateur dans Firebase
        ap.saveUserDataToFirebase(
          context: context,
          workerModel: workerModel,
          profilePic: image!,
          onSuccess: () {
            // Sauvegarde les données utilisateur dans les SharedPreferences et redirige vers l'écran d'accueil
            ap.saveUserDataToSP().then(
                  (value) => ap.setSignIn().then(
                        (value) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                );
          },
        );
      } else {
        // Affiche un message si l'image de profil n'a pas été téléchargée
        showSnackBar(context, "Please upload your profile photo");
      }
    } else {
      // Affiche un message si le type de travailleur n'a pas été sélectionné
      showSnackBar(context, "Please select worker type");
    }
  }

  // Convertit la chaîne de caractères du type de travailleur en énumération
  WorkerType getWorkerTypeFromString(String typeString) {
    switch (typeString) {
      case 'Plombier':
        return WorkerType.plombier;
      case 'Electricien':
        return WorkerType.electricien;
      case 'Peintre':
        return WorkerType.peintre;
      default:
        throw Exception("Invalid worker type string: $typeString");
    }
  }
}
