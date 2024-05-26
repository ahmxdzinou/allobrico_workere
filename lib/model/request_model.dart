class BookingRequest {
  final String id;
  final String title;
  final String description;
  final String requesterName;
  final String workerId;
  String status; 

  BookingRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.requesterName,
    required this.workerId,
    required this.status, 
  });
}
