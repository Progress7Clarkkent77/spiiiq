import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spiiiq/controllers/rooms_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:spiiiq/widgets/report_reason_dialog.dart';

class RoomChatPage extends StatefulWidget {
  final RoomInfo room;

  const RoomChatPage({super.key, required this.room});

  @override
  State<RoomChatPage> createState() => _RoomChatPageState();
}

class _RoomChatPageState extends State<RoomChatPage> {
  final ThemeController themeCtrl = Get.find<ThemeController>();
  final RoomsController ctrl = RoomsController.ensure();
  final TextEditingController _input = TextEditingController();
  final String? _myUid = FirebaseAuth.instance.currentUser?.uid;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stream = ctrl
      .messagesStream(widget.room.id);

  static const Color _like = Color(0xFFF91880);

  @override
  void initState() {
    super.initState();
    ctrl.pendingImage.value = null;
    ctrl.refreshImageStatus();
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text;
    final image = ctrl.pendingImage.value;
    if (text.trim().isEmpty && image == null) return;

    final ok = await ctrl.sendMessage(
      roomId: widget.room.id,
      text: text,
      imageBytes: image,
    );
    if (ok) _input.clear();
  }

  void _openImage(String url) {
    Get.to(
      () => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(child: InteractiveViewer(child: Image.network(url))),
      ),
      transition: Transition.fadeIn,
    );
  }

  // =====================================================================
  // BUILD
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          titleSpacing: 0,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          title: Row(
            children: [
              Icon(
                widget.room.icon,
                size: 20,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                widget.room.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildBanner(isDark),
            Expanded(child: _buildMessages(isDark)),
            _buildInputBar(isDark),
          ],
        ),
      );
    });
  }

  // =====================================================================
  // FIXED DESCRIPTION BANNER
  // =====================================================================
  Widget _buildBanner(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 0.6,
          ),
          bottom: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 0.6,
          ),
        ),
      ),
      child: Text(
        widget.room.description,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12.5,
          height: 1.35,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
        ),
      ),
    );
  }

  // =====================================================================
  // MESSAGES (last 30, newest at the bottom)
  // =====================================================================
  Widget _buildMessages(bool isDark) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Could not load messages. Check your connection.',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final docs = snapshot.data!.docs;

        // Load avatars + verified badges for the senders on screen.
        final senderUids = docs
            .map((d) => (d.data()['uid'] ?? '').toString())
            .toSet();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ctrl.preloadSenders(senderUids);
        });

        // Obx so the list re-filters the moment a message is flagged or a
        // user is blocked.
        return Obx(() {
          final mod = ctrl.moderation;

          final visible = docs.where((d) {
            final senderUid = (d.data()['uid'] ?? '').toString();
            if (mod.flaggedPostIds.contains(d.id)) return false;
            if (senderUid.isNotEmpty && mod.isEitherBlocked(senderUid)) {
              return false;
            }
            return true;
          }).toList();

          if (visible.isEmpty) {
            return Center(
              child: Text(
                'No messages yet.\nBe the first to say something.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                ),
              ),
            );
          }

          // docs are newest-first, so a reversed list puts the newest at
          // the bottom, just above the input bar.
          return ListView.builder(
            reverse: true,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            itemCount: visible.length,
            itemBuilder: (context, index) =>
                _buildMessage(visible[index], isDark),
          );
        });
      },
    );
  }

  // =====================================================================
  // ONE MESSAGE
  // =====================================================================
  Widget _buildMessage(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    bool isDark,
  ) {
    final data = doc.data();
    final senderUid = (data['uid'] ?? '').toString();
    final senderEmail = (data['email'] ?? '').toString();
    final rawName = (data['name'] ?? '').toString().trim();
    final name = rawName.isEmpty ? 'Anonymous User' : rawName;
    final text = (data['text'] ?? '').toString();
    final imageUrl = (data['imageUrl'] ?? '').toString();
    final likes = List<String>.from(data['likes'] ?? []);
    final hasLiked = _myUid != null && likes.contains(_myUid);
    final isMine = senderUid.isNotEmpty && senderUid == _myUid;

    // A message that is still being saved has no server time yet.
    final ts = data['timestamp'] as Timestamp?;
    final time = _formatTime(ts?.toDate() ?? DateTime.now());

    final Color bubbleColor = isMine
        ? (isDark ? const Color(0xFF005C4B) : const Color(0xFFD9FDD3))
        : (isDark ? const Color(0xFF1F2C34) : Colors.white);
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color subColor = isDark
        ? Colors.white.withOpacity(0.6)
        : Colors.black.withOpacity(0.5);

    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.78;

    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxBubbleWidth),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 6),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          border: isDark || isMine
              ? null
              : Border.all(color: Colors.black12, width: 0.6),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Owner's username on every message (tap opens report / block
            /// for other people's messages only)
            GestureDetector(
              onTap: isMine
                  ? null
                  : () => _showUserActions(
                      uid: senderUid,
                      name: name,
                      email: senderEmail,
                      isDark: isDark,
                    ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isMine
                              ? (isDark
                                    ? Colors.white70
                                    : const Color(0xFF075E54))
                              : (isDark
                                    ? const Color(0xFF7BD8C5)
                                    : const Color(0xFF0B7A66)),
                        ),
                      ),
                    ),
                    Obx(
                      () => ctrl.verifiedCache[senderUid] == true
                          ? Padding(
                              padding: const EdgeInsets.only(left: 3),
                              child: Image.asset(
                                'assets/images/verified.png',
                                width: 14,
                                height: 14,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            /// Image (one per user per day)
            if (imageUrl.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: text.isNotEmpty ? 6 : 0),
                child: GestureDetector(
                  onTap: () => _openImage(imageUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: maxBubbleWidth - 20,
                      height: 200,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: maxBubbleWidth - 20,
                        height: 200,
                        color: isDark ? Colors.white10 : Colors.black12,
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        width: maxBubbleWidth - 20,
                        height: 200,
                        color: isDark ? Colors.white10 : Colors.black12,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: subColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            /// Message text
            if (text.isNotEmpty)
              Text(
                text,
                style: TextStyle(fontSize: 15, height: 1.35, color: textColor),
              ),

            const SizedBox(height: 4),

            /// ❤️ like · 🚩 flag · time
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => ctrl.toggleLike(
                    roomId: widget.room.id,
                    messageId: doc.id,
                    ownerUid: senderUid,
                    currentlyLiked: hasLiked,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: hasLiked ? _like : subColor,
                        ),
                        if (likes.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            '${likes.length}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: hasLiked ? _like : subColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                /// 🚩 Flag is on every message.
                const SizedBox(width: 14),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _flagMessage(doc, data, isDark),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Icon(
                      Icons.outlined_flag_rounded,
                      size: 16,
                      color: subColor,
                    ),
                  ),
                ),

                const SizedBox(width: 16),
                Text(time, style: TextStyle(fontSize: 10.5, color: subColor)),
              ],
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isMine) ...[
            GestureDetector(
              onTap: () => _showUserActions(
                uid: senderUid,
                name: name,
                email: senderEmail,
                isDark: isDark,
              ),
              child: _buildAvatar(senderUid, name),
            ),
            const SizedBox(width: 6),
          ],
          bubble,
        ],
      ),
    );
  }

  Widget _buildAvatar(String uid, String name) {
    return Obx(() {
      final avatar = ctrl.avatarCache[uid];
      final hasAvatar = avatar != null && avatar.isNotEmpty;

      return CircleAvatar(
        radius: 15,
        backgroundColor: Colors.white,
        backgroundImage: hasAvatar
            ? AssetImage('assets/images/$avatar.png')
            : null,
        child: hasAvatar
            ? null
            : Text(
                name.isEmpty ? 'A' : name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
      );
    });
  }

  // =====================================================================
  // FLAG A MESSAGE (opens the moderation reason dialog)
  // =====================================================================
  void _flagMessage(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
    bool isDark,
  ) {
    ReportReasonDialog.show(
      context: context,
      title: 'Report this message',
      reasons: kFlagPostReasons,
      confirmLabel: 'Report Message',
      onConfirm: (reason) async {
        await ctrl.flagMessage(
          room: widget.room,
          messageId: doc.id,
          data: data,
          reason: reason,
        );
        Get.snackbar(
          'Reported',
          'This message has been flagged successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
          colorText: isDark ? Colors.white : Colors.black,
        );
      },
    );
  }

  // =====================================================================
  // REPORT / BLOCK THE SENDER (tap their name or avatar)
  // =====================================================================
  void _showUserActions({
    required String uid,
    required String name,
    required String email,
    required bool isDark,
  }) {
    if (uid.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1F24) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final Color fg = isDark ? Colors.white : Colors.black87;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.outlined_flag_rounded, color: fg),
                  title: Text('Report user', style: TextStyle(color: fg)),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ReportReasonDialog.show(
                      context: context,
                      title: 'Report $name',
                      reasons: kReportUserReasons,
                      confirmLabel: 'Report User',
                      onConfirm: (reason) async {
                        await ctrl.reportSender(
                          uid: uid,
                          name: name,
                          email: email,
                          reason: reason,
                        );
                        Get.snackbar(
                          'Reported',
                          'Thanks, we will review this user.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: isDark
                              ? Colors.grey.shade900
                              : Colors.white,
                          colorText: isDark ? Colors.white : Colors.black,
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.block_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Block user',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ReportReasonDialog.show(
                      context: context,
                      title: 'Block $name',
                      reasons: kBlockUserReasons,
                      confirmLabel: 'Block User',
                      onConfirm: (reason) async {
                        await ctrl.blockSender(
                          uid: uid,
                          email: email,
                          reason: reason,
                        );
                        Get.snackbar(
                          'Blocked',
                          'You will no longer see messages from $name.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: isDark
                              ? Colors.grey.shade900
                              : Colors.white,
                          colorText: isDark ? Colors.white : Colors.black,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================================================================
  // INPUT BAR
  // =====================================================================
  Widget _buildInputBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 0.6,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🖼️ Preview of the picked image, with a remove button
            Obx(() {
              final bytes = ctrl.pendingImage.value;
              if (bytes == null) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          bytes,
                          height: 90,
                          width: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: ctrl.clearPendingImage,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black54,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  /// ➕ Image button — one image per day, then it is
                  /// deactivated until the next day.
                  Obx(() {
                    final used = ctrl.imageUsedToday.value;
                    final active = !used;

                    return GestureDetector(
                      onTap: ctrl.pickImage,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF1F2C34)
                              : Colors.grey.shade100,
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 22,
                          color: active
                              ? (isDark ? Colors.white : Colors.black87)
                              : (isDark ? Colors.white24 : Colors.black26),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1F2C34)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _input,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: RoomsController.maxMessageLength,
                        textCapitalization: TextCapitalization.sentences,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        cursorColor: isDark ? Colors.white : Colors.black,
                        decoration: InputDecoration(
                          hintText: 'Message',
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade600,
                          ),
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() {
                    final sending = ctrl.isSending.value;

                    return GestureDetector(
                      onTap: sending ? null : _send,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        child: Center(
                          child: sending
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isDark ? Colors.black : Colors.white,
                                  ),
                                )
                              : Icon(
                                  Icons.send_rounded,
                                  size: 20,
                                  color: isDark ? Colors.black : Colors.white,
                                ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================================
  // TIME — "2:05 PM", "Yesterday 2:05 PM", "14/11 2:05 PM"
  // =====================================================================
  String _formatTime(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    final clock = '$hour:$minute $period';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(t.year, t.month, t.day);
    final diff = today.difference(day).inDays;

    if (diff <= 0) return clock;
    if (diff == 1) return 'Yesterday $clock';
    return '${t.day}/${t.month} $clock';
  }
}
