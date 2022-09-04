import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:olx_clone/constants.dart';

class MessageChat {
  String uidFrom;
  String uidTo;
  String timestamp;
  String content;
  int type;

  MessageChat({
    required this.uidFrom,
    required this.uidTo,
    required this.timestamp,
    required this.content,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      FirestoreConstants.UID_FROM: uidFrom,
      FirestoreConstants.UID_TO: uidTo,
      FirestoreConstants.TIMESTAMP: timestamp,
      FirestoreConstants.CONTENT: content,
      FirestoreConstants.TYPE: type,
    };
  }

  factory MessageChat.fromDocument(DocumentSnapshot doc) {
    String uidFrom = doc.get(FirestoreConstants.UID_FROM);
    String uidTo = doc.get(FirestoreConstants.UID_TO);
    String timestamp = doc.get(FirestoreConstants.TIMESTAMP);
    String content = doc.get(FirestoreConstants.CONTENT);
    int type = doc.get(FirestoreConstants.TYPE);
    return MessageChat(
        uidFrom: uidFrom,
        uidTo: uidTo,
        timestamp: timestamp,
        content: content,
        type: type);
  }
}
