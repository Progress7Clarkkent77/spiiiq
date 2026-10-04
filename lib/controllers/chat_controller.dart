import 'dart:async';

import 'package:spiiiq/controllers/e_login_controller.dart';
import 'package:spiiiq/controllers/reward_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
//import 'dart:html' as html;

import 'package:intl/intl.dart'; // For Web Notifications

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _auth = Get.find<AuthController>();
  //final Blockchain _blockchain = Blockchain();
  final RewardController _rewardCtrl = Get.find<RewardController>();

  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;

  final RxString otherUserAvatar = ''.obs;
  final RxString otherUserName = ''.obs;
  final RxBool otherUserVerified = false.obs;
  final RxBool isSending = false.obs;

  StreamSubscription? _messageSub;
  StreamSubscription? _profileSub;
  StreamSubscription? _allChatsSub;

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // ===============================
  // 🔹 SAFE current UID
  // ===============================
  String? get currentUid => _auth.currentUser?.uid;

  bool get isLoggedIn => currentUid != null;

  // ===============================
  // 🔹 Chat ID (SAFE)
  // ===============================
  String chatId(String otherUid) {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    return uid.compareTo(otherUid) < 0
        ? '${uid}_$otherUid'
        : '${otherUid}_$uid';
  }

  /// 🔁 Reply state (WhatsApp style)
  final Rx<Map<String, dynamic>?> replyingTo = Rx<Map<String, dynamic>?>(null);

  void setReply(Map<String, dynamic> message) {
    replyingTo.value = {
      'messageId': message['id'],
      'senderId': message['senderId'],
      'text': message['text'],
    };
  }

  void clearReply() {
    replyingTo.value = null;
  }

  // ===============================
  // 🔹 Listen to messages (SAFE)
  // ===============================
  void listenToMessages(String otherUid) {
    if (!isLoggedIn) return;

    final uid = currentUid!;
    final id = chatId(otherUid);

    _messageSub?.cancel();
    _messageSub = _firestore
        .collection('chats')
        .doc(id)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
          final temp = <Map<String, dynamic>>[];

          for (final doc in snapshot.docs) {
            final data = doc.data();
            final senderId = data['senderId'] ?? '';
            // final text = data['text'] ?? '';

            final readBy = List<String>.from(data['readBy'] ?? []);

            if (!readBy.contains(uid)) {
              doc.reference.update({
                'readBy': FieldValue.arrayUnion([uid]),
              });

              if (senderId != uid) {
                ///  _showWebNotification(otherUserName.value, text);
              }
            }

            //temp.add(data);
            temp.add({'id': doc.id, ...data});
          }

          messages.assignAll(temp);
        });
  }

  // ===============================
  // 🔹 Listen to OTHER USER profile
  // ===============================
  void listenToOtherUserProfile(String otherUid) {
    if (!isLoggedIn) return;

    _profileSub?.cancel();
    _profileSub = _firestore
        .collection('e-users')
        .doc(otherUid)
        .snapshots()
        .listen((doc) {
          if (!doc.exists) return;

          final data = doc.data()!;
          otherUserName.value = data['name'] ?? '';
          otherUserAvatar.value = data['avatar'] ?? '';

          /// ✅ VERIFIED STATUS
          otherUserVerified.value = data['verified'] == true;
        });
  }

  // Future<void> sendMessage({
  //   required String otherUid,
  //   required String text,
  // }) async {
  //   if (!isLoggedIn) return;
  //   if (text.trim().isEmpty) return;

  //   // 🛑 HARD LOCK
  //   if (isSending.value) return;
  //   isSending.value = true;

  //   try {
  //     final uid = currentUid!;
  //     final id = chatId(otherUid);
  //     final now = Timestamp.now();

  //     final chatRef = _firestore.collection('chats').doc(id);
  //     final messagesRef = chatRef.collection('messages');

  //     final lastMessageSnapshot = await messagesRef
  //         .orderBy('timestamp', descending: true)
  //         .limit(1)
  //         .get();

  //     bool isReply = false;
  //     if (lastMessageSnapshot.docs.isNotEmpty) {
  //       final lastSenderId = lastMessageSnapshot.docs.first['senderId'];
  //       if (lastSenderId != uid) isReply = true;
  //     }

  //     await chatRef.set({
  //       'participants': [uid, otherUid],
  //       'lastMessage': text.trim(),
  //       'lastMessageTime': now,
  //     }, SetOptions(merge: true));

  //     final replyData = replyingTo.value;

  //     // await messagesRef.add({
  //     //   'senderId': uid,
  //     //   'text': text.trim(),
  //     //   'timestamp': now,
  //     //   'readBy': [uid],
  //     // });
  //     await messagesRef.add({
  //       'senderId': uid,
  //       'text': text.trim(),
  //       'timestamp': now,
  //       'readBy': [uid],
  //       if (replyData != null) 'replyTo': replyData,
  //     });

  //     if (isReply) {
  //       await handleReward(otherUid: otherUid);
  //     }
  //   } finally {
  //     // 🔓 ALWAYS UNLOCK
  //     isSending.value = false;
  //     clearReply();
  //   }
  // }

  Future<void> sendMessage({
    required String otherUid,
    required String text,

    /// ✅ MARKET SHARE SUPPORT
    bool isMarketShare = false,
    String? productId,
    String? productImage,
    String? productText,
    String? sellerName,
  }) async {
    if (!isLoggedIn) return;

    if (text.trim().isEmpty && !isMarketShare) {
      return;
    }

    /// 🛑 HARD LOCK
    if (isSending.value) return;

    isSending.value = true;

    try {
      final uid = currentUid!;

      final id = chatId(otherUid);

      final now = Timestamp.now();

      final chatRef = _firestore.collection('chats').doc(id);

      final messagesRef = chatRef.collection('messages');

      /// ✅ CHECK LAST MESSAGE
      final lastMessageSnapshot = await messagesRef
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      bool isReply = false;

      if (lastMessageSnapshot.docs.isNotEmpty) {
        final lastSenderId = lastMessageSnapshot.docs.first['senderId'];

        if (lastSenderId != uid) {
          isReply = true;
        }
      }

      /// ✅ CHAT PREVIEW
      await chatRef.set({
        'participants': [uid, otherUid],
        'lastMessage': isMarketShare ? '📦 Shared a product' : text.trim(),
        'lastMessageTime': now,
      }, SetOptions(merge: true));

      final replyData = replyingTo.value;

      /// ✅ MESSAGE DATA
      final Map<String, dynamic> messageData = {
        'senderId': uid,

        'text': text.trim(),

        'timestamp': now,

        'readBy': [uid],

        /// ✅ REPLY
        if (replyData != null) 'replyTo': replyData,

        /// ✅ MARKET SHARE
        'isMarketShare': isMarketShare,

        if (isMarketShare) ...{
          'productId': productId,
          'productImage': productImage,
          'productText': productText,
          'sellerName': sellerName,
        },
      };

      /// ✅ SEND MESSAGE
      await messagesRef.add(messageData);

      /// ✅ REWARD
      if (isReply) {
        await handleReward(otherUid: otherUid);
      }
    } catch (e) {
      print("❌ sendMessage error: $e");
    } finally {
      /// 🔓 ALWAYS UNLOCK
      isSending.value = false;

      clearReply();
    }
  }

  // ===============================
  // 🔹 GLOBAL notifications (SAFE)
  // ===============================
  void listenToAllChatsForNotifications() {
    if (!isLoggedIn) return;

    final uid = currentUid!;

    _allChatsSub?.cancel();
    _allChatsSub = _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .listen((snapshot) {
          for (final doc in snapshot.docs) {
            _firestore
                .collection('chats')
                .doc(doc.id)
                .collection('messages')
                .orderBy('timestamp', descending: true)
                .limit(1)
                .snapshots()
                .listen((messagesSnapshot) {
                  for (final change in messagesSnapshot.docChanges) {
                    final data = change.doc.data();
                    if (data == null) continue;

                    final senderId = data['senderId'];
                    final readBy = List<String>.from(data['readBy'] ?? []);

                    if (senderId != uid && !readBy.contains(uid)) {
                      // _showWebNotification(senderId, data['text'] ?? '');
                    }
                  }
                });
          }
        });
  }

  // ===============================
  // 🔹 Web notification helper
  // ===============================
  // Future<void> _showWebNotification(String senderId, String message) async {
  //   if (!html.Notification.supported) return;

  //   if (html.Notification.permission != 'granted') {
  //     await html.Notification.requestPermission();
  //   }

  //   if (html.Notification.permission != 'granted') return;

  //   final userDoc = await _firestore.collection('e-users').doc(senderId).get();

  //   final senderName = userDoc.data()?['name'] ?? 'New message';
  //   final avatar = userDoc.data()?['avatar'] ?? '';

  //   html.Notification(
  //     senderName,
  //     body: message,
  //     icon: avatar.isNotEmpty ? 'assets/images/$avatar.png' : null,
  //   );
  // }

  String formatChatMessageTime(DateTime time) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(time.year, time.month, time.day);

    final dayDiff = today.difference(messageDay).inDays;

    // 🟢 Today → show time only
    if (dayDiff == 0) {
      return DateFormat('h:mm a').format(time);
    }

    // 🟡 Yesterday
    if (dayDiff == 1) {
      return 'Yesterday ${DateFormat('h:mm a').format(time)}';
    }

    // 🔵 This week
    if (dayDiff < 7) {
      return '${DateFormat('EEE').format(time)} ${DateFormat('h:mm a').format(time)}';
    }

    // ⚪ Older → date
    return DateFormat('dd/MM/yyyy').format(time);
  }

  // Future<String?> _fetchWalletAddress() async {
  //   try {
  //     final userEmail = _auth.currentUser?.email;
  //     if (userEmail == null) return null;

  //     final querySnapshot = await _firestore
  //         .collection("e-users")
  //         .where("email", isEqualTo: userEmail)
  //         .limit(1)
  //         .get();

  //     if (querySnapshot.docs.isNotEmpty) {
  //       return querySnapshot.docs.first["wallet_address"];
  //     }
  //   } catch (e) {
  //     print("❌ Error fetching wallet address: $e");
  //   }
  //   return null;
  // }

  // Future<void> handleReward() async {
  //   try {
  //     final walletAddress = await _fetchWalletAddress();
  //     if (walletAddress == null) {
  //       print("⚠️ Wallet address not found.");
  //       return;
  //     }

  //     await _blockchain.deductAndTransferToken3(walletAddress);
  //     print("✅ Reward sent to $walletAddress");
  //   } catch (e) {
  //     print("❌ Error rewarding user: $e");
  //   }
  // }

  Future<void> handleReward({required String otherUid}) async {
    try {
      final uid = currentUid;
      if (uid == null) return;

      final id = chatId(otherUid);

      /// 🛑 Check daily limit per chat
      final allowed = await _canReward(chatId: id, uid: uid);
      if (!allowed) {
        print('⛔ Reward limit reached for this chat today');
        return;
      }

      // final walletAddress = await _fetchWalletAddress();
      // if (walletAddress == null) {
      //   print("⚠️ Wallet address not found.");
      //   return;
      // }

      await _rewardCtrl.incrementChatReward(uid: uid);
      print("💰 Reward of 0.0001 sent for reply");

      /// 🎁 Send reward
      //await _blockchain.deductAndTransferToken3(walletAddress);

      /// ✅ Increment count only after success
      await _incrementRewardCount(chatId: id, uid: uid);

      print("✅ Reward sent ($id)");
    } catch (e) {
      print("❌ Error rewarding user: $e");
    }
  }

  Future<bool> _canReward({required String chatId, required String uid}) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final snap = await chatRef.get();

    final today = _todayKey();

    if (!snap.exists) {
      // Fresh chat → allow
      await chatRef.set({
        'rewardDate': today,
        'rewardCounts': {uid: 0},
      }, SetOptions(merge: true));
      return true;
    }

    final data = snap.data()!;
    final storedDate = data['rewardDate'] as String?;
    final counts = Map<String, dynamic>.from(data['rewardCounts'] ?? {});

    // 🔄 New day → reset
    if (storedDate != today) {
      await chatRef.update({
        'rewardDate': today,
        'rewardCounts': {uid: 0},
      });
      return true;
    }

    final currentCount = counts[uid] ?? 0;

    // ❌ Limit reached
    if (currentCount >= 40) {
      return false;
    }

    return true;
  }

  Future<void> _incrementRewardCount({
    required String chatId,
    required String uid,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);

    await chatRef.update({'rewardCounts.$uid': FieldValue.increment(1)});
  }

  // ===============================
  // 🔹 Cleanup on logout
  // ===============================
  void clearMessages() {
    _messageSub?.cancel();
    _profileSub?.cancel();
    _allChatsSub?.cancel();

    messages.clear();
    otherUserAvatar.value = '';
    otherUserName.value = '';
  }
}
