import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    User? user = _auth.currentUser;
    setState(() {
      _currentUserId = user?.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
      ),
      body:  _currentUserId == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('booking_requests')
                  .where('workerId', isEqualTo: _currentUserId)
                  .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No booking requests found'));
              }
              return ListView(
                children: snapshot.data!.docs.map((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String status = data['status'] ?? '';
                  Color cardColor;

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

                  return Card(
                    color: cardColor,
                    margin: const EdgeInsets.all(10.0),
                    child: ListTile(
                      title: Text(data['title'] ?? 'No Title'),
                      subtitle: Text(data['description'] ?? 'No Description'),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(data['requesterName'] ?? 'No Name'),
                          Text(status),
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
