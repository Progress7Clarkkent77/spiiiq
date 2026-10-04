import 'package:spiiiq/controllers/account_controller.dart';

import 'package:spiiiq/controllers/e_login_controller.dart';

import 'package:spiiiq/controllers/chat_list_controller.dart';
import 'package:spiiiq/controllers/status_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:spiiiq/pages/add_status.dart';
import 'package:spiiiq/pages/comment_screen.dart';
import 'package:spiiiq/pages/public_profile.dart';
import 'package:spiiiq/pages/referral_screen.dart';
import 'package:spiiiq/widgets/report_reason_dialog.dart';
import 'package:spiiiq/widgets/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

// class StatusScreen extends StatefulWidget {
//   final String userName;
//   final String userEmail;

//   const StatusScreen({
//     super.key,
//     required this.userName,
//     required this.userEmail,
//   });

//   @override
//   State<StatusScreen> createState() => _StatusScreenState();
// }

// class _StatusScreenState extends State<StatusScreen> {
//   final ChatListController controller = Get.put(ChatListController());

//   final ThemeController themeCtrl = Get.put(ThemeController());

//   final AccountController accountController = Get.put(AccountController());
//   final IconNavigationHandler navigationHandler = IconNavigationHandler();
//   // final CurrencyController currencyController = Get.put(CurrencyController());
//   // final AddMoneyController addMoneyController = Get.find<AddMoneyController>();
//   // final PbcMarketController pbcMarketController =
//   //     Get.put(PbcMarketController());

//   /// 🔹 Obfuscate email
//   String obfuscateEmail(String email) {
//     final parts = email.split('@');
//     if (parts.isEmpty) return email;

//     final name = parts[0];
//     final domain = parts.length > 1 ? '@${parts[1]}' : '';

//     if (name.length <= 4) {
//       // If too short, just show first letter + dots + last letter
//       final first = name.substring(0, 1);
//       final last = name.length > 1 ? name.substring(name.length - 1) : '';
//       return '$first....$last$domain';
//     }

//     final firstTwo = name.substring(0, 2);
//     final lastTwo = name.substring(name.length - 2);
//     return '$firstTwo....$lastTwo$domain';
//   }

//   @override
//   void initState() {
//     super.initState();
//     accountController.fetchUserInfo();
//     // accountController.fetchBalances(); // Fetch data on widget load
//     // accountController.fetchWalletAddress(); // Fetch wallet address on init
//     // accountController.toggleBalanceVisibility();
//     // accountController.fetchWalletDetails();
//     // accountController
//     //     .fetchWalletAddress(); // Fetch wallet address on initialization
//     // accountController
//     //     .fetchWalletData(); // Fetch both address & publicKey on init
//     // addMoneyController.fetchVaultBalance();

//     // Watch for email availability and fetch transactions once it's ready
//     // ever(addMoneyController.email, (String email) {
//     //   if (email.isNotEmpty) {
//     //     addMoneyController.fetchTransactions(email);
//     //   }
//     // });
//   }

//   String resolveDisplayName(String? name) {
//     if (name == null) return 'Anonymous User';

//     final cleaned = name.trim();

//     if (cleaned.isEmpty || cleaned.toLowerCase() == 'unknown') {
//       return 'Anonymous User';
//     }

//     return cleaned;
//   }

//   //Hey this is My first post
//   @override
//   Widget build(BuildContext context) {
//     final ThemeController themeCtrl = Get.find<ThemeController>();
//     final StatusController statusCtrl = Get.put(StatusController());
//     // final TextEditingController inputCtrl = TextEditingController();

//     // final userInitial =
//     //     widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?';

//     return Obx(() {
//       final isDark = themeCtrl.isDarkMode.value;

//       return Scaffold(
//         backgroundColor: isDark ? Colors.black : Colors.white,
//         // appBar: AppBar(
//         //   backgroundColor: isDark ? Colors.black : Colors.white,
//         //   elevation: 0,
//         //   iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
//         //   title: Text(
//         //     'Updates',
//         //     style: TextStyle(
//         //       color: isDark ? Colors.white : Colors.black,
//         //       fontWeight: FontWeight.bold,
//         //     ),
//         //   ),
//         // ),
//         appBar: AppBar(
//           backgroundColor: isDark ? Colors.black : Colors.white,
//           elevation: 0,
//           iconTheme: IconThemeData(
//             color: isDark ? Colors.white : Colors.black,
//           ),
//           title: Text(
//             'Updates',
//             style: TextStyle(
//               color: isDark ? Colors.white : Colors.black,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 final currentUserName = accountController.userName.value;
//                 final currentUserEmail = accountController.userEmail.value;

//                 Get.to(() => ReferScreen(
//                       userName: currentUserName,
//                       userEmail: currentUserEmail,
//                     ));
//               },
//               style: TextButton.styleFrom(
//                 foregroundColor: isDark ? Colors.white : Colors.black,
//                 textStyle: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 14,
//                 ),
//               ),
//               child: const Text('Refer'),
//             ),
//             const SizedBox(width: 8),
//           ],
//         ),

//         body: Column(
//           children: [
//             /// 🔍 SEARCH BAR
//             Padding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
//               child: TextField(
//                 onChanged: (value) => statusCtrl.searchQuery.value = value,
//                 style: TextStyle(color: isDark ? Colors.white : Colors.black),
//                 decoration: InputDecoration(
//                   hintText: 'Search post by user',
//                   hintStyle:
//                       TextStyle(color: isDark ? Colors.grey : Colors.black54),
//                   prefixIcon: Icon(Icons.search,
//                       color: isDark ? Colors.white : Colors.black54),
//                   filled: true,
//                   fillColor:
//                       isDark ? Colors.grey.shade900 : Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//             ),

//             Divider(
//               height: 1,
//               thickness: 0.6,
//               color: isDark ? Colors.white24 : Colors.black12,
//             ),

//             /// 🔹 POSTS LIST
//             Expanded(
//               child: Obx(() {
//                 // final posts = statusCtrl.filteredStatuses;
//                 final posts = statusCtrl.paginatedStatuses;

//                 if (posts.isEmpty) {
//                   return Center(
//                     child: Text(
//                       'No statuses yet',
//                       style: TextStyle(
//                           color: isDark ? Colors.white : Colors.black),
//                     ),
//                   );
//                 }

//                 return ListView.builder(
//                   cacheExtent: 500,
//                   addAutomaticKeepAlives: false,
//                   addRepaintBoundaries: true,
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   //itemCount: posts.length,
//                   itemCount: posts.length + 1,
//                   itemBuilder: (context, index) {
//                     /// ✅ LOAD MORE BUTTON (PUT YOUR CODE 1 HERE)
//                     if (index == posts.length) {
//                       final canLoadMore = posts.length >=
//                               statusCtrl.visibleCount.value &&
//                           statusCtrl.visibleCount.value < statusCtrl.maxLimit;

//                       if (!canLoadMore) return const SizedBox.shrink();

//                       return Obx(() {
//                         if (statusCtrl.isLoadingMore.value) {
//                           return Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             child: Center(
//                               child: Text(
//                                 "loading...",
//                                 style: TextStyle(
//                                   fontStyle: FontStyle.italic,
//                                   color: isDark ? Colors.white : Colors.black,
//                                 ),
//                               ),
//                             ),
//                           );
//                         }

//                         return Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           child: Center(
//                             child: TextButton.icon(
//                               onPressed: statusCtrl.loadMore,
//                               icon: Icon(
//                                 Icons.keyboard_arrow_down,
//                                 color: isDark ? Colors.white : Colors.black,
//                               ),
//                               label: Text(
//                                 "Load more",
//                                 style: TextStyle(
//                                   color: isDark ? Colors.white : Colors.black,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       });
//                     }
//                     final data = posts[index].data() as Map<String, dynamic>;
//                     final postText = data['text'] ?? '';
//                     //final postName = data['name'] ?? '';
//                     final postName = resolveDisplayName(data['name']);
//                     final postEmail = data['email'] ?? '';
//                     final likes = List<String>.from(data['likes'] ?? []);
//                     // final postInitial =
//                     //     postName.isNotEmpty ? postName[0].toUpperCase() : '?';
//                     final postInitial = postName == 'Anonymous User'
//                         ? 'A'
//                         : postName[0].toUpperCase();

//                     // final hasLiked = likes.contains(
//                     //     Get.find<AuthController>().currentUser?.email);

//                     final currentUid =
//                         Get.find<AuthController>().currentUser?.uid;

//                     final hasLiked =
//                         currentUid != null && likes.contains(currentUid);

//                     final Timestamp? timestamp = data['timestamp'];
//                     final postTime = statusCtrl.formatPostTime(timestamp);

//                     return GestureDetector(
//                       onDoubleTap: () {
//                         statusCtrl.toggleLike(posts[index]);
//                       },
//                       child: Container(
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
//                             Row(
//                               children: [
//                                 FutureBuilder<String?>(
//                                   future: statusCtrl
//                                       .fetchStatusUserAvatarName(postEmail),
//                                   builder: (context, snapshot) {
//                                     final avatarName = snapshot.data;

//                                     return GestureDetector(
//                                       onTap: () async {
//                                         try {
//                                           // Fetch UID by email from Firestore or your users collection
//                                           final userDoc = await FirebaseFirestore
//                                               .instance
//                                               .collection(
//                                                   'e-users') // replace with your users collection
//                                               .where('email',
//                                                   isEqualTo: postEmail)
//                                               .limit(1)
//                                               .get();

//                                           if (userDoc.docs.isEmpty) {
//                                             Get.snackbar('Anonymous user',
//                                                 'This profile did not back up their Seed Phrase',
//                                                 snackPosition:
//                                                     SnackPosition.BOTTOM);
//                                             return;
//                                           }

//                                           // if (postName == 'Anonymous User') {
//                                           //   Get.snackbar(
//                                           //     'Anonymous user',
//                                           //     'This profile did not back up Seed Phrase',
//                                           //     snackPosition: SnackPosition.BOTTOM,
//                                           //   );
//                                           //   return;
//                                           // }

//                                           final userId = userDoc
//                                               .docs.first.id; // This is the UID

//                                           // Navigate to profile with correct UID
//                                           Get.to(() => PublicProfileScreen(
//                                               userId: userId));
//                                         } catch (e) {
//                                           Get.snackbar(
//                                               'Error', 'Failed to fetch user',
//                                               snackPosition:
//                                                   SnackPosition.BOTTOM);
//                                         }
//                                       },
//                                       child: CircleAvatar(
//                                         radius: 14,
//                                         backgroundColor: Colors.white,
//                                         backgroundImage: (avatarName != null &&
//                                                 avatarName.isNotEmpty)
//                                             ? AssetImage(
//                                                 'assets/images/$avatarName.png')
//                                             : null,
//                                         child: (avatarName == null ||
//                                                 avatarName.isEmpty)
//                                             ? Text(
//                                                 postInitial,
//                                                 style: const TextStyle(
//                                                   color: Colors.black,
//                                                   fontSize: 12,
//                                                   fontWeight: FontWeight.bold,
//                                                 ),
//                                               )
//                                             : null,
//                                       ),
//                                     );
//                                   },
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Text(
//                                           postName,
//                                           style: TextStyle(
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.w600,
//                                             color: isDark
//                                                 ? Colors.white
//                                                 : Colors.black,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 4),

//                                         /// ✅ VERIFIED BADGE
//                                         FutureBuilder<bool>(
//                                           future: statusCtrl
//                                               .isUserVerifiedByEmail(postEmail),
//                                           builder: (context, snapshot) {
//                                             if (snapshot.data == true) {
//                                               return Image.asset(
//                                                 'assets/images/verified.png',
//                                                 width: 14,
//                                                 height: 14,
//                                               );
//                                             }
//                                             return const SizedBox.shrink();
//                                           },
//                                         ),
//                                       ],
//                                     ),
//                                     Text(
//                                       obfuscateEmail(postEmail),
//                                       style: TextStyle(
//                                         fontSize: 11,
//                                         color: isDark
//                                             ? Colors.grey
//                                             : Colors.black54,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             // Text(
//                             //   postText,
//                             //   style: TextStyle(
//                             //       fontSize: 14,
//                             //       color: isDark ? Colors.white : Colors.black),
//                             // ),
//                             // RichText(
//                             //   text: TextSpan(
//                             //     children: _linkifyText(postText, isDark),
//                             //   ),
//                             // ),

//                             /// 🖼️ STATUS IMAGE
//                             // if (data['imageUrl'] != null &&
//                             //     data['imageUrl'].toString().isNotEmpty)
//                             //   Padding(
//                             //     padding: const EdgeInsets.only(bottom: 8),
//                             //     child: ClipRRect(
//                             //       borderRadius: BorderRadius.circular(12),
//                             //       child: Image.network(
//                             //         data['imageUrl'],
//                             //         width: double.infinity,
//                             //         height: 320,
//                             //         fit: BoxFit.cover,
//                             //         loadingBuilder: (context, child, progress) {
//                             //           if (progress == null) return child;
//                             //           return Container(
//                             //             height: 300,
//                             //             alignment: Alignment.center,
//                             //             child:
//                             //                 const CircularProgressIndicator(),
//                             //           );
//                             //         },
//                             //         errorBuilder: (_, __, ___) =>
//                             //             const SizedBox(),
//                             //       ),
//                             //     ),
//                             //   ),

//                             if (data['imageUrl'] != null &&
//                                 data['imageUrl'].toString().isNotEmpty)
//                               Padding(
//                                 padding: const EdgeInsets.only(bottom: 8),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(12),
//                                   child: CachedNetworkImage(
//                                     imageUrl: data['imageUrl'],

//                                     width: double.infinity,
//                                     height: 300,
//                                     fit: BoxFit.cover,

//                                     /// ✅ Reduce memory usage (VERY IMPORTANT)
//                                     // memCacheWidth: 600, // lower = lighter image
//                                     // memCacheHeight: 600,

//                                     memCacheWidth: 400,
//                                     memCacheHeight: 400,
//                                     maxWidthDiskCache: 400,

//                                     /// ✅ While loading
//                                     placeholder: (context, url) => Container(
//                                       height: 300,
//                                       alignment: Alignment.center,
//                                       child: Text(
//                                         "loading...",
//                                         style: TextStyle(
//                                           fontStyle: FontStyle.italic,
//                                           color: isDark
//                                               ? Colors.white
//                                               : Colors.black,
//                                         ),
//                                       ),
//                                     ),

//                                     /// ✅ If error occurs
//                                     errorWidget: (context, url, error) =>
//                                         Container(
//                                       height: 300,
//                                       alignment: Alignment.center,
//                                       child: Text(
//                                         "failed to load",
//                                         style: TextStyle(
//                                           color: Colors.red,
//                                           fontStyle: FontStyle.italic,
//                                         ),
//                                       ),
//                                     ),

//                                     /// ✅ Optional fade for smooth appearance
//                                     fadeInDuration:
//                                         const Duration(milliseconds: 300),
//                                   ),
//                                 ),
//                               ),

//                             /// 📝 TEXT
//                             RichText(
//                               text: TextSpan(
//                                 children: _linkifyText(postText, isDark),
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Row(
//                               children: [
//                                 /// 👍 LIKE
//                                 InkWell(
//                                   onTap: () =>
//                                       statusCtrl.toggleLike(posts[index]),
//                                   child: Row(
//                                     children: [
//                                       Icon(
//                                         Icons.thumb_up,
//                                         size: 18,
//                                         color: hasLiked
//                                             ? const Color.fromARGB(
//                                                 255, 8, 51, 85)
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

//                                 /// 💬 COMMENT COUNT
//                                 InkWell(
//                                   onTap: () {
//                                     final currentUserName =
//                                         accountController.userName.value;
//                                     final currentUserEmail =
//                                         accountController.userEmail.value;

//                                     Get.to(() => CommentScreen(
//                                           userName: currentUserName,
//                                           userEmail: currentUserEmail,
//                                           statusDoc: posts[index],
//                                         ));
//                                   },
//                                   child: StreamBuilder<QuerySnapshot>(
//                                     stream: statusCtrl
//                                         .commentStream(posts[index].id),
//                                     builder: (context, snapshot) {
//                                       final commentCount =
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
//                                             '$commentCount',
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

//                                 /// 🕒 TIME (Facebook / X style)
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
//                       ),
//                     );
//                   },
//                 );
//               }),
//             ),
//           ],
//         ),
//         floatingActionButton: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//           child: FloatingActionButton(
//             heroTag: 'statusFab',
//             backgroundColor:
//                 isDark ? Colors.white : Colors.black.withOpacity(0.65),
//             child: Icon(
//               Icons.add,
//               color: isDark ? Colors.black : Colors.white,
//             ),
//             onPressed: () {
//               final currentUserName = accountController.userName.value;
//               final currentUserEmail = accountController.userEmail.value;

//               print(
//                   "Navigated with user: $currentUserName, email: $currentUserEmail");

//               Get.to(() => AddStatus(
//                     userName: currentUserName,
//                     userEmail: currentUserEmail,
//                   ));
//             },
//           ),
//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
//       );
//     });
//   }
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
//       spans.add(TextSpan(
//         text: text.substring(start, match.start),
//         style: TextStyle(
//           fontSize: 13,
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
//         fontSize: 13,
//         color: Colors.blue,
//         // decoration: TextDecoration.underline,
//         fontStyle: FontStyle.italic,
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
//         fontSize: 13,
//         color: isDark ? Colors.white : Colors.black,
//       ),
//     ));
//   }

//   return spans;
// }

class StatusScreen extends StatefulWidget {
  final String userName;
  final String userEmail;

  const StatusScreen({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen>
    with AutomaticKeepAliveClientMixin {
  final ChatListController controller = Get.put(ChatListController());

  final ThemeController themeCtrl = Get.put(ThemeController());

  final AccountController accountController = Get.put(AccountController());

  final StatusController statusCtrl = Get.put(StatusController());

  final IconNavigationHandler navigationHandler = IconNavigationHandler();

  final ScrollController _scrollController = ScrollController();

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

  @override
  void initState() {
    super.initState();

    accountController.fetchUserInfo();

    _scrollController.addListener(() {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
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
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,

        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          title: Text(
            'Updates',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () {
                  //final currentUserName = accountController.userName.value;

                  // final currentUserEmail = accountController.userEmail.value;

                  // Get.to(
                  //   // () => ReferScreen(
                  //   //   userName: currentUserName,
                  //   //   userEmail: currentUserEmail,
                  //   // ),
                  //   //transition: Transition.cupertino,
                  // );
                },
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : Colors.black,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                child: const Text('Refer'),
              ),
            ),
          ],
        ),

        body: Column(
          children: [
            /// ✅ SEARCH BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    statusCtrl.searchQuery.value = value;
                  },
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search post by user',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.grey : Colors.black54,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

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
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Text(
                                "loading...",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          child: Center(
                            child: TextButton.icon(
                              onPressed: statusCtrl.loadMore,
                              icon: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              label: Text(
                                "Load more",
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      });
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

                    return RepaintBoundary(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(24),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// ✅ TOP USER SECTION
                            Row(
                              children: [
                                FutureBuilder<String?>(
                                  future: statusCtrl.fetchStatusUserAvatarName(
                                    postEmail,
                                  ),
                                  builder: (context, snapshot) {
                                    final avatarName = statusCtrl
                                        .getCachedAvatar(postEmail);

                                    return GestureDetector(
                                      onTap: () async {
                                        try {
                                          final userDoc =
                                              await FirebaseFirestore.instance
                                                  .collection('e-users')
                                                  .where(
                                                    'email',
                                                    isEqualTo: postEmail,
                                                  )
                                                  .limit(1)
                                                  .get();

                                          if (userDoc.docs.isEmpty) {
                                            Get.snackbar(
                                              'Anonymous user',
                                              'This profile did not back up their Seed Phrase',
                                              snackPosition:
                                                  SnackPosition.BOTTOM,
                                            );

                                            return;
                                          }

                                          final userId = userDoc.docs.first.id;

                                          Get.to(
                                            () => PublicProfileScreen(
                                              userId: userId,
                                            ),
                                            transition: Transition.cupertino,
                                          );
                                        } catch (e) {
                                          Get.snackbar(
                                            'Error',
                                            'Failed to fetch user',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                        }
                                      },
                                      child: CircleAvatar(
                                        radius: 20,
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
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      /// ✅ NAME BUTTON
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                            backgroundColor: isDark
                                                ? Colors.white.withOpacity(0.05)
                                                : Colors.black.withOpacity(
                                                    0.04,
                                                  ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () async {
                                            try {
                                              final userDoc =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('e-users')
                                                      .where(
                                                        'email',
                                                        isEqualTo: postEmail,
                                                      )
                                                      .limit(1)
                                                      .get();

                                              if (userDoc.docs.isEmpty) {
                                                Get.snackbar(
                                                  'Anonymous user',
                                                  'This profile did not back up their Seed Phrase',
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                );

                                                return;
                                              }

                                              final userId =
                                                  userDoc.docs.first.id;

                                              Get.to(
                                                () => PublicProfileScreen(
                                                  userId: userId,
                                                ),
                                                transition:
                                                    Transition.cupertino,
                                              );
                                            } catch (e) {
                                              Get.snackbar(
                                                'Error',
                                                'Failed to fetch user',
                                                snackPosition:
                                                    SnackPosition.BOTTOM,
                                              );
                                            }
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  postName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
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
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 5,
                                                      ),
                                                  child: Image.asset(
                                                    'assets/images/verified.png',
                                                    width: 15,
                                                    height: 15,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        obfuscateEmail(postEmail),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? Colors.grey
                                              : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            /// ✅ IMAGE
                            if (data['imageUrl'] != null &&
                                data['imageUrl'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: CachedNetworkImage(
                                        imageUrl: data['imageUrl'],
                                        width: double.infinity,
                                        height: 300,
                                        fit: BoxFit.cover,

                                        /// ✅ MEMORY FIX
                                        memCacheWidth: 500,
                                        memCacheHeight: 500,
                                        maxWidthDiskCache: 500,
                                        fadeInDuration: const Duration(
                                          milliseconds: 250,
                                        ),

                                        placeholder: (context, url) =>
                                            Container(
                                              height: 300,
                                              alignment: Alignment.center,
                                              child: Text(
                                                "loading...",
                                                style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                            ),

                                        errorWidget: (context, url, error) =>
                                            Container(
                                              height: 300,
                                              alignment: Alignment.center,
                                              child: const Text(
                                                "failed to load",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 12,
                                      bottom: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? Colors.black.withOpacity(0.65)
                                              : Colors.white.withOpacity(0.90),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Text(
                                          "Tap to View",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            /// ✅ TEXT
                            if (postText.toString().trim().isNotEmpty)
                              RichText(
                                text: TextSpan(
                                  children: _linkifyText(postText, isDark),
                                ),
                              ),

                            const SizedBox(height: 14),

                            /// ✅ ACTIONS
                            Row(
                              children: [
                                /// ❤️ LIKE
                                InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () {
                                    statusCtrl.toggleLike(doc);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        hasLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 24,
                                        color: hasLiked
                                            ? Colors.red
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '${likes.length}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 22),

                                /// 💬 COMMENT
                                InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () {
                                    final currentUserName =
                                        accountController.userName.value;

                                    final currentUserEmail =
                                        accountController.userEmail.value;

                                    Get.to(
                                      () => CommentScreen(
                                        userName: currentUserName,
                                        userEmail: currentUserEmail,
                                        statusDoc: doc,
                                      ),
                                      transition: Transition.cupertino,
                                    );
                                  },
                                  child: StreamBuilder<QuerySnapshot>(
                                    stream: statusCtrl.commentStream(doc.id),
                                    builder: (context, snapshot) {
                                      final commentCount =
                                          snapshot.data?.docs.length ?? 0;

                                      return Row(
                                        children: [
                                          Icon(
                                            Icons.comment_outlined,
                                            size: 24,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '$commentCount',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(width: 22),

                                /// 📋 COPY
                                InkWell(
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () {
                                    statusCtrl.copyStatus(postText);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.copy,
                                        size: 22,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Copy',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Spacer(),

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
                              ],
                            ),
                          ],
                        ),
                        // Positioned(
                        //   top: 0,
                        //   right: 0,
                        //   child: Text(
                        //     'SpiiiQ',
                        //     style: TextStyle(
                        //       fontSize: 11,
                        //       color: isDark
                        //           ? Colors.grey.shade400
                        //           : Colors.grey.shade600,
                        //     ),
                        //   ),
                        // ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),

        /// ✅ FAB
        floatingActionButton: FloatingActionButton(
          heroTag: 'statusFab',
          elevation: 3,
          backgroundColor: isDark ? Colors.white : Colors.black,
          child: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
          onPressed: () {
            final currentUserName = accountController.userName.value;

            final currentUserEmail = accountController.userEmail.value;

            Get.to(
              () => AddStatus(
                userName: currentUserName,
                userEmail: currentUserEmail,
              ),
              transition: Transition.cupertino,
            );
          },
        ),
      );
    });
  }
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
