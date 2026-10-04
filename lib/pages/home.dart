// import 'dart:async';

// //import 'package:audioplayers/audioplayers.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:photo_view/photo_view.dart';
// import 'package:spiiiq/controllers/account_controller.dart';
// import 'package:spiiiq/controllers/e_login_controller.dart';
// import 'package:spiiiq/controllers/balance_controller.dart';
// import 'package:spiiiq/controllers/chat_list_controller.dart';
// import 'package:spiiiq/controllers/status_controller.dart';
// import 'package:spiiiq/controllers/theme_controller.dart';
// import 'package:spiiiq/pages/add_status.dart';
// import 'package:spiiiq/pages/chat_screen.dart';
// import 'package:spiiiq/pages/comment_screen.dart';
// import 'package:spiiiq/pages/pay_history.dart';
// import 'package:spiiiq/pages/policy.dart';
// import 'package:spiiiq/pages/profile.dart';
// import 'package:spiiiq/pages/public_profile.dart';
// import 'package:spiiiq/pages/status_screen.dart';
// import 'package:spiiiq/pages/withdrawal_page.dart';
// import 'package:spiiiq/widgets/url_launcher.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// //import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';

// import 'dart:async';

// class Home extends StatefulWidget {
//   final String userName;
//   final String userEmail;

//   const Home({super.key, required this.userName, required this.userEmail});

//   @override
//   State<Home> createState() => _HomeState();
// }

// class _HomeState extends State<Home> {
//   final ChatListController controller = Get.put(ChatListController());
//   final ThemeController themeCtrl = Get.put(ThemeController());
//   final AccountController accountController = Get.put(AccountController());
//   final IconNavigationHandler navigationHandler = IconNavigationHandler();
//   // final CurrencyController currencyController = Get.put(CurrencyController());
//   // final AddMoneyController addMoneyController = Get.find<AddMoneyController>();
//   // final PbcMarketController pbcMarketController =
//   //     Get.put(PbcMarketController());
//   final AvailableBalanceController balanceCtrl = Get.put(
//     AvailableBalanceController(),
//   );
//   final StatusController statusCtrl = Get.put(StatusController());
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     accountController.fetchUserInfo();

//     ///accountController.fetchBalances();
//     // accountController.fetchWalletAddress();
//     //  accountController.toggleBalanceVisibility();
//     // accountController.fetchWalletDetails();
//     // accountController.fetchWalletData();
//     // addMoneyController.fetchVaultBalance();

//     // ever(addMoneyController.email, (String email) {
//     //   if (email.isNotEmpty) {
//     //     addMoneyController.fetchTransactions(email);
//     //   }
//     // });
//   }

//   String selectedCurrency = "\$ Dollar";

//   String resolveDisplayName(String? name) {
//     if (name == null) return 'Anonymous User';

//     final cleaned = name.trim();
//     if (cleaned.isEmpty || cleaned.toLowerCase() == 'unknown') {
//       return 'Anonymous User';
//     }

//     return cleaned;
//   }

//   String resolveInitial(String displayName) {
//     return displayName == 'Anonymous User' ? 'A' : displayName[0].toUpperCase();
//   }

//   @override
//   bool get wantKeepAlive => true;

//   /// 🔹 Obfuscate email
//   String obfuscateEmail(String email) {
//     final parts = email.split('@');

//     if (parts.isEmpty) return email;

//     final name = parts[0];

//     final domain = parts.length > 1 ? '@${parts[1]}' : '';

//     if (name.length <= 4) {
//       final first = name.substring(0, 1);

//       final last = name.length > 1 ? name.substring(name.length - 1) : '';

//       return '$first....$last$domain';
//     }

//     final firstTwo = name.substring(0, 2);

//     final lastTwo = name.substring(name.length - 2);

//     return '$firstTwo....$lastTwo$domain';
//   }

//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async => false,
//       child: Obx(() {
//         final isDark = themeCtrl.isDarkMode.value;

//         return Scaffold(
//           backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
//           appBar: AppBar(
//             automaticallyImplyLeading: false,
//             backgroundColor: isDark ? Colors.black : Colors.white,
//             elevation: 0,
//             titleSpacing: 0,
//             title: Row(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(width: 16),

//                 Container(
//                   width: 46,
//                   height: 46,
//                   padding: const EdgeInsets.all(1.5), // Thin border spacing
//                   decoration: BoxDecoration(
//                     color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(
//                       color: isDark ? Colors.white12 : Colors.black12,
//                       width: 1,
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(isDark ? 0.30 : 0.08),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.asset(
//                       'assets/images/spiiq Logo.png',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(width: 12),
//                 // App name
//                 Text(
//                   'SpiiiQ',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),

//                 const Spacer(),

//                 // Menu
//                 PopupMenuButton<String>(
//                   color: isDark ? Colors.grey.shade900 : Colors.white,
//                   icon: Icon(
//                     Icons.more_vert,
//                     color: isDark ? Colors.white : Colors.black54,
//                   ),
//                   onSelected: (value) async {
//                     switch (value) {
//                       // case 'profile':
//                       //   Get.to(() => const ProfileScreen());
//                       //   break;
//                       // case 'deeOracle':
//                       //   Get.to(() => const DeeOracle());
//                       //   break;
//                       // case 'policy':
//                       //   Get.to(() => spiiiqRewardPolicyScreen());
//                       //   break;
//                       case 'support':
//                         final Uri waUrl = Uri.parse(
//                           "https://wa.me/2349014078396",
//                         );

//                         if (await canLaunchUrl(waUrl)) {
//                           await launchUrl(
//                             waUrl,
//                             mode: LaunchMode.externalApplication, // opens in WhatsApp or browser
//                           );
//                         } else {
//                           Get.snackbar(
//                             'Error',
//                             'Could not open WhatsApp link',
//                             snackPosition: SnackPosition.BOTTOM,
//                           );
//                         }
//                         break;
//                       case 'dark':
//                         themeCtrl.setDark();
//                         break;
//                       case 'light':
//                         themeCtrl.setLight();
//                         break;
//                       case 'logout':
//                         Get.find<AuthController>().logout();
//                         break;
//                     }
//                   },
//                   itemBuilder: (_) => [
//                     // PopupMenuItem(
//                     //   value: 'profile',
//                     //   child: Row(
//                     //     children: [
//                     //       Icon(Icons.person,
//                     //           color: isDark ? Colors.white : Colors.black),
//                     //       const SizedBox(width: 10),
//                     //       Text(
//                     //         'Profile',
//                     //         style: TextStyle(
//                     //             color: isDark ? Colors.white : Colors.black),
//                     //       ),
//                     //     ],
//                     //   ),
//                     // ),
//                     //const PopupMenuDivider(),
//                     // PopupMenuItem(
//                     //   value: 'policy',
//                     //   child: Row(
//                     //     children: [
//                     //       Icon(Icons.person,
//                     //           color: isDark ? Colors.white : Colors.black),
//                     //       const SizedBox(width: 10),
//                     //       Text(
//                     //         'Policy',
//                     //         style: TextStyle(
//                     //             color: isDark ? Colors.white : Colors.black),
//                     //       ),
//                     //     ],
//                     //   ),
//                     // ),

//                     // PopupMenuItem(
//                     //   value: 'deeOracle',
//                     //   child: Row(
//                     //     children: [
//                     //       Icon(
//                     //         Icons.smart_toy,
//                     //         color: isDark ? Colors.white : Colors.black,
//                     //       ),
//                     //       const SizedBox(width: 10),
//                     //       Text(
//                     //         'déèOracle',
//                     //         style: TextStyle(
//                     //           color: isDark ? Colors.white : Colors.black,
//                     //         ),
//                     //       ),
//                     //     ],
//                     //   ),
//                     //),

//                     // const PopupMenuDivider(),

//                     // PopupMenuItem(
//                     //   value: 'policy',
//                     //   child: Row(
//                     //     children: [
//                     //       Icon(
//                     //         Icons.policy,
//                     //         color: isDark ? Colors.white : Colors.black,
//                     //       ),
//                     //       const SizedBox(width: 10),
//                     //       Text(
//                     //         'Policy',
//                     //         style: TextStyle(
//                     //           color: isDark ? Colors.white : Colors.black,
//                     //         ),
//                     //       ),
//                     //     ],
//                     //   ),
//                     // ),

//                     // const PopupMenuDivider(),
//                     PopupMenuItem(
//                       value: 'support',
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.support_agent,
//                             color: isDark ? Colors.white : Colors.black,
//                           ),
//                           const SizedBox(width: 10),
//                           Text(
//                             'Support',
//                             style: TextStyle(
//                               color: isDark ? Colors.white : Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const PopupMenuDivider(),
//                     PopupMenuItem(
//                       value: isDark ? 'light' : 'dark',
//                       child: Row(
//                         children: [
//                           Icon(
//                             isDark ? Icons.light_mode : Icons.dark_mode,
//                             color: isDark ? Colors.amber : Colors.black,
//                           ),
//                           const SizedBox(width: 10),
//                           Text(
//                             isDark ? 'Light Mode' : 'Dark Mode',
//                             style: TextStyle(
//                               color: isDark ? Colors.white : Colors.black,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const PopupMenuDivider(),
//                     PopupMenuItem(
//                       value: 'logout',
//                       child: Row(
//                         children: const [
//                           Icon(Icons.logout, color: Colors.red),
//                           SizedBox(width: 10),
//                           Text('Logout', style: TextStyle(color: Colors.red)),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(width: 8),
//               ],
//             ),
//           ),
//           body: Column(
//             children: [
//               // 🔍 Search Bar
//               // Padding(
//               //   padding:
//               //       const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               //   child: TextField(
//               //     onChanged: (v) => controller.searchQuery.value = v,
//               //     style:
//               //         TextStyle(color: isDark ? Colors.white : Colors.black87),
//               //     decoration: InputDecoration(
//               //       hintText: 'Search posts...',
//               //       prefixIcon: Icon(Icons.search,
//               //           color: isDark ? Colors.white38 : Colors.black38),
//               //       filled: true,
//               //       fillColor:
//               //           isDark ? Colors.grey.shade900 : Colors.grey.shade200,
//               //       border: OutlineInputBorder(
//               //         borderRadius: BorderRadius.circular(14),
//               //         borderSide: BorderSide.none,
//               //       ),
//               //     ),
//               //   ),
//               // ),

//               Padding(
//                 padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(18),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: TextField(
//                     onChanged: (value) {
//                       statusCtrl.searchQuery.value = value;
//                     },
//                     style: TextStyle(
//                       color: isDark ? Colors.white : Colors.black,
//                       fontSize: 14,
//                     ),
//                     decoration: InputDecoration(
//                       hintText: 'Search post by user',
//                       hintStyle: TextStyle(
//                         color: isDark ? Colors.grey : Colors.black54,
//                       ),
//                       prefixIcon: Icon(
//                         Icons.search_rounded,
//                         color: isDark ? Colors.white70 : Colors.black54,
//                       ),
//                       filled: true,
//                       fillColor: Colors.transparent,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(18),
//                         borderSide: BorderSide.none,
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(vertical: 14),
//                     ),
//                   ),
//                 ),
//               ),

//               Divider(
//                 height: 1,
//                 thickness: 0.5,
//                 color: isDark ? Colors.white12 : Colors.black12,
//               ),

//               /// ✅ POSTS
//               Expanded(
//                 child: Obx(() {
//                   final posts = statusCtrl.paginatedStatuses;

//                   if (posts.isEmpty) {
//                     return Center(
//                       child: Text(
//                         'Loading Posts.....',
//                         style: TextStyle(
//                           color: isDark ? Colors.white : Colors.black,
//                           fontSize: 15,
//                         ),
//                       ),
//                     );
//                   }

//                   return ListView.builder(
//                     controller: _scrollController,
//                     physics: const BouncingScrollPhysics(),
//                     keyboardDismissBehavior:
//                         ScrollViewKeyboardDismissBehavior.onDrag,
//                     cacheExtent: 1200,
//                     addAutomaticKeepAlives: false,
//                     addRepaintBoundaries: true,
//                     itemCount: posts.length + 1,
//                     padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
//                     itemBuilder: (context, index) {
//                       /// ✅ LOAD MORE
//                       if (index == posts.length) {
//                         final canLoadMore =
//                             posts.length >= statusCtrl.visibleCount.value &&
//                             statusCtrl.visibleCount.value < statusCtrl.maxLimit;

//                         if (!canLoadMore) {
//                           return const SizedBox.shrink();
//                         }

//                         return Obx(() {
//                           if (statusCtrl.isLoadingMore.value) {
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 20),
//                               child: Center(
//                                 child: Text(
//                                   "loading...",
//                                   style: TextStyle(
//                                     fontStyle: FontStyle.italic,
//                                     color: isDark ? Colors.white : Colors.black,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }

//                           return Padding(
//                             padding: const EdgeInsets.only(top: 8, bottom: 24),
//                             child: Center(
//                               child: TextButton.icon(
//                                 onPressed: statusCtrl.loadMore,
//                                 icon: Icon(
//                                   Icons.keyboard_arrow_down_rounded,
//                                   color: isDark ? Colors.white : Colors.black,
//                                 ),
//                                 label: Text(
//                                   "Load more",
//                                   style: TextStyle(
//                                     color: isDark ? Colors.white : Colors.black,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         });
//                       }

//                       final doc = posts[index];

//                       final data = doc.data() as Map<String, dynamic>;

//                       final postText = data['text'] ?? '';

//                       final postName = resolveDisplayName(data['name']);

//                       final postEmail = data['email'] ?? '';

//                       final likes = List<String>.from(data['likes'] ?? []);

//                       final postInitial = postName == 'Anonymous User'
//                           ? 'A'
//                           : postName[0].toUpperCase();

//                       final currentUid =
//                           Get.find<AuthController>().currentUser?.uid;

//                       final hasLiked =
//                           currentUid != null && likes.contains(currentUid);

//                       final Timestamp? timestamp = data['timestamp'];

//                       final postTime = statusCtrl.formatPostTime(timestamp);

//                       return RepaintBoundary(
//                         child: Container(
//                           margin: const EdgeInsets.only(bottom: 14),
//                           padding: const EdgeInsets.all(14),
//                           decoration: BoxDecoration(
//                             color: isDark
//                                 ? Colors.grey.shade900
//                                 : Colors.grey.shade100,
//                             borderRadius: BorderRadius.circular(24),
//                             border: Border.all(
//                               color: isDark ? Colors.white10 : Colors.black12,
//                             ),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 10,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ],
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               /// ✅ TOP USER SECTION
//                               Row(
//                                 children: [
//                                   FutureBuilder<String?>(
//                                     future: statusCtrl
//                                         .fetchStatusUserAvatarName(postEmail),
//                                     builder: (context, snapshot) {
//                                       final avatarName = statusCtrl
//                                           .getCachedAvatar(postEmail);

//                                       return GestureDetector(
//                                         onTap: () async {
//                                           try {
//                                             final userDoc =
//                                                 await FirebaseFirestore.instance
//                                                     .collection('e-users')
//                                                     .where(
//                                                       'email',
//                                                       isEqualTo: postEmail,
//                                                     )
//                                                     .limit(1)
//                                                     .get();

//                                             if (userDoc.docs.isEmpty) {
//                                               Get.snackbar(
//                                                 'Anonymous user',
//                                                 'This profile did not back up their Seed Phrase',
//                                                 snackPosition:
//                                                     SnackPosition.BOTTOM,
//                                               );

//                                               return;
//                                             }

//                                             final userId =
//                                                 userDoc.docs.first.id;

//                                             Get.to(
//                                               () => PublicProfileScreen(
//                                                 userId: userId,
//                                               ),
//                                               transition: Transition.cupertino,
//                                             );
//                                           } catch (e) {
//                                             Get.snackbar(
//                                               'Error',
//                                               'Failed to fetch user',
//                                               snackPosition:
//                                                   SnackPosition.BOTTOM,
//                                             );
//                                           }
//                                         },
//                                         child: CircleAvatar(
//                                           radius: 20,
//                                           backgroundColor: Colors.white,
//                                           backgroundImage:
//                                               (avatarName != null &&
//                                                   avatarName.isNotEmpty)
//                                               ? AssetImage(
//                                                   'assets/images/$avatarName.png',
//                                                 )
//                                               : null,
//                                           child:
//                                               (avatarName == null ||
//                                                   avatarName.isEmpty)
//                                               ? Text(
//                                                   postInitial,
//                                                   style: const TextStyle(
//                                                     color: Colors.black,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                 )
//                                               : null,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                   const SizedBox(width: 12),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         /// ✅ NAME BUTTON
//                                         Align(
//                                           alignment: Alignment.centerLeft,
//                                           child: TextButton(
//                                             style: TextButton.styleFrom(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                     horizontal: 10,
//                                                     vertical: 6,
//                                                   ),
//                                               minimumSize: Size.zero,
//                                               tapTargetSize:
//                                                   MaterialTapTargetSize
//                                                       .shrinkWrap,
//                                               backgroundColor: isDark
//                                                   ? Colors.white.withOpacity(
//                                                       0.05,
//                                                     )
//                                                   : Colors.black.withOpacity(
//                                                       0.04,
//                                                     ),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(12),
//                                               ),
//                                             ),
//                                             onPressed: () async {
//                                               try {
//                                                 final userDoc =
//                                                     await FirebaseFirestore
//                                                         .instance
//                                                         .collection('e-users')
//                                                         .where(
//                                                           'email',
//                                                           isEqualTo: postEmail,
//                                                         )
//                                                         .limit(1)
//                                                         .get();

//                                                 if (userDoc.docs.isEmpty) {
//                                                   Get.snackbar(
//                                                     'Anonymous user',
//                                                     'This profile did not back up their Seed Phrase',
//                                                     snackPosition:
//                                                         SnackPosition.BOTTOM,
//                                                   );

//                                                   return;
//                                                 }

//                                                 final userId =
//                                                     userDoc.docs.first.id;

//                                                 Get.to(
//                                                   () => PublicProfileScreen(
//                                                     userId: userId,
//                                                   ),
//                                                   transition:
//                                                       Transition.cupertino,
//                                                 );
//                                               } catch (e) {
//                                                 Get.snackbar(
//                                                   'Error',
//                                                   'Failed to fetch user',
//                                                   snackPosition:
//                                                       SnackPosition.BOTTOM,
//                                                 );
//                                               }
//                                             },
//                                             child: Row(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 Flexible(
//                                                   child: Text(
//                                                     postName,
//                                                     overflow:
//                                                         TextOverflow.ellipsis,
//                                                     style: TextStyle(
//                                                       fontSize: 14,
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       color: isDark
//                                                           ? Colors.white
//                                                           : Colors.black,
//                                                     ),
//                                                   ),
//                                                 ),
//                                                 if (statusCtrl
//                                                     .getCachedVerified(
//                                                       postEmail,
//                                                     ))
//                                                   Padding(
//                                                     padding:
//                                                         const EdgeInsets.only(
//                                                           left: 5,
//                                                         ),
//                                                     child: Image.asset(
//                                                       'assets/images/verified.png',
//                                                       width: 15,
//                                                       height: 15,
//                                                     ),
//                                                   ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),

//                                         const SizedBox(height: 4),

//                                         Text(
//                                           obfuscateEmail(postEmail),
//                                           style: TextStyle(
//                                             fontSize: 11,
//                                             color: isDark
//                                                 ? Colors.grey
//                                                 : Colors.black54,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),

//                               const SizedBox(height: 14),

//                               /// ✅ IMAGE
//                               // if (data['imageUrl'] != null &&
//                               //     data['imageUrl'].toString().isNotEmpty)
//                               //   Padding(
//                               //     padding: const EdgeInsets.only(
//                               //       bottom: 14,
//                               //     ),
//                               //     child: GestureDetector(
//                               //       // onTap: () {
//                               //       //   Get.to(
//                               //       //     () => StatusImageViewScreen(
//                               //       //       statusDoc: doc,
//                               //       //     ),
//                               //       //     transition: Transition.cupertino,
//                               //       //   );
//                               //       // },
//                               //       onTap: () {
//                               //         Get.to(
//                               //           () => FullImageScreen(
//                               //             imageUrl: data['imageUrl'],
//                               //           ),
//                               //           transition: Transition.fadeIn,
//                               //         );
//                               //       },
//                               //       child: Stack(
//                               //         children: [
//                               //           ClipRRect(
//                               //             borderRadius: BorderRadius.circular(
//                               //               20,
//                               //             ),
//                               //             child: CachedNetworkImage(
//                               //               imageUrl: data['imageUrl'],
//                               //               width: double.infinity,
//                               //               height: 300,
//                               //               fit: BoxFit.cover,

//                               //               /// ✅ MEMORY FIX
//                               //               memCacheWidth: 500,
//                               //               memCacheHeight: 500,
//                               //               maxWidthDiskCache: 500,
//                               //               fadeInDuration: const Duration(
//                               //                 milliseconds: 250,
//                               //               ),

//                               //               placeholder: (
//                               //                 context,
//                               //                 url,
//                               //               ) =>
//                               //                   Container(
//                               //                 height: 300,
//                               //                 alignment: Alignment.center,
//                               //                 child: Text(
//                               //                   "loading...",
//                               //                   style: TextStyle(
//                               //                     fontStyle: FontStyle.italic,
//                               //                     color: isDark
//                               //                         ? Colors.white
//                               //                         : Colors.black,
//                               //                   ),
//                               //                 ),
//                               //               ),

//                               //               errorWidget: (
//                               //                 context,
//                               //                 url,
//                               //                 error,
//                               //               ) =>
//                               //                   Container(
//                               //                 height: 300,
//                               //                 alignment: Alignment.center,
//                               //                 child: const Text(
//                               //                   "failed to load",
//                               //                   style: TextStyle(
//                               //                     color: Colors.red,
//                               //                     fontStyle: FontStyle.italic,
//                               //                   ),
//                               //                 ),
//                               //               ),
//                               //             ),
//                               //           ),
//                               //           Positioned(
//                               //             right: 12,
//                               //             bottom: 12,
//                               //             child: Container(
//                               //               padding: const EdgeInsets.symmetric(
//                               //                 horizontal: 12,
//                               //                 vertical: 6,
//                               //               ),
//                               //               decoration: BoxDecoration(
//                               //                 color: isDark
//                               //                     ? Colors.black.withOpacity(
//                               //                         0.65,
//                               //                       )
//                               //                     : Colors.white.withOpacity(
//                               //                         0.90,
//                               //                       ),
//                               //                 borderRadius:
//                               //                     BorderRadius.circular(
//                               //                   14,
//                               //                 ),
//                               //               ),
//                               //               child: Text(
//                               //                 "Tap to View",
//                               //                 style: TextStyle(
//                               //                   fontSize: 12,
//                               //                   fontWeight: FontWeight.bold,
//                               //                   color: isDark
//                               //                       ? Colors.white
//                               //                       : Colors.black,
//                               //                 ),
//                               //               ),
//                               //             ),
//                               //           ),
//                               //         ],
//                               //       ),
//                               //     ),
//                               //   ),

//                               /// ===========================
//                               /// PREMIUM MEDIA SECTION
//                               /// ===========================
//                               if ((data['imageUrl'] ?? '')
//                                       .toString()
//                                       .isNotEmpty ||
//                                   (data['audioUrl'] ?? '')
//                                       .toString()
//                                       .isNotEmpty)
//                                 Padding(
//                                   padding: const EdgeInsets.only(bottom: 18),
//                                   // child: GestureDetector(
//                                   //   onTap: () {
//                                   //     if ((data['imageUrl'] ?? '')
//                                   //         .toString()
//                                   //         .isNotEmpty) {
//                                   //       Get.to(
//                                   //         () => FullImageScreen(
//                                   //           imageUrl: data['imageUrl'],
//                                   //         ),
//                                   //         transition: Transition.fadeIn,
//                                   //       );
//                                   //     }
//                                   //   },
//                                   child: Stack(
//                                     children: [
//                                       /// IMAGE
//                                       if ((data['imageUrl'] ?? '')
//                                           .toString()
//                                           .isNotEmpty)
//                                         Hero(
//                                           tag: data['imageUrl'],
//                                           child: ClipRRect(
//                                             borderRadius: BorderRadius.circular(
//                                               24,
//                                             ),
//                                             child: CachedNetworkImage(
//                                               imageUrl: data['imageUrl'],
//                                               width: double.infinity,
//                                               height: 320,
//                                               fit: BoxFit.cover,
//                                               memCacheWidth: 700,
//                                               memCacheHeight: 700,
//                                               maxWidthDiskCache: 700,
//                                               fadeInDuration: const Duration(
//                                                 milliseconds: 250,
//                                               ),
//                                               placeholder: (_, __) => Container(
//                                                 height: 320,
//                                                 color: isDark
//                                                     ? Colors.grey.shade900
//                                                     : Colors.grey.shade200,
//                                                 child: const Center(
//                                                   child:
//                                                       CircularProgressIndicator(),
//                                                 ),
//                                               ),
//                                               errorWidget: (_, __, ___) =>
//                                                   Container(
//                                                     height: 320,
//                                                     alignment: Alignment.center,
//                                                     child: const Icon(
//                                                       Icons
//                                                           .broken_image_outlined,
//                                                       size: 40,
//                                                     ),
//                                                   ),
//                                             ),
//                                           ),
//                                         ),

//                                       /// IMAGE OVERLAY
//                                       if ((data['imageUrl'] ?? '')
//                                           .toString()
//                                           .isNotEmpty)
//                                         Positioned.fill(
//                                           child: DecoratedBox(
//                                             decoration: BoxDecoration(
//                                               borderRadius:
//                                                   BorderRadius.circular(24),
//                                               gradient: LinearGradient(
//                                                 begin: Alignment.topCenter,
//                                                 end: Alignment.bottomCenter,
//                                                 colors: [
//                                                   Colors.transparent,
//                                                   Colors.black.withOpacity(.10),
//                                                   Colors.black.withOpacity(.55),
//                                                 ],
//                                               ),
//                                             ),
//                                           ),
//                                         ),

//                                       /// VOICE PLAYER
//                                       // if ((data['audioUrl'] ?? '')
//                                       //     .toString()
//                                       //     .isNotEmpty)
//                                       //   Positioned(
//                                       //     left: 18,
//                                       //     right: 18,
//                                       //     bottom: 18,
//                                       //     child: Container(
//                                       //       padding: const EdgeInsets.all(16),
//                                       //       decoration: BoxDecoration(
//                                       //         color:
//                                       //             Colors.white.withOpacity(.15),
//                                       //         borderRadius:
//                                       //             BorderRadius.circular(20),
//                                       //         border: Border.all(
//                                       //           color: Colors.white24,
//                                       //         ),
//                                       //       ),
//                                       //       child: Row(
//                                       //         children: [
//                                       //           Container(
//                                       //             width: 52,
//                                       //             height: 52,
//                                       //             decoration:
//                                       //                 const BoxDecoration(
//                                       //               color: Colors.white,
//                                       //               shape: BoxShape.circle,
//                                       //             ),
//                                       //             child: const Icon(
//                                       //               Icons.play_arrow_rounded,
//                                       //               color: Colors.black,
//                                       //               size: 30,
//                                       //             ),
//                                       //           ),
//                                       //           const SizedBox(width: 16),
//                                       //           Expanded(
//                                       //             child: Column(
//                                       //               crossAxisAlignment:
//                                       //                   CrossAxisAlignment
//                                       //                       .start,
//                                       //               children: [
//                                       //                 const Text(
//                                       //                   "Voice Note",
//                                       //                   style: TextStyle(
//                                       //                     color: Colors.white,
//                                       //                     fontWeight:
//                                       //                         FontWeight.bold,
//                                       //                     fontSize: 14,
//                                       //                   ),
//                                       //                 ),
//                                       //                 const SizedBox(height: 8),
//                                       //                 ClipRRect(
//                                       //                   borderRadius:
//                                       //                       BorderRadius
//                                       //                           .circular(100),
//                                       //                   child:
//                                       //                       LinearProgressIndicator(
//                                       //                     value: 0,
//                                       //                     minHeight: 4,
//                                       //                     backgroundColor:
//                                       //                         Colors.white24,
//                                       //                     valueColor:
//                                       //                         const AlwaysStoppedAnimation(
//                                       //                       Colors.white,
//                                       //                     ),
//                                       //                   ),
//                                       //                 ),
//                                       //                 const SizedBox(height: 8),
//                                       //                 Row(
//                                       //                   mainAxisAlignment:
//                                       //                       MainAxisAlignment
//                                       //                           .spaceBetween,
//                                       //                   children: const [
//                                       //                     Text(
//                                       //                       "00:00",
//                                       //                       style: TextStyle(
//                                       //                         color: Colors
//                                       //                             .white70,
//                                       //                         fontSize: 11,
//                                       //                       ),
//                                       //                     ),
//                                       //                     Text(
//                                       //                       "00:30",
//                                       //                       style: TextStyle(
//                                       //                         color: Colors
//                                       //                             .white70,
//                                       //                         fontSize: 11,
//                                       //                       ),
//                                       //                     ),
//                                       //                   ],
//                                       //                 ),
//                                       //               ],
//                                       //             ),
//                                       //           ),
//                                       //         ],
//                                       //       ),
//                                       //     ),
//                                       //   ),
//                                       /// VOICE PLAYER
//                                       if ((data['audioUrl'] ?? '')
//                                           .toString()
//                                           .isNotEmpty)
//                                         Positioned(
//                                           left: 18,
//                                           right: 18,
//                                           bottom: 18,
//                                           child: _VoiceNotePlayer(
//                                             audioUrl: data['audioUrl'],
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),

//                               /// ✅ TEXT
//                               // if (postText.toString().trim().isNotEmpty)
//                               //   RichText(
//                               //     text: TextSpan(
//                               //       children: _linkifyText(
//                               //         postText,
//                               //         isDark,
//                               //       ),
//                               //     ),
//                               //   ),
//                               if (postText.trim().isNotEmpty) ...[
//                                 Padding(
//                                   padding: const EdgeInsets.only(bottom: 16),
//                                   child: RichText(
//                                     text: TextSpan(
//                                       style: TextStyle(
//                                         fontSize: 15,
//                                         height: 1.6,
//                                         color: isDark
//                                             ? Colors.white
//                                             : Colors.black87,
//                                       ),
//                                       children: _linkifyText(postText, isDark),
//                                     ),
//                                   ),
//                                 ),
//                               ],

//                               const SizedBox(height: 14),

//                               /// ✅ ACTIONS
//                               Row(
//                                 children: [
//                                   /// ❤️ LIKE
//                                   InkWell(
//                                     borderRadius: BorderRadius.circular(30),
//                                     onTap: () {
//                                       statusCtrl.toggleLike(doc);
//                                     },
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           hasLiked
//                                               ? Icons.favorite
//                                               : Icons.favorite_border,
//                                           size: 24,
//                                           color: hasLiked
//                                               ? Colors.red
//                                               : Colors.grey,
//                                         ),
//                                         const SizedBox(width: 5),
//                                         Text(
//                                           '${likes.length}',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: isDark
//                                                 ? Colors.white
//                                                 : Colors.black,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),

//                                   const SizedBox(width: 22),

//                                   /// 💬 COMMENT
//                                   InkWell(
//                                     borderRadius: BorderRadius.circular(30),
//                                     onTap: () {
//                                       final currentUserName =
//                                           accountController.userName.value;

//                                       final currentUserEmail =
//                                           accountController.userEmail.value;

//                                       Get.to(
//                                         () => CommentScreen(
//                                           userName: currentUserName,
//                                           userEmail: currentUserEmail,
//                                           statusDoc: doc,
//                                         ),
//                                         transition: Transition.cupertino,
//                                       );
//                                     },
//                                     child: StreamBuilder<QuerySnapshot>(
//                                       stream: statusCtrl.commentStream(doc.id),
//                                       builder: (context, snapshot) {
//                                         final commentCount =
//                                             snapshot.data?.docs.length ?? 0;

//                                         return Row(
//                                           children: [
//                                             Icon(
//                                               Icons.comment_outlined,
//                                               size: 24,
//                                               color: isDark
//                                                   ? Colors.white
//                                                   : Colors.black,
//                                             ),
//                                             const SizedBox(width: 5),
//                                             Text(
//                                               '$commentCount',
//                                               style: TextStyle(
//                                                 fontSize: 12,
//                                                 color: isDark
//                                                     ? Colors.white
//                                                     : Colors.black,
//                                               ),
//                                             ),
//                                           ],
//                                         );
//                                       },
//                                     ),
//                                   ),

//                                   const SizedBox(width: 22),

//                                   /// 📋 COPY
//                                   InkWell(
//                                     borderRadius: BorderRadius.circular(30),
//                                     onTap: () {
//                                       statusCtrl.copyStatus(postText);
//                                     },
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           Icons.copy,
//                                           size: 22,
//                                           color: isDark
//                                               ? Colors.white
//                                               : Colors.black,
//                                         ),
//                                         const SizedBox(width: 5),
//                                         Text(
//                                           'Copy',
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             color: isDark
//                                                 ? Colors.white
//                                                 : Colors.black,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),

//                                   const Spacer(),

//                                   /// 🕒 TIME
//                                   Text(
//                                     postTime,
//                                     style: TextStyle(
//                                       fontSize: 11,
//                                       color: isDark
//                                           ? Colors.grey.shade400
//                                           : Colors.grey.shade600,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 }),
//               ),
//             ],
//           ),
//           bottomNavigationBar: Obx(() {
//             final isDark = themeCtrl.isDarkMode.value;

//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               decoration: BoxDecoration(
//                 color: isDark ? Colors.grey.shade900 : Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     blurRadius: 12,
//                     offset: const Offset(0, -4),
//                   ),
//                 ],
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(22),
//                   topRight: Radius.circular(22),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _bottomBarItem(
//                     icon: Icons.policy,
//                     label: 'Policy',
//                     isDark: isDark,
//                     onTap: () {
//                       // Get.to(() => StatusScreen(
//                       //       userName: accountController.userName.value,
//                       //       userEmail: accountController.userEmail.value,
//                       //     ));

//                       //Get.to(() => spiiiqRewardPolicyScreen());
//                       Get.toNamed('/policy');
//                     },
//                   ),
//                   // _bottomBarItem(
//                   //   icon: Icons.view_list,
//                   //   label: 'Channels',
//                   //   isDark: isDark,
//                   //   onTap: () {
//                   //     // Get.to(() => ChannelsScreen(
//                   //     //       userName: accountController.userName.value,
//                   //     //       userEmail: accountController.userEmail.value,
//                   //     //     ));
//                   //   },
//                   // ),
//                   // _bottomBarItem(
//                   //   icon: Icons.emoji_events,
//                   //   label: 'TSC',
//                   //   isDark: isDark,
//                   //   onTap: () {
//                   //     Get.to(() => Tsc(
//                   //           //SplendorsContest(
//                   //           userName: accountController.userName.value,
//                   //           userEmail: accountController.userEmail.value,
//                   //         ));
//                   //   },
//                   // ),
//                   _bottomBarItem(
//                     icon: Icons.add,
//                     label: 'Add Post',
//                     isDark: isDark,
//                     onTap: () {
//                       final currentUserName = accountController.userName.value;
//                       final currentUserEmail =
//                           accountController.userEmail.value;

//                       Get.to(
//                         () => AddStatus(
//                           userName: currentUserName,
//                           userEmail: currentUserEmail,
//                         ),
//                         transition: Transition.cupertino,
//                       );
//                     },
//                   ),
//                   _bottomBarItem(
//                     icon: Icons.person,
//                     label: 'Profile',
//                     isDark: isDark,
//                     onTap: () {
//                       //Get.to(() => const ProfileScreen());
//                       Get.toNamed('/profile');
//                     },
//                   ),
//                 ],
//               ),
//             );
//           }),
//         );
//       }),
//     );
//   }
// }

// // Widget _fabWithLabel({
// //   required String heroTag,
// //   required IconData icon,
// //   required String label,
// //   required bool isDark,
// //   required VoidCallback onPressed,
// // }) {
// //   return Column(
// //     mainAxisSize: MainAxisSize.min,
// //     children: [
// //       FloatingActionButton(
// //         heroTag: heroTag,
// //         backgroundColor: isDark ? Colors.white : Colors.black.withOpacity(0.65),
// //         onPressed: onPressed,
// //         child: Icon(
// //           icon,
// //           color: isDark ? Colors.black : Colors.white,
// //         ),
// //       ),
// //       const SizedBox(height: 6),
// //       Text(
// //         label,
// //         style: TextStyle(
// //           fontSize: 12,
// //           fontWeight: FontWeight.w500,
// //           color: isDark ? Colors.white : Colors.black,
// //         ),
// //       ),
// //     ],
// //   );
// // }

// Widget _bottomBarItem({
//   required IconData icon,
//   required String label,
//   required bool isDark,
//   required VoidCallback onTap,
// }) {
//   return InkWell(
//     borderRadius: BorderRadius.circular(14),
//     onTap: onTap,
//     child: Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 24, color: isDark ? Colors.white : Colors.black87),
//           const SizedBox(height: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w600,
//               color: isDark ? Colors.white70 : Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }

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
//       spans.add(
//         TextSpan(
//           text: text.substring(start, match.start),
//           style: TextStyle(
//             fontSize: 15,
//             height: 1.5,
//             color: isDark ? Colors.white : Colors.black,
//           ),
//         ),
//       );
//     }

//     String linkText = text.substring(match.start, match.end);

//     if (!linkText.startsWith(RegExp(r'https?:\/\/'))) {
//       linkText = 'https://$linkText';
//     }

//     spans.add(
//       TextSpan(
//         text: text.substring(match.start, match.end),
//         style: const TextStyle(
//           fontSize: 15,
//           color: Colors.blue,
//           fontStyle: FontStyle.italic,
//         ),
//         recognizer: TapGestureRecognizer()
//           ..onTap = () async {
//             final Uri url = Uri.parse(linkText);

//             if (await canLaunchUrl(url)) {
//               await launchUrl(url, mode: LaunchMode.externalApplication);
//             }
//           },
//       ),
//     );

//     start = match.end;
//   }

//   if (start < text.length) {
//     spans.add(
//       TextSpan(
//         text: text.substring(start),
//         style: TextStyle(
//           fontSize: 15,
//           height: 1.5,
//           color: isDark ? Colors.white : Colors.black,
//         ),
//       ),
//     );
//   }

//   return spans;
// }

// class FullImageScreen extends StatelessWidget {
//   final String imageUrl;

//   const FullImageScreen({super.key, required this.imageUrl});

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
//                 backgroundDecoration: const BoxDecoration(color: Colors.black),
//                 loadingBuilder: (context, event) {
//                   return const Center(
//                     child: CircularProgressIndicator(color: Colors.white),
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
//                   icon: const Icon(Icons.arrow_back, color: Colors.white),
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

// class _VoiceNotePlayer extends StatefulWidget {
//   final String audioUrl;
//   const _VoiceNotePlayer({required this.audioUrl});

//   @override
//   State<_VoiceNotePlayer> createState() => _VoiceNotePlayerState();
// }

// class _VoiceNotePlayerState extends State<_VoiceNotePlayer> {
//   late final AudioPlayer _player;

//   bool _isLoading = false;
//   bool _isPlaying = false;
//   Duration _duration = Duration.zero;
//   Duration _position = Duration.zero;

//   StreamSubscription<Duration>? _durationSub;
//   StreamSubscription<Duration>? _positionSub;
//   StreamSubscription<PlayerState>? _stateSub;

//   @override
//   void initState() {
//     super.initState();
//     _player = AudioPlayer();

//     _durationSub = _player.onDurationChanged.listen((d) {
//       if (mounted) setState(() => _duration = d);
//     });

//     _positionSub = _player.onPositionChanged.listen((p) {
//       if (mounted) setState(() => _position = p);
//     });

//     _stateSub = _player.onPlayerStateChanged.listen((state) {
//       if (!mounted) return;

//       setState(() => _isPlaying = state == PlayerState.playing);

//       if (state == PlayerState.completed) {
//         _player.seek(Duration.zero);

//         setState(() {
//           _isPlaying = false;
//           _position = Duration.zero;
//         });

//         GlobalAudioManager.clearIfCurrent(_pause);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _durationSub?.cancel();
//     _positionSub?.cancel();
//     _stateSub?.cancel();
//     GlobalAudioManager.clearIfCurrent(_pause);
//     _player.dispose();
//     super.dispose();
//   }

//   void _pause() {
//     _player.pause();
//     if (mounted) setState(() => _isPlaying = false);
//   }

//   Future<void> _togglePlay() async {
//     if (_isPlaying) {
//       GlobalAudioManager.clearIfCurrent(_pause);
//       await _player.pause();
//       return;
//     }

//     /// ✅ Pauses whatever other voice note is currently playing in the feed
//     GlobalAudioManager.requestPlay(_pause);

//     setState(() => _isLoading = true);

//     try {
//       await _player.play(UrlSource(widget.audioUrl));
//     } catch (e) {
//       if (kDebugMode) print('❌ Voice playback error: $e');
//       GlobalAudioManager.clearIfCurrent(_pause);
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   String _format(Duration d) {
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final double progress = _duration.inMilliseconds == 0
//         ? 0
//         : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(.15),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white24),
//       ),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: _togglePlay,
//             child: Container(
//               width: 52,
//               height: 52,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 shape: BoxShape.circle,
//               ),
//               child: _isLoading
//                   ? const Padding(
//                       padding: EdgeInsets.all(14),
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.black,
//                       ),
//                     )
//                   : Icon(
//                       _isPlaying ? Icons.pause : Icons.play_arrow_rounded,
//                       color: Colors.black,
//                       size: 30,
//                     ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   "Voice Note",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(100),
//                   child: LinearProgressIndicator(
//                     value: progress,
//                     minHeight: 4,
//                     backgroundColor: Colors.white24,
//                     valueColor: const AlwaysStoppedAnimation(Colors.white),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       _format(_position),
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 11,
//                       ),
//                     ),
//                     Text(
//                       _format(_duration),
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 11,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Ensures only one voice note plays at a time across the whole feed —
// /// starting a new one pauses whichever was previously playing.
// class GlobalAudioManager {
//   static VoidCallback? _pauseCurrent;

//   static void requestPlay(VoidCallback pauseThis) {
//     if (_pauseCurrent != null && _pauseCurrent != pauseThis) {
//       _pauseCurrent!.call();
//     }
//     _pauseCurrent = pauseThis;
//   }

//   static void clearIfCurrent(VoidCallback pauseThis) {
//     if (_pauseCurrent == pauseThis) _pauseCurrent = null;
//   }
// }

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:photo_view/photo_view.dart';
import 'package:spiiiq/controllers/account_controller.dart';
import 'package:spiiiq/controllers/ads_controller.dart';
import 'package:spiiiq/controllers/e_login_controller.dart';
import 'package:spiiiq/controllers/balance_controller.dart';
import 'package:spiiiq/controllers/chat_list_controller.dart';
import 'package:spiiiq/controllers/status_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:spiiiq/pages/add_status.dart';
import 'package:spiiiq/pages/chat_screen.dart';
import 'package:spiiiq/pages/comment_screen.dart';
import 'package:spiiiq/pages/pay_history.dart';
import 'package:spiiiq/pages/policy.dart';
import 'package:spiiiq/pages/profile.dart';
import 'package:spiiiq/pages/public_profile.dart';
import 'package:spiiiq/pages/status_screen.dart';
import 'package:spiiiq/pages/withdrawal_page.dart';
import 'package:spiiiq/widgets/report_reason_dialog.dart';
import 'package:spiiiq/widgets/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  final String userName;
  final String userEmail;

  const Home({super.key, required this.userName, required this.userEmail});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ChatListController controller = Get.put(ChatListController());
  final ThemeController themeCtrl = Get.put(ThemeController());
  final AccountController accountController = Get.put(AccountController());
  final IconNavigationHandler navigationHandler = IconNavigationHandler();
  // final CurrencyController currencyController = Get.put(CurrencyController());
  // final AddMoneyController addMoneyController = Get.find<AddMoneyController>();
  // final PbcMarketController pbcMarketController =
  //     Get.put(PbcMarketController());
  final AvailableBalanceController balanceCtrl = Get.put(
    AvailableBalanceController(),
  );
  final StatusController statusCtrl = Get.put(StatusController());
  final ScrollController _scrollController = ScrollController();
  final AdsController adsCtrl = Get.find<AdsController>();

  @override
  void initState() {
    super.initState();
    accountController.fetchUserInfo();

    ///accountController.fetchBalances();
    // accountController.fetchWalletAddress();
    //  accountController.toggleBalanceVisibility();
    // accountController.fetchWalletDetails();
    // accountController.fetchWalletData();
    // addMoneyController.fetchVaultBalance();

    // ever(addMoneyController.email, (String email) {
    //   if (email.isNotEmpty) {
    //     addMoneyController.fetchTransactions(email);
    //   }
    // });
  }

  String selectedCurrency = "\$ Dollar";

  String resolveDisplayName(String? name) {
    if (name == null) return 'Anonymous User';

    final cleaned = name.trim();
    if (cleaned.isEmpty || cleaned.toLowerCase() == 'unknown') {
      return 'Anonymous User';
    }

    return cleaned;
  }

  String resolveInitial(String displayName) {
    return displayName == 'Anonymous User' ? 'A' : displayName[0].toUpperCase();
  }

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

  /// ✅ Opens a post author's public profile by email.
  Future<void> _openUserProfile(String email) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('e-users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userDoc.docs.isEmpty) {
        Get.snackbar(
          'Anonymous user',
          'This profile did not back up their Seed Phrase',
          snackPosition: SnackPosition.BOTTOM,
        );

        return;
      }

      final userId = userDoc.docs.first.id;

      Get.to(
        () => PublicProfileScreen(userId: userId),
        transition: Transition.cupertino,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch user',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> openPrivacyPolicy() async {
    final Uri url = Uri.parse(
      'https://docs.google.com/document/d/e/2PACX-1vSn7x1FOwx60soMucPxEiDqGauOUNykgrYJ0eTvBYd1Os21knTZ6XYJVvDWpE1bc7VFZl8txM0ghTXV/pub',
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  // 🔹 Premium dropdown row used by the header three-dot menu.
  PopupMenuItem<String> _menuItem({
    required String value,
    required IconData icon,
    required String label,
    required bool isDark,
    Color? iconColor,
    Color? labelColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: iconColor ?? (isDark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: labelColor ?? (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Obx(() {
        final isDark = themeCtrl.isDarkMode.value;

        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0,
            titleSpacing: 0,
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 16),

                Container(
                  width: 46,
                  height: 46,
                  padding: const EdgeInsets.all(1.5), // Thin border spacing
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.30 : 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/spiiq Logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 12),
                // App name
                Text(
                  'SpiiiQ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),

                const Spacer(),

                // Menu — premium dropdown (same styling as HOMEo)
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: PopupMenuButton<String>(
                    tooltip: 'Menu',
                    color: isDark ? const Color(0xFF1C1F24) : Colors.white,
                    elevation: 10,
                    surfaceTintColor: Colors.transparent,
                    offset: const Offset(0, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(
                        color: isDark
                            ? Colors.white10
                            : Colors.black.withOpacity(0.05),
                      ),
                    ),
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    onSelected: (value) async {
                      switch (value) {
                        // case 'profile':
                        //   Get.to(() => const ProfileScreen());
                        //   break;
                        // case 'deeOracle':
                        //   Get.to(() => const DeeOracle());
                        //   break;
                        case 'about':
                          Get.to(() => spiiiqRewardPolicyScreen());
                          break;
                        case 'support':
                          final Uri waUrl = Uri.parse(
                            'https://wa.me/2349014078396',
                          );

                          try {
                            final launched = await launchUrl(
                              waUrl,
                              mode: LaunchMode.externalApplication,
                            );

                            if (!launched) {
                              Get.snackbar(
                                'Error',
                                'Could not open WhatsApp',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          } catch (e) {
                            Get.snackbar(
                              'Error',
                              'Could not open WhatsApp',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                          break;
                        case 'dark':
                          themeCtrl.setDark();
                          break;
                        case 'light':
                          themeCtrl.setLight();
                          break;
                        case 'logout':
                          Get.find<AuthController>().logout();
                          break;
                      }
                    },
                    itemBuilder: (_) => [
                      _menuItem(
                        value: 'about',
                        icon: Icons.card_giftcard_rounded,
                        label: 'About Us',
                        isDark: isDark,
                      ),
                      const PopupMenuDivider(height: 12),
                      _menuItem(
                        value: 'support',
                        icon: Icons.support_agent_rounded,
                        label: 'Support',
                        isDark: isDark,
                      ),
                      const PopupMenuDivider(height: 12),
                      _menuItem(
                        value: isDark ? 'light' : 'dark',
                        icon: isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        label: isDark ? 'Light Mode' : 'Dark Mode',
                        isDark: isDark,
                        iconColor: isDark ? Colors.amber : null,
                      ),
                      const PopupMenuDivider(height: 12),
                      _menuItem(
                        value: 'logout',
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        isDark: isDark,
                        iconColor: Colors.redAccent,
                        labelColor: Colors.redAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
              ],
            ),
          ),
          body: Column(
            children: [
              // 🔍 Search Bar
              // Padding(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              //   child: TextField(
              //     onChanged: (v) => controller.searchQuery.value = v,
              //     style:
              //         TextStyle(color: isDark ? Colors.white : Colors.black87),
              //     decoration: InputDecoration(
              //       hintText: 'Search posts...',
              //       prefixIcon: Icon(Icons.search,
              //           color: isDark ? Colors.white38 : Colors.black38),
              //       filled: true,
              //       fillColor:
              //           isDark ? Colors.grey.shade900 : Colors.grey.shade200,
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(14),
              //         borderSide: BorderSide.none,
              //       ),
              //     ),
              //   ),
              // ),

              // Padding(
              //   padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              //       borderRadius: BorderRadius.circular(18),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withOpacity(0.05),
              //           blurRadius: 10,
              //           offset: const Offset(0, 4),
              //         ),
              //       ],
              //     ),
              //     child: TextField(
              //       onChanged: (value) {
              //         statusCtrl.searchQuery.value = value;
              //       },
              //       style: TextStyle(
              //         color: isDark ? Colors.white : Colors.black,
              //         fontSize: 14,
              //       ),
              //       decoration: InputDecoration(
              //         hintText: 'Search post by user',
              //         hintStyle: TextStyle(
              //           color: isDark ? Colors.grey : Colors.black54,
              //         ),
              //         prefixIcon: Icon(
              //           Icons.search_rounded,
              //           color: isDark ? Colors.white70 : Colors.black54,
              //         ),
              //         filled: true,
              //         fillColor: Colors.transparent,
              //         border: OutlineInputBorder(
              //           borderRadius: BorderRadius.circular(18),
              //           borderSide: BorderSide.none,
              //         ),
              //         contentPadding: const EdgeInsets.symmetric(vertical: 14),
              //       ),
              //     ),
              //   ),
              // ),
              Divider(
                height: 1,
                thickness: 0.5,
                color: isDark ? Colors.white12 : Colors.black12,
              ),

              /// ✅ POSTS
              Expanded(
                child: Obx(() {
                  final posts = statusCtrl.paginatedStatuses;

                  if (posts.isEmpty) {
                    return Center(
                      child: Text(
                        'Loading Posts.....',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    );
                  }

                  /// 📢 Interleave a sponsored ad slot after every 5 real
                  /// posts. `adsCtrl.ads` is reactive, so wrapping this in
                  /// the same Obx keeps it live as ads are added/removed.
                  final items = _buildFeedItems(posts);

                  return ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    cacheExtent: 1200,
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                    itemCount: posts.length + 1,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    itemBuilder: (context, index) {
                      /// ✅ LOAD MORE
                      if (index == posts.length) {
                        final canLoadMore =
                            posts.length >= statusCtrl.visibleCount.value &&
                            statusCtrl.visibleCount.value < statusCtrl.maxLimit;

                        if (!canLoadMore) {
                          return const SizedBox.shrink();
                        }

                        return Obx(() {
                          if (statusCtrl.isLoadingMore.value) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 22),
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                  ),
                                ),
                              ),
                            );
                          }

                          final showMoreButton = InkWell(
                            onTap: statusCtrl.loadMore,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: isDark
                                        ? Colors.white12
                                        : Colors.black12,
                                    width: 0.6,
                                  ),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Show more posts",
                                  style: TextStyle(
                                    color: const Color(0xFF1D9BF0),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              showMoreButton,
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 14,
                                  bottom: 24,
                                ),
                                child: Text(
                                  "Powered by AFIA SPLENDID LTD",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.6,
                                    color: isDark
                                        ? Colors.white38
                                        : Colors.black38,
                                  ),
                                ),
                              ),
                            ],
                          );
                        });
                      }

                      final item = items[index];

                      /// 📢 SPONSORED CARD
                      if (item is _SponsoredSlot) {
                        return _buildSponsoredCard(isDark, item.slot);
                      }

                      final doc = posts[index];

                      final data = doc.data() as Map<String, dynamic>;

                      final postText = data['text'] ?? '';

                      final postName = resolveDisplayName(data['name']);

                      final postEmail = data['email'] ?? '';

                      final likes = List<String>.from(data['likes'] ?? []);

                      final postInitial = postName == 'Anonymous User'
                          ? 'A'
                          : postName[0].toUpperCase();

                      final currentUid =
                          Get.find<AuthController>().currentUser?.uid;

                      final hasLiked =
                          currentUid != null && likes.contains(currentUid);

                      final Timestamp? timestamp = data['timestamp'];

                      final postTime = statusCtrl.formatPostTime(timestamp);

                      final imageUrl = (data['imageUrl'] ?? '').toString();

                      return RepaintBoundary(
                        child: InkWell(
                          onTap: () {
                            Get.to(
                              () => CommentScreen(
                                userName: accountController.userName.value,
                                userEmail: accountController.userEmail.value,
                                statusDoc: doc,
                              ),
                              transition: Transition.cupertino,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isDark
                                      ? Colors.white12
                                      : Colors.black12,
                                  width: 0.6,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// ✅ AVATAR
                                FutureBuilder<String?>(
                                  future: statusCtrl.fetchStatusUserAvatarName(
                                    postEmail,
                                  ),
                                  builder: (context, snapshot) {
                                    final avatarName = statusCtrl
                                        .getCachedAvatar(postEmail);

                                    return GestureDetector(
                                      onTap: () => _openUserProfile(postEmail),
                                      child: CircleAvatar(
                                        radius: 21,
                                        backgroundColor: Colors.white,
                                        backgroundImage:
                                            (avatarName != null &&
                                                avatarName.isNotEmpty)
                                            ? AssetImage(
                                                'assets/images/$avatarName.png',
                                              )
                                            : null,
                                        child:
                                            (avatarName == null ||
                                                avatarName.isEmpty)
                                            ? Text(
                                                postInitial,
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : null,
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// ✅ NAME · HANDLE · TIME
                                      GestureDetector(
                                        onTap: () =>
                                            _openUserProfile(postEmail),
                                        behavior: HitTestBehavior.opaque,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                postName,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),
                                            if (statusCtrl.getCachedVerified(
                                              postEmail,
                                            ))
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 3,
                                                ),
                                                child: Image.asset(
                                                  'assets/images/verified.png',
                                                  width: 15,
                                                  height: 15,
                                                ),
                                              ),
                                            //const SizedBox(width: 5),
                                            Spacer(),
                                            Text(
                                              'SpiiiQ',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark
                                                    ? Colors.grey.shade500
                                                    : Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      /// ✅ TEXT
                                      if (postText
                                          .toString()
                                          .trim()
                                          .isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 15,
                                              height: 1.4,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black87,
                                            ),
                                            children: _linkifyText(
                                              postText,
                                              isDark,
                                            ),
                                          ),
                                        ),
                                      ],

                                      /// ✅ MEDIA
                                      if (imageUrl.isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        GestureDetector(
                                          onTap: () {
                                            Get.to(
                                              () => FullImageScreen(
                                                imageUrl: imageUrl,
                                              ),
                                              transition: Transition.fadeIn,
                                            );
                                          },
                                          child: Hero(
                                            tag: imageUrl,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                memCacheWidth: 700,
                                                memCacheHeight: 700,
                                                maxWidthDiskCache: 700,
                                                fadeInDuration: const Duration(
                                                  milliseconds: 200,
                                                ),
                                                placeholder: (_, __) =>
                                                    Container(
                                                      height: 220,
                                                      color: isDark
                                                          ? Colors.grey.shade900
                                                          : Colors
                                                                .grey
                                                                .shade200,
                                                      child: const Center(
                                                        child: Text(
                                                          "loading",
                                                          style: TextStyle(
                                                            color:
                                                                Colors.blueGrey,
                                                            fontStyle: FontStyle
                                                                .italic,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                errorWidget: (_, __, ___) =>
                                                    Container(
                                                      height: 220,
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Icon(
                                                        Icons
                                                            .broken_image_outlined,
                                                        size: 40,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 10),

                                      /// ✅ ACTIONS
                                      Row(
                                        children: [
                                          /// 💬 REPLY / COMMENT
                                          InkWell(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            onTap: () {
                                              Get.to(
                                                () => CommentScreen(
                                                  userName: accountController
                                                      .userName
                                                      .value,
                                                  userEmail: accountController
                                                      .userEmail
                                                      .value,
                                                  statusDoc: doc,
                                                ),
                                                transition:
                                                    Transition.cupertino,
                                              );
                                            },
                                            child: StreamBuilder<QuerySnapshot>(
                                              stream: statusCtrl.commentStream(
                                                doc.id,
                                              ),
                                              builder: (context, snapshot) {
                                                final commentCount =
                                                    snapshot
                                                        .data
                                                        ?.docs
                                                        .length ??
                                                    0;

                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                        horizontal: 4,
                                                      ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .chat_bubble_outline,
                                                        size: 18,
                                                        color: isDark
                                                            ? Colors
                                                                  .grey
                                                                  .shade400
                                                            : Colors
                                                                  .grey
                                                                  .shade700,
                                                      ),
                                                      if (commentCount > 0) ...[
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          '$commentCount',
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            color: isDark
                                                                ? Colors
                                                                      .grey
                                                                      .shade400
                                                                : Colors
                                                                      .grey
                                                                      .shade700,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),

                                          const SizedBox(width: 24),

                                          /// ❤️ LIKE
                                          InkWell(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            onTap: () {
                                              statusCtrl.toggleLike(doc);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                    horizontal: 4,
                                                  ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    hasLiked
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    size: 18,
                                                    color: hasLiked
                                                        ? const Color(
                                                            0xFFF91880,
                                                          )
                                                        : (isDark
                                                              ? Colors
                                                                    .grey
                                                                    .shade400
                                                              : Colors
                                                                    .grey
                                                                    .shade700),
                                                  ),
                                                  if (likes.isNotEmpty) ...[
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      '${likes.length}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: hasLiked
                                                            ? const Color(
                                                                0xFFF91880,
                                                              )
                                                            : (isDark
                                                                  ? Colors
                                                                        .grey
                                                                        .shade400
                                                                  : Colors
                                                                        .grey
                                                                        .shade700),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),

                                          const SizedBox(width: 24),

                                          /// 🚩 FLAG / REPORT
                                          InkWell(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            onTap: () {
                                              ReportReasonDialog.show(
                                                context: context,
                                                title: 'Report this post',
                                                reasons: kFlagPostReasons,
                                                confirmLabel: 'Report Post',
                                                onConfirm: (reason) async {
                                                  await statusCtrl
                                                      .flagPostAction(
                                                        doc: doc,
                                                        postText: postText,
                                                        postEmail: postEmail,
                                                        postName: postName,
                                                        reason: reason,
                                                      );
                                                  Get.snackbar(
                                                    'Reported',
                                                    'This post has been flagged successfully',
                                                    snackPosition:
                                                        SnackPosition.BOTTOM,
                                                    backgroundColor: isDark
                                                        ? Colors.grey.shade900
                                                        : Colors.white,
                                                    colorText: isDark
                                                        ? Colors.white
                                                        : Colors.black,
                                                  );
                                                },
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.flag_outlined,
                                                  size: 18,
                                                  color: isDark
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade700,
                                                ),
                                                const SizedBox(width: 5),
                                                // Text('Flag',
                                                //     style: TextStyle(
                                                //         fontSize: 12,
                                                //         color: isDark
                                                //             ? Colors.white
                                                //             : Colors.black)),
                                              ],
                                            ),
                                          ),

                                          const SizedBox(width: 24),

                                          /// 🕒 TIME
                                          Text(
                                            postTime,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade600,
                                            ),
                                          ),

                                          const Spacer(),

                                          /// 📋 SHARE / COPY
                                          InkWell(
                                            borderRadius: BorderRadius.circular(
                                              30,
                                            ),
                                            onTap: () {
                                              statusCtrl.copyStatus(postText);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 4,
                                                    horizontal: 4,
                                                  ),
                                              child: Icon(
                                                Icons.ios_share_outlined,
                                                size: 17,
                                                color: isDark
                                                    ? Colors.grey.shade400
                                                    : Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
          bottomNavigationBar: Obx(() {
            final isDark = themeCtrl.isDarkMode.value;

            return SafeArea(
              top: false,
              child: Padding(
                // keeps every side away from the screen edges
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.white,
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                      width: 0.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
                        blurRadius: 24,
                        spreadRadius: 1,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _bottomBarItem(
                        icon: Icons.policy,
                        label: 'Policy',
                        isDark: isDark,
                        onTap: () {
                          // Get.to(() => StatusScreen(
                          //       userName: accountController.userName.value,
                          //       userEmail: accountController.userEmail.value,
                          //     ));

                          //Get.to(() => spiiiqRewardPolicyScreen());
                          openPrivacyPolicy();
                        },
                      ),
                      // _bottomBarItem(
                      //   icon: Icons.view_list,
                      //   label: 'Channels',
                      //   isDark: isDark,
                      //   onTap: () {
                      //     // Get.to(() => ChannelsScreen(
                      //     //       userName: accountController.userName.value,
                      //     //       userEmail: accountController.userEmail.value,
                      //     //     ));
                      //   },
                      // ),
                      // _bottomBarItem(
                      //   icon: Icons.emoji_events,
                      //   label: 'TSC',
                      //   isDark: isDark,
                      //   onTap: () {
                      //     Get.to(() => Tsc(
                      //           //SplendorsContest(
                      //           userName: accountController.userName.value,
                      //           userEmail: accountController.userEmail.value,
                      //         ));
                      //   },
                      // ),
                      _bottomBarItem(
                        icon: Icons.add,
                        label: 'Add Post',
                        isDark: isDark,
                        onTap: () {
                          final currentUserName =
                              accountController.userName.value;
                          final currentUserEmail =
                              accountController.userEmail.value;

                          Get.to(
                            () => AddStatus(
                              userName: currentUserName,
                              userEmail: currentUserEmail,
                            ),
                            transition: Transition.cupertino,
                          );
                        },
                      ),
                      _bottomBarItem(
                        icon: Icons.person,
                        label: 'Profile',
                        isDark: isDark,
                        onTap: () {
                          //Get.to(() => const ProfileScreen());
                          Get.toNamed('/profile');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  /// 📢 SPONSORED CARD
  ///
  /// Same row/divider layout as a normal post — a Container with vertical
  /// padding and a bottom border, no background fill, no rounded card, no
  /// shadow — so it sits in the feed like any other post. Pulls from
  /// `adsCtrl.ads` — no like/comment affordances, no post restrictions on
  /// the ad side, just a campaign "avatar", title + description with
  /// clickable links, and a "Sponsored" tag in place of the name/handle row.
  Widget _buildSponsoredCard(bool isDark, int slot) {
    return Obx(() {
      final ad = adsCtrl.adForSlot(slot);

      if (ad == null) return const SizedBox.shrink();

      final adId = ad['id'] as String?;
      final title = (ad['title'] ?? '').toString();
      final description = (ad['description'] ?? '').toString();

      return RepaintBoundary(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white12 : Colors.black12,
                width: 0.6,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 "AVATAR" — campaign icon in place of a profile photo
              CircleAvatar(
                radius: 21,
                backgroundColor: isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
                child: Icon(
                  Icons.campaign_rounded,
                  size: 20,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 🔹 SPONSORED TAG — sits where the name/handle row
                    /// does on a normal post.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Sponsored',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),

                    /// 🔹 TITLE
                    if (title.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],

                    /// 🔹 DESCRIPTION — clickable links, rewards the ad
                    /// owner's link on tap via
                    /// AdsController.handleAdLinkClickReward.
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          children: _linkifySponsoredText(
                            description,
                            isDark,
                            adId,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// 📢 Marks a sponsored-ad slot in the interleaved feed list built by
/// `_buildFeedItems`. `slot` increments each time one is inserted, so
/// consecutive sponsored slots rotate through every live ad in order.
class _SponsoredSlot {
  final int slot;
  const _SponsoredSlot(this.slot);
}

/// 🔹 Builds the feed's display list: every real post, with a
/// `_SponsoredSlot` marker inserted after every 5th post.
List<dynamic> _buildFeedItems(List<DocumentSnapshot> posts) {
  final items = <dynamic>[];
  int slot = 0;

  for (int i = 0; i < posts.length; i++) {
    items.add(posts[i]);
    if ((i + 1) % 5 == 0) {
      items.add(_SponsoredSlot(slot));
      slot++;
    }
  }

  return items;
}

/// 🔹 Same link-detection as `_linkifyText`, but for sponsored-ad text:
/// tapping a link also rewards the ad owner once per ad via
/// `AdsController.handleAdLinkClickReward`.
List<TextSpan> _linkifySponsoredText(String text, bool isDark, String? adId) {
  final RegExp linkRegex = RegExp(
    r'((https?:\/\/|www\.)\S+|\S+\.com)',
    caseSensitive: false,
  );

  final List<TextSpan> spans = [];

  final matches = linkRegex.allMatches(text);

  int start = 0;

  for (final match in matches) {
    if (match.start > start) {
      spans.add(
        TextSpan(
          text: text.substring(start, match.start),
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    String linkText = text.substring(match.start, match.end);

    if (!linkText.startsWith(RegExp(r'https?:\/\/'))) {
      linkText = 'https://$linkText';
    }

    spans.add(
      TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(
          fontSize: 15,
          color: Colors.blue,
          fontStyle: FontStyle.italic,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final Uri url = Uri.parse(linkText);

            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);

              if (adId != null) {
                await Get.find<AdsController>().handleAdLinkClickReward(adId);
              }
            }
          },
      ),
    );

    start = match.end;
  }

  if (start < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(start),
        style: TextStyle(
          fontSize: 15,
          height: 1.5,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  return spans;
}

// Widget _fabWithLabel({
//   required String heroTag,
//   required IconData icon,
//   required String label,
//   required bool isDark,
//   required VoidCallback onPressed,
// }) {
//   return Column(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       FloatingActionButton(
//         heroTag: heroTag,
//         backgroundColor: isDark ? Colors.white : Colors.black.withOpacity(0.65),
//         onPressed: onPressed,
//         child: Icon(
//           icon,
//           color: isDark ? Colors.black : Colors.white,
//         ),
//       ),
//       const SizedBox(height: 6),
//       Text(
//         label,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w500,
//           color: isDark ? Colors.white : Colors.black,
//         ),
//       ),
//     ],
//   );
// }

Widget _bottomBarItem({
  required IconData icon,
  required String label,
  required bool isDark,
  required VoidCallback onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: isDark ? Colors.white : Colors.black87),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    ),
  );
}

List<TextSpan> _linkifyText(String text, bool isDark) {
  final RegExp linkRegex = RegExp(
    r'((https?:\/\/|www\.)\S+|\S+\.com)',
    caseSensitive: false,
  );

  final List<TextSpan> spans = [];

  final matches = linkRegex.allMatches(text);

  int start = 0;

  for (final match in matches) {
    if (match.start > start) {
      spans.add(
        TextSpan(
          text: text.substring(start, match.start),
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    String linkText = text.substring(match.start, match.end);

    if (!linkText.startsWith(RegExp(r'https?:\/\/'))) {
      linkText = 'https://$linkText';
    }

    spans.add(
      TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(
          fontSize: 15,
          color: Colors.blue,
          fontStyle: FontStyle.italic,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final Uri url = Uri.parse(linkText);

            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
      ),
    );

    start = match.end;
  }

  if (start < text.length) {
    spans.add(
      TextSpan(
        text: text.substring(start),
        style: TextStyle(
          fontSize: 15,
          height: 1.5,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  return spans;
}

class FullImageScreen extends StatelessWidget {
  final String imageUrl;

  const FullImageScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: PhotoView(
                imageProvider: CachedNetworkImageProvider(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                loadingBuilder: (context, event) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
              ),
            ),
            Positioned(
              top: 15,
              left: 10,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
