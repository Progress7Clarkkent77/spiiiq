import 'package:spiiiq/controllers/e_login_controller.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// class UserPresenceController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final AuthController _auth = Get.find<AuthController>();

//   String get uid => _auth.currentUser!.uid;

//   Future<void> setOnline() async {
//     await _firestore.collection('e-users').doc(uid).set({
//       'isOnline': true,
//       'lastSeen': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Future<void> setOffline() async {
//     await _firestore.collection('e-users').doc(uid).set({
//       'isOnline': false,
//       'lastSeen': FieldValue.serverTimestamp(),
//     }, SetOptions(merge: true));
//   }

//   Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser(String userId) {
//     return _firestore.collection('e-users').doc(userId).snapshots();
//   }
// }

class UserPresenceController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _auth = Get.find<AuthController>();

  String get uid => _auth.currentUser!.uid;

  Future<void> setOnline() async {
    await _firestore.collection('e-users').doc(uid).set({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setOffline() async {
    await _firestore.collection('e-users').doc(uid).set({
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUser(String userId) {
    return _firestore.collection('e-users').doc(userId).snapshots();
  }
}
