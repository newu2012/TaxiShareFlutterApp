import 'package:cloud_firestore/cloud_firestore.dart';
import 'message.dart';

class MessageDao {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('message');

  void saveMessage(Message message) {
    collection.add(message.toJson());
  }

  Stream<QuerySnapshot> getMessageStream(String? tripId) {
    return collection.where('tripId', isEqualTo: tripId).snapshots();
  }
}
