import 'package:spiiiq/controllers/account_controller.dart';
import 'package:spiiiq/controllers/e_login_controller.dart';

import 'package:spiiiq/controllers/status_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import 'package:spiiiq/pages/comment_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final StatusController statusCtrl = Get.find<StatusController>();

  final ThemeController themeCtrl = Get.find<ThemeController>();

  final AuthController authCtrl = Get.find<AuthController>();

  final AccountController accountCtrl = Get.find<AccountController>();

  final ScrollController _scrollController = ScrollController();

  /// 🔹 LOAD MORE POSTS
  final RxInt visiblePosts = 10.obs;

  final RxBool isLoadingMorePosts = false.obs;

  /// 🔹 INSTANT LIKE UI
  final RxMap<String, bool> localLiked = <String, bool>{}.obs;

  final RxMap<String, int> localLikeCount = <String, int>{}.obs;

  /// 🔹 PROFILE TABS
  final RxInt selectedTab = 0.obs;

  /// 🔹 PRODUCT LOAD MORE
  // final RxInt visibleProducts = 10.obs;

  // final RxBool isLoadingMoreProducts = false.obs;

  @override
  bool get wantKeepAlive => true;

  /// 🔹 Obfuscate email
  String obfuscateEmail(String email) {
    final parts = email.split('@');

    if (parts.isEmpty) return email;

    final name = parts[0];

    final domain = parts.length > 1 ? '@${parts[1]}' : '';

    if (name.length <= 4) {
      final first = name.substring(0, 1);

      final last = name.length > 1 ? name.substring(name.length - 1) : '';

      return '$first....$last$domain';
    }

    final firstTwo = name.substring(0, 2);

    final lastTwo = name.substring(name.length - 2);

    return '$firstTwo....$lastTwo$domain';
  }

  String resolveDisplayName(String? name) {
    if (name == null) return 'Anonymous User';

    final cleaned = name.trim();

    if (cleaned.isEmpty || cleaned.toLowerCase() == 'unknown') {
      return 'Anonymous User';
    }

    return cleaned;
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          title: Text(
            'Profile',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('e-users')
              .doc(widget.userId)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text(
                  'Loading profile...',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User not found'));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;

            final userName = userData['name'] ?? 'Unknown';

            final userEmail = userData['email'] ?? '';

            final wallet = userData['walletAddress'] ?? '';

            final avatar = userData['avatar'];

            final isVerified = userData['verified'] == true;

            /// ✅ USER POSTS
            final userPosts = statusCtrl.filteredStatuses.where((doc) {
              final data = doc.data() as Map<String, dynamic>;

              return data['email'] == userEmail;
            }).toList();

            //   final data = doc.data() as Map<String, dynamic>;

            //   return (data['email'] ?? '') == userEmail;
            // }).toList();

            return ListView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              children: [
                /// ✅ PROFILE CARD
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            (avatar != null && avatar.toString().isNotEmpty)
                            ? AssetImage('assets/images/$avatar.png')
                            : null,
                        child: (avatar == null || avatar.toString().isEmpty)
                            ? Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    userName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                if (isVerified)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Image.asset(
                                      'assets/images/verified.png',
                                      width: 18,
                                      height: 18,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              obfuscateEmail(userEmail),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey : Colors.black54,
                              ),
                            ),
                            if (wallet.toString().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                'Wallet: $wallet',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.grey : Colors.black54,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // /// ✅ POSTS TITLE
              ],
            );
          },
        ),
      );
    });
  }
}
