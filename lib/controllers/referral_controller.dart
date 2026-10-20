import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:spiiiq/controllers/e_login_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:url_launcher/url_launcher.dart';

/// 🔹 Referral system, code-based:
/// - Every user has a 6-digit `referCode` on their e-users doc, generated
///   by AuthController (on signup, and backfilled on login).
/// - This controller just displays that code as simple, copiable text —
///   no submissions, no admin approval.
/// - The actual reward is handled entirely by AuthController: when a new
///   user who entered someone's referCode at signup gets their `verify`
///   field set to true, that referrer is rewarded automatically (once).
class ReferController extends GetxController {
  final AuthController authController = Get.find<AuthController>();
  final ThemeController themeController = Get.find<ThemeController>();

  final RxString referCode = ''.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadReferCode();
  }

  /// 🔢 Loads this user's referCode, generating + saving one first if the
  /// field somehow isn't set yet (AuthController already does this on
  /// every login/signup — this is just a safety net for the refer page).
  Future<void> loadReferCode() async {
    final uid = authController.currentUser?.uid;

    if (uid == null) {
      isLoading.value = false;
      return;
    }

    try {
      final code = await authController.ensureReferCode(uid);
      referCode.value = code;
    } catch (e) {
      _showSnackbar(
        'Error',
        'Could not load your referral code. Pull to refresh and try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔗 The exact copiable referral message, built with this user's code.
  String get referralText {
    final code = referCode.value;

    return '''
SpiiiQ is 100% Legit! 🎉

Download SpiiiQ and sign up with my referral code: $code, Log in, verify your email & start earning rewards by:

• Posting & reacting to posts
• You can withdraw anytime.
''';
  }

  /// 🔔 Themed Snackbar (Dark / Light aware)
  void _showSnackbar(String title, String message) {
    final isDark = themeController.isDarkMode.value;

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      colorText: isDark ? Colors.white : Colors.black,
      borderRadius: 12,
      margin: const EdgeInsets.all(12),
    );
  }

  /// 📋 Copy the full referral message to the clipboard.
  Future<void> copyReferralText() async {
    if (referCode.value.isEmpty) {
      _showSnackbar('Not ready', 'Your referral code is still loading.');
      return;
    }

    await Clipboard.setData(ClipboardData(text: referralText));

    _showSnackbar('Copied', 'Referral message copied to clipboard.');
  }

  /// 🔗 Open WhatsApp with the referral message prefilled. No reward is
  /// tied to sharing itself — the reward only fires once someone who
  /// actually used this code verifies their email (see AuthController).
  Future<void> shareToWhatsApp() async {
    if (referCode.value.isEmpty) {
      _showSnackbar('Not ready', 'Your referral code is still loading.');
      return;
    }

    final uri = Uri.parse(
      'https://wa.me/?text=${Uri.encodeComponent(referralText)}',
    );

    if (!await canLaunchUrl(uri)) {
      _showSnackbar('WhatsApp Error', 'Unable to open WhatsApp.');
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
