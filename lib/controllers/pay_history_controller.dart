import 'package:spiiiq/controllers/e_login_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class PayHistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController authController = Get.find<AuthController>();

  final RxList<Map<String, dynamic>> historyList = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  /// 🔹 Fetch pay history for current user
  void fetchHistory() {
    final email = authController.currentUser?.email;
    if (email == null) return;

    isLoading.value = true;

    _firestore
        .collection('text withdrawal')
        .where('email', isEqualTo: email)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
          historyList.value = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'email': data['email'] ?? '',
              'wallet_address': data['wallet_address'] ?? '',
              'amount_usd': data['amount_usd'] ?? 0.0,
              'status': data['status'] ?? 'pending',
              'account_name': data['account_name'] ?? '',
              'account_number': data['account_number'] ?? '',
              'time':
                  (data['created_at'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
            };
          }).toList();
          isLoading.value = false;
        });
  }
}
