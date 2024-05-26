import 'package:allobrico_worker/model/request_model.dart';
import 'package:allobrico_worker/widgets/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BookingRequest> bookingRequests = [];
  String filter = 'En cours';

  @override
  void initState() {
    super.initState();
    fetchBookingRequests();
  }

  void fetchBookingRequests() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String workerUid = user.uid;
      FirebaseFirestore.instance
          .collection('booking_requests')
          .where('workerId', isEqualTo: workerUid)
          .where('status', isEqualTo: filter)
          .get()
          .then((querySnapshot) {
        setState(() {
          bookingRequests = querySnapshot.docs.map((doc) {
            var data = doc.data();
            return BookingRequest(
              id: doc.id,
              title: data['title'],
              description: data['description'],
              requesterName: data['requesterName'],
              workerId: data['workerId'],
              status: data['status'],
            );
          }).toList();
        });
      }).catchError((error) {
        print('Error fetching booking requests: $error');
      });
    } else {
      print('User not signed in');
    }
  }

  ElevatedButton buildCustomElevatedButton({
    required String text,
    required VoidCallback onPressed,
    required String currentFilter,
  }) {
    Color backgroundColor;
    Color textColor;
    if (text == currentFilter) {
      backgroundColor = const Color.fromRGBO(251, 53, 105, 1); // Change to your desired color
      textColor = const Color.fromRGBO(255, 230, 236, 1); // Change to your desired color
    } else {
      backgroundColor = const Color.fromRGBO(255, 230, 236, 1); // Default color
      textColor = const Color.fromRGBO(251, 53, 105, 1); // Default color
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return Colors.white.withOpacity(0.5); // Change to your desired pressed color
          }
          return backgroundColor;
        }),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MyDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded,
            size: 28,
            color:  Color.fromRGBO(251, 53, 105, 1),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Allo Brico Worker',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27, color: Color.fromRGBO(251, 53, 105, 1),),
        ),
        backgroundColor:  Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildCustomElevatedButton(
                text: 'En cours',
                onPressed: () {
                  setState(() {
                    filter = 'En cours';
                    fetchBookingRequests();
                  });
                },
                currentFilter: filter,
              ),
              buildCustomElevatedButton(
                text: 'Accepte',
                onPressed: () {
                  setState(() {
                    filter = 'Accepte';
                    fetchBookingRequests();
                  });
                },
                currentFilter: filter,
              ),
              buildCustomElevatedButton(
                text: 'Refuse',
                onPressed: () {
                  setState(() {
                    filter = 'Refuse';
                    fetchBookingRequests();
                  });
                },
                currentFilter: filter,
              ),
            ],
          ),
          const SizedBox(height: 10,),
          Expanded(
            child: bookingRequests.isEmpty
              ? Center(
                  child: Image.asset(
                    'assets/nodata.png',
                    height: 350,
                    
                  ),
                )
              : ListView.builder(
                  itemCount: bookingRequests.length,
                  itemBuilder: (context, index) {
                    return BookingRequestCard(
                      bookingRequest: bookingRequests[index],
                      onAccept: () {
                        acceptBookingRequest(bookingRequests[index]);
                      },
                      onDecline: () {
                        declineBookingRequest(bookingRequests[index]);
                      },
                      onTerminer: () {
                        terminerBookingRequest(bookingRequests[index]);
                      },
                      onAnnuler: () {
                        annulerBookingRequest(bookingRequests[index]);
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  void acceptBookingRequest(BookingRequest bookingRequest) {
    FirebaseFirestore.instance
      .collection('booking_requests')
      .doc(bookingRequest.id)
      .update({'status': 'Accepte'})
      .then((_) {
        setState(() {
          bookingRequest.status = 'Accepte';
        });
      })
      .catchError((error) {
        print('Error accepting booking request: $error');
      });
  }

  void declineBookingRequest(BookingRequest bookingRequest) {
    FirebaseFirestore.instance
      .collection('booking_requests')
      .doc(bookingRequest.id)
      .update({'status': 'Refuse'})
      .then((_) {
        setState(() {
          bookingRequest.status = 'Refuse';
        });
      })
      .catchError((error) {
        print('Error declining booking request: $error');
      });
  }

  void terminerBookingRequest(BookingRequest bookingRequest) {
    FirebaseFirestore.instance
      .collection('booking_requests')
      .doc(bookingRequest.id)
      .update({'status': 'Terminer'})
      .then((_) {
        setState(() {
          bookingRequest.status = 'Terminer';
        });
      })
      .catchError((error) {
        print('Error declining booking request: $error');
      });
  }

  void annulerBookingRequest(BookingRequest bookingRequest) {
    FirebaseFirestore.instance
      .collection('booking_requests')
      .doc(bookingRequest.id)
      .update({'status': 'Annuler'})
      .then((_) {
        setState(() {
          bookingRequest.status = 'Annuler';
        });
      })
      .catchError((error) {
        print('Error declining booking request: $error');
      });
  }

  
}

class BookingRequestCard extends StatelessWidget {
  final BookingRequest bookingRequest;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onTerminer;
  final VoidCallback? onAnnuler;

  const BookingRequestCard({
    Key? key,
    required this.bookingRequest,
    this.onAccept,
    this.onDecline,
    this.onTerminer,
    this.onAnnuler,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      color: const Color.fromARGB(255, 255, 246, 248),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bookingRequest.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Description: ${bookingRequest.description}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Requested by: ${bookingRequest.requesterName}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (bookingRequest.status == 'En cours')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: onAccept,
                    child: const Text('Accepter'),
                  ),
                  ElevatedButton(
                    onPressed: onDecline,
                    child: const Text('Refuser'),
                  ),
                ],
              ),
            if (bookingRequest.status == 'Accepte')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: onTerminer,
                        child: const Text('Terminer'),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onAnnuler,
                        child: const Text('Annuler'),
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: onAnnuler,
                    icon: Icon(Icons.call),
                    label: Text('Appelle'),
                    style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)
                            ),
                        ),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.green[100]!),
                    ),
                  )
                ],
              ),
            if (bookingRequest.status == 'Refuse')
              const Text(
                'Was Refused',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

}
