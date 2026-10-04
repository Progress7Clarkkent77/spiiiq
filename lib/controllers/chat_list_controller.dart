import 'package:spiiiq/controllers/e_login_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'dart:async';

class ChatListController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthController _auth = Get.find<AuthController>();

  final RxList<Map<String, dynamic>> chats = <Map<String, dynamic>>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = true.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _chatSubscription;

  String get currentUid => _auth.currentUser!.uid;

  @override
  void onInit() {
    super.onInit();
    _listen();
  }

  @override
  void onClose() {
    _chatSubscription?.cancel();
    super.onClose();
  }

  void _listen() {
    isLoading.value = true;

    _chatSubscription?.cancel();

    _chatSubscription = _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .listen(
          (snapshot) async {
            try {
              final results = await Future.wait(
                snapshot.docs.map((doc) async {
                  final data = doc.data();

                  final participants = List<String>.from(
                    data['participants'] ?? [],
                  );

                  if (participants.length < 2) return null;

                  final otherUid = participants.firstWhere(
                    (id) => id != currentUid,
                    orElse: () => '',
                  );

                  if (otherUid.isEmpty) return null;

                  //----------------------------------------------------------------
                  // Fetch user + unread counts in parallel
                  //----------------------------------------------------------------

                  final futures = await Future.wait([
                    _firestore.collection('e-users').doc(otherUid).get(),
                    _firestore
                        .collection('chats')
                        .doc(doc.id)
                        .collection('messages')
                        .where('readBy', arrayContains: currentUid)
                        .count()
                        .get(),
                    _firestore
                        .collection('chats')
                        .doc(doc.id)
                        .collection('messages')
                        .count()
                        .get(),
                  ]);

                  final userDoc =
                      futures[0] as DocumentSnapshot<Map<String, dynamic>>;
                  final readCount = futures[1] as AggregateQuerySnapshot;
                  final totalCount = futures[2] as AggregateQuerySnapshot;

                  if (!userDoc.exists) return null;

                  final user = userDoc.data()!;

                  final unreadCount =
                      (totalCount.count ?? 0) - (readCount.count ?? 0);

                  return <String, dynamic>{
                    'chatId': doc.id,
                    'otherUid': otherUid,
                    'otherName': user['name'] ?? 'Unknown',
                    'avatar': user['avatar'] ?? '',
                    'isOnline': user['isOnline'] ?? false,
                    'lastSeen': user['lastSeen'],
                    'lastMessage': data['lastMessage'] ?? '',
                    'lastMessageTime': data['lastMessageTime'],
                    'unreadCount': unreadCount < 0 ? 0 : unreadCount,
                    'isVerified': user['verified'] == true,
                  };
                }),
              );

              chats.assignAll(
                results.whereType<Map<String, dynamic>>().toList(),
              );

              isLoading.value = false;
            } catch (e) {
              isLoading.value = false;
              print('ChatList Error: $e');
            }
          },
          onError: (e) {
            isLoading.value = false;
            print('Chat Stream Error: $e');
          },
        );
  }

  List<Map<String, dynamic>> get filteredChats {
    final q = searchQuery.value.toLowerCase().trim();

    if (q.isEmpty) {
      return chats;
    }

    return chats.where((chat) {
      return (chat['otherName'] ?? '').toString().toLowerCase().contains(q) ||
          (chat['lastMessage'] ?? '').toString().toLowerCase().contains(q);
    }).toList();
  }
}
