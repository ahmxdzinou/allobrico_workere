import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Déclaration de la classe HistoryScreen qui est un StatefulWidget
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

// Déclaration de l'état associé à HistoryScreen
class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance de FirebaseAuth
  String? _currentUserId; // UID de l'utilisateur courant

  // Méthode initState appelée lors de l'initialisation de l'état
  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // Appel de la méthode pour obtenir l'utilisateur courant
  }

  // Méthode asynchrone pour obtenir l'utilisateur courant
  Future<void> _getCurrentUser() async {
    User? user = _auth.currentUser;
    setState(() {
      _currentUserId = user?.uid; // Mise à jour de l'UID de l'utilisateur courant
    });
  }

  // Construction de l'interface utilisateur
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'), // Titre de l'application
      ),
      body: _currentUserId == null
          ? const Center(child: CircularProgressIndicator()) // Affichage d'un indicateur de chargement si l'UID est null
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('booking_requests')
                  .where('workerId', isEqualTo: _currentUserId)
                  .snapshots(), // Flux des requêtes de réservation pour l'utilisateur courant
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator()); // Affichage d'un indicateur de chargement pendant la récupération des données
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No booking requests found')); // Message si aucune requête de réservation n'est trouvée
                }
                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String status = data['status'] ?? '';
                    Color cardColor;

                    // Définition de la couleur de la carte en fonction du statut
                    switch (status) {
                      case 'Annuler':
                      case 'Refuse':
                        cardColor = Colors.red[100]!;
                        break;
                      case 'Terminer':
                        cardColor = Colors.green[100]!;
                        break;
                      case 'Accepte':
                      case 'En cours':
                        cardColor = Colors.grey[300]!;
                        break;
                      default:
                        cardColor = Colors.white;
                    }

                    // Construction de la carte pour chaque requête de réservation
                    return Card(
                      color: cardColor,
                      margin: const EdgeInsets.all(10.0),
                      child: ListTile(
                        title: Text(data['title'] ?? 'No Title'), // Titre de la requête
                        subtitle: Text(data['description'] ?? 'No Description'), // Description de la requête
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(data['requesterName'] ?? 'No Name'), // Nom du demandeur
                            Text(status), // Statut de la requête
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
