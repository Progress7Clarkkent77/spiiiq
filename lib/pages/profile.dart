import 'dart:ui' show FontFeature;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:spiiiq/controllers/account_controller.dart';
import 'package:spiiiq/controllers/balance_controller.dart';
import 'package:spiiiq/controllers/e_login_controller.dart';
import 'package:spiiiq/controllers/referral_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:spiiiq/controllers/verified_controller.dart';
import 'package:spiiiq/pages/avatar_screen.dart';
import 'package:spiiiq/pages/pay_history.dart';
import 'package:spiiiq/pages/withdrawal_page.dart';

/// ─────────────────────────────────────────────────────────────
/// DESIGN TOKENS
/// One place for every colour. Gold is the single accent and is
/// only used on the avatar ring and the wallet card.
/// ─────────────────────────────────────────────────────────────
const Color _gold = Color(0xFFD4B26A);
const Color _ink = Color(0xFF0B0B0D);
const Color _danger = Color(0xFFE5484D);

class _Tk {
  const _Tk(this.dark);
  final bool dark;

  Color get bg => dark ? _ink : const Color(0xFFF5F5F3);
  Color get surface => dark ? const Color(0xFF141416) : Colors.white;
  Color get field => dark ? const Color(0xFF1B1B1E) : const Color(0xFFF5F5F3);
  Color get line => dark ? const Color(0xFF242428) : const Color(0xFFE7E6E1);
  Color get text => dark ? const Color(0xFFF4F4F5) : const Color(0xFF111113);
  Color get sub => dark ? const Color(0xFF8E8E96) : const Color(0xFF6B6B73);
  Color get accent => dark ? Colors.white : _ink;
  Color get onAccent => dark ? _ink : Colors.white;
  Color get ring => dark ? _gold : const Color(0xFF9A7B3A);
}

const _tabular = [FontFeature.tabularFigures()];

void _snack(bool isDark, String title, String message) {
  final t = _Tk(isDark);
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: t.surface,
    colorText: t.text,
    borderColor: t.line,
    borderWidth: 1,
    borderRadius: 16,
    margin: const EdgeInsets.all(14),
  );
}

/// Shared dialog used by every confirmation in this file.
void _showAppDialog({
  required bool isDark,
  required String title,
  required List<Widget> body,
  required String confirmLabel,
  required VoidCallback onConfirm,
  Color? confirmColor,
  Color? confirmTextColor,
  bool showCancel = true,
  bool barrierDismissible = false,
}) {
  final t = _Tk(isDark);

  Get.dialog(
    Dialog(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: t.line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: t.text,
              ),
            ),
            const SizedBox(height: 10),
            ...body,
            const SizedBox(height: 24),
            Row(
              children: [
                if (showCancel) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        side: BorderSide(color: t.line),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: t.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: confirmColor ?? t.accent,
                      foregroundColor: confirmTextColor ?? t.onAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onConfirm,
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
    barrierDismissible: barrierDismissible,
  );
}

Widget _dialogText(_Tk t, String text) =>
    Text(text, style: TextStyle(fontSize: 13.5, height: 1.55, color: t.sub));

/// Standard card surface: hairline border, one soft shadow in light mode.
class _Surface extends StatelessWidget {
  const _Surface({
    required this.t,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  final _Tk t;
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);

    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
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
      child: Material(
        color: t.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: t.line),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// SCREEN
/// ─────────────────────────────────────────────────────────────
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final ThemeController themeCtrl = Get.find();
  final AccountController accountCtrl = Get.find();
  final VerifiedController verifiedCtrl = Get.find();
  final AuthController authCtrl = Get.find();
  final ReferController referCtrl = Get.put(ReferController());
  final AvailableBalanceController balanceCtrl = Get.put(
    AvailableBalanceController(),
  );

  final ScrollController scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Obx(() {
      final t = _Tk(themeCtrl.isDarkMode.value);

      return Scaffold(
        backgroundColor: t.bg,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          backgroundColor: t.bg,
          iconTheme: IconThemeData(color: t.text),
          title: Text(
            "Profile",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: t.text,
            ),
          ),
        ),
        body: RefreshIndicator(
          color: t.accent,
          backgroundColor: t.surface,
          onRefresh: () async {
            accountCtrl.fetchUserInfo();
            balanceCtrl.listenToBalance();
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: ListView(
            controller: scrollController,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: const [
              ProfileHeader(),
              SizedBox(height: 28),
              WalletCard(),
              SizedBox(height: 16),
              ReferralCard(),
              SizedBox(height: 16),
              DeleteCard(),
            ],
          ),
        ),
      );
    });
  }
}

/// ─────────────────────────────────────────────────────────────
/// HEADER  (no card, the avatar sits directly on the page)
/// ─────────────────────────────────────────────────────────────
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final accountCtrl = Get.find<AccountController>();
    final verifiedCtrl = Get.find<VerifiedController>();
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final t = _Tk(themeCtrl.isDarkMode.value);
      final avatar = accountCtrl.avatarName.value;
      final name = accountCtrl.userName.value;

      return Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Hero(
                tag: "profile_avatar",
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [t.ring, t.ring.withAlpha(0x22)],
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.bg,
                    ),
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: t.surface,
                      backgroundImage: avatar.isNotEmpty
                          ? AssetImage("assets/images/$avatar.png")
                          : null,
                      child: avatar.isEmpty
                          ? Text(
                              name.isEmpty ? "?" : name[0].toUpperCase(),
                              style: TextStyle(
                                color: t.text,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () => Get.to(() => const AvatarSelectionScreen()),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: t.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: t.bg, width: 3),
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      size: 14,
                      color: t.onAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.8,
                    color: t.text,
                  ),
                ),
              ),
              if (verifiedCtrl.isVerified.value) ...[
                const SizedBox(width: 6),
                Image.asset(
                  "assets/images/verified.png",
                  width: 20,
                  height: 20,
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            accountCtrl.userEmail.value,
            style: TextStyle(fontSize: 14, color: t.sub),
          ),
        ],
      );
    });
  }
}

/// Kept for when the verification flow is switched back on.
void showVerificationDialog(bool isDark) {
  final t = _Tk(isDark);

  Widget benefit(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_rounded, size: 18, color: t.ring),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, height: 1.4, color: t.text),
          ),
        ),
      ],
    ),
  );

  _showAppDialog(
    isDark: isDark,
    title: 'Get verified',
    confirmLabel: 'Continue',
    onConfirm: () {
      Get.back();
      // verifiedCtrl.verifyWithPaystack();
    },
    body: [
      _dialogText(
        t,
        'Verification unlocks higher visibility and trust for 30 days on '
        'SpiiiQ. Verified users are prioritized across posts, comments, and '
        'channels.',
      ),
      const SizedBox(height: 16),
      benefit('Up to 3× more exposure on posts'),
      benefit('Priority placement for posts and comments'),
      benefit('A visible verified badge'),
      benefit('Increased chances of reactions'),
      const SizedBox(height: 4),
      Text(
        'Verification does not change reward rates. Higher earnings come '
        'from increased visibility and engagement.',
        style: TextStyle(
          fontSize: 12,
          height: 1.5,
          fontStyle: FontStyle.italic,
          color: t.sub,
        ),
      ),
    ],
  );
}

/// ─────────────────────────────────────────────────────────────
/// WALLET  (the one memorable element: always a dark metal card)
/// ─────────────────────────────────────────────────────────────
class WalletCard extends StatefulWidget {
  const WalletCard({super.key});

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  final themeCtrl = Get.find<ThemeController>();
  final balanceCtrl = Get.find<AvailableBalanceController>();
  final authCtrl = Get.find<AuthController>();

  final RxBool hideBalance = false.obs;
  final RxBool busy = false.obs;

  Future<void> _withdraw(bool isDark) async {
    final user = authCtrl.currentUser;
    if (user == null || busy.value) return;

    busy.value = true;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('e-users')
          .doc(user.uid)
          .get();

      final verified = doc.exists && doc.data()?['withdraw_verify'] == true;

      if (verified) {
        Get.to(() => WithdrawPage());
        return;
      }

      final ok = await authCtrl.checkWithdrawVerification();

      if (ok) {
        Get.to(() => WithdrawPage());
        return;
      }

      await authCtrl.sendWithdrawVerificationEmail();

      final t = _Tk(isDark);
      _showAppDialog(
        isDark: isDark,
        title: 'Withdrawal locked',
        confirmLabel: 'OK',
        showCancel: false,
        barrierDismissible: true,
        onConfirm: () => Get.back(),
        body: [
          _dialogText(
            t,
            'Verify your email before withdrawing. A verification email has '
            'been sent to your inbox.',
          ),
        ],
      );
    } finally {
      busy.value = false;
    }
  }

  Widget _amount() {
    final s = balanceCtrl.avlBal.value.toStringAsFixed(5);
    final dot = s.indexOf('.');
    final head = dot == -1 ? s : s.substring(0, dot + 3);
    final tail = dot == -1 ? '' : s.substring(dot + 3);

    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: '\$',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFFA9A9B0),
            ),
          ),
          TextSpan(
            text: head,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.4,
              color: Colors.white,
            ),
          ),
          TextSpan(
            text: tail,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6E6E76),
            ),
          ),
        ],
      ),
      style: const TextStyle(fontFeatures: _tabular),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;
      final hidden = hideBalance.value;

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF242428), Color(0xFF0F0F11)],
          ),
          border: Border.all(color: const Color(0x33D4B26A)),
          boxShadow: isDark
              ? const []
              : const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 32,
                    offset: Offset(0, 16),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                top: -70,
                right: -50,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x2ED4B26A), Color(0x00D4B26A)],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            "Available balance",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF9A9AA2),
                            ),
                          ),
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: hidden ? 'Show balance' : 'Hide balance',
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            hideBalance.toggle();
                          },
                          icon: Icon(
                            hidden
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: const Color(0xFF9A9AA2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 50,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: hidden
                            ? const Align(
                                key: ValueKey('hidden'),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "••••••",
                                  style: TextStyle(
                                    fontSize: 36,
                                    letterSpacing: 4,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Align(
                                key: const ValueKey('shown'),
                                alignment: Alignment.centerLeft,
                                child: _amount(),
                              ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: busy.value
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _ink,
                                    ),
                                  )
                                : const Icon(
                                    Icons.north_east_rounded,
                                    size: 18,
                                  ),
                            label: const Text("Withdraw"),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: _gold,
                              foregroundColor: _ink,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: busy.value
                                ? null
                                : () => _withdraw(isDark),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.history_rounded, size: 18),
                            label: const Text("History"),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              foregroundColor: Colors.white,
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.1,
                              ),
                              side: const BorderSide(color: Color(0x33FFFFFF)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () =>
                                Get.to(() => const PayHistoryPage()),
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
      );
    });
  }
}

/// ─────────────────────────────────────────────────────────────
/// REFERRAL
/// ─────────────────────────────────────────────────────────────
class ReferralCard extends StatefulWidget {
  const ReferralCard({super.key});

  @override
  State<ReferralCard> createState() => _ReferralCardState();
}

class _ReferralCardState extends State<ReferralCard> {
  final themeCtrl = Get.find<ThemeController>();
  final AuthController authController = Get.find<AuthController>();
  final ReferController referController = Get.isRegistered<ReferController>()
      ? Get.find<ReferController>()
      : Get.put(ReferController());

  final RxString referCode = ''.obs;
  final RxBool isLoading = true.obs;

  @override
  void initState() {
    super.initState();
    _loadReferCode();
  }

  Future<void> _loadReferCode() async {
    final uid = authController.currentUser?.uid;

    if (uid == null) {
      isLoading.value = false;
      return;
    }

    try {
      referCode.value = await authController.ensureReferCode(uid);
    } catch (e) {
      _snack(
        themeCtrl.isDarkMode.value,
        'Error',
        'Could not load your referral code. Pull to refresh and try again.',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _copy() {
    HapticFeedback.lightImpact();
    referController.copyReferralText();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final t = _Tk(themeCtrl.isDarkMode.value);

      final code = isLoading.value
          ? '••••••'
          : (referCode.value.isEmpty ? '—' : referCode.value);

      return _Surface(
        t: t,
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Invite friends",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                color: t.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Earn rewards when a new user signs up with your code.",
              style: TextStyle(fontSize: 13.5, height: 1.5, color: t.sub),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _copy,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: t.field,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: t.line),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        code,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 3,
                          fontFeatures: _tabular,
                          color: t.text,
                        ),
                      ),
                    ),
                    Icon(Icons.copy_rounded, size: 18, color: t.sub),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.ios_share_rounded, size: 18),
                label: const Text("Copy referral code"),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: t.accent,
                  foregroundColor: t.onAccent,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _copy,
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// ─────────────────────────────────────────────────────────────
/// DELETE ACCOUNT  (quiet row instead of a loud red button)
/// ─────────────────────────────────────────────────────────────
class DeleteCard extends StatelessWidget {
  const DeleteCard({super.key});

  void _confirmDelete(bool isDark) {
    final t = _Tk(isDark);
    final accountCtrl = Get.find<AccountController>();

    _showAppDialog(
      isDark: isDark,
      title: 'Delete account',
      confirmLabel: 'Delete',
      confirmColor: _danger,
      confirmTextColor: Colors.white,
      body: [
        _dialogText(
          t,
          'This will permanently delete your account and all associated '
          'data, including your posts and comments. This action cannot be '
          'undone.',
        ),
      ],
      onConfirm: () async {
        Get.back(); // close dialog first

        try {
          await accountCtrl.deleteAccount();
        } catch (e) {
          _snack(
            isDark,
            'Error',
            'Could not delete account. Please try again.',
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = Get.find<ThemeController>();

    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;
      final t = _Tk(isDark);

      return _Surface(
        t: t,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        onTap: () => _confirmDelete(isDark),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1AE5484D),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: _danger,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Delete account",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _danger,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Permanently remove your account and data",
                    style: TextStyle(fontSize: 12.5, color: t.sub),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: t.sub),
          ],
        ),
      );
    });
  }
}
