// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:spiiiq/controllers/e_login_controller.dart';
// import 'package:spiiiq/controllers/reward_controller.dart';

// // class MarketController extends GetxController {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// //   final AuthController _auth = Get.find<AuthController>();

// //   final RewardController _rewardCtrl = Get.find<RewardController>();

// //   final ImagePicker _picker = ImagePicker();

// //   /// ✅ MULTIPLE IMAGES
// //   final RxList<File> selectedImages = <File>[].obs;

// //   final RxList<DocumentSnapshot> products = <DocumentSnapshot>[].obs;

// //   final RxBool isUploading = false.obs;

// //   @override
// //   void onInit() {
// //     super.onInit();
// //     listenToProducts();
// //   }

// //   void listenToProducts() {
// //     _firestore
// //         .collection('market')
// //         .orderBy('timestamp', descending: true)
// //         .snapshots()
// //         .listen((snapshot) {
// //       products.value = snapshot.docs;
// //     });
// //   }

// //   /// ✅ PICK MULTIPLE IMAGES
// //   Future<void> pickImagesFromDevice() async {
// //     try {
// //       final List<XFile> pickedFiles = await _picker.pickMultiImage(
// //         imageQuality: 70,
// //       );

// //       if (pickedFiles.isNotEmpty) {
// //         selectedImages.value = pickedFiles.map((e) => File(e.path)).toList();
// //       }
// //     } catch (e) {
// //       print("Image error: $e");
// //     }
// //   }

// //   /// ✅ UPLOAD SINGLE IMAGE
// //   Future<String?> uploadSingleImage(
// //     File imageFile,
// //     String uid,
// //   ) async {
// //     try {
// //       final ref = FirebaseStorage.instance.ref().child('market_images').child(
// //             '${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
// //           );

// //       await ref.putFile(imageFile);

// //       return await ref.getDownloadURL();
// //     } catch (e) {
// //       print(e);
// //       return null;
// //     }
// //   }

// //   /// ✅ POST PRODUCT
// //   Future<bool> postProduct({
// //     required String text,
// //     required String userName,
// //     required String userEmail,
// //   }) async {
// //     final user = _auth.currentUser;

// //     if (user == null) return false;

// //     if (text.isEmpty || selectedImages.isEmpty) {
// //       Get.snackbar(
// //         "Missing fields",
// //         "Add images and product description",
// //         snackPosition: SnackPosition.BOTTOM,
// //       );

// //       return false;
// //     }

// //     try {
// //       isUploading.value = true;

// //       /// ✅ UPLOAD ALL IMAGES
// //       List<String> imageUrls = [];

// //       for (File image in selectedImages) {
// //         final uploadedUrl = await uploadSingleImage(
// //           image,
// //           user.uid,
// //         );

// //         if (uploadedUrl != null) {
// //           imageUrls.add(uploadedUrl);
// //         }
// //       }

// //       await _firestore.collection('market').add({
// //         'text': text,
// //         'imageUrls': imageUrls,
// //         'name': userName,
// //         'email': userEmail,
// //         'likes': [],
// //         'timestamp': FieldValue.serverTimestamp(),
// //       });

// //       selectedImages.clear();

// //       isUploading.value = false;

// //       return true;
// //     } catch (e) {
// //       isUploading.value = false;

// //       Get.snackbar(
// //         "Upload Failed",
// //         "Something went wrong",
// //         snackPosition: SnackPosition.BOTTOM,
// //       );

// //       return false;
// //     }
// //   }

// //   /// ✅ TOGGLE MARKET LIKE
// //   Future<void> toggleLike(
// //     DocumentSnapshot productDoc,
// //   ) async {
// //     try {
// //       final currentUid = _auth.currentUser?.uid;

// //       if (currentUid == null) return;

// //       final data = productDoc.data() as Map<String, dynamic>;

// //       final List likes = data['likes'] ?? [];

// //       /// ✅ ONLY REWARD WHEN USER IS LIKING
// //       if (!likes.contains(currentUid)) {
// //         await handleStatusLikeReward(
// //           statusId: productDoc.id,
// //           userUid: currentUid,
// //         );

// //         await _firestore.collection('market').doc(productDoc.id).update({
// //           'likes': FieldValue.arrayUnion([currentUid]),
// //         });
// //       } else {
// //         /// ✅ UNLIKE
// //         await _firestore.collection('market').doc(productDoc.id).update({
// //           'likes': FieldValue.arrayRemove([currentUid]),
// //         });
// //       }
// //     } catch (e) {
// //       print("❌ Market like error: $e");
// //     }
// //   }

// //   Future<void> handleStatusLikeReward({
// //     required String statusId,
// //     required String userUid,
// //   }) async {
// //     try {
// //       final rewardRef = _firestore
// //           .collection('statusRewards')
// //           .doc(userUid)
// //           .collection('statusLikes')
// //           .doc(statusId);

// //       final rewardDoc = await rewardRef.get();

// //       /// ✅ PREVENT DOUBLE REWARD
// //       if (!rewardDoc.exists) {
// //         await _rewardCtrl.incrementTinyReward(
// //           uid: userUid,
// //         );

// //         print("💰 Rewarded $userUid for liking market post");

// //         await rewardRef.set({
// //           'rewarded': true,
// //           'timestamp': FieldValue.serverTimestamp(),
// //         });
// //       }
// //     } catch (e) {
// //       print("❌ Error rewarding market like: $e");
// //     }
// //   }

// //   String formatPostTime(Timestamp? timestamp) {
// //     if (timestamp == null) return '';

// //     final now = DateTime.now();

// //     final diff = now.difference(timestamp.toDate());

// //     if (diff.inMinutes < 1) {
// //       return "Just now";
// //     }

// //     if (diff.inHours < 1) {
// //       return "${diff.inMinutes}m ago";
// //     }

// //     if (diff.inDays < 1) {
// //       return "${diff.inHours}h ago";
// //     }

// //     return "${diff.inDays}d ago";
// //   }
// // }

// class MarketController extends GetxController {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   final AuthController _auth = Get.find<AuthController>();

//   final RewardController _rewardCtrl = Get.find<RewardController>();

//   final ImagePicker _picker = ImagePicker();

//   /// ✅ WEB + MOBILE SUPPORT
//   final RxList<File> selectedImages = <File>[].obs;

//   final RxList<Uint8List> webImages = <Uint8List>[].obs;

//   final RxList<DocumentSnapshot> products = <DocumentSnapshot>[].obs;

//   final RxBool isUploading = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     listenToProducts();
//   }

//   void listenToProducts() {
//     _firestore
//         .collection('market')
//         .orderBy('timestamp', descending: true)
//         .limit(38)
//         .snapshots()
//         .listen((snapshot) {
//       products.value = snapshot.docs;
//     });
//   }

//   /// ✅ PICK IMAGES FOR WEB + MOBILE
//   Future<void> pickImagesFromDevice() async {
//     try {
//       final List<XFile> pickedFiles = await _picker.pickMultiImage(
//         imageQuality: 70,
//       );

//       if (pickedFiles.isEmpty) return;

//       /// ✅ WEB
//       if (kIsWeb) {
//         webImages.clear();

//         for (final file in pickedFiles) {
//           final bytes = await file.readAsBytes();

//           webImages.add(bytes);
//         }
//       } else {
//         /// ✅ MOBILE
//         selectedImages.value = pickedFiles.map((e) => File(e.path)).toList();
//       }
//     } catch (e) {
//       print("Image error: $e");
//     }
//   }

//   /// ✅ MOBILE IMAGE UPLOAD
//   Future<String?> uploadSingleImage(
//     File imageFile,
//     String uid,
//   ) async {
//     try {
//       final ref = FirebaseStorage.instance.ref().child('market_images').child(
//             '${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
//           );

//       await ref.putFile(imageFile);

//       return await ref.getDownloadURL();
//     } catch (e) {
//       print(e);

//       return null;
//     }
//   }

//   /// ✅ WEB IMAGE UPLOAD
//   Future<String?> uploadWebImage(
//     Uint8List imageBytes,
//     String uid,
//   ) async {
//     try {
//       final ref = FirebaseStorage.instance.ref().child('market_images').child(
//             '${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
//           );

//       await ref.putData(imageBytes);

//       return await ref.getDownloadURL();
//     } catch (e) {
//       print("Web upload error: $e");

//       return null;
//     }
//   }

//   /// ✅ POST PRODUCT
//   // Future<bool> postProduct({
//   //   required String text,
//   //   required String userName,
//   //   required String userEmail,
//   // }) async {
//   //   final user = _auth.currentUser;

//   //   if (user == null) return false;

//   //   /// ✅ CHECK EMPTY
//   //   if (text.trim().isEmpty ||
//   //       (!kIsWeb && selectedImages.isEmpty) ||
//   //       (kIsWeb && webImages.isEmpty)) {
//   //     Get.snackbar(
//   //       "Missing fields",
//   //       "Add images and product description",
//   //       snackPosition: SnackPosition.BOTTOM,
//   //     );

//   //     return false;
//   //   }

//   //   try {
//   //     isUploading.value = true;

//   //     List<String> imageUrls = [];

//   //     /// ✅ WEB UPLOAD
//   //     if (kIsWeb) {
//   //       for (Uint8List image in webImages) {
//   //         final uploadedUrl = await uploadWebImage(
//   //           image,
//   //           user.uid,
//   //         );

//   //         if (uploadedUrl != null) {
//   //           imageUrls.add(uploadedUrl);
//   //         }
//   //       }
//   //     } else {
//   //       /// ✅ MOBILE UPLOAD
//   //       for (File image in selectedImages) {
//   //         final uploadedUrl = await uploadSingleImage(
//   //           image,
//   //           user.uid,
//   //         );

//   //         if (uploadedUrl != null) {
//   //           imageUrls.add(uploadedUrl);
//   //         }
//   //       }
//   //     }

//   //     await _firestore.collection('market').add({
//   //       'text': text,
//   //       'imageUrls': imageUrls,
//   //       'name': userName,
//   //       'email': userEmail,
//   //       'likes': [],
//   //       'timestamp': FieldValue.serverTimestamp(),
//   //     });

//   //     /// ✅ CLEAR AFTER SUCCESS
//   //     selectedImages.clear();

//   //     webImages.clear();

//   //     isUploading.value = false;

//   //     return true;
//   //   } catch (e) {
//   //     isUploading.value = false;

//   //     print("❌ Post product error: $e");

//   //     Get.snackbar(
//   //       "Upload Failed",
//   //       "Something went wrong",
//   //       snackPosition: SnackPosition.BOTTOM,
//   //     );

//   //     return false;
//   //   }
//   // }

//   /// ✅ POST PRODUCT
//   Future<bool> postProduct({
//     required String text,
//     required String userName,
//     required String userEmail,
//   }) async {
//     final user = _auth.currentUser;

//     if (user == null) return false;

//     /// ✅ CHECK EMPTY
//     if (text.trim().isEmpty ||
//         (!kIsWeb && selectedImages.isEmpty) ||
//         (kIsWeb && webImages.isEmpty)) {
//       Get.snackbar(
//         "Missing fields",
//         "Add images and product description",
//         snackPosition: SnackPosition.BOTTOM,
//       );

//       return false;
//     }

//     try {
//       /// ============================================================
//       /// ✅ CHECK VERIFIED ACCOUNT
//       /// ============================================================
//       final userDoc =
//           await _firestore.collection('e-users').doc(user.uid).get();

//       final userData = userDoc.data() ?? {};

//       final bool isVerified = userData['verified'] == true;

//       if (!isVerified) {
//         Get.dialog(
//           Dialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     height: 70,
//                     width: 70,
//                     decoration: const BoxDecoration(
//                       color: Colors.amber,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.workspace_premium,
//                       color: Colors.white,
//                       size: 40,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     "Verified Gold Badge Required",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   const Text(
//                     "You are not verified.\n\nPay for a Verified Gold Badge to start posting products in the spiiiq Market.",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: Colors.black87,
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 25),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.black,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed: () {
//                         Get.back();
//                       },
//                       child: const Text(
//                         "OK",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );

//         return false;
//       }

//       /// ============================================================
//       /// ✅ LIMIT USER TO 3 POSTS PER DAY
//       /// ============================================================
//       final now = DateTime.now();

//       final startOfDay = DateTime(
//         now.year,
//         now.month,
//         now.day,
//       );

//       final endOfDay = startOfDay.add(
//         const Duration(days: 1),
//       );

//       final todayPosts = await _firestore
//           .collection('market')
//           .where('uid', isEqualTo: user.uid)
//           .where(
//             'timestamp',
//             isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
//           )
//           .where(
//             'timestamp',
//             isLessThan: Timestamp.fromDate(endOfDay),
//           )
//           .get();

//       if (todayPosts.docs.length >= 3) {
//         Get.dialog(
//           Dialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     height: 70,
//                     width: 70,
//                     decoration: const BoxDecoration(
//                       color: Colors.black,
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.verified,
//                       color: Colors.amber,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     "Daily Posting Limit Reached",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   const Text(
//                     "You have reached today's posting limit.\n\nYou can only post 3 products in the spiiiq Market each day. Please try again tomorrow.",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       fontSize: 10,
//                       color: Colors.black87,
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 25),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.black,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       onPressed: () => Get.back(),
//                       child: const Text(
//                         "OK",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );

//         return false;
//       }

//       isUploading.value = true;

//       List<String> imageUrls = [];

//       /// ✅ WEB UPLOAD
//       if (kIsWeb) {
//         for (Uint8List image in webImages) {
//           final uploadedUrl = await uploadWebImage(
//             image,
//             user.uid,
//           );

//           if (uploadedUrl != null) {
//             imageUrls.add(uploadedUrl);
//           }
//         }
//       } else {
//         /// ✅ MOBILE UPLOAD
//         for (File image in selectedImages) {
//           final uploadedUrl = await uploadSingleImage(
//             image,
//             user.uid,
//           );

//           if (uploadedUrl != null) {
//             imageUrls.add(uploadedUrl);
//           }
//         }
//       }

//       await _firestore.collection('market').add({
//         'uid': user.uid,
//         'text': text,
//         'imageUrls': imageUrls,
//         'name': userName,
//         'email': userEmail,
//         'likes': [],
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       /// ✅ CLEAR AFTER SUCCESS
//       selectedImages.clear();

//       webImages.clear();

//       isUploading.value = false;

//       return true;
//     } catch (e) {
//       isUploading.value = false;

//       print("❌ Post product error: $e");

//       Get.snackbar(
//         "Upload Failed",
//         "Something went wrong",
//         snackPosition: SnackPosition.BOTTOM,
//       );

//       return false;
//     }
//   }

//   /// ✅ TOGGLE MARKET LIKE
//   Future<void> toggleLike(
//     DocumentSnapshot productDoc,
//   ) async {
//     try {
//       final currentUid = _auth.currentUser?.uid;

//       if (currentUid == null) return;

//       final data = productDoc.data() as Map<String, dynamic>;

//       final List likes = data['likes'] ?? [];

//       /// ✅ ONLY REWARD WHEN USER IS LIKING
//       if (!likes.contains(currentUid)) {
//         await handleStatusLikeReward(
//           statusId: productDoc.id,
//           userUid: currentUid,
//         );

//         await _firestore.collection('market').doc(productDoc.id).update({
//           'likes': FieldValue.arrayUnion([currentUid]),
//         });
//       } else {
//         /// ✅ UNLIKE
//         await _firestore.collection('market').doc(productDoc.id).update({
//           'likes': FieldValue.arrayRemove([currentUid]),
//         });
//       }
//     } catch (e) {
//       print("❌ Market like error: $e");
//     }
//   }

//   Future<void> handleStatusLikeReward({
//     required String statusId,
//     required String userUid,
//   }) async {
//     try {
//       final rewardRef = _firestore
//           .collection('statusRewards')
//           .doc(userUid)
//           .collection('statusLikes')
//           .doc(statusId);

//       final rewardDoc = await rewardRef.get();

//       /// ✅ PREVENT DOUBLE REWARD
//       if (!rewardDoc.exists) {
//         await _rewardCtrl.incrementTinyReward(
//           uid: userUid,
//         );

//         print("💰 Rewarded $userUid for liking market post");

//         await rewardRef.set({
//           'rewarded': true,
//           'timestamp': FieldValue.serverTimestamp(),
//         });
//       }
//     } catch (e) {
//       print("❌ Error rewarding market like: $e");
//     }
//   }

//   String formatPostTime(Timestamp? timestamp) {
//     if (timestamp == null) return '';

//     final now = DateTime.now();

//     final diff = now.difference(timestamp.toDate());

//     if (diff.inMinutes < 1) {
//       return "Just now";
//     }

//     if (diff.inHours < 1) {
//       return "${diff.inMinutes}m ago";
//     }

//     if (diff.inDays < 1) {
//       return "${diff.inHours}h ago";
//     }

//     return "${diff.inDays}d ago";
//   }
// }
