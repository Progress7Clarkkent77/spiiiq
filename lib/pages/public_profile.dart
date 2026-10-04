import 'package:spiiiq/controllers/account_controller.dart';
import 'package:spiiiq/controllers/e_login_controller.dart';

import 'package:spiiiq/controllers/market_controller.dart';
import 'package:spiiiq/controllers/status_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:spiiiq/pages/chat_screen.dart';
import 'package:spiiiq/pages/comment_screen.dart';
import 'package:url_launcher/url_launcher.dart';

// class PublicProfileScreen extends StatelessWidget {
//   final String userId;

//   const PublicProfileScreen({
//     super.key,
//     required this.userId,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final StatusController1 statusCtrl = Get.find<StatusController1>();
//     final ThemeController themeCtrl = Get.find<ThemeController>();
//     final AuthController authCtrl = Get.find<AuthController>();

//     /// 🔹 Obfuscate email
//     String obfuscateEmail(String email) {
//       final parts = email.split('@');
//       if (parts.isEmpty) return email;

//       final name = parts[0];
//       final domain = parts.length > 1 ? '@${parts[1]}' : '';

//       if (name.length <= 4) {
//         // If too short, just show first letter + dots + last letter
//         final first = name.substring(0, 1);
//         final last = name.length > 1 ? name.substring(name.length - 1) : '';
//         return '$first....$last$domain';
//       }

//       final firstTwo = name.substring(0, 2);
//       final lastTwo = name.substring(name.length - 2);
//       return '$firstTwo....$lastTwo$domain';
//     }

//     /// 🔹 Fetch verified status for the user
//     Future<bool> _isUserVerified(String uid) async {
//       try {
//         final doc = await FirebaseFirestore.instance
//             .collection('e-users')
//             .doc(uid)
//             .get();

//         if (!doc.exists) return false;

//         return doc.data()?['verified'] == true;
//       } catch (e) {
//         print('❌ Error fetching verified status: $e');
//         return false;
//       }
//     }

//     return Obx(() {
//       final isDark = themeCtrl.isDarkMode.value;

//       return Scaffold(
//         backgroundColor: isDark ? Colors.black : Colors.white,
//         appBar: AppBar(
//           backgroundColor: isDark ? Colors.black : Colors.white,
//           elevation: 0,
//           iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
//           title: Text(
//             'Profile',
//             style: TextStyle(color: isDark ? Colors.white : Colors.black),
//           ),
//         ),
//         body: FutureBuilder<DocumentSnapshot>(
//           future: FirebaseFirestore.instance
//               .collection('e-users')
//               .doc(userId)
//               .get(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: const Text(
//                   'Loading user profile...',
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               );
//             }

//             if (!snapshot.hasData || !snapshot.data!.exists) {
//               return const Center(child: Text('User not found'));
//             }

//             final userData = snapshot.data!.data() as Map<String, dynamic>;

//             final userName = userData['name'] ?? 'Unknown';
//             final userEmail = userData['email'] ?? '';
//             final wallet = userData['walletAddress'] ?? '';
//             final avatar = userData['avatar'];

//             /// 🔹 FILTER POSTS
//             final userPosts = statusCtrl.filteredStatuses.where((doc) {
//               final data = doc.data() as Map<String, dynamic>;
//               return data['email'] == userEmail;
//             }).toList();

//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   /// 👤 PROFILE HEADER
//                   Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 30,
//                         backgroundColor: isDark ? Colors.white : Colors.black,
//                         backgroundImage:
//                             (avatar != null && avatar.toString().isNotEmpty)
//                                 ? AssetImage(
//                                     'assets/images/$avatar.png',
//                                   )
//                                 : null,
//                         child: (avatar == null || avatar.toString().isEmpty)
//                             ? Text(
//                                 userName.isNotEmpty
//                                     ? userName[0].toUpperCase()
//                                     : '?',
//                                 style: TextStyle(
//                                   color: isDark ? Colors.black : Colors.white,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               )
//                             : null,
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: FutureBuilder<bool>(
//                           future: _isUserVerified(userId),
//                           builder: (context, snapshot) {
//                             final isVerified = snapshot.data ?? false;

//                             return Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Text(
//                                       userName,
//                                       style: TextStyle(
//                                         fontSize: 18,
//                                         fontWeight: FontWeight.bold,
//                                         color: isDark
//                                             ? Colors.white
//                                             : Colors.black,
//                                       ),
//                                     ),
//                                     if (isVerified) ...[
//                                       const SizedBox(width: 4),
//                                       Image.asset(
//                                         'assets/images/verified.png',
//                                         width: 16,
//                                         height: 16,
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                                 const SizedBox(height: 4),
//                                 if (userEmail.isNotEmpty)
//                                   Text(
//                                     obfuscateEmail(userEmail),
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color:
//                                           isDark ? Colors.grey : Colors.black54,
//                                     ),
//                                   ),
//                                 if (wallet.isNotEmpty) ...[
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     'Wallet: $wallet',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color:
//                                           isDark ? Colors.grey : Colors.black54,
//                                     ),
//                                   ),
//                                 ],
//                               ],
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 16),
//                   Divider(
//                     color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
//                   ),
//                   const SizedBox(height: 16),

//                   /// 📝 POSTS
//                   Text(
//                     'Posts',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: isDark ? Colors.white : Colors.black,
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   if (userPosts.isEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 20),
//                       child: Center(
//                         child: Text(
//                           'No posts yet',
//                           style: TextStyle(
//                             color: isDark ? Colors.white : Colors.black,
//                           ),
//                         ),
//                       ),
//                     ),

//                   /// 🔹 POSTS LIST
//                   ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: userPosts.length,
//                     itemBuilder: (context, index) {
//                       final doc = userPosts[index];
//                       final data = doc.data() as Map<String, dynamic>;
//                       final postText = data['text'] ?? '';
//                       final likes = List<String>.from(data['likes'] ?? []);
//                       final timestamp = data['timestamp'] as Timestamp?;
//                       final postTime = statusCtrl.formatPostTime(timestamp);

//                       final hasLiked =
//                           likes.contains(authCtrl.currentUser?.email);

//                       return Container(
//                         margin: const EdgeInsets.symmetric(vertical: 6),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: isDark
//                               ? Colors.grey.shade900
//                               : Colors.grey.shade200,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             /// POST TEXT

//                             if (data['imageUrl'] != null &&
//                                 data['imageUrl'].toString().isNotEmpty)
//                               Padding(
//                                 padding: const EdgeInsets.only(bottom: 8),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(12),
//                                   child: Image.network(
//                                     data['imageUrl'],
//                                     width: double.infinity,
//                                     height: 320,
//                                     fit: BoxFit.cover,
//                                     loadingBuilder: (context, child, progress) {
//                                       if (progress == null) return child;
//                                       return Container(
//                                         height: 300,
//                                         alignment: Alignment.center,
//                                         child:
//                                             const CircularProgressIndicator(),
//                                       );
//                                     },
//                                     errorBuilder: (_, __, ___) =>
//                                         const SizedBox(),
//                                   ),
//                                 ),
//                               ),

//                             RichText(
//                               text: TextSpan(
//                                 children: _linkifyText(postText, isDark),
//                               ),
//                             ),
//                             const SizedBox(height: 8),

//                             /// ACTIONS
//                             Row(
//                               children: [
//                                 /// 👍 LIKE
//                                 InkWell(
//                                   onTap: () => statusCtrl.toggleLike(doc),
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         Icons.thumb_up,
//                                         size: 18,
//                                         color: hasLiked
//                                             ? Colors.blue
//                                             : Colors.grey,
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Text(
//                                         '${likes.length}',
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: isDark
//                                               ? Colors.white
//                                               : Colors.black,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),

//                                 const SizedBox(width: 20),

//                                 /// 💬 COMMENT
//                                 InkWell(
//                                   onTap: () {
//                                     Get.to(() => CommentScreen(
//                                           userName: authCtrl
//                                                   .currentUser?.displayName ??
//                                               '',
//                                           userEmail:
//                                               authCtrl.currentUser?.email ?? '',
//                                           statusDoc: doc,
//                                         ));
//                                   },
//                                   child: StreamBuilder<QuerySnapshot>(
//                                     stream: statusCtrl.commentStream(doc.id),
//                                     builder: (context, snapshot) {
//                                       final count =
//                                           snapshot.data?.docs.length ?? 0;
//                                       return Row(
//                                         children: [
//                                           Icon(
//                                             Icons.comment,
//                                             size: 18,
//                                             color: isDark
//                                                 ? Colors.white
//                                                 : Colors.black,
//                                           ),
//                                           const SizedBox(width: 4),
//                                           Text(
//                                             '$count',
//                                             style: TextStyle(
//                                               fontSize: 12,
//                                               color: isDark
//                                                   ? Colors.white
//                                                   : Colors.black,
//                                             ),
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   ),
//                                 ),

//                                 const SizedBox(width: 20),

//                                 /// 📋 COPY
//                                 InkWell(
//                                   onTap: () => statusCtrl.copyStatus(postText),
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         Icons.copy,
//                                         size: 18,
//                                         color: isDark
//                                             ? Colors.white
//                                             : Colors.black,
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Text(
//                                         'Copy',
//                                         style: TextStyle(
//                                           fontSize: 12,
//                                           color: isDark
//                                               ? Colors.white
//                                               : Colors.black,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),

//                                 const Spacer(),

//                                 /// 🕒 TIME
//                                 Text(
//                                   postTime,
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     color: isDark
//                                         ? Colors.grey.shade400
//                                         : Colors.grey.shade600,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//       );
//     });
//   }
// }

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

            //final marketCtrl = Get.find<MarketController>();

            // final userProducts = marketCtrl.products.where((doc) {
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
                            // Container(
                            //   padding: const EdgeInsets.symmetric(
                            //     horizontal: 12,
                            //     vertical: 6,
                            //   ),
                            //   decoration: BoxDecoration(
                            //     color: isDark
                            //         ? Colors.white.withOpacity(
                            //             0.05,
                            //           )
                            //         : Colors.black.withOpacity(
                            //             0.05,
                            //           ),
                            //     borderRadius: BorderRadius.circular(
                            //       12,
                            //     ),
                            //   ),
                            //   child:

                            //       /// ✅ SEND MESSAGE BUTTON
                            //       SizedBox(
                            //     height: 34,
                            //     child: ElevatedButton.icon(
                            //       onPressed: () async {
                            //         /// 🔹 MESSAGE LOGIC LATER
                            //         try {
                            //           final userEmailFromData =
                            //               userData['email'] ?? '';

                            //           if (userEmailFromData
                            //               .toString()
                            //               .trim()
                            //               .isEmpty) {
                            //             Get.snackbar(
                            //               "Unavailable",
                            //               "Seller information not found",
                            //               snackPosition:
                            //                   SnackPosition.BOTTOM,
                            //               backgroundColor: isDark
                            //                   ? Colors.grey.shade900
                            //                   : Colors.white,
                            //               colorText: isDark
                            //                   ? Colors.white
                            //                   : Colors.black,
                            //             );
                            //             return;
                            //           }

                            //           /// ✅ FIND SELLER USER DOCUMENT
                            //           final sellerQuery =
                            //               await FirebaseFirestore.instance
                            //                   .collection('e-users')
                            //                   .where(
                            //                     'email',
                            //                     isEqualTo: userEmail,
                            //                   )
                            //                   .limit(1)
                            //                   .get();

                            //           if (sellerQuery.docs.isEmpty) {
                            //             Get.snackbar(
                            //               "User not found",
                            //               "Unable to contact user",
                            //               snackPosition:
                            //                   SnackPosition.BOTTOM,
                            //               backgroundColor: isDark
                            //                   ? Colors.grey.shade900
                            //                   : Colors.white,
                            //               colorText: isDark
                            //                   ? Colors.white
                            //                   : Colors.black,
                            //             );
                            //             return;
                            //           }

                            //           final sellerDoc =
                            //               sellerQuery.docs.first;

                            //           final userId = sellerDoc.id;

                            //           final chatUserName =
                            //               sellerDoc.data()['name'] ??
                            //                   userName;

                            //           /// ✅ OPEN CHAT SCREEN
                            //           Get.to(
                            //             () => ChatScreen(
                            //               userId: userId,
                            //               userName: chatUserName,
                            //             ),
                            //           );
                            //         } catch (e) {
                            //           Get.snackbar(
                            //             "Error",
                            //             "Failed to open chat",
                            //             snackPosition: SnackPosition.BOTTOM,
                            //             backgroundColor: isDark
                            //                 ? Colors.grey.shade900
                            //                 : Colors.white,
                            //             colorText: isDark
                            //                 ? Colors.white
                            //                 : Colors.black,
                            //           );

                            //           print("❌ Contact seller error: $e");
                            //         }
                            //       },
                            //       style: ElevatedButton.styleFrom(
                            //         elevation: 0,
                            //         backgroundColor: isDark
                            //             ? Colors.white.withOpacity(0.08)
                            //             : Colors.black.withOpacity(0.06),
                            //         foregroundColor: isDark
                            //             ? Colors.white
                            //             : Colors.black,
                            //         padding: const EdgeInsets.symmetric(
                            //           horizontal: 14,
                            //         ),
                            //         shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(
                            //             12,
                            //           ),
                            //           side: BorderSide(
                            //             color: isDark
                            //                 ? Colors.white10
                            //                 : Colors.black12,
                            //           ),
                            //         ),
                            //       ),
                            //       icon: Icon(
                            //         Icons.chat_bubble_outline,
                            //         size: 16,
                            //         color: isDark
                            //             ? Colors.white
                            //             : Colors.black,
                            //       ),
                            //       label: Text(
                            //         "Send Message",
                            //         style: TextStyle(
                            //           fontSize: 12,
                            //           fontWeight: FontWeight.w600,
                            //           color: isDark
                            //               ? Colors.white
                            //               : Colors.black,
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // /// ✅ POSTS TITLE
                // Text(
                //   'Posts',
                //   style: TextStyle(
                //     fontSize: 18,
                //     fontWeight: FontWeight.bold,
                //     color: isDark ? Colors.white : Colors.black,
                //   ),
                // ),

                // const SizedBox(height: 14),

                // if (userPosts.isEmpty)
                //   Padding(
                //     padding: const EdgeInsets.only(
                //       top: 40,
                //     ),
                //     child: Center(
                //       child: Text(
                //         'No posts yet',
                //         style: TextStyle(
                //           color: isDark ? Colors.white : Colors.black,
                //         ),
                //       ),
                //     ),
                //   ),

                // /// 🔥 SNAPCHAT STYLE SWITCHER
                // Container(
                //   padding: const EdgeInsets.all(5),
                //   decoration: BoxDecoration(
                //     color: isDark
                //         ? Colors.grey.shade900
                //         : Colors.grey.shade100,
                //     borderRadius: BorderRadius.circular(20),
                //     border: Border.all(
                //       color: isDark ? Colors.white10 : Colors.black12,
                //     ),
                //   ),
                //   child: Obx(() {
                //     return Row(
                //       children: [
                //         Expanded(
                //           child: GestureDetector(
                //             onTap: () {
                //               selectedTab.value = 0;
                //             },
                //             child: AnimatedContainer(
                //               duration: const Duration(milliseconds: 250),
                //               padding: const EdgeInsets.symmetric(
                //                 vertical: 12,
                //               ),
                //               decoration: BoxDecoration(
                //                 color: selectedTab.value == 0
                //                     ? (isDark ? Colors.white : Colors.black)
                //                     : Colors.transparent,
                //                 borderRadius: BorderRadius.circular(16),
                //               ),
                //               child: Center(
                //                 child: Text(
                //                   'Posts',
                //                   style: TextStyle(
                //                     fontWeight: FontWeight.bold,
                //                     color: selectedTab.value == 0
                //                         ? (isDark
                //                             ? Colors.black
                //                             : Colors.white)
                //                         : (isDark
                //                             ? Colors.white
                //                             : Colors.black),
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ),

                //       ],
                //     );
                //   }),
                // ),

                // const SizedBox(height: 18),

                // /// 🔹 POSTS
                // Obx(() {
                //   /// =========================================================
                //   /// POSTS TAB
                //   /// =========================================================
                //   //  if (selectedTab.value == 0) {
                //   if (userPosts.isEmpty) {
                //     return Padding(
                //       padding: const EdgeInsets.only(top: 40),
                //       child: Center(
                //         child: Text(
                //           'No posts yet',
                //           style: TextStyle(
                //             color: isDark ? Colors.white : Colors.black,
                //           ),
                //         ),
                //       ),
                //     );
                //   }
                //   final visibleList = userPosts
                //       .take(
                //         visiblePosts.value > userPosts.length
                //             ? userPosts.length
                //             : visiblePosts.value,
                //       )
                //       .toList();

                //   return Column(
                //     children: [
                //       ListView.builder(
                //         shrinkWrap: true,
                //         physics: const NeverScrollableScrollPhysics(),
                //         itemCount: visibleList.length,
                //         itemBuilder: (context, index) {
                //           final doc = visibleList[index];

                //           final data = doc.data() as Map<String, dynamic>;

                //           final postText = data['text'] ?? '';

                //           final likes = List<String>.from(
                //             data['likes'] ?? [],
                //           );

                //           final timestamp = data['timestamp'] as Timestamp?;

                //           final postTime = statusCtrl.formatPostTime(
                //             timestamp,
                //           );

                //           final currentUid = authCtrl.currentUser?.uid;

                //           final originalHasLiked = currentUid != null &&
                //               likes.contains(
                //                 currentUid,
                //               );

                //           final hasLiked =
                //               localLiked[doc.id] ?? originalHasLiked;

                //           final likeCount =
                //               localLikeCount[doc.id] ?? likes.length;

                //           return Container(
                //             margin: const EdgeInsets.only(
                //               bottom: 14,
                //             ),
                //             padding: const EdgeInsets.all(14),
                //             decoration: BoxDecoration(
                //               color: isDark
                //                   ? Colors.grey.shade900
                //                   : Colors.grey.shade100,
                //               borderRadius: BorderRadius.circular(24),
                //               border: Border.all(
                //                 color: isDark
                //                     ? Colors.white10
                //                     : Colors.black12,
                //               ),
                //               boxShadow: [
                //                 BoxShadow(
                //                   color: Colors.black.withOpacity(0.05),
                //                   blurRadius: 10,
                //                   offset: const Offset(
                //                     0,
                //                     4,
                //                   ),
                //                 ),
                //               ],
                //             ),
                //             child: Column(
                //               crossAxisAlignment: CrossAxisAlignment.start,
                //               children: [
                //                 /// ✅ TOP USER
                //                 Row(
                //                   children: [
                //                     CircleAvatar(
                //                       radius: 20,
                //                       backgroundColor: Colors.white,
                //                       backgroundImage: (avatar != null &&
                //                               avatar.toString().isNotEmpty)
                //                           ? AssetImage(
                //                               'assets/images/$avatar.png',
                //                             )
                //                           : null,
                //                       child: (avatar == null ||
                //                               avatar.toString().isEmpty)
                //                           ? Text(
                //                               userName[0].toUpperCase(),
                //                               style: const TextStyle(
                //                                 color: Colors.black,
                //                                 fontWeight: FontWeight.bold,
                //                               ),
                //                             )
                //                           : null,
                //                     ),
                //                     const SizedBox(
                //                       width: 12,
                //                     ),
                //                     Expanded(
                //                       child: Column(
                //                         crossAxisAlignment:
                //                             CrossAxisAlignment.start,
                //                         children: [
                //                           Row(
                //                             children: [
                //                               Flexible(
                //                                 child: Text(
                //                                   userName,
                //                                   overflow:
                //                                       TextOverflow.ellipsis,
                //                                   style: TextStyle(
                //                                     fontSize: 14,
                //                                     fontWeight:
                //                                         FontWeight.bold,
                //                                     color: isDark
                //                                         ? Colors.white
                //                                         : Colors.black,
                //                                   ),
                //                                 ),
                //                               ),
                //                               if (isVerified)
                //                                 Padding(
                //                                   padding:
                //                                       const EdgeInsets.only(
                //                                     left: 5,
                //                                   ),
                //                                   child: Image.asset(
                //                                     'assets/images/verified.png',
                //                                     width: 15,
                //                                     height: 15,
                //                                   ),
                //                                 ),
                //                             ],
                //                           ),
                //                           const SizedBox(
                //                             height: 4,
                //                           ),
                //                           Text(
                //                             obfuscateEmail(
                //                               userEmail,
                //                             ),
                //                             style: TextStyle(
                //                               fontSize: 11,
                //                               color: isDark
                //                                   ? Colors.grey
                //                                   : Colors.black54,
                //                             ),
                //                           ),
                //                         ],
                //                       ),
                //                     ),
                //                   ],
                //                 ),

                //                 const SizedBox(
                //                   height: 14,
                //                 ),

                //                 /// ✅ IMAGE
                //                 if (data['imageUrl'] != null &&
                //                     data['imageUrl'].toString().isNotEmpty)
                //                   Padding(
                //                     padding: const EdgeInsets.only(
                //                       bottom: 14,
                //                     ),
                //                     child: GestureDetector(
                //                       // onTap: () {
                //                       //   Get.to(
                //                       //     () => StatusImageViewScreen1(
                //                       //       statusDoc: doc,
                //                       //     ),
                //                       //     transition:
                //                       //         Transition.cupertino,
                //                       //   );
                //                       // },
                //                       onTap: () {
                //                         Get.to(
                //                           () => FullImageScreen(
                //                             imageUrl: data['imageUrl'],
                //                           ),
                //                           transition: Transition.fadeIn,
                //                         );
                //                       },
                //                       child: Stack(
                //                         children: [
                //                           ClipRRect(
                //                             borderRadius:
                //                                 BorderRadius.circular(20),
                //                             child: CachedNetworkImage(
                //                               imageUrl: data['imageUrl'],
                //                               width: double.infinity,
                //                               height: 300,
                //                               fit: BoxFit.cover,
                //                               memCacheWidth: 500,
                //                               memCacheHeight: 500,
                //                               maxWidthDiskCache: 500,
                //                               fadeInDuration:
                //                                   const Duration(
                //                                 milliseconds: 250,
                //                               ),
                //                               placeholder: (
                //                                 context,
                //                                 url,
                //                               ) =>
                //                                   Container(
                //                                 height: 300,
                //                                 alignment: Alignment.center,
                //                                 child: Text(
                //                                   "loading...",
                //                                   style: TextStyle(
                //                                     fontStyle:
                //                                         FontStyle.italic,
                //                                     color: isDark
                //                                         ? Colors.white
                //                                         : Colors.black,
                //                                   ),
                //                                 ),
                //                               ),
                //                               errorWidget: (
                //                                 context,
                //                                 url,
                //                                 error,
                //                               ) =>
                //                                   Container(
                //                                 height: 300,
                //                                 alignment: Alignment.center,
                //                                 child: const Text(
                //                                   "failed to load",
                //                                   style: TextStyle(
                //                                     color: Colors.red,
                //                                     fontStyle:
                //                                         FontStyle.italic,
                //                                   ),
                //                                 ),
                //                               ),
                //                             ),
                //                           ),
                //                           Positioned(
                //                             right: 12,
                //                             bottom: 12,
                //                             child: Container(
                //                               padding: const EdgeInsets
                //                                   .symmetric(
                //                                 horizontal: 12,
                //                                 vertical: 6,
                //                               ),
                //                               decoration: BoxDecoration(
                //                                 color: isDark
                //                                     ? Colors.black
                //                                         .withOpacity(
                //                                         0.65,
                //                                       )
                //                                     : Colors.white
                //                                         .withOpacity(
                //                                         0.90,
                //                                       ),
                //                                 borderRadius:
                //                                     BorderRadius.circular(
                //                                   14,
                //                                 ),
                //                               ),
                //                               child: Text(
                //                                 "Tap to View",
                //                                 style: TextStyle(
                //                                   fontSize: 12,
                //                                   fontWeight:
                //                                       FontWeight.bold,
                //                                   color: isDark
                //                                       ? Colors.white
                //                                       : Colors.black,
                //                                 ),
                //                               ),
                //                             ),
                //                           ),
                //                         ],
                //                       ),
                //                     ),
                //                   ),

                //                 /// ✅ TEXT
                //                 if (postText.toString().trim().isNotEmpty)
                //                   RichText(
                //                     text: TextSpan(
                //                       children: _linkifyText(
                //                         postText,
                //                         isDark,
                //                       ),
                //                     ),
                //                   ),

                //                 const SizedBox(
                //                   height: 14,
                //                 ),

                //                 /// ✅ ACTIONS
                //                 Row(
                //                   children: [
                //                     /// ❤️ LIKE
                //                     // InkWell(
                //                     //   borderRadius: BorderRadius.circular(30),
                //                     //   onTap: () {
                //                     //     if (currentUid == null) {
                //                     //       return;
                //                     //     }

                //                     //     final currentLike =
                //                     //         localLiked[doc.id] ??
                //                     //             originalHasLiked;

                //                     //     final currentCount =
                //                     //         localLikeCount[doc.id] ??
                //                     //             likes.length;

                //                     //     localLiked[doc.id] = !currentLike;

                //                     //     localLikeCount[doc.id] = currentLike
                //                     //         ? currentCount - 1
                //                     //         : currentCount + 1;

                //                     //     statusCtrl.toggleLike(
                //                     //       doc,
                //                     //     );
                //                     //   },
                //                     //   child: Row(
                //                     //     children: [
                //                     //       Icon(
                //                     //         hasLiked
                //                     //             ? Icons.favorite
                //                     //             : Icons.favorite_border,
                //                     //         size: 24,
                //                     //         color: hasLiked
                //                     //             ? Colors.red
                //                     //             : Colors.grey,
                //                     //       ),
                //                     //       const SizedBox(
                //                     //         width: 5,
                //                     //       ),
                //                     //       Text(
                //                     //         '$likeCount',
                //                     //         style: TextStyle(
                //                     //           fontSize: 12,
                //                     //           color: isDark
                //                     //               ? Colors.white
                //                     //               : Colors.black,
                //                     //         ),
                //                     //       ),
                //                     //     ],
                //                     //   ),
                //                     // ),

                //                     /// ❤️ LIKE
                //                     Obx(() {
                //                       final currentLike =
                //                           localLiked[doc.id] ??
                //                               originalHasLiked;

                //                       final currentCount =
                //                           localLikeCount[doc.id] ??
                //                               likes.length;

                //                       return InkWell(
                //                         borderRadius:
                //                             BorderRadius.circular(30),
                //                         onTap: () {
                //                           if (currentUid == null) {
                //                             return;
                //                           }

                //                           /// ✅ INSTANT UI UPDATE
                //                           localLiked[doc.id] = !currentLike;

                //                           localLikeCount[doc.id] =
                //                               currentLike
                //                                   ? currentCount - 1
                //                                   : currentCount + 1;

                //                           /// ✅ FIRESTORE UPDATE
                //                           statusCtrl.toggleLike(doc);
                //                         },
                //                         child: Row(
                //                           children: [
                //                             AnimatedSwitcher(
                //                               duration: const Duration(
                //                                 milliseconds: 180,
                //                               ),
                //                               transitionBuilder: (
                //                                 child,
                //                                 animation,
                //                               ) {
                //                                 return ScaleTransition(
                //                                   scale: animation,
                //                                   child: child,
                //                                 );
                //                               },
                //                               child: Icon(
                //                                 currentLike
                //                                     ? Icons.favorite
                //                                     : Icons.favorite_border,
                //                                 key: ValueKey(currentLike),
                //                                 size: 24,
                //                                 color: currentLike
                //                                     ? Colors.red
                //                                     : Colors.grey,
                //                               ),
                //                             ),
                //                             const SizedBox(width: 5),
                //                             Text(
                //                               '$currentCount',
                //                               style: TextStyle(
                //                                 fontSize: 12,
                //                                 color: isDark
                //                                     ? Colors.white
                //                                     : Colors.black,
                //                               ),
                //                             ),
                //                           ],
                //                         ),
                //                       );
                //                     }),

                //                     const SizedBox(
                //                       width: 22,
                //                     ),

                //                     /// 💬 COMMENT
                //                     InkWell(
                //                       borderRadius:
                //                           BorderRadius.circular(30),
                //                       onTap: () {
                //                         Get.to(
                //                           () => CommentScreen(
                //                             userName: authCtrl.currentUser
                //                                     ?.displayName ??
                //                                 '',
                //                             userEmail: authCtrl
                //                                     .currentUser?.email ??
                //                                 '',
                //                             statusDoc: doc,
                //                           ),
                //                           transition: Transition.cupertino,
                //                         );
                //                       },
                //                       child: StreamBuilder<QuerySnapshot>(
                //                         stream: statusCtrl.commentStream(
                //                           doc.id,
                //                         ),
                //                         builder: (
                //                           context,
                //                           snapshot,
                //                         ) {
                //                           final commentCount =
                //                               snapshot.data?.docs.length ??
                //                                   0;

                //                           return Row(
                //                             children: [
                //                               Icon(
                //                                 Icons.comment_outlined,
                //                                 size: 24,
                //                                 color: isDark
                //                                     ? Colors.white
                //                                     : Colors.black,
                //                               ),
                //                               const SizedBox(
                //                                 width: 5,
                //                               ),
                //                               Text(
                //                                 '$commentCount',
                //                                 style: TextStyle(
                //                                   fontSize: 12,
                //                                   color: isDark
                //                                       ? Colors.white
                //                                       : Colors.black,
                //                                 ),
                //                               ),
                //                             ],
                //                           );
                //                         },
                //                       ),
                //                     ),

                //                     const SizedBox(
                //                       width: 22,
                //                     ),

                //                     /// 📋 COPY
                //                     InkWell(
                //                       borderRadius:
                //                           BorderRadius.circular(30),
                //                       onTap: () {
                //                         statusCtrl.copyStatus(
                //                           postText,
                //                         );
                //                       },
                //                       child: Row(
                //                         children: [
                //                           Icon(
                //                             Icons.copy,
                //                             size: 22,
                //                             color: isDark
                //                                 ? Colors.white
                //                                 : Colors.black,
                //                           ),
                //                           const SizedBox(
                //                             width: 5,
                //                           ),
                //                           Text(
                //                             'Copy',
                //                             style: TextStyle(
                //                               fontSize: 12,
                //                               color: isDark
                //                                   ? Colors.white
                //                                   : Colors.black,
                //                             ),
                //                           ),
                //                         ],
                //                       ),
                //                     ),

                //                     const Spacer(),

                //                     /// 🕒 TIME
                //                     Text(
                //                       postTime,
                //                       style: TextStyle(
                //                         fontSize: 11,
                //                         color: isDark
                //                             ? Colors.grey.shade400
                //                             : Colors.grey.shade600,
                //                       ),
                //                     ),
                //                   ],
                //                 ),
                //               ],
                //             ),
                //           );
                //         },
                //       ),

                //       /// ✅ LOAD MORE BUTTON
                //       if (visiblePosts.value < userPosts.length)
                //         Obx(() {
                //           if (isLoadingMorePosts.value) {
                //             return Padding(
                //               padding: const EdgeInsets.symmetric(
                //                 vertical: 20,
                //               ),
                //               child: Center(
                //                 child: Text(
                //                   "loading...",
                //                   style: TextStyle(
                //                     fontStyle: FontStyle.italic,
                //                     color: isDark
                //                         ? Colors.white
                //                         : Colors.black,
                //                   ),
                //                 ),
                //               ),
                //             );
                //           }

                //           return Padding(
                //             padding: const EdgeInsets.only(
                //               top: 8,
                //               bottom: 24,
                //             ),
                //             child: Center(
                //               child: TextButton.icon(
                //                 onPressed: () async {
                //                   if (isLoadingMorePosts.value) {
                //                     return;
                //                   }

                //                   isLoadingMorePosts.value = true;

                //                   await Future.delayed(
                //                     const Duration(
                //                       milliseconds: 400,
                //                     ),
                //                   );

                //                   visiblePosts.value += 10;

                //                   isLoadingMorePosts.value = false;
                //                 },
                //                 icon: Icon(
                //                   Icons.keyboard_arrow_down_rounded,
                //                   color:
                //                       isDark ? Colors.white : Colors.black,
                //                 ),
                //                 label: Text(
                //                   "Load more",
                //                   style: TextStyle(
                //                     color: isDark
                //                         ? Colors.white
                //                         : Colors.black,
                //                     fontWeight: FontWeight.w600,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //           );
                //         }),
                //     ],
                //   );
                // }

                // /// =========================================================
                // /// PRODUCTS TAB
                // /// =========================================================
                // if (userProducts.isEmpty) {
                //   return Padding(
                //     padding: const EdgeInsets.only(top: 40),
                //     child: Center(
                //       child: Text(
                //         'No products or services yet',
                //         style: TextStyle(
                //           color: isDark ? Colors.white : Colors.black,
                //         ),
                //       ),
                //     ),
                //   );
                // }

                // final visibleProductList = userProducts
                //     .take(
                //       visibleProducts.value > userProducts.length
                //           ? userProducts.length
                //           : visibleProducts.value,
                //     )
                //     .toList();

                // return Column(
                //   children: [
                //     ListView.builder(
                //       shrinkWrap: true,
                //       physics: const NeverScrollableScrollPhysics(),
                //       itemCount: visibleProductList.length,
                //       itemBuilder: (context, index) {
                //         final doc = visibleProductList[index];

                //         final data = doc.data() as Map<String, dynamic>;

                //         /// ✅ SAFE IMAGE EXTRACTION
                //         final List<String> imageUrls =
                //             List<String>.from(data['imageUrls'] ?? []);

                //         final text = data['text'] ?? '';

                //         final timestamp = data['timestamp'] as Timestamp?;

                //         final time = marketCtrl.formatPostTime(timestamp);

                //         return StatefulBuilder(
                //           builder: (context, setImageState) {
                //             final PageController pageController =
                //                 PageController();

                //             int currentPage = 0;

                //             return Container(
                //               margin: const EdgeInsets.only(
                //                 bottom: 16,
                //               ),
                //               decoration: BoxDecoration(
                //                 color: isDark
                //                     ? Colors.grey.shade900
                //                     : Colors.grey.shade100,
                //                 borderRadius: BorderRadius.circular(26),
                //                 border: Border.all(
                //                   color: isDark
                //                       ? Colors.white10
                //                       : Colors.black12,
                //                 ),
                //                 boxShadow: [
                //                   BoxShadow(
                //                     color: Colors.black.withOpacity(0.05),
                //                     blurRadius: 10,
                //                     offset: const Offset(0, 4),
                //                   ),
                //                 ],
                //               ),
                //               child: Column(
                //                 crossAxisAlignment:
                //                     CrossAxisAlignment.start,
                //                 children: [
                //                   /// =====================================================
                //                   /// NO IMAGE
                //                   /// =====================================================
                //                   if (imageUrls.isEmpty)
                //                     Container(
                //                       height: 190,
                //                       alignment: Alignment.center,
                //                       decoration: BoxDecoration(
                //                         color: isDark
                //                             ? Colors.black26
                //                             : Colors.white,
                //                         borderRadius:
                //                             const BorderRadius.only(
                //                           topLeft: Radius.circular(26),
                //                           topRight: Radius.circular(26),
                //                         ),
                //                       ),
                //                       child: Column(
                //                         mainAxisAlignment:
                //                             MainAxisAlignment.center,
                //                         children: [
                //                           Icon(
                //                             Icons.inventory_2_outlined,
                //                             size: 60,
                //                             color: isDark
                //                                 ? Colors.white54
                //                                 : Colors.black38,
                //                           ),
                //                           const SizedBox(height: 10),
                //                           Text(
                //                             "No product image",
                //                             style: TextStyle(
                //                               fontSize: 12,
                //                               color: isDark
                //                                   ? Colors.white54
                //                                   : Colors.black45,
                //                             ),
                //                           ),
                //                         ],
                //                       ),
                //                     ),

                //                   /// =====================================================
                //                   /// SINGLE IMAGE
                //                   /// =====================================================
                //                   if (imageUrls.length == 1)
                //                     ClipRRect(
                //                       borderRadius:
                //                           const BorderRadius.only(
                //                         topLeft: Radius.circular(26),
                //                         topRight: Radius.circular(26),
                //                       ),
                //                       child: CachedNetworkImage(
                //                         imageUrl: imageUrls.first,

                //                         /// ✅ IMPORTANT
                //                         key: ValueKey(imageUrls.first),

                //                         width: double.infinity,
                //                         height: 270,
                //                         fit: BoxFit.cover,

                //                         /// ✅ FIXES IMAGE DISAPPEARING
                //                         memCacheWidth: 1200,
                //                         memCacheHeight: 1200,
                //                         maxWidthDiskCache: 1200,

                //                         fadeInDuration: const Duration(
                //                             milliseconds: 200),

                //                         placeholder: (context, url) =>
                //                             Container(
                //                           height: 270,
                //                           alignment: Alignment.center,
                //                           child: Text(
                //                             'loading...',
                //                             style: TextStyle(
                //                               fontStyle: FontStyle.italic,
                //                               color: isDark
                //                                   ? Colors.white
                //                                   : Colors.black,
                //                             ),
                //                           ),
                //                         ),

                //                         errorWidget:
                //                             (context, url, error) =>
                //                                 Container(
                //                           height: 270,
                //                           alignment: Alignment.center,
                //                           color: isDark
                //                               ? Colors.black26
                //                               : Colors.white,
                //                           child: Column(
                //                             mainAxisAlignment:
                //                                 MainAxisAlignment.center,
                //                             children: [
                //                               Icon(
                //                                 Icons
                //                                     .broken_image_outlined,
                //                                 size: 50,
                //                                 color: isDark
                //                                     ? Colors.white54
                //                                     : Colors.black38,
                //                               ),
                //                               const SizedBox(height: 8),
                //                               Text(
                //                                 "Failed to load image",
                //                                 style: TextStyle(
                //                                   fontSize: 12,
                //                                   color: isDark
                //                                       ? Colors.white54
                //                                       : Colors.black45,
                //                                 ),
                //                               ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ),

                //                   /// =====================================================
                //                   /// MULTIPLE IMAGES
                //                   /// =====================================================
                //                   if (imageUrls.length > 1)
                //                     SizedBox(
                //                       height: 270,
                //                       child: Stack(
                //                         children: [
                //                           PageView.builder(
                //                             controller: pageController,
                //                             physics:
                //                                 const BouncingScrollPhysics(),
                //                             itemCount: imageUrls.length,
                //                             onPageChanged: (value) {
                //                               currentPage = value;

                //                               setImageState(() {});
                //                             },
                //                             itemBuilder:
                //                                 (context, imgIndex) {
                //                               final image =
                //                                   imageUrls[imgIndex];

                //                               return ClipRRect(
                //                                 borderRadius:
                //                                     const BorderRadius
                //                                         .only(
                //                                   topLeft:
                //                                       Radius.circular(26),
                //                                   topRight:
                //                                       Radius.circular(26),
                //                                 ),
                //                                 child: CachedNetworkImage(
                //                                   imageUrl: image,

                //                                   /// ✅ IMPORTANT
                //                                   key: ValueKey(
                //                                     '$index-$imgIndex-$image',
                //                                   ),

                //                                   width: double.infinity,
                //                                   height: 270,
                //                                   fit: BoxFit.cover,

                //                                   /// ✅ FIX FOR MANY PRODUCTS
                //                                   memCacheWidth: 1200,
                //                                   memCacheHeight: 1200,
                //                                   maxWidthDiskCache: 1200,

                //                                   fadeInDuration:
                //                                       const Duration(
                //                                     milliseconds: 200,
                //                                   ),

                //                                   placeholder:
                //                                       (context, url) =>
                //                                           Container(
                //                                     alignment:
                //                                         Alignment.center,
                //                                     child: Text(
                //                                       'loading...',
                //                                       style: TextStyle(
                //                                         fontStyle:
                //                                             FontStyle
                //                                                 .italic,
                //                                         color: isDark
                //                                             ? Colors.white
                //                                             : Colors
                //                                                 .black,
                //                                       ),
                //                                     ),
                //                                   ),

                //                                   errorWidget: (context,
                //                                           url, error) =>
                //                                       Container(
                //                                     alignment:
                //                                         Alignment.center,
                //                                     color: isDark
                //                                         ? Colors.black26
                //                                         : Colors.white,
                //                                     child: Icon(
                //                                       Icons
                //                                           .broken_image_outlined,
                //                                       size: 50,
                //                                       color: isDark
                //                                           ? Colors.white54
                //                                           : Colors
                //                                               .black38,
                //                                     ),
                //                                   ),
                //                                 ),
                //                               );
                //                             },
                //                           ),

                //                           /// =====================================================
                //                           /// LEFT ARROW
                //                           /// =====================================================
                //                           if (currentPage > 0)
                //                             Positioned(
                //                               left: 12,
                //                               top: 0,
                //                               bottom: 0,
                //                               child: Center(
                //                                 child: GestureDetector(
                //                                   onTap: () {
                //                                     pageController
                //                                         .previousPage(
                //                                       duration:
                //                                           const Duration(
                //                                         milliseconds: 250,
                //                                       ),
                //                                       curve: Curves
                //                                           .easeInOut,
                //                                     );
                //                                   },
                //                                   child: Container(
                //                                     padding:
                //                                         const EdgeInsets
                //                                             .all(
                //                                       10,
                //                                     ),
                //                                     decoration:
                //                                         BoxDecoration(
                //                                       color: Colors.black
                //                                           .withOpacity(
                //                                         0.45,
                //                                       ),
                //                                       shape:
                //                                           BoxShape.circle,
                //                                     ),
                //                                     child: const Icon(
                //                                       Icons
                //                                           .arrow_back_ios_new_rounded,
                //                                       color: Colors.white,
                //                                       size: 18,
                //                                     ),
                //                                   ),
                //                                 ),
                //                               ),
                //                             ),

                //                           /// =====================================================
                //                           /// RIGHT ARROW
                //                           /// =====================================================
                //                           if (currentPage <
                //                               imageUrls.length - 1)
                //                             Positioned(
                //                               right: 12,
                //                               top: 0,
                //                               bottom: 0,
                //                               child: Center(
                //                                 child: GestureDetector(
                //                                   onTap: () {
                //                                     pageController
                //                                         .nextPage(
                //                                       duration:
                //                                           const Duration(
                //                                         milliseconds: 250,
                //                                       ),
                //                                       curve: Curves
                //                                           .easeInOut,
                //                                     );
                //                                   },
                //                                   child: Container(
                //                                     padding:
                //                                         const EdgeInsets
                //                                             .all(
                //                                       10,
                //                                     ),
                //                                     decoration:
                //                                         BoxDecoration(
                //                                       color: Colors.black
                //                                           .withOpacity(
                //                                         0.45,
                //                                       ),
                //                                       shape:
                //                                           BoxShape.circle,
                //                                     ),
                //                                     child: const Icon(
                //                                       Icons
                //                                           .arrow_forward_ios_rounded,
                //                                       color: Colors.white,
                //                                       size: 18,
                //                                     ),
                //                                   ),
                //                                 ),
                //                               ),
                //                             ),

                //                           /// =====================================================
                //                           /// IMAGE COUNTER
                //                           /// =====================================================
                //                           Positioned(
                //                             right: 14,
                //                             bottom: 14,
                //                             child: Container(
                //                               padding: const EdgeInsets
                //                                   .symmetric(
                //                                 horizontal: 10,
                //                                 vertical: 5,
                //                               ),
                //                               decoration: BoxDecoration(
                //                                 color: Colors.black
                //                                     .withOpacity(0.55),
                //                                 borderRadius:
                //                                     BorderRadius.circular(
                //                                   14,
                //                                 ),
                //                               ),
                //                               child: Text(
                //                                 '${currentPage + 1}/${imageUrls.length}',
                //                                 style: const TextStyle(
                //                                   color: Colors.white,
                //                                   fontSize: 11,
                //                                   fontWeight:
                //                                       FontWeight.bold,
                //                                 ),
                //                               ),
                //                             ),
                //                           ),

                //                           /// =====================================================
                //                           /// SWIPE HINT
                //                           /// =====================================================
                //                           Positioned(
                //                             left: 14,
                //                             bottom: 14,
                //                             child: Container(
                //                               padding: const EdgeInsets
                //                                   .symmetric(
                //                                 horizontal: 10,
                //                                 vertical: 5,
                //                               ),
                //                               decoration: BoxDecoration(
                //                                 color: Colors.black
                //                                     .withOpacity(0.55),
                //                                 borderRadius:
                //                                     BorderRadius.circular(
                //                                   14,
                //                                 ),
                //                               ),
                //                               child: const Row(
                //                                 children: [
                //                                   Icon(
                //                                     Icons.swipe,
                //                                     color: Colors.white,
                //                                     size: 13,
                //                                   ),
                //                                   SizedBox(width: 5),
                //                                   Text(
                //                                     'Swipe',
                //                                     style: TextStyle(
                //                                       color: Colors.white,
                //                                       fontSize: 11,
                //                                       fontWeight:
                //                                           FontWeight.w600,
                //                                     ),
                //                                   ),
                //                                 ],
                //                               ),
                //                             ),
                //                           ),
                //                         ],
                //                       ),
                //                     ),

                //                   /// =====================================================
                //                   /// PRODUCT CONTENT
                //                   /// =====================================================
                //                   Padding(
                //                     padding: const EdgeInsets.all(16),
                //                     child: Column(
                //                       crossAxisAlignment:
                //                           CrossAxisAlignment.start,
                //                       children: [
                //                         Row(
                //                           crossAxisAlignment:
                //                               CrossAxisAlignment.start,
                //                           children: [
                //                             Expanded(
                //                               child: Text(
                //                                 text,
                //                                 style: TextStyle(
                //                                   fontSize: 14,
                //                                   height: 1.6,
                //                                   color: isDark
                //                                       ? Colors.white
                //                                       : Colors.black,
                //                                 ),
                //                               ),
                //                             ),
                //                             const SizedBox(width: 10),

                //                             /// EDIT BUTTON
                //                             // GestureDetector(
                //                             //   onTap: () async {
                //                             //     final controller =
                //                             //         TextEditingController(
                //                             //       text: text,
                //                             //     );

                //                             //     final result = await Get
                //                             //         .dialog<String>(
                //                             //       AlertDialog(
                //                             //         backgroundColor:
                //                             //             isDark
                //                             //                 ? Colors.grey
                //                             //                     .shade900
                //                             //                 : Colors
                //                             //                     .white,
                //                             //         title: Text(
                //                             //           'Edit Product',
                //                             //           style: TextStyle(
                //                             //             color: isDark
                //                             //                 ? Colors.white
                //                             //                 : Colors
                //                             //                     .black,
                //                             //           ),
                //                             //         ),
                //                             //         content: TextField(
                //                             //           controller:
                //                             //               controller,
                //                             //           maxLines: 6,
                //                             //           style: TextStyle(
                //                             //             color: isDark
                //                             //                 ? Colors.white
                //                             //                 : Colors
                //                             //                     .black,
                //                             //           ),
                //                             //           decoration:
                //                             //               const InputDecoration(
                //                             //             hintText:
                //                             //                 'Edit write up',
                //                             //           ),
                //                             //         ),
                //                             //         actions: [
                //                             //           TextButton(
                //                             //             onPressed: () {
                //                             //               Get.back();
                //                             //             },
                //                             //             child: const Text(
                //                             //               'Cancel',
                //                             //             ),
                //                             //           ),
                //                             //           ElevatedButton(
                //                             //             onPressed: () {
                //                             //               Get.back(
                //                             //                 result:
                //                             //                     controller
                //                             //                         .text,
                //                             //               );
                //                             //             },
                //                             //             child: const Text(
                //                             //               'Save',
                //                             //             ),
                //                             //           ),
                //                             //         ],
                //                             //       ),
                //                             //     );

                //                             //     if (result != null &&
                //                             //         result
                //                             //             .trim()
                //                             //             .isNotEmpty) {
                //                             //       await FirebaseFirestore
                //                             //           .instance
                //                             //           .collection(
                //                             //               'market')
                //                             //           .doc(doc.id)
                //                             //           .update({
                //                             //         'text': result.trim(),
                //                             //       });
                //                             //     }
                //                             //   },
                //                             //   child: Icon(
                //                             //     Icons.edit,
                //                             //     size: 20,
                //                             //     color: isDark
                //                             //         ? Colors.white
                //                             //         : Colors.black,
                //                             //   ),
                //                             // ),
                //                           ],
                //                         ),
                //                         const SizedBox(height: 14),
                //                         Row(
                //                           children: [
                //                             Icon(
                //                               Icons.access_time,
                //                               size: 15,
                //                               color: isDark
                //                                   ? Colors.grey
                //                                   : Colors.black54,
                //                             ),
                //                             const SizedBox(width: 5),
                //                             Text(
                //                               time,
                //                               style: TextStyle(
                //                                 fontSize: 11,
                //                                 color: isDark
                //                                     ? Colors.grey
                //                                     : Colors.black54,
                //                               ),
                //                             ),
                //                           ],
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             );
                //           },
                //         );
                //       },
                //     ),

                //     /// =========================================================
                //     /// LOAD MORE
                //     /// =========================================================
                //     if (visibleProducts.value < userProducts.length)
                //       TextButton(
                //         onPressed: () async {
                //           if (isLoadingMoreProducts.value) {
                //             return;
                //           }

                //           isLoadingMoreProducts.value = true;

                //           await Future.delayed(
                //             const Duration(milliseconds: 300),
                //           );

                //           visibleProducts.value += 10;

                //           isLoadingMoreProducts.value = false;
                //         },
                //         child: Text(
                //           'Load more',
                //           style: TextStyle(
                //             color: isDark ? Colors.white : Colors.black,
                //           ),
                //         ),
                //       ),
                //   ],
                // );
                //  ),
              ],
            );
          },
        ),
      );
    });
  }
}

// List<TextSpan> _linkifyText(String text, bool isDark) {
//   final RegExp linkRegex = RegExp(
//     r'((https?:\/\/|www\.)\S+|\S+\.com)',
//     caseSensitive: false,
//   );

//   final List<TextSpan> spans = [];
//   final matches = linkRegex.allMatches(text);

//   int start = 0;

//   for (final match in matches) {
//     if (match.start > start) {
//       spans.add(TextSpan(
//         text: text.substring(start, match.start),
//         style: TextStyle(
//           fontSize: 14,
//           color: isDark ? Colors.white : Colors.black,
//         ),
//       ));
//     }

//     String linkText = text.substring(match.start, match.end);

//     // Ensure link starts with https:// if missing
//     if (!linkText.startsWith(RegExp(r'https?:\/\/'))) {
//       linkText = 'https://$linkText';
//     }

//     spans.add(TextSpan(
//       text: text.substring(match.start, match.end),
//       style: TextStyle(
//         fontSize: 14,
//         color: Colors.blue,
//         // decoration: TextDecoration.underline,
//       ),
//       recognizer: TapGestureRecognizer()
//         ..onTap = () async {
//           final Uri url = Uri.parse(linkText);
//           if (await canLaunchUrl(url)) {
//             await launchUrl(url, mode: LaunchMode.externalApplication);
//           } else {
//             print('Could not launch $linkText');
//           }
//         },
//     ));

//     start = match.end;
//   }

//   if (start < text.length) {
//     spans.add(TextSpan(
//       text: text.substring(start),
//       style: TextStyle(
//         fontSize: 14,
//         color: isDark ? Colors.white : Colors.black,
//       ),
//     ));
//   }

//   return spans;
// }

// class FullImageScreen extends StatelessWidget {
//   final String imageUrl;

//   const FullImageScreen({
//     super.key,
//     required this.imageUrl,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Positioned.fill(
//               child: PhotoView(
//                 imageProvider: CachedNetworkImageProvider(imageUrl),
//                 minScale: PhotoViewComputedScale.contained,
//                 maxScale: PhotoViewComputedScale.covered * 4,
//                 backgroundDecoration: const BoxDecoration(
//                   color: Colors.black,
//                 ),
//                 loadingBuilder: (context, event) {
//                   return const Center(
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                     ),
//                   );
//                 },
//               ),
//             ),
//             Positioned(
//               top: 15,
//               left: 10,
//               child: CircleAvatar(
//                 backgroundColor: Colors.black54,
//                 child: IconButton(
//                   icon: const Icon(
//                     Icons.arrow_back,
//                     color: Colors.white,
//                   ),
//                   onPressed: () => Get.back(),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
