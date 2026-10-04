import 'package:spiiiq/controllers/e_login_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

// class ContactsController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final AuthController _auth = Get.find<AuthController>();

//   final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> users =
//       <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
//   final RxString searchQuery = ''.obs;
//   final RxBool isSearching = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _firestore.collection('e-users').snapshots().listen((snapshot) {
//       users.value = snapshot.docs
//           .where((doc) => doc.id != _auth.currentUser!.uid)
//           .toList()
//           .cast<QueryDocumentSnapshot<Map<String, dynamic>>>(); // 🔹 cast
//     });
//   }

//   List<QueryDocumentSnapshot<Map<String, dynamic>>> get filteredUsers {
//     final q = searchQuery.value.toLowerCase();
//     if (q.isEmpty) return users;

//     return users.where((doc) {
//       final data = doc.data();
//       return (data['name'] ?? '').toString().toLowerCase().contains(q) ||
//           (data['email'] ?? '').toString().toLowerCase().contains(q);
//     }).toList();
//   }
// }

// class ContactsController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final AuthController _auth = Get.find<AuthController>();

//   final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> users =
//       <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
//   final RxString searchQuery = ''.obs;
//   final RxBool isSearching = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _firestore.collection('e-users').snapshots().listen((snapshot) {
//       users.value = snapshot.docs
//           .where((doc) => doc.id != _auth.currentUser!.uid)
//           .toList();
//     });
//   }

//   List<QueryDocumentSnapshot<Map<String, dynamic>>> get filteredUsers {
//     final q = searchQuery.value.toLowerCase();
//     if (q.isEmpty) return users;

//     return users.where((doc) {
//       final data = doc.data();
//       return (data['name'] ?? '').toString().toLowerCase().contains(q) ||
//           (data['email'] ?? '').toString().toLowerCase().contains(q);
//     }).toList();
//   }
// }

// class ContactsController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final AuthController _auth = Get.find<AuthController>();

//   final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> users =
//       <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;
//   final RxString searchQuery = ''.obs;
//   final RxBool isSearching = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     // Listen to all users except current
//     _firestore.collection('e-users').snapshots().listen((snapshot) {
//       users.value = snapshot.docs
//           .where((doc) => doc.id != _auth.currentUser?.uid)
//           .toList();
//     });
//   }

//   // Filter users by search query
//   List<QueryDocumentSnapshot<Map<String, dynamic>>> get filteredUsers {
//     final q = searchQuery.value.toLowerCase();
//     if (q.isEmpty) return users;

//     return users.where((doc) {
//       final data = doc.data();
//       final name = (data['name'] ?? '').toString().toLowerCase();
//       final email = (data['email'] ?? '').toString().toLowerCase();
//       return name.contains(q) || email.contains(q);
//     }).toList();
//   }

//   // Safely get user fields with defaults
//   String getName(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
//     return doc.data()['name'] ?? 'Unknown';
//   }

//   String getEmail(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
//     return doc.data()['email'] ?? '';
//   }

//   String getAvatar(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
//     return doc.data()['avatar'] ?? '';
//   }

//   bool isVerified(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
//     return doc.data()['isVerified'] == true;
//   }
// }

class ContactsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _auth = Get.find<AuthController>();

  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> users =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();

    _firestore.collection('e-users').snapshots().listen((snapshot) {
      users.value = snapshot.docs.where(_isValidUser).toList();
    });
  }

  /// ✅ Schema validator (single source of truth)
  bool _isValidUser(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    // Exclude current user
    if (doc.id == _auth.currentUser?.uid) return false;

    // Required fields
    if (data['name'] == null || data['name'] is! String) return false;
    if (data['email'] == null || data['email'] is! String) return false;

    // Optional but type-safe fields
    if (data['avatar'] != null && data['avatar'] is! String) return false;
    if (data['verified'] != null && data['verified'] is! bool) return false;

    return true;
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get filteredUsers {
    final q = searchQuery.value.toLowerCase();
    if (q.isEmpty) return users;

    return users.where((doc) {
      final data = doc.data();
      final name = data['name'].toString().toLowerCase();
      final email = data['email'].toString().toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();
  }

  String getName(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return doc.data()['name'];
  }

  String getEmail(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return doc.data()['email'];
  }

  String getAvatar(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return doc.data()['avatar'] ?? '';
  }

  bool isVerified(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return doc.data()['verified'] == true;
  }
}
