import 'package:spiiiq/controllers/balance_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:spiiiq/controllers/withdraw_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WithdrawPage extends StatelessWidget {
  final WithdrawController ctrl = Get.put(WithdrawController());
  final ThemeController themeCtrl = Get.find<ThemeController>();
  final AvailableBalanceController balanceCtrl =
      Get.find<AvailableBalanceController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            "Withdraw",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(
                label: "Amount (USD)",
                controller: ctrl.usdCtrl,
                keyboard: TextInputType.number,
                isDark: isDark,
                onChanged: (value) {
                  final input = double.tryParse(value) ?? 0.0;
                  final maxBal = balanceCtrl.avlBal.value;

                  if (input > maxBal) {
                    // Prevent entering more than available balance
                    final corrected = maxBal.toStringAsFixed(5);
                    ctrl.usdCtrl.text = corrected;
                    ctrl.usdCtrl.selection = TextSelection.fromPosition(
                      TextPosition(offset: corrected.length),
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  "Available Balance: \$${balanceCtrl.avlBal.value.toStringAsFixed(5)}",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _field(
                label: "Bank Name",
                controller: ctrl.bankNameCtrl,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _field(
                label: "Account Name",
                controller: ctrl.accountNameCtrl,
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _field(
                label: "Account Number",
                controller: ctrl.accountNumberCtrl, // NEW
                keyboard: TextInputType.number,
                isDark: isDark,
              ),
              const SizedBox(height: 30),
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: ctrl.isSubmitting.value
                        ? null
                        : ctrl.placeWithdrawal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? Colors.white : Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: ctrl.isSubmitting.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Place Withdrawal",
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.black87 : Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    Function(String)? onChanged,
    bool isDark = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      onChanged: onChanged,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        filled: true,
        fillColor: isDark ? Colors.grey[850] : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
