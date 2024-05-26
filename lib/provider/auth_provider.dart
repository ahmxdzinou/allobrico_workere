import 'dart:convert';
import 'dart:io';

import 'package:allobrico_worker/model/worker_model.dart';
import 'package:allobrico_worker/screens/otp_screen.dart';
import 'package:allobrico_worker/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  String? _uid;
  String get uid => _uid!;
  WorkerModel? _workerModel;
  WorkerModel get userModel => _workerModel!;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  AuthProvider() {
    checkSign();
  }

  void checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }

  // signin
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

  // verify otp
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
        // carry our logic
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

  // DATABASE OPERATIONS
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

  void saveUserDataToFirebase({
    required BuildContext context,
    required WorkerModel workerModel,
    required File profilePic,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // uploading image to firebase storage.
      await storeFileToStorage("Worker_profilePic/$_uid", profilePic).then((value) {
        workerModel.profilePic = value;
        workerModel.createdAt = DateTime.now().millisecondsSinceEpoch.toString();
        workerModel.phoneNumber = _firebaseAuth.currentUser!.phoneNumber!;
        workerModel.uid = _firebaseAuth.currentUser!.phoneNumber!;
      });
      _workerModel = workerModel;

      // uploading to database
     await _firebaseFirestore.collection("workers").doc(_uid).set({
  ...workerModel.toMap(),
  'workerType': workerModel.workerType.toString(), // Enregistrez le type de travailleur sous forme de chaîne de caractères
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

  Future<String> storeFileToStorage(String ref, File file) async {
    UploadTask uploadTask = _firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

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
        workerType: getWorkerTypeFromFirestore(snapshot['workerType']), // Ajoutez cette ligne pour récupérer le type de travailleur
      );
      _uid = userModel.uid;
    });
  }

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
  // If the value doesn't match any enum, return a default value or handle the error as needed.
  return WorkerType.plombier; // Default to plombier if the value is invalid.
}


  // STORING DATA LOCALLY
  Future saveUserDataToSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString("worker_model", jsonEncode(userModel.toMap()));
  }

  Future getDataFromSP() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    String data = s.getString("worker_model") ?? '';
    _workerModel = WorkerModel.fromMap(jsonDecode(data));
    _uid = _workerModel!.uid;
    notifyListeners();
  }

  Future userSignOut() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();
    s.clear();
  }
}

