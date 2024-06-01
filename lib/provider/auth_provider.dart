import 'dart:convert';
import 'dart:io';

import 'package:allobrico_worker/model/worker_model.dart'; // Modèle pour les travailleurs
import 'package:allobrico_worker/screens/otp_screen.dart'; // Écran de vérification OTP
import 'package:allobrico_worker/utils/utils.dart'; // Utilitaires (par exemple, pour afficher des messages)
import 'package:cloud_firestore/cloud_firestore.dart'; // Intégration de Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Authentification Firebase
import 'package:firebase_storage/firebase_storage.dart'; // Stockage Firebase
import 'package:flutter/material.dart'; // Composants Material Design pour Flutter
import 'package:shared_preferences/shared_preferences.dart'; // Stockage local partagé

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false; // Indicateur d'état de connexion
  bool get isSignedIn => _isSignedIn;
  bool _isLoading = false; // Indicateur de chargement
  bool get isLoading => _isLoading;
  String? _uid; // UID de l'utilisateur
  String get uid => _uid!;
  WorkerModel? _workerModel; // Modèle de données du travailleur
  WorkerModel get userModel => _workerModel!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  AuthProvider() {
    checkSign(); // Vérifie l'état de connexion lors de l'initialisation
  }

  // Vérifie si l'utilisateur est connecté
  void checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  // Définit l'utilisateur comme connecté
  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }

  // Connexion avec le numéro de téléphone
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) async {
          await _firebaseAuth.signInWithCredential(phoneAuthCredential);
        },
        verificationFailed: (error) {
          throw Exception(error.message);
        },
        codeSent: (verificationId, forceResendingToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(verificationId: verificationId),
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  // Vérification du code OTP
  void verifyOtp({
    required BuildContext context,
    required String verificationId,
    required String userOtp,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOtp,
      );

      User? worker = (await _firebaseAuth.signInWithCredential(creds)).user;

      if (worker != null) {
        // Logique à exécuter après la vérification réussie
        _uid = worker.uid;
        onSuccess();
      }
      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // Opérations sur la base de données
  Future<bool> checkExistingUser() async {
    DocumentSnapshot snapshot = await _firebaseFirestore.collection("workers").doc(_uid).get();
    if (snapshot.exists) {
      print("WORKER EXISTS");
      return true;
    } else {
      print("NEW WORKER");
      return false;
    }
  }

  // Enregistrement des données de l'utilisateur dans Firebase
  void saveUserDataToFirebase({
    required BuildContext context,
    required WorkerModel workerModel,
    required File profilePic,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Téléchargement de l'image sur Firebase Storage
      await storeFileToStorage("Worker_profilePic/$_uid", profilePic).then((value) {
        workerModel.profilePic = value;
        workerModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
        workerModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
        workerModel.uid = _firebaseAuth.currentUser!.phoneNumber!;
      });
      _workerModel = workerModel;

      // Téléchargement des données dans Firestore
      await _firebaseFirestore.collection("workers").doc(_uid).set({
        ...workerModel.toMap(),
        'workerType': workerModel.workerType.toString(), // Enregistre le type de travailleur sous forme de chaîne de caractères
      }).then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  // Téléchargement d'un fichier vers Firebase Storage
  Future<String> storeFileToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Récupération des données depuis Firestore
  Future getDataFromFirestore() async {
    await _firebaseFirestore.collection("workers").doc(_firebaseAuth.currentUser!.uid).get().then((DocumentSnapshot snapshot) {
      _workerModel = WorkerModel(
        name: snapshot['name'],
        email: snapshot['email'],
        createdAt: snapshot['createdAt'],
        bio: snapshot['bio'],
        uid: snapshot['uid'],
        profilePic: snapshot['profilePic'],
        phoneNumber: snapshot['phoneNumber'],
        workerType: getWorkerTypeFromFirestore(snapshot['workerType']), // Récupère le type de travailleur
      );
      _uid = userModel.uid;
    });
  }

  // Conversion de la chaîne de caractères en type de travailleur
  WorkerType getWorkerTypeFromFirestore(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'plombier':
          return WorkerType.plombier;
        case 'electricien':
          return WorkerType.electricien;
        case 'peintre':
          return WorkerType.peintre;
      }
    }
    // Si la valeur ne correspond à aucun type, retourne une valeur par défaut
    return WorkerType.plombier; // Par défaut, retourne 'plombier' si la valeur est invalide
  }

  // Enregistrement des données localement
  Future saveUserDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("worker_model", jsonEncode(userModel.toMap()));
  }

  // Récupération des données locales
  Future getDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("worker_model") ?? '';
    _workerModel = WorkerModel.fromMap(jsonDecode(data));
    _uid = _workerModel!.uid;
    notifyListeners();
  }

  // Déconnexion de l'utilisateur
  Future userSignOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();
    s.clear();
  }
}
