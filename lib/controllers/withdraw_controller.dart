import 'package:spiiiq/controllers/balance_controller.dart';

import 'package:spiiiq/controllers/e_login_controller.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WithdrawController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final AvailableBalanceController balanceController =
      Get.find<AvailableBalanceController>();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController usdCtrl = TextEditingController();
  final TextEditingController bankNameCtrl = TextEditingController();
  final TextEditingController accountNameCtrl = TextEditingController();
  final TextEditingController accountNumberCtrl = TextEditingController();

  final RxBool isSubmitting = false.obs;

  Future<void> placeWithdrawal() async {
    final uid = authController.currentUser?.uid;
    if (uid == null) {
      _showErrorDialog("User not authenticated");
      return;
    }

    final usd = double.tryParse(usdCtrl.text.trim()) ?? 0.0;
    final bankName = bankNameCtrl.text.trim();
    final accountName = accountNameCtrl.text.trim();
    final accountNumber = accountNumberCtrl.text.trim();

    if (usd <= 0) {
      _showErrorDialog("Please enter a valid amount");
      return;
    }

    if (usd > balanceController.avlBal.value) {
      _showErrorDialog(
        "Insufficient balance. Max available: \$${balanceController.avlBal.value.toStringAsFixed(4)}",
      );
      usdCtrl.text = balanceController.avlBal.value.toStringAsFixed(4);
      usdCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: usdCtrl.text.length),
      );
      return;
    }

    if (bankName.isEmpty || accountName.isEmpty || accountNumber.isEmpty) {
      _showErrorDialog("Please fill all bank details");
      return;
    }

    isSubmitting.value = true;

    try {
      final userRef = _firestore.collection('e-users').doc(uid);
      final userSnap = await userRef.get();

      double currentBal = 0.0;
      if (userSnap.exists) {
        final data = userSnap.data();
        final rawBal = data?['available_bal'];
        if (rawBal is num) currentBal = rawBal.toDouble();
      }

      if (usd > currentBal) {
        _showErrorDialog(
          "Insufficient balance. Max available: \$${currentBal.toStringAsFixed(4)}",
        );
        usdCtrl.text = currentBal.toStringAsFixed(4);
        usdCtrl.selection = TextSelection.fromPosition(
          TextPosition(offset: usdCtrl.text.length),
        );
        return;
      }

      // Deduct and update Firestore safely
      await userRef.update({'available_bal': currentBal - usd});

      // Save withdrawal request
      await _firestore.collection('text withdrawal').add({
        'userId': uid,
        'email': authController.currentUser?.email ?? '',
        'amount_usd': usd,
        'bank_name': bankName,
        'account_name': accountName,
        'account_number': accountNumber,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      });

      _showSuccessDialog(
        "Withdrawal of \$${usd.toStringAsFixed(5)} placed successfully!",
      );
      _clearInputs();
    } catch (e, stack) {
      print("WithdrawController Exception: $e");
      print("StackTrace: $stack");
      _showErrorDialog("Failed to place withdrawal. Please try again.");
    } finally {
      isSubmitting.value = false;
    }
  }

  void _clearInputs() {
    usdCtrl.clear();
    bankNameCtrl.clear();
    accountNameCtrl.clear();
    accountNumberCtrl.clear();
  }

  // ✅ Professional Error Dialog
  void _showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.red[50],
        title: const Text(
          "Withdrawal Failed",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              "OK",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ✅ Professional Success Dialog
  void _showSuccessDialog(String message) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.green[50],
        title: const Text(
          "Withdrawal Successful",
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // close dialog
            child: const Text(
              "OK",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
