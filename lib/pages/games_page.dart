import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:spiiiq/controllers/word_throne_controller.dart';
import 'package:spiiiq/pages/word_throne_round_page.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  final ThemeController themeCtrl = Get.find<ThemeController>();
  final WordThroneController ctrl = WordThroneController.ensure();
  final String? _myUid = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    ctrl.loadMyStats();
  }

  Future<void> _start() async {
    final ok = await ctrl.startRound();
    if (!ok) return;

    await Get.to(
      () => const WordThroneRoundPage(),
      transition: Transition.cupertino,
    );

    // Back in the lobby: refresh points and attempts.
    ctrl.loadMyStats();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;
      final Color fg = isDark ? Colors.white : Colors.black87;
      final Color sub = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
          title: Text(
            'Word Throne',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            _buildHero(isDark, fg),
            const SizedBox(height: 14),
            _buildStats(isDark, fg, sub),
            const SizedBox(height: 14),
            _buildStartButton(isDark),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Win a round to earn a reward '
                '(up to ${WordThroneController.maxRewardedWinsPerDay} '
                'rewarded wins a day) and ${WordThroneController.winBonusPoints} '
                'bonus points.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11.5, height: 1.4, color: sub),
              ),
            ),
            const SizedBox(height: 26),
            Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            const SizedBox(height: 10),
            _buildLeaderboard(isDark, fg, sub),
          ],
        ),
      );
    });
  }

  // =====================================================================
  // HERO — name + how to play
  // =====================================================================
  Widget _buildHero(bool isDark, Color fg) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white : Colors.black,
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 24,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Take the throne',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _rule(
            '1',
            'You get 5 random letters and '
                '${WordThroneController.roundSeconds} seconds.',
            fg,
            isDark,
          ),
          _rule(
            '2',
            'Type ${WordThroneController.wordsToWin} different real words. '
                'Each one must start with one of the letters.',
            fg,
            isDark,
          ),
          _rule(
            '3',
            'Finish before time runs out to win the round.',
            fg,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _rule(String n, String text, Color fg, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white12 : Colors.black12,
            ),
            child: Text(
              n,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13.5, height: 1.4, color: fg),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================================
  // MY STATS
  // =====================================================================
  Widget _buildStats(bool isDark, Color fg, Color sub) {
    Widget tile(String label, String value) => Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black12,
            width: 0.8,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11.5, color: sub)),
          ],
        ),
      ),
    );

    return Row(
      children: [
        tile('Points', '${ctrl.myPoints.value}'),
        const SizedBox(width: 10),
        tile('Wins', '${ctrl.myWins.value}'),
        const SizedBox(width: 10),
        tile(
          'Attempts left',
          '${ctrl.attemptsLeft}/${WordThroneController.maxRoundsPerDay}',
        ),
      ],
    );
  }

  // =====================================================================
  // START BUTTON
  // =====================================================================
  Widget _buildStartButton(bool isDark) {
    final loading = ctrl.isStarting.value;
    final noAttempts = ctrl.attemptsLeft <= 0;
    final enabled = !loading && !noAttempts;

    String label = 'Start round';
    if (noAttempts) label = 'Come back tomorrow';

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : Colors.black,
          disabledBackgroundColor: isDark ? Colors.white24 : Colors.black26,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: enabled ? _start : null,
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isDark ? Colors.black : Colors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
      ),
    );
  }

  // =====================================================================
  // LEADERBOARD — top 20 by total points
  // =====================================================================
  Widget _buildLeaderboard(bool isDark, Color fg, Color sub) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: ctrl.leaderboardStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'Could not load the leaderboard.',
                style: TextStyle(color: sub),
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        final docs = snapshot.data!.docs
            .where((d) => ((d.data()['totalPoints'] as num?) ?? 0) > 0)
            .toList();

        if (docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No scores yet. Be the first on the throne.',
                style: TextStyle(color: sub),
              ),
            ),
          );
        }

        return Column(
          children: [
            for (int i = 0; i < docs.length; i++)
              _buildRow(i + 1, docs[i].data(), isDark, fg, sub),
          ],
        );
      },
    );
  }

  Widget _buildRow(
    int rank,
    Map<String, dynamic> data,
    bool isDark,
    Color fg,
    Color sub,
  ) {
    final uid = (data['uid'] ?? '').toString();
    final isMe = _myUid != null && uid == _myUid;
    final rawName = (data['name'] ?? '').toString().trim();
    final name = rawName.isEmpty ? 'Anonymous User' : rawName;
    final points = (data['totalPoints'] as num?)?.toInt() ?? 0;
    final wins = (data['wins'] as num?)?.toInt() ?? 0;

    Widget rankBadge;
    if (rank <= 3) {
      const medals = [Color(0xFFD4AF37), Color(0xFFB0B7C3), Color(0xFFCD7F32)];
      rankBadge = Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: medals[rank - 1],
        ),
        child: Text(
          '$rank',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      );
    } else {
      rankBadge = SizedBox(
        width: 28,
        child: Center(
          child: Text(
            '$rank',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: sub,
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? (isDark ? const Color(0xFF1F2C34) : const Color(0xFFE8F5F1))
            : (isDark ? const Color(0xFF111111) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          rankBadge,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMe ? '$name (you)' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                Text(
                  '$wins ${wins == 1 ? 'win' : 'wins'}',
                  style: TextStyle(fontSize: 11.5, color: sub),
                ),
              ],
            ),
          ),
          Text(
            '$points pts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
