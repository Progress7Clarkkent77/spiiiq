import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:spiiiq/controllers/account_controller.dart';
import 'package:spiiiq/controllers/chat_list_controller.dart';
import 'package:spiiiq/controllers/status_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:spiiiq/controllers/verified_controller.dart';
import 'package:spiiiq/pages/home.dart';

/// Design tokens (same palette as the profile screen).
const Color _gold = Color(0xFFD4B26A);
const Color _ink = Color(0xFF0B0B0D);

class _Tk {
  const _Tk(this.dark);
  final bool dark;

  Color get bg => dark ? _ink : const Color(0xFFF5F5F3);
  Color get surface => dark ? const Color(0xFF141416) : Colors.white;
  Color get field => dark ? const Color(0xFF1B1B1E) : const Color(0xFFF5F5F3);
  Color get line => dark ? const Color(0xFF242428) : const Color(0xFFE7E6E1);
  Color get text => dark ? const Color(0xFFF4F4F5) : const Color(0xFF111113);
  Color get sub => dark ? const Color(0xFF8E8E96) : const Color(0xFF6B6B73);
  Color get hint => dark ? const Color(0xFF5E5E66) : const Color(0xFF9A9AA2);
  Color get accent => dark ? Colors.white : _ink;
  Color get onAccent => dark ? _ink : Colors.white;
  Color get ring => dark ? _gold : const Color(0xFF9A7B3A);
}

class AddStatus extends StatefulWidget {
  final String userName;
  final String userEmail;

  const AddStatus({super.key, required this.userName, required this.userEmail});

  @override
  State<AddStatus> createState() => _AddStatusState();
}

class _AddStatusState extends State<AddStatus> {
  static const int _maxLength = 80;

  final ChatListController controller = Get.put(ChatListController());
  final ThemeController themeCtrl = Get.put(ThemeController());
  final AccountController accountController = Get.put(AccountController());

  // Put once in initState, not on every build().
  late final StatusController statusCtrl;

  final TextEditingController inputCtrl = TextEditingController();

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

    statusCtrl = Get.put(StatusController());

    accountController.fetchUserInfo();
    accountController.fetchWalletAddress();
    accountController.toggleBalanceVisibility();
    accountController.fetchWalletDetails();
    accountController.fetchWalletData();
  }

  @override
  void dispose() {
    inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    HapticFeedback.lightImpact();

    final text = inputCtrl.text.trim();

    await statusCtrl.postStatus(text, widget.userName, widget.userEmail);

    if (!mounted) return;

    inputCtrl.clear();

    Get.to(
      () => Home(
        userName: accountController.userName.value,
        userEmail: accountController.userEmail.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userInitial = widget.userName.isNotEmpty
        ? widget.userName[0].toUpperCase()
        : '?';

    return Obx(() {
      final t = _Tk(themeCtrl.isDarkMode.value);
      final avatar = accountController.avatarName.value;
      final isVerified = Get.find<VerifiedController>().isVerified.value;

      return Scaffold(
        backgroundColor: t.bg,
        appBar: AppBar(
          backgroundColor: t.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          iconTheme: IconThemeData(color: t.text),
          title: Text(
            'Post update',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: t.text,
            ),
          ),
        ),

        /// Post button stays pinned above the keyboard
        bottomNavigationBar: SafeArea(
          child: Container(
            color: t.bg,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Obx(() {
              final isPosting = statusCtrl.isPosting.value;

              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isPosting ? null : _post,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: t.accent,
                    foregroundColor: t.onAccent,
                    disabledBackgroundColor: t.accent.withAlpha(0x66),
                    disabledForegroundColor: t.onAccent,
                    textStyle: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: isPosting
                        ? SizedBox(
                            key: const ValueKey('posting'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: t.onAccent,
                            ),
                          )
                        : const Row(
                            key: ValueKey('idle'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Post'),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_upward_rounded, size: 20),
                            ],
                          ),
                  ),
                ),
              );
            }),
          ),
        ),

        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Container(
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: t.line),
                boxShadow: t.dark
                    ? const []
                    : const [
                        BoxShadow(
                          color: Color(0x0A000000),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// USER HEADER
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [t.ring, t.ring.withAlpha(0x22)],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: t.surface,
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: t.field,
                            backgroundImage: avatar.isNotEmpty
                                ? AssetImage('assets/images/$avatar.png')
                                : null,
                            child: avatar.isEmpty
                                ? Text(
                                    userInitial,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: t.text,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.userName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                      color: t.text,
                                    ),
                                  ),
                                ),
                                if (isVerified) ...[
                                  const SizedBox(width: 5),
                                  Image.asset(
                                    "assets/images/verified.png",
                                    width: 15,
                                    height: 15,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              obfuscateEmail(widget.userEmail),
                              style: TextStyle(fontSize: 12.5, color: t.sub),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// COMPOSER (borderless, the card is the field)
                  TextField(
                    controller: inputCtrl,
                    autofocus: true,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: _maxLength,
                    cursorColor: t.ring,
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      letterSpacing: -0.2,
                      color: t.text,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: "Share something with everyone...",
                      hintStyle: TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        letterSpacing: -0.2,
                        color: t.hint,
                      ),
                    ),
                  ),

                  /// IMAGE PREVIEW
                  Obx(() {
                    final image = statusCtrl.selectedImageBytes.value;

                    return AnimatedSize(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: image == null
                          ? const SizedBox(width: double.infinity)
                          : Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.memory(
                                      image,
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        statusCtrl.selectedImageBytes.value =
                                            null;
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Color(0x99000000),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    );
                  }),

                  const SizedBox(height: 14),
                  Divider(height: 1, thickness: 1, color: t.line),
                  const SizedBox(height: 12),

                  /// TOOLBAR: add image on the left, live counter on the right
                  Row(
                    children: [
                      Material(
                        color: t.field,
                        shape: StadiumBorder(side: BorderSide(color: t.line)),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            statusCtrl.pickImageFromDevice();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 19,
                                  color: t.text,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Image",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: t.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: inputCtrl,
                        builder: (_, value, __) {
                          final len = value.text.length;
                          final nearLimit = len >= _maxLength - 10;

                          return Text(
                            '$len/$_maxLength',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              color: nearLimit ? t.ring : t.sub,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
