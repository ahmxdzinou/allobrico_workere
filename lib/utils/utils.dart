import 'dart:io'; // Importation du package pour manipuler les fichiers

import 'package:flutter/material.dart'; // Importation du package Flutter pour les widgets Material
import 'package:image_picker/image_picker.dart'; // Importation du package image_picker pour choisir des images

// Fonction pour afficher une SnackBar avec un message spécifié
void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content), // Contenu de la SnackBar
    ),
  );
}

// Fonction pour choisir une image depuis la galerie
Future<File?> pickImage(BuildContext context) async {
  File? image; // Variable pour stocker l'image sélectionnée
  try {
    // Utilisation de ImagePicker pour choisir une image depuis la galerie
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      image = File(pickedImage.path); // Conversion du chemin de l'image en fichier
    }
  } catch (e) {
    // Affichage d'une SnackBar en cas d'erreur
    showSnackBar(context, e.toString());
  }

  return image; // Retourne l'image sélectionnée ou null si aucune image n'a été choisie
}
