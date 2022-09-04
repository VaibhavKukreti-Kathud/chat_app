import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:olx_clone/constants.dart';

class HomeProvider {
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({required this.firebaseFirestore});

  Future<void> updateDataFirestore(
      String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update(dataNeedUpdate);
  }

  Stream<QuerySnapshot>? getStreamFireStore(
      String pathCollection, int limit, String? textSearch) {
    if (textSearch != '') {
      return firebaseFirestore
          .collection(pathCollection)
          .limit(limit)
          .where('username', isEqualTo: textSearch)
          .snapshots();
    } else if (textSearch!.isEmpty) {
      return firebaseFirestore
          .collection(pathCollection)
          .limit(limit)
          .snapshots();
    } else {
      return null;
    }
  }
}
