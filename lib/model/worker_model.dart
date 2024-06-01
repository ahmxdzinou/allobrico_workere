// Enumération pour les types de travailleurs
enum WorkerType { plombier, electricien, peintre }

// Modèle de données pour les travailleurs
class WorkerModel {
  String name; // Nom du travailleur
  String email; // Email du travailleur
  String bio; // Bio du travailleur
  String profilePic; // URL de l'image de profil du travailleur
  String createdAt; // Date de création du compte
  String phoneNumber; // Numéro de téléphone du travailleur
  String uid; // UID unique du travailleur
  WorkerType workerType; // Type de travailleur

  // Constructeur pour initialiser les propriétés du modèle
  WorkerModel({
    required this.name,
    required this.email,
    required this.bio,
    required this.profilePic,
    required this.createdAt,
    required this.phoneNumber,
    required this.uid,
    required this.workerType,
  });

  // Constructeur factory pour créer une instance à partir d'une Map
  factory WorkerModel.fromMap(Map<String, dynamic> map) {
    return WorkerModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      bio: map['bio'] ?? '',
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      createdAt: map['createdAt'] ?? '',
      profilePic: map['profilePic'] ?? '',
      workerType: _getWorkerTypeFromString(map['workerType']),
    );
  }

  // Méthode pour convertir les propriétés du modèle en Map
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "email": email,
      "uid": uid,
      "bio": bio,
      "profilePic": profilePic,
      "phoneNumber": phoneNumber,
      "createdAt": createdAt,
      "workerType": _workerTypeToString(workerType),
    };
  }

  // Méthode statique pour obtenir le type de travailleur à partir d'une chaîne de caractères
  static WorkerType _getWorkerTypeFromString(String typeString) {
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

  // Méthode statique pour convertir le type de travailleur en chaîne de caractères
  static String _workerTypeToString(WorkerType type) {
    switch (type) {
      case WorkerType.plombier:
        return 'Plombier';
      case WorkerType.electricien:
        return 'Electricien';
      case WorkerType.peintre:
        return 'Peintre';
    }
  }
}
