enum WorkerType { plombier, electricien, peintre }

class WorkerModel {
  String name;
  String email;
  String bio;
  String profilePic;
  String createdAt;
  String phoneNumber;
  String uid;
  WorkerType workerType;

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
