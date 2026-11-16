import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:spiiiq/controllers/word_throne_controller.dart';

class WordThroneRoundPage extends StatefulWidget {
  const WordThroneRoundPage({super.key});

  @override
  State<WordThroneRoundPage> createState() => _WordThroneRoundPageState();
}

class _WordThroneRoundPageState extends State<WordThroneRoundPage> {
  final ThemeController themeCtrl = Get.find<ThemeController>();
  final WordThroneController ctrl = WordThroneController.ensure();
  final TextEditingController _input = TextEditingController();
  final FocusNode _focus = FocusNode();

  Worker? _statusWorker;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();

    // Show the result dialog the moment the round finishes.
    _statusWorker = ever<String>(ctrl.status, (s) {
      if (s == 'finished' && !_resultShown) {
        _resultShown = true;
        _showResult();
      }
    });
  }

  @override
  void dispose() {
    _statusWorker?.dispose();
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    ctrl.submitWord(_input.text);
    _input.clear();
    _focus.requestFocus();
  }

  // =====================================================================
  // LEAVING MID-ROUND
  // =====================================================================
  Future<bool> _onWillPop() async {
    if (ctrl.status.value != 'playing') return true;

    final leave = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Leave this round?',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: const Text(
          'You will lose this attempt and earn no points.',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Keep playing'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (leave == true) {
      ctrl.abandonRound();
      return true;
    }
    return false;
  }

  // =====================================================================
  // BUILD
  // =====================================================================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Obx(() {
        final isDark = themeCtrl.isDarkMode.value;
        final Color fg = isDark ? Colors.white : Colors.black87;
        final Color sub = isDark ? Colors.grey.shade400 : Colors.grey.shade700;

        return Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.grey.shade50,
          appBar: AppBar(
            backgroundColor: isDark ? Colors.black : Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : Colors.black,
            ),
            title: Text(
              'Word Throne',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: fg,
              ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  children: [
                    _buildTimer(isDark, fg, sub),
                    const SizedBox(height: 22),
                    _buildLetters(isDark),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        'Every word must start with one of these letters.',
                        style: TextStyle(fontSize: 12, color: sub),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildFeedback(isDark),
                    const SizedBox(height: 10),
                    _buildWords(isDark, fg),
                  ],
                ),
              ),
              _buildInputBar(isDark),
            ],
          ),
        );
      }),
    );
  }

  // =====================================================================
  // TIMER + WORD COUNT
  // =====================================================================
  Widget _buildTimer(bool isDark, Color fg, Color sub) {
    final secs = ctrl.secondsLeft.value;
    final low = secs <= 5 && ctrl.status.value == 'playing';
    final fraction = secs / WordThroneController.roundSeconds;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Time', style: TextStyle(fontSize: 12, color: sub)),
                Text(
                  '${secs}s',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: low ? Colors.redAccent : fg,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Words', style: TextStyle(fontSize: 12, color: sub)),
                Text(
                  '${ctrl.words.length}/${WordThroneController.wordsToWin}',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: fg,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: isDark ? Colors.white12 : Colors.black12,
            valueColor: AlwaysStoppedAnimation<Color>(
              low ? Colors.redAccent : (isDark ? Colors.white : Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  // =====================================================================
  // THE 5 LETTERS
  // =====================================================================
  Widget _buildLetters(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ctrl.letters
          .map(
            (l) => Container(
              width: 54,
              height: 64,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? Colors.white : Colors.black,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                l,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // =====================================================================
  // FEEDBACK + ACCEPTED WORDS
  // =====================================================================
  Widget _buildFeedback(bool isDark) {
    final msg = ctrl.feedback.value;
    final isError = ctrl.feedbackIsError.value;

    return SizedBox(
      height: 20,
      child: Center(
        child: Text(
          msg,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isError
                ? Colors.redAccent
                : (isDark ? const Color(0xFF7BD8C5) : const Color(0xFF0B7A66)),
          ),
        ),
      ),
    );
  }

  Widget _buildWords(bool isDark, Color fg) {
    if (ctrl.words.isEmpty && ctrl.pendingWords.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget chip(String w, {required bool checking}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2C34) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (checking) ...[
            SizedBox(
              width: 11,
              height: 11,
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(width: 7),
          ],
          Text(
            w,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: checking ? fg.withOpacity(0.5) : fg,
            ),
          ),
        ],
      ),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        ...ctrl.words.map((w) => chip(w, checking: false)),
        ...ctrl.pendingWords.map((w) => chip(w, checking: true)),
      ],
    );
  }

  // =====================================================================
  // INPUT
  // =====================================================================
  Widget _buildInputBar(bool isDark) {
    final playing = ctrl.status.value == 'playing' && !ctrl.isTimeUp.value;

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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1F2C34)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _input,
                    focusNode: _focus,
                    enabled: playing,
                    autofocus: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.send,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                    ],
                    onSubmitted: (_) => _submit(),
                    style: TextStyle(
                      fontSize: 17,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    cursorColor: isDark ? Colors.white : Colors.black,
                    decoration: InputDecoration(
                      hintText: 'Type a word',
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: playing ? _submit : null,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    size: 22,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================================
  // RESULT DIALOG
  // =====================================================================
  void _showResult() {
    final won = ctrl.lastWon.value;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
            child: Obx(() {
              final saving = ctrl.isSaving.value;
              final rewarded = ctrl.lastRewarded.value;
              final canPlayAgain = ctrl.attemptsLeft > 0;

              String rewardLine;
              if (!won) {
                rewardLine = 'Win a round to earn a reward.';
              } else if (saving) {
                rewardLine = 'Saving your reward...';
              } else if (rewarded) {
                rewardLine = 'Reward added to your balance.';
              } else {
                rewardLine =
                    'Daily reward limit reached. Your points still count.';
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: won ? const Color(0xFFD4AF37) : Colors.black12,
                    ),
                    child: Icon(
                      won
                          ? Icons.workspace_premium_rounded
                          : Icons.timer_off_outlined,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    won ? 'You took the throne!' : "Time's up",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    won
                        ? 'You found all ${WordThroneController.wordsToWin} words.'
                        : 'You found ${ctrl.words.length} of '
                              '${WordThroneController.wordsToWin} words.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '+${ctrl.lastPoints.value} points',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rewardLine,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: saving
                              ? null
                              : () {
                                  Get.back(); // close dialog
                                  Get.back(); // back to the lobby
                                },
                          child: const Text(
                            'Lobby',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            disabledBackgroundColor: Colors.black26,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: (saving || !canPlayAgain)
                              ? null
                              : _playAgain,
                          child: Text(
                            canPlayAgain ? 'Play again' : 'No attempts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _playAgain() async {
    Get.back(); // close the dialog

    final ok = await ctrl.startRound();
    if (ok) {
      _resultShown = false;
      _input.clear();
      _focus.requestFocus();
    } else {
      Get.back(); // no attempt available: back to the lobby
    }
  }
}
