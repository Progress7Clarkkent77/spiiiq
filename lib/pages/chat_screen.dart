import 'package:spiiiq/controllers/e_login_controller.dart';
import 'package:spiiiq/controllers/chat_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:spiiiq/controllers/user_presence_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:spiiiq/pages/public_profile.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final String userId;
  final String userName;

  const ChatScreen({super.key, required this.userId, required this.userName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController chatController = Get.find<ChatController>();
  final AuthController authController = Get.find<AuthController>();
  final UserPresenceController presence = Get.find<UserPresenceController>();
  final ThemeController themeCtrl = Get.find<ThemeController>();

  final TextEditingController messageCtrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();
  final FocusNode messageFocusNode = FocusNode();

  bool showEmojiKeyboard = false;

  @override
  void initState() {
    super.initState();
    chatController.listenToMessages(widget.userId);
    chatController.listenToOtherUserProfile(widget.userId);
    _markAllMessagesAsRead();
  }

  @override
  void dispose() {
    chatController.clearMessages();
    messageCtrl.dispose();
    scrollCtrl.dispose();
    messageFocusNode.dispose();
    super.dispose();
  }

  final List<String> _emojis = [
    "😀",
    "😁",
    "😂",
    "🤣",
    "😊",
    "😍",
    "😘",
    "😎",
    "🤔",
    "😢",
    "😭",
    "😡",
    "👍",
    "👎",
    "🙏",
    "👏",
    "🔥",
    "❤️",
    "💔",
    "🎉",
    "💯",
    "✨",
    "⚡",
    "🌍",
    "🎯",
    "🚀",
    "💰",
    "📱",
    "🧠",
    "🎵",
  ];

  void _insertEmoji(String emoji) {
    final text = messageCtrl.text;
    TextSelection selection = messageCtrl.selection;

    // ✅ FIX: normalize invalid selection
    if (selection.start < 0 || selection.end < 0) {
      selection = TextSelection.collapsed(offset: text.length);
    }

    final newText = text.replaceRange(selection.start, selection.end, emoji);

    messageCtrl.text = newText;
    messageCtrl.selection = TextSelection.collapsed(
      offset: selection.start + emoji.length,
    );
  }

  Widget _buildEmojiPicker(bool isDark) {
    return Container(
      height: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
          ),
        ),
      ),
      child: GridView.builder(
        itemCount: _emojis.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemBuilder: (_, index) {
          return GestureDetector(
            onTap: () => _insertEmoji(_emojis[index]),
            child: Center(
              child: Text(_emojis[index], style: const TextStyle(fontSize: 26)),
            ),
          );
        },
      ),
    );
  }

  Future<void> _markAllMessagesAsRead() async {
    final currentUid = authController.currentUser!.uid;
    final id = chatController.chatId(widget.userId);

    final snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(id)
        .collection('messages')
        .get();

    for (final msg in snapshot.docs) {
      final readBy = List<String>.from(msg['readBy'] ?? []);
      if (!readBy.contains(currentUid)) {
        msg.reference.update({
          'readBy': FieldValue.arrayUnion([currentUid]),
        });
      }
    }
  }

  // void _toggleEmojiKeyboard() {
  //   if (showEmojiKeyboard) {
  //     FocusScope.of(context).requestFocus(messageFocusNode);
  //   } else {
  //     messageFocusNode.unfocus();
  //   }
  //   setState(() => showEmojiKeyboard = !showEmojiKeyboard);
  // }

  void _toggleEmojiKeyboard() {
    if (showEmojiKeyboard) {
      FocusScope.of(context).requestFocus(messageFocusNode);
    } else {
      messageFocusNode.unfocus();
    }
    setState(() => showEmojiKeyboard = !showEmojiKeyboard);
  }

  String formatLastSeenHuman(Timestamp ts) {
    final date = ts.toDate();
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'last seen just now';
    if (diff.inMinutes < 60) return 'last seen ${diff.inMinutes} min ago';
    if (diff.inHours < 24 && date.day == now.day)
      return 'last seen today at ${_formatTime(date)}';
    if (diff.inHours < 48 && date.day == now.day - 1)
      return 'last seen yesterday at ${_formatTime(date)}';
    return 'last seen ${date.day}/${date.month}/${date.year} at ${_formatTime(date)}';
  }

  String _formatTime(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

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

  String formatChatDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(date.year, date.month, date.day);

    final diff = today.difference(messageDay).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(date); // Monday
    return DateFormat('dd MMM yyyy').format(date); // 12 Aug 2025
  }

  String formatBubbleTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = authController.currentUser!.uid;

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(
            color: isDark ? Colors.white : Colors.black87,
          ),
          title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: presence.streamUser(widget.userId),
            builder: (context, snapshot) {
              final data = snapshot.data?.data();
              final isOnline = data?['isOnline'] ?? false;
              final lastSeen = data?['lastSeen'];

              return Row(
                children: [
                  Obx(() {
                    final avatar = chatController.otherUserAvatar.value;
                    return GestureDetector(
                      onTap: () {
                        // Navigate to PublicProfileScreen with the correct userId
                        Get.to(
                          () => PublicProfileScreen(userId: widget.userId),
                        );
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: avatar.isNotEmpty
                            ? AssetImage('assets/images/$avatar.png')
                            : null,
                        child: avatar.isEmpty
                            ? Text(
                                widget.userName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.userName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Obx(() {
                            return chatController.otherUserVerified.value
                                ? Image.asset(
                                    'assets/images/verified.png',
                                    width: 16,
                                    height: 16,
                                  )
                                : const SizedBox.shrink();
                          }),
                        ],
                      ),
                      Text(
                        isOnline
                            ? 'online'
                            : lastSeen != null
                            ? formatLastSeenHuman(lastSeen)
                            : 'offline',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        body: Column(
          children: [
            // 🔹 Encryption Notice directly below AppBar
            Container(
              width: double.infinity,
              color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Text(
                'Messages are end-to-end encrypted. spiiiq cannot view your messages.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                ),
              ),
            ),

            // 🔹 Chat Messages
            Expanded(
              child: Obx(() {
                if (chatController.messages.isEmpty) {
                  return Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: chatController.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatController.messages[index];
                    final isMe = msg['senderId'] == currentUid;

                    final bool isMarketShare = msg['isMarketShare'] == true;

                    final msgTime = (msg['timestamp'] as Timestamp).toDate();

                    DateTime? prevMsgTime;
                    if (index < chatController.messages.length - 1) {
                      prevMsgTime =
                          (chatController.messages[index + 1]['timestamp']
                                  as Timestamp)
                              .toDate();
                    }

                    final showDateHeader =
                        prevMsgTime == null ||
                        prevMsgTime.year != msgTime.year ||
                        prevMsgTime.month != msgTime.month ||
                        prevMsgTime.day != msgTime.day;

                    return Column(
                      children: [
                        // 🟡 DATE HEADER (CENTERED)
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  formatChatDayLabel(msgTime),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // 🟢 MESSAGE BUBBLE
                        GestureDetector(
                          onTap: () {
                            chatController.setReply(msg);
                          },
                          child: Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 12,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                gradient: isMe
                                    ? LinearGradient(
                                        colors: [
                                          Colors.green.shade600,
                                          Colors.green.shade500,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: isMe
                                    ? null
                                    : isDark
                                    ? Colors.grey.shade900
                                    : Colors.grey.shade300,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (msg['replyTo'] != null)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? Colors.green.shade700.withOpacity(
                                                0.9,
                                              )
                                            : isDark
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border(
                                          left: BorderSide(
                                            color: Colors.greenAccent,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            msg['replyTo']['senderId'] ==
                                                    currentUid
                                                ? 'You'
                                                : widget.userName,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.greenAccent,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            msg['replyTo']['text'],
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (isMarketShare)
                                    GestureDetector(
                                      onTap: () {
                                        // Get.to(
                                        //   () => MarketPage(
                                        //     initialProductId: msg['productId'],
                                        //   ),
                                        // );
                                      },
                                      child: Container(
                                        width: 230,
                                        margin: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isMe
                                              ? Colors.green.shade700
                                              : isDark
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade200,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          border: Border.all(
                                            color: Colors.white12,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            /// ✅ PRODUCT IMAGE
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(18),
                                                  ),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    msg['productImage'] ?? '',
                                                height: 120,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                      height: 120,
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Text(
                                                        "loading...",
                                                        style: TextStyle(
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                      ),
                                                    ),
                                                errorWidget: (_, __, ___) =>
                                                    Container(
                                                      height: 120,
                                                      alignment:
                                                          Alignment.center,
                                                      child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                      ),
                                                    ),
                                              ),
                                            ),

                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  /// ✅ SMALL FEELBLE LABEL
                                                  Text(
                                                    "Shared Product",
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                      color: isDark
                                                          ? Colors.white54
                                                          : Colors.black54,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 6),

                                                  /// ✅ PRODUCT TEXT
                                                  Text(
                                                    msg['productText'] ?? '',
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isMe
                                                          ? Colors.white
                                                          : isDark
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 8),

                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.open_in_new,
                                                        size: 13,
                                                        color: isDark
                                                            ? Colors.white54
                                                            : Colors.black54,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        "Tap to view product",
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: isDark
                                                              ? Colors.white54
                                                              : Colors.black54,
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
                                  RichText(
                                    text: TextSpan(
                                      children: _linkifyText(
                                        msg['text'] ?? '',
                                        isDark,
                                      ),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isMe
                                            ? Colors.white
                                            : isDark
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatBubbleTime(msgTime),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isMe
                                          ? Colors.white70
                                          : isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }),
            ),

            if (showEmojiKeyboard) _buildEmojiPicker(isDark),

            Obx(() {
              final reply = chatController.replyingTo.value;
              if (reply == null) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reply['senderId'] == currentUid
                                ? 'Replying to yourself'
                                : 'Replying',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            reply['text'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: chatController.clearReply,
                    ),
                  ],
                ),
              );
            }),

            // 🔹 Input Bar
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                color: isDark ? Colors.black : Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: messageCtrl,
                                focusNode: messageFocusNode,
                                maxLines: null,
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Type a message',
                                  border: InputBorder.none,
                                ),
                                onTap: () {
                                  if (showEmojiKeyboard) {
                                    setState(() => showEmojiKeyboard = false);
                                  }
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: _toggleEmojiKeyboard,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // CircleAvatar(
                    //   radius: 22,
                    //   backgroundColor: Colors.green,
                    //   child: IconButton(
                    //     icon: const Icon(Icons.send,
                    //         color: Colors.white, size: 20),
                    //     onPressed: () async {
                    //       if (messageCtrl.text.trim().isEmpty) return;
                    //       await chatController.sendMessage(
                    //         otherUid: widget.userId,
                    //         text: messageCtrl.text.trim(),
                    //       );
                    //       messageCtrl.clear();
                    //     },
                    //   ),
                    // ),

                    Obx(() {
                      final sending = chatController.isSending.value;

                      return CircleAvatar(
                        radius: 22,
                        backgroundColor: sending ? Colors.grey : Colors.green,
                        child: IconButton(
                          icon: sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                          onPressed: sending
                              ? null
                              : () {
                                  final text = messageCtrl.text.trim();
                                  if (text.isEmpty) return;

                                  messageCtrl.clear();
                                  chatController.sendMessage(
                                    otherUid: widget.userId,
                                    text: text,
                                  );
                                },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
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
            fontSize: 14,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      );
    }

    String linkText = text.substring(match.start, match.end);

    // Ensure link starts with https:// if missing
    if (!linkText.startsWith(RegExp(r'https?:\/\/'))) {
      linkText = 'https://$linkText';
    }

    spans.add(
      TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(
          fontSize: 14,
          color: Colors.blue,
          fontStyle: FontStyle.italic,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final Uri url = Uri.parse(linkText);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              print('Could not launch $linkText');
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
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  return spans;
}
