import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String? photoUrl;
  final String email;
  final String username;
  AppUser({
    required this.username,
    required this.uid,
    required this.email,
    required this.photoUrl,
  });

  static AppUser fromSnap(DocumentSnapshot snap) {
    var json = snap.data() as Map<String, dynamic>;

    return AppUser(
      username: json["username"],
      uid: json["id"],
      email: json["email"],
      photoUrl: json["photoUrl"],
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "id": uid,
        "email": email,
        "photoUrl": photoUrl,
      };
}
