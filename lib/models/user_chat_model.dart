import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:olx_clone/constants.dart';

class UserChat {
  String uid;
  String photoUrl;
  String username;

  UserChat({
    required this.uid,
    required this.photoUrl,
    required this.username,
  });

  Map<String, String> toJson() {
    return {
      FirestoreConstants.USERNAME: username,
      FirestoreConstants.PHOTO_URL: photoUrl,
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String photoUrl = "";
    String username = "";
    try {
      photoUrl = doc.get(FirestoreConstants.PHOTO_URL);
    } catch (e) {}
    try {
      username = doc.get(FirestoreConstants.USERNAME);
    } catch (e) {}
    return UserChat(
      uid: doc.id,
      photoUrl: photoUrl,
      username: username,
    );
  }
}
