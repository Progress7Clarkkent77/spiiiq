import 'package:spiiiq/controllers/account_controller.dart';

import 'package:spiiiq/controllers/chat_list_controller.dart';
import 'package:spiiiq/controllers/pay_history_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:spiiiq/widgets/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PayHistoryPage extends StatefulWidget {
  const PayHistoryPage({super.key});

  @override
  State<PayHistoryPage> createState() => _PayHistoryPageState();
}

class _PayHistoryPageState extends State<PayHistoryPage> {
  final ChatListController controller = Get.put(ChatListController());
  final ThemeController themeCtrl = Get.put(ThemeController());
  final AccountController accountController = Get.put(AccountController());
  final IconNavigationHandler navigationHandler = IconNavigationHandler();
  // final CurrencyController currencyController = Get.put(CurrencyController());
  // final AddMoneyController addMoneyController = Get.find<AddMoneyController>();
  // final PbcMarketController pbcMarketController =
  //     Get.put(PbcMarketController());

  @override
  void initState() {
    super.initState();
    accountController.fetchUserInfo();
    //accountController.fetchBalances();
    accountController.fetchWalletAddress();
    accountController.toggleBalanceVisibility();
    accountController.fetchWalletDetails();
    accountController.fetchWalletData();
    // addMoneyController.fetchVaultBalance();

    // ever(addMoneyController.email, (String email) {
    //   if (email.isNotEmpty) {
    //     addMoneyController.fetchTransactions(email);
    //   }
    // });
  }

  String selectedCurrency = "\$ Dollar";

  String format12HourTime(DateTime time) {
    int hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');

    final period = hour >= 12 ? 'PM' : 'AM';

    hour = hour % 12;
    hour = hour == 0 ? 12 : hour;

    return "$hour:$minute $period";
  }

  String formatWalletAddress(String address) {
    if (address.length <= 10) return address;

    final start = address.substring(0, 6);
    final end = address.substring(address.length - 3);

    return "$start...$end";
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final ctrl = Get.put(PayHistoryController());

    return Obx(() {
      final isDark = themeController.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey[100],
        appBar: AppBar(
          title: const Text(
            'Pay History',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black87,
          elevation: 0,
        ),
        body: ctrl.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: Colors.black),
              )
            : ctrl.historyList.isEmpty
            ? Center(
                child: Text(
                  'No withdrawal history yet',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ctrl.historyList.length,
                itemBuilder: (context, index) {
                  final item = ctrl.historyList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.25)
                                : Colors.grey.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Status: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                item['status'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      item['status'].toString().toLowerCase() ==
                                          'pending'
                                      ? Colors.orange
                                      : (item['status']
                                                    .toString()
                                                    .toLowerCase() ==
                                                'paid'
                                            ? Colors.green
                                            : Colors.red),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "${format12HourTime(item['time'])} • "
                                "${item['time'].day}/${item['time'].month}/${item['time'].year}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Email: ${item['email']}",
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          Text(
                            "From Wallet: ${formatWalletAddress(item['wallet_address'])}",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "To: ",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "${item['account_number']} • ${item['account_name']}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.black54,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Amount: \$${item['amount_usd'].toStringAsFixed(5)}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.tealAccent[200]
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      );
    });
  }
}
