import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spiiiq/controllers/account_controller.dart';
import 'package:spiiiq/controllers/moderation_controller.dart';
import 'package:spiiiq/controllers/reward_controller.dart';

class RoomInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  const RoomInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class RoomsController extends GetxController {
  /// Safe way to get the controller from any page.
  static RoomsController ensure() => Get.isRegistered<RoomsController>()
      ? Get.find<RoomsController>()
      : Get.put(RoomsController());

  static const int messageLimit = 30;
  static const int maxMessageLength = 500;

  /// Anti-farming guard: a user can earn at most this many LIKE rewards
  /// per day. Raise it, or set it to a very large number to remove it.
  static const int maxLikeRewardsPerDay = 10;

  static const List<RoomInfo> rooms = [
    RoomInfo(
      id: 'business',
      name: 'Business',
      description: 'Business ideas, side hustles and careers. No investment schemes or money requests.',
      icon: Icons.work_outline_rounded,
    ),
    RoomInfo(
      id: 'game_arena',
      name: 'Game Arena',
      description: 'Talk games, tips, news and challenges.',
      icon: Icons.sports_esports_outlined,
    ),
    RoomInfo(
      id: 'campus',
      name: 'Campus',
      description: 'School gists, news and updates.',
      icon: Icons.school_outlined,
    ),
    RoomInfo(
      id: 'movies',
      name: 'Movies',
      description: 'Movies and series: reviews, news and recommendations.',
      icon: Icons.movie_outlined,
    ),
  ];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  RewardController get _rewardCtrl => Get.find<RewardController>();

  ModerationController get moderation =>
      Get.isRegistered<ModerationController>()
      ? Get.find<ModerationController>()
      : Get.put(ModerationController(), permanent: true);

  /// Hard lock so a double tap can't send two messages.
  final RxBool isSending = false.obs;

  /// True once the user has used today's one image (plus icon turns off).
  final RxBool imageUsedToday = false.obs;

  /// Image picked by the user, waiting to be sent with the next message.
  final Rx<Uint8List?> pendingImage = Rx<Uint8List?>(null);
  final ImagePicker _picker = ImagePicker();

  /// Sender caches, keyed by uid (filled by [preloadSenders]).
  final RxMap<String, String?> avatarCache = <String, String?>{}.obs;
  final RxMap<String, bool> verifiedCache = <String, bool>{}.obs;
  final Set<String> _requestedSenders = {};

  // =====================================================================
  // STREAM — last 30 messages, newest first
  // =====================================================================
  Stream<QuerySnapshot<Map<String, dynamic>>> messagesStream(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(messageLimit)
        .snapshots(includeMetadataChanges: true);
  }

  // =====================================================================
  // SENDER AVATAR + VERIFIED BADGE (cached, one read per user)
  // =====================================================================
  Future<void> preloadSenders(Iterable<String> uids) async {
    final todo = uids
        .where((u) => u.isNotEmpty && !_requestedSenders.contains(u))
        .toSet();
    if (todo.isEmpty) return;

    _requestedSenders.addAll(todo);

    await Future.wait(
      todo.map((uid) async {
        try {
          final doc = await _firestore
              .collection('e-users')
              .doc(uid)
              .get(const GetOptions(source: Source.serverAndCache));

          final data = doc.data() ?? {};
          final avatar = data['avatar'] as String?;

          avatarCache[uid] = (avatar != null && avatar.isNotEmpty)
              ? avatar
              : null;
          verifiedCache[uid] = data['verified'] == true;
        } catch (e) {
          _requestedSenders.remove(uid); // allow a retry later
          if (kDebugMode) print('❌ Room sender preload error: $e');
        }
      }),
    );
  }

  // =====================================================================
  // IMAGE — one per user per day
  // =====================================================================
  Future<void> refreshImageStatus() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final snap = await _dailyRef(user.uid)
          .get(const GetOptions(source: Source.serverAndCache));
      imageUsedToday.value = snap.data()?['imageSent'] == true;
    } catch (e) {
      if (kDebugMode) print('❌ Image status error: $e');
    }
  }

  Future<void> pickImage() async {
    // Re-check first, in case the day changed while the app stayed open.
    if (imageUsedToday.value) {
      await refreshImageStatus();
      if (imageUsedToday.value) {
        _notify(
          'Daily image limit reached',
          'You can send one image per day. Try again tomorrow.',
        );
        return;
      }
    }

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1600,
      );
      if (picked != null) {
        pendingImage.value = await picked.readAsBytes();
      }
    } catch (e) {
      if (kDebugMode) print('❌ Room image pick error: $e');
    }
  }

  void clearPendingImage() => pendingImage.value = null;

  Future<String?> _uploadRoomImage(Uint8List bytes, String uid) async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('room_images')
          .child('${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          cacheControl: 'public,max-age=31536000',
        ),
      );

      return await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) print('❌ Room image upload error: $e');
      return null;
    }
  }

  Future<bool> sendMessage({
    required String roomId,
    required String text,
    Uint8List? imageBytes,
  }) async {
    final trimmed = text.trim();
    final bytes = imageBytes;
    final hasImage = bytes != null;
    final hasText = trimmed.isNotEmpty;

    if (!hasText && !hasImage) return false;

    final user = _firebaseAuth.currentUser;
    if (user == null) return false;

    if (isSending.value) return false;
    isSending.value = true;

    final normalized = _normalize(trimmed);
    final dailyRef = _dailyRef(user.uid);

    bool textReserved = false;
    bool imageReserved = false;
    bool messageSaved = false;

    try {
      // 1️⃣ Reserve today's text / image (atomic)
      final result = await _firestore.runTransaction<String>((tx) async {
        final snap = await tx.get(dailyRef);
        final data = snap.data() ?? <String, dynamic>{};
        final used = List<String>.from(data['texts'] ?? <String>[]);

        if (hasText && used.contains(normalized)) return 'duplicate';
        if (hasImage && data['imageSent'] == true) return 'imageLimit';

        final update = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (hasText) {
          update['texts'] = FieldValue.arrayUnion([normalized]);
        }
        if (hasImage) {
          update['imageSent'] = true;
        }

        tx.set(dailyRef, update, SetOptions(merge: true));
        return 'ok';
      });

      if (result == 'duplicate') {
        _notify(
          'Message already sent today',
          'You already sent that message today. Try writing something different.',
        );
        return false;
      }

      if (result == 'imageLimit') {
        imageUsedToday.value = true;
        pendingImage.value = null;
        _notify(
          'Daily image limit reached',
          'You can send one image per day. Try again tomorrow.',
        );
        return false;
      }

      textReserved = hasText;
      imageReserved = hasImage;

      // 2️⃣ Upload the image
      String? imageUrl;
      if (bytes != null) {
        imageUrl = await _uploadRoomImage(bytes, user.uid);
        if (imageUrl == null) {
          throw Exception('Image upload failed');
        }
      }

      // 3️⃣ Save the message
      await _firestore
          .collection('rooms')
          .doc(roomId)
          .collection('messages')
          .add({
            'text': trimmed,
            'imageUrl': imageUrl,
            'name': _currentName(),
            'email': user.email ?? '',
            'uid': user.uid,
            'likes': <String>[],
            'timestamp': FieldValue.serverTimestamp(),
          });
      messageSaved = true;

      if (hasImage) {
        imageUsedToday.value = true;
        pendingImage.value = null;
      }

      // 4️⃣ First message of the day reward
      await _claimFirstMessageReward(user.uid, dailyRef);

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Send room message error: $e');

      // Message never saved: give the text / image slot back.
      if (!messageSaved && (textReserved || imageReserved)) {
        try {
          final rollback = <String, dynamic>{};
          if (textReserved) {
            rollback['texts'] = FieldValue.arrayRemove([normalized]);
          }
          if (imageReserved) {
            rollback['imageSent'] = false;
          }
          await dailyRef.set(rollback, SetOptions(merge: true));
        } catch (_) {}
      }

      if (!messageSaved) {
        _notify('Not sent', 'Could not send your message. Please try again.');
      }
      return messageSaved;
    } finally {
      isSending.value = false;
    }
  }

  Future<void> _claimFirstMessageReward(
    String uid,
    DocumentReference<Map<String, dynamic>> dailyRef,
  ) async {
    try {
      final shouldReward = await _firestore.runTransaction<bool>((tx) async {
        final snap = await tx.get(dailyRef);
        if (snap.data()?['rewarded'] == true) return false;

        tx.set(dailyRef, {'rewarded': true}, SetOptions(merge: true));
        return true;
      });

      if (shouldReward) {
        await _rewardCtrl.incrementTinyReward(uid: uid);
      }
    } catch (e) {
      if (kDebugMode) print('❌ First message reward error: $e');
    }
  }

  // =====================================================================
  // LIKES
  // ---------------------------------------------------------------------
  // arrayUnion / arrayRemove, so two people liking at the same moment
  // never overwrite each other. Firestore updates the screen instantly
  // from its local cache, so no manual optimistic update is needed.
  // =====================================================================
  Future<void> toggleLike({
    required String roomId,
    required String messageId,
    required String ownerUid,
    required bool currentlyLiked,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    final msgRef = _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .doc(messageId);

    try {
      if (currentlyLiked) {
        await msgRef.update({
          'likes': FieldValue.arrayRemove([user.uid]),
        });
        return;
      }

      await msgRef.update({
        'likes': FieldValue.arrayUnion([user.uid]),
      });

      await _handleLikeRewards(
        roomId: roomId,
        messageId: messageId,
        likerUid: user.uid,
        ownerUid: ownerUid,
      );
    } catch (e) {
      if (kDebugMode) print('❌ Room toggle like error: $e');
    }
  }

  Future<void> _handleLikeRewards({
    required String roomId,
    required String messageId,
    required String likerUid,
    required String ownerUid,
  }) async {
    // No rewards for liking your own message.
    if (ownerUid.isEmpty || ownerUid == likerUid) return;

    final key = '${roomId}_$messageId';

    try {
      // 🎁 Liker: once per message, with a daily cap
      final likerRef = _firestore
          .collection('statusRewards')
          .doc(likerUid)
          .collection('roomLikes')
          .doc(key);
      final dailyRef = _dailyRef(likerUid);

      final likerEarns = await _firestore.runTransaction<bool>((tx) async {
        final claimed = await tx.get(likerRef);
        if (claimed.exists) return false;

        final daily = await tx.get(dailyRef);
        final count = (daily.data()?['likeRewards'] as num?)?.toInt() ?? 0;
        if (count >= maxLikeRewardsPerDay) return false;

        tx.set(likerRef, {
          'rewarded': true,
          'timestamp': FieldValue.serverTimestamp(),
        });
        tx.set(dailyRef, {'likeRewards': count + 1}, SetOptions(merge: true));
        return true;
      });

      if (likerEarns) {
        await _rewardCtrl.incrementTinyReward(uid: likerUid);
      }

      // 🎁 Message owner: once per liker
      final ownerRef = _firestore
          .collection('statusRewards')
          .doc(ownerUid)
          .collection('roomOwnerRewards')
          .doc('${key}_$likerUid');

      final ownerEarns = await _firestore.runTransaction<bool>((tx) async {
        final claimed = await tx.get(ownerRef);
        if (claimed.exists) return false;

        tx.set(ownerRef, {
          'rewarded': true,
          'byUser': likerUid,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return true;
      });

      if (ownerEarns) {
        await _rewardCtrl.incrementTinyReward(uid: ownerUid);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Room like reward error: $e');
    }
  }

  // =====================================================================
  // MODERATION — thin wrappers around ModerationController
  // =====================================================================
  Future<void> flagMessage({
    required RoomInfo room,
    required String messageId,
    required Map<String, dynamic> data,
    required String reason,
  }) {
    return moderation.flagPost(
      postId: messageId,
      postText: (data['text'] ?? '').toString(),
      postImageUrl: data['imageUrl'] as String?,
      postOwnerEmail: (data['email'] ?? '').toString(),
      postOwnerName: (data['name'] ?? '').toString(),
      reason: reason,
      roomId: room.id,
      roomName: room.name,
    );
  }

  Future<void> reportSender({
    required String uid,
    required String name,
    required String email,
    required String reason,
  }) {
    return moderation.reportUser(
      reportedUid: uid,
      reportedName: name,
      reportedEmail: email,
      reason: reason,
    );
  }

  Future<void> blockSender({
    required String uid,
    required String email,
    required String reason,
  }) {
    return moderation.blockUser(
      targetUid: uid,
      targetEmail: email,
      reason: reason,
    );
  }

  // =====================================================================
  // HELPERS
  // =====================================================================
  String _normalize(String text) =>
      text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  String _dateKey([DateTime? d]) {
    final n = d ?? DateTime.now();
    return '${n.year}-'
        '${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }

  DocumentReference<Map<String, dynamic>> _dailyRef(String uid) => _firestore
      .collection('e-users')
      .doc(uid)
      .collection('dailyRoomMessages')
      .doc(_dateKey());

  String _currentName() {
    try {
      final name = Get.find<AccountController>().userName.value.trim();
      if (name.isNotEmpty && name.toLowerCase() != 'unknown') return name;
    } catch (_) {}
    return 'Anonymous User';
  }

  void _notify(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
    );
  }
}
