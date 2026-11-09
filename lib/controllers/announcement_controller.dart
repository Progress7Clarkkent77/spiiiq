import 'package:spiiiq/controllers/e_login_controller.dart';
import 'package:spiiiq/controllers/reward_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnnouncementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _auth = Get.find<AuthController>();
  final ThemeController _themeCtrl = Get.find<ThemeController>();

  final RewardController _rewardCtrl = Get.find<RewardController>();

  final RxList<Map<String, dynamic>> ads = <Map<String, dynamic>>[].obs;

  bool get _isDark => _themeCtrl.isDarkMode.value;
  String? get uid => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _listenToAds();
    _autoCleanupExpiredAds();
  }

  void _listenToAds() {
    _firestore
        .collection('ads')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) {
          ads.assignAll(
            snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList(),
          );
        });
  }

  Future<void> addAd({
    required String title,
    required String description,
  }) async {
    if (uid == null) return;

    // 🔹 Validate fields before posting
    if (title.trim().isEmpty) {
      _snack('Missing Title', 'Please enter a title for your ad.');
      return;
    }
    if (description.trim().isEmpty) {
      _snack('Missing Description', 'Please enter a description for your ad.');
      return;
    }

    final now = DateTime.now();

    await _firestore.collection('ads').add({
      'uid': uid,
      'title': title.trim(),
      'description': description.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(now.add(const Duration(days: 30))),
    });

    Get.back();
    _snack('Ad posted', 'Your ad is live');
  }

  Map<String, dynamic>? adForSlot(int slot) {
    if (ads.isEmpty) return null;
    return ads[slot % ads.length];
  }

  Future<void> _autoCleanupExpiredAds() async {
    final now = Timestamp.now();

    final expired = await _firestore
        .collection('ads')
        .where('expiresAt', isLessThan: now)
        .get();

    for (final doc in expired.docs) {
      await doc.reference.delete();
    }
  }

  void _snack(String title, String msg) {
    Get.snackbar(
      title,
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _isDark ? Colors.grey.shade900 : Colors.grey.shade100,
      colorText: _isDark ? Colors.white : Colors.black,
    );
  }
}
