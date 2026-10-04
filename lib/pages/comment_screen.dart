import 'package:spiiiq/controllers/account_controller.dart';
import 'package:spiiiq/controllers/chat_list_controller.dart';
import 'package:spiiiq/controllers/status_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:spiiiq/widgets/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final DocumentSnapshot statusDoc;

  CommentScreen({
    super.key,
    required this.statusDoc,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final StatusController statusCtrl = Get.find<StatusController>();

  final ThemeController themeCtrl = Get.find<ThemeController>();

  final TextEditingController commentCtrl = TextEditingController();

  final ChatListController controller = Get.put(ChatListController());

  final AccountController accountController = Get.put(AccountController());
  final IconNavigationHandler navigationHandler = IconNavigationHandler();
  // final CurrencyController currencyController = Get.put(CurrencyController());
  // final AddMoneyController addMoneyController = Get.find<AddMoneyController>();
  // final PbcMarketController pbcMarketController =
  //     Get.put(PbcMarketController());

  @override
  void initState() {
    super.initState();
    accountController.fetchUserInfo();
    //accountController.fetchBalances(); // Fetch data on widget load
    // accountController.fetchWalletAddress(); // Fetch wallet address on init
    // accountController.toggleBalanceVisibility();
    // accountController.fetchWalletDetails();
    // accountController
    //     .fetchWalletAddress(); // Fetch wallet address on initialization
    // accountController
    //     .fetchWalletData(); // Fetch both address & publicKey on init
    // addMoneyController.fetchVaultBalance();

    // Watch for email availability and fetch transactions once it's ready
    // ever(addMoneyController.email, (String email) {
    //   if (email.isNotEmpty) {
    //     addMoneyController.fetchTransactions(email);
    //   }
    // });
  }

  /// 🔹 Fetch verified status for the user
  Future<bool> _isVerifiedByEmail(String email) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('e-users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return false;

      return query.docs.first.data()['verified'] == true;
    } catch (e) {
      print('❌ Error checking verification for $email: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.statusDoc.data() as Map<String, dynamic>;
    final Timestamp? postTimestamp = data['timestamp'];
    final postTime = statusCtrl.formatPostTime(postTimestamp);

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      /// 🔹 Watched here so the send button can switch to a spinner while
      /// postComment() is running, the same way ChatController.isSending
      /// drives the send button in the chat screen.
      final sendingComment = statusCtrl.isPostingComment.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          title: const Text(
            'Comments',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: isDark ? Colors.black : Colors.white,
          foregroundColor: isDark ? Colors.white : Colors.black,
          elevation: 0,
        ),

        /// BODY WITH STACK
        body: Stack(
          children: [
            /// 🔹 COMMENTS LIST
            Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  /// 🔹 ORIGINAL POST
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade900
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              data['name'] ?? '',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 4),

                            /// ✅ VERIFIED BADGE
                            /// ✅ VERIFIED BADGE
                            FutureBuilder<bool>(
                              future: _isVerifiedByEmail(data['email'] ?? ''),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox.shrink(); // or tiny loader
                                }
                                final verified = snapshot.data ?? false;
                                if (verified) {
                                  return Image.asset(
                                    'assets/images/verified.png',
                                    width: 16,
                                    height: 16,
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        /// 🔹 TEXT + TIME LAYOUT
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.end, // keeps time at bottom
                          children: [
                            /// 📝 POST TEXT (wraps to multiple lines)
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: _linkifyText(
                                    data['text'] ?? '',
                                    softWrap: true,
                                    isDark,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

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
                  ),

                  const SizedBox(height: 12),
                  const Divider(),

                  /// 🔹 COMMENTS STREAM
                  StreamBuilder<QuerySnapshot>(
                    stream: statusCtrl.commentStream(widget.statusDoc.id),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }

                      final comments = snapshot.data!.docs;

                      if (comments.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No comments yet',
                            style: TextStyle(
                              color: isDark ? Colors.grey : Colors.black54,
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: comments.map((doc) {
                          final c = doc.data() as Map<String, dynamic>;
                          final Timestamp? commentTimestamp = c['timestamp'];
                          final commentTime = statusCtrl.formatPostTime(
                            commentTimestamp,
                          );

                          return Align(
                            alignment: Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.85,
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.grey.shade900
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        /// ✅ COMMENTER NAME
                                        Text(
                                          c['name'] ??
                                              'Anonymous', // <- FIXED HERE
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          commentTime,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: isDark
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      c['text'] ?? '',
                                      softWrap: true,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),

            /// 🔹 FLOATING COMMENT INPUT
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentCtrl,
                        maxLines: null,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Write a reasonable comment...',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey : Colors.black54,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (_) {
                          (context as Element).markNeedsBuild();
                        },
                      ),
                    ),
                    if (commentCtrl.text.trim().length >= 16 || sendingComment)
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isDark
                            ? Colors.white24
                            : Colors.black87,
                        child: IconButton(
                          icon: sendingComment
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                          onPressed: sendingComment
                              ? null
                              : () async {
                                  final text = commentCtrl.text.trim();
                                  if (text.length < 16) return;

                                  commentCtrl.clear();
                                  (context as Element).markNeedsBuild();

                                  await statusCtrl.postComment(
                                    statusId: widget.statusDoc.id,
                                    text: text,
                                  );
                                },
                        ),
                      ),
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

List<TextSpan> _linkifyText(
  String text,
  bool isDark, {
  required bool softWrap,
}) {
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
        style: TextStyle(
          fontSize: 14,
          color: Colors.blue,
          // decoration: TextDecoration.underline,
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
