// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:spiiiq/controllers/referral_controller.dart';
// import 'package:spiiiq/controllers/theme_controller.dart';

// // class ReferScreen extends StatelessWidget {
// //   final String userName;
// //   final String userEmail;

// //   const ReferScreen({
// //     super.key,
// //     required this.userName,
// //     required this.userEmail,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final isDark = Get.find<ThemeController>().isDarkMode.value;

// //     final ReferController referController = Get.put(ReferController());

// //     return Scaffold(
// //       backgroundColor: isDark ? Colors.black : Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: isDark ? Colors.black : Colors.white,
// //         elevation: 0,
// //         iconTheme: IconThemeData(
// //           color: isDark ? Colors.white : Colors.black,
// //         ),
// //         title: Text(
// //           'Refer & Earn',
// //           style: TextStyle(
// //             color: isDark ? Colors.white : Colors.black,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               'Invite friends',
// //               style: TextStyle(
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.w700,
// //                 color: isDark ? Colors.white : Colors.black,
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             Text(
// //               'Share your referral link and earn rewards when it is successfully shared, but through here.',
// //               style: TextStyle(
// //                 fontSize: 14,
// //                 color: isDark ? Colors.grey : Colors.black54,
// //               ),
// //             ),
// //             const SizedBox(height: 24),

// //             /// USER INFO (context awareness)
// //             Container(
// //               padding: const EdgeInsets.all(14),
// //               decoration: BoxDecoration(
// //                 color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
// //                 borderRadius: BorderRadius.circular(14),
// //               ),
// //               child: Row(
// //                 children: [
// //                   CircleAvatar(
// //                     radius: 18,
// //                     backgroundColor: Colors.blue,
// //                     child: Text(
// //                       userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
// //                       style: const TextStyle(
// //                         color: Colors.white,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         userName.isEmpty ? 'Anonymous User' : userName,
// //                         style: TextStyle(
// //                           fontWeight: FontWeight.w600,
// //                           color: isDark ? Colors.white : Colors.black,
// //                         ),
// //                       ),
// //                       Text(
// //                         userEmail,
// //                         style: TextStyle(
// //                           fontSize: 12,
// //                           color: isDark ? Colors.grey : Colors.black54,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             const SizedBox(height: 32),

// //             /// REFER ACTION
// //             SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton(
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: isDark ? Colors.white : Colors.black,
// //                   padding: const EdgeInsets.symmetric(vertical: 14),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                 ),
// //                 onPressed: () {
// //                   referController.shareToWhatsAppStatus();
// //                 },
// //                 child: Text(
// //                   'Share Referral Link',
// //                   style: TextStyle(
// //                     color: isDark ? Colors.black : Colors.white,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// class ReferScreen extends StatelessWidget {
//   final String userName;
//   final String userEmail;

//   const ReferScreen({
//     super.key,
//     required this.userName,
//     required this.userEmail,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final ThemeController themeController = Get.find<ThemeController>();
//     final ReferController referController = Get.put(ReferController());

//     return Obx(() {
//       final isDark = themeController.isDarkMode.value;

//       return Scaffold(
//         backgroundColor: isDark ? Colors.black : Colors.white,
//         appBar: AppBar(
//           elevation: 0,
//           backgroundColor: isDark ? Colors.black : Colors.white,
//           iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
//           title: Text(
//             "Promote, Refer & Earn",
//             style: TextStyle(
//               color: isDark ? Colors.white : Colors.black,
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//         ),
//         body: SafeArea(
//           child: ListView(
//             padding: const EdgeInsets.all(20),
//             children: [
//               const SizedBox(height: 20),
//               Text(
//                 'Invite and Refer friends',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w700,
//                   color: isDark ? Colors.white : Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Share your referral link and earn rewards when it is successfully shared, but through here.',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: isDark ? Colors.grey : Colors.black54,
//                 ),
//               ),
//               const SizedBox(height: 8),

//               // Container(
//               //   padding: const EdgeInsets.all(16),
//               //   decoration: BoxDecoration(
//               //     color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
//               //     borderRadius: BorderRadius.circular(16),
//               //   ),
//               //   child: Row(
//               //     children: [
//               //       CircleAvatar(
//               //         radius: 22,
//               //         backgroundColor: Colors.blue,
//               //         child: Text(
//               //           userName.isEmpty ? "U" : userName[0].toUpperCase(),
//               //           style: const TextStyle(
//               //             color: Colors.white,
//               //             fontWeight: FontWeight.bold,
//               //           ),
//               //         ),
//               //       ),
//               //       const SizedBox(width: 15),
//               //       Expanded(
//               //         child: Column(
//               //           crossAxisAlignment: CrossAxisAlignment.start,
//               //           children: [
//               //             Text(
//               //               userName.isEmpty ? "Anonymous User" : userName,
//               //               style: TextStyle(
//               //                 fontWeight: FontWeight.bold,
//               //                 color: isDark ? Colors.white : Colors.black,
//               //               ),
//               //             ),
//               //             const SizedBox(height: 4),
//               //             Text(
//               //               userEmail,
//               //               style: TextStyle(
//               //                 fontSize: 12,
//               //                 color: isDark ? Colors.grey : Colors.black54,
//               //               ),
//               //             ),
//               //           ],
//               //         ),
//               //       ),
//               //     ],
//               //   ),
//               // ),
//               const SizedBox(height: 10),

//               /// REFER ACTION
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: isDark ? Colors.white : Colors.black,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: () {
//                     referController.shareToWhatsAppStatus();
//                   },
//                   child: Text(
//                     'Share Referral Link',
//                     style: TextStyle(
//                       color: isDark ? Colors.black : Colors.white,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 30),
//               Container(
//                 padding: const EdgeInsets.all(18),
//                 decoration: BoxDecoration(
//                   color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Promote spiiiq",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: isDark ? Colors.white : Colors.black,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       "post your referral link on TikTok, Facebook, or Instagram and Submit the link of the post here for approval.",
//                       style: TextStyle(
//                         fontSize: 10,
//                         height: 1.6,
//                         color: isDark ? Colors.grey.shade300 : Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 15),
//               Text(
//                 "Content Link",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: referController.linkController,
//                 style: TextStyle(color: isDark ? Colors.white : Colors.black),
//                 decoration: InputDecoration(
//                   hintText: "https://...",
//                   filled: true,
//                   fillColor: isDark
//                       ? Colors.grey.shade900
//                       : Colors.grey.shade100,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 "Platform",
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Obx(
//                 () => DropdownButtonFormField<String>(
//                   value: referController.selectedPlatform.value.isEmpty
//                       ? null
//                       : referController.selectedPlatform.value,
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: isDark
//                         ? Colors.grey.shade900
//                         : Colors.grey.shade100,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(14),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
//                   style: TextStyle(color: isDark ? Colors.white : Colors.black),
//                   items: referController.platforms
//                       .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                       .toList(),
//                   onChanged: (value) {
//                     referController.selectedPlatform.value = value ?? "";
//                   },
//                 ),
//               ),
//               const SizedBox(height: 30),
//               SizedBox(
//                 height: 55,
//                 child: Obx(
//                   () => ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: isDark ? Colors.white : Colors.black,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(14),
//                       ),
//                     ),
//                     onPressed: referController.submitting.value
//                         ? null
//                         : () {
//                             referController.submitPromotion(
//                               userName: userName,
//                               userEmail: userEmail,
//                             );
//                           },
//                     child: referController.submitting.value
//                         ? SizedBox(
//                             width: 22,
//                             height: 22,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               color: isDark ? Colors.black : Colors.white,
//                             ),
//                           )
//                         : Text(
//                             "Submit for Review",
//                             style: TextStyle(
//                               color: isDark ? Colors.black : Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 35),
//               Text(
//                 "My Submissions",
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: isDark ? Colors.white : Colors.black,
//                 ),
//               ),
//               const SizedBox(height: 15),
//               Obx(() {
//                 if (referController.submissions.isEmpty) {
//                   return Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: isDark
//                           ? Colors.grey.shade900
//                           : Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Center(
//                       child: Text(
//                         "No submissions yet.",
//                         style: TextStyle(
//                           color: isDark ? Colors.grey : Colors.black54,
//                         ),
//                       ),
//                     ),
//                   );
//                 }

//                 return Column(
//                   children: referController.submissions.map((doc) {
//                     final data = doc.data();

//                     final approved = data['status'] == true;

//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 15),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: isDark
//                             ? Colors.grey.shade900
//                             : Colors.grey.shade100,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             data['platform'] ?? "",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: isDark ? Colors.white : Colors.black,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           SelectableText(
//                             data['link'] ?? "",
//                             style: const TextStyle(color: Colors.blue),
//                           ),
//                           const SizedBox(height: 12),
//                           Row(
//                             children: [
//                               Icon(
//                                 approved ? Icons.check_circle : Icons.pending,
//                                 color: approved ? Colors.green : Colors.orange,
//                                 size: 18,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 approved ? "Approved" : "Pending Review",
//                                 style: TextStyle(
//                                   color: approved
//                                       ? Colors.green
//                                       : Colors.orange,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 );
//               }),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }
