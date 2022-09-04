import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:olx_clone/constants.dart';
import 'package:olx_clone/models/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore;

  ChatProvider({required this.firebaseFirestore, required this.prefs});

  String? getPref(String key) {
    return prefs.getString(key);
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath,
      Map<String, String> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(docPath)
        .update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return firebaseFirestore
        .collection(FirestoreConstants.MESSAGE_COLLECTION)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.TIMESTAMP, descending: true)
        .limit(limit)
        .snapshots();
  }

  void sendMessage(String content, int type, String groupChatId,
      String currentUserId, String peerId) {
    DocumentReference documentReference = firebaseFirestore
        .collection(FirestoreConstants.MESSAGE_COLLECTION)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChat messageChat = MessageChat(
      uidFrom: currentUserId,
      uidTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        messageChat.toJson(),
      );
    });
  }
}

class TypeMessage {
  static const text = 0;
  static const image = 1;
  static const sticker = 2;
}
