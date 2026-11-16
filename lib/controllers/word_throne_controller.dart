import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:spiiiq/controllers/account_controller.dart';
import 'package:spiiiq/controllers/reward_controller.dart';

class WordThroneController extends GetxController {
  static WordThroneController ensure() =>
      Get.isRegistered<WordThroneController>()
      ? Get.find<WordThroneController>()
      : Get.put(WordThroneController());

  // ---- Game settings (change these to tune the game) ------------------
  static const int roundSeconds = 80;
  static const int wordsToWin = 10;
  static const int minWordLength = 3;
  static const int pointsPerWord = 1;
  static const int winBonusPoints = 10;

  /// Attempts per day. Stops people spamming rounds to inflate the board.
  static const int maxRoundsPerDay = 10;

  /// Rewarded wins per day. Wins after this still earn points, no reward.
  static const int maxRewardedWinsPerDay = 3;

  /// Letters a round can draw from (skips rare starters like Q, X, Z).
  static const String _vowels = 'AEIOU';
  static const String _consonants = 'BCDFGHLMNPRSTW';

  /// Every round has at least this many vowels among its 5 letters.
  static const int minVowels = 2;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  RewardController get _rewardCtrl => Get.find<RewardController>();

  // ---- Word checking --------------------------------------------------
  /// Optional bundled list (instant answers). Empty if the asset is missing.
  final Set<String> _localWords = <String>{};

  /// Online answers already received this session: word -> is it valid.
  final Map<String, bool> _verified = <String, bool>{};

  static const Duration _dictionaryApiTimeout = Duration(seconds: 4);
  static const Duration _datamuseTimeout = Duration(seconds: 3);
  static const Duration _gracePeriod = Duration(seconds: 5);

  // ---- Round state ----------------------------------------------------
  /// 'idle' | 'playing' | 'finished'
  final RxString status = 'idle'.obs;
  final RxList<String> letters = <String>[].obs;
  final RxList<String> words = <String>[].obs;
  final RxInt secondsLeft = roundSeconds.obs;
  final RxString feedback = ''.obs;
  final RxBool feedbackIsError = false.obs;
  final RxBool isStarting = false.obs;

  /// Words submitted and waiting for an online answer.
  final RxList<String> pendingWords = <String>[].obs;

  /// True once the round time is over (input locks, last checks finish).
  final RxBool isTimeUp = false.obs;

  // ---- Result of the last round --------------------------------------
  final RxBool lastWon = false.obs;
  final RxInt lastPoints = 0.obs;
  final RxBool lastRewarded = false.obs;
  final RxBool isSaving = false.obs;

  // ---- My stats -------------------------------------------------------
  final RxInt myPoints = 0.obs;
  final RxInt myWins = 0.obs;
  final RxInt roundsToday = 0.obs;
  final RxInt rewardedWinsToday = 0.obs;

  int get attemptsLeft =>
      (maxRoundsPerDay - roundsToday.value).clamp(0, maxRoundsPerDay);

  Timer? _timer;
  Timer? _graceTimer;
  DateTime? _endsAt;

  /// Changes every round so late answers from an old round are ignored.
  int _roundToken = 0;

  /// Top 20 players by total points.
  late final Stream<QuerySnapshot<Map<String, dynamic>>> leaderboardStream =
      _firestore
          .collection('gameScores')
          .orderBy('totalPoints', descending: true)
          .limit(20)
          .snapshots();

  @override
  void onInit() {
    super.onInit();
    _loadDictionary();
    loadMyStats();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _graceTimer?.cancel();
    super.onClose();
  }

  // =====================================================================
  // OPTIONAL BUNDLED WORD LIST
  // =====================================================================
  Future<void> _loadDictionary() async {
    if (_localWords.isNotEmpty) return;

    try {
      final raw = await rootBundle.loadString('assets/words/words.txt');

      _localWords.addAll(
        raw.split('\n').map((w) => w.trim()).where((w) => w.isNotEmpty),
      );
    } catch (_) {
      // Not an error: the game falls back to the online dictionaries.
      if (kDebugMode) {
        print('ℹ️ Bundled word list not found, using online dictionaries.');
      }
    }
  }

  // =====================================================================
  // MY STATS
  // =====================================================================
  Future<void> loadMyStats() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    try {
      final score = await _firestore
          .collection('gameScores')
          .doc(user.uid)
          .get(const GetOptions(source: Source.serverAndCache));
      final s = score.data() ?? <String, dynamic>{};

      myPoints.value = (s['totalPoints'] as num?)?.toInt() ?? 0;
      myWins.value = (s['wins'] as num?)?.toInt() ?? 0;

      final daily = await _dailyRef(user.uid)
          .get(const GetOptions(source: Source.serverAndCache));
      final d = daily.data() ?? <String, dynamic>{};

      roundsToday.value = (d['rounds'] as num?)?.toInt() ?? 0;
      rewardedWinsToday.value = (d['rewardedWins'] as num?)?.toInt() ?? 0;
    } catch (e) {
      if (kDebugMode) print('❌ Word Throne stats error: $e');
    }
  }

  // =====================================================================
  // START A ROUND
  // ---------------------------------------------------------------------
  // The attempt is counted when the round starts, so quitting mid-round
  // to re-roll the letters still uses it up.
  // =====================================================================
  Future<bool> startRound() async {
    if (isStarting.value || status.value == 'playing') return false;

    final user = _firebaseAuth.currentUser;
    if (user == null) return false;

    isStarting.value = true;
    try {
      final ref = _dailyRef(user.uid);

      final allowed = await _firestore.runTransaction<bool>((tx) async {
        final snap = await tx.get(ref);
        final rounds = (snap.data()?['rounds'] as num?)?.toInt() ?? 0;

        if (rounds >= maxRoundsPerDay) return false;

        tx.set(ref, {
          'rounds': rounds + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return true;
      });

      if (!allowed) {
        roundsToday.value = maxRoundsPerDay;
        _notify(
          'No attempts left today',
          'You have used all $maxRoundsPerDay attempts. Come back tomorrow.',
        );
        return false;
      }

      roundsToday.value = roundsToday.value + 1;

      _roundToken++;
      _graceTimer?.cancel();
      letters.assignAll(_pickLetters());
      words.clear();
      pendingWords.clear();
      isTimeUp.value = false;
      feedback.value = '';
      feedbackIsError.value = false;
      lastWon.value = false;
      lastPoints.value = 0;
      lastRewarded.value = false;
      status.value = 'playing';

      _startTimer();
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Start round error: $e');
      _notify('Could not start', 'Please check your connection and try again.');
      return false;
    } finally {
      isStarting.value = false;
    }
  }

  List<String> _pickLetters() {
    final rng = Random();

    final vowels = _vowels.split('')..shuffle(rng);
    final picked = vowels.take(minVowels).toList();

    final rest = <String>[...vowels.skip(minVowels), ..._consonants.split('')]
      ..shuffle(rng);
    picked.addAll(rest.take(5 - minVowels));

    return picked..sort();
  }

  void _startTimer() {
    _timer?.cancel();
    _endsAt = DateTime.now().add(const Duration(seconds: roundSeconds));
    secondsLeft.value = roundSeconds;

    _timer = Timer.periodic(const Duration(milliseconds: 250), (t) {
      final remainingMs = _endsAt!.difference(DateTime.now()).inMilliseconds;
      final secs = (remainingMs / 1000).ceil();
      secondsLeft.value = secs < 0 ? 0 : secs;

      if (remainingMs <= 0) {
        t.cancel();
        _onTimeUp();
      }
    });
  }

  /// The clock hit zero. Words already submitted still get their answers.
  void _onTimeUp() {
    if (status.value != 'playing') return;

    isTimeUp.value = true;

    if (pendingWords.isEmpty) {
      _finishRound(won: words.length >= wordsToWin);
      return;
    }

    _setFeedback('Checking your last words...', error: false);
    _graceTimer?.cancel();
    _graceTimer = Timer(_gracePeriod, () {
      _finishRound(won: words.length >= wordsToWin);
    });
  }

  /// Leaving mid-round: the attempt stays used, no points, no reward.
  void abandonRound() {
    _roundToken++;
    _timer?.cancel();
    _graceTimer?.cancel();
    pendingWords.clear();
    status.value = 'idle';
  }

  // =====================================================================
  // SUBMIT A WORD
  // =====================================================================
  void submitWord(String raw) {
    if (status.value != 'playing' || isTimeUp.value) return;

    final word = raw.trim().toLowerCase();
    if (word.isEmpty) return;

    if (!RegExp(r'^[a-z]+$').hasMatch(word)) {
      _setFeedback('Letters only.', error: true);
      return;
    }
    if (word.length < minWordLength) {
      _setFeedback('Use at least $minWordLength letters.', error: true);
      return;
    }
    if (!letters.contains(word[0].toUpperCase())) {
      _setFeedback('Start with ${letters.join(', ')}.', error: true);
      return;
    }
    if (words.contains(word) || pendingWords.contains(word)) {
      _setFeedback('You already used "$word".', error: true);
      return;
    }

    // Instant answers: already checked, or in the bundled list.
    final known = _verified[word];
    if (known == true || _localWords.contains(word)) {
      _acceptWord(word);
      return;
    }
    if (known == false) {
      _setFeedback('"$word" is not a valid word.', error: true);
      return;
    }

    // Ask the online dictionaries while the clock keeps running.
    pendingWords.add(word);
    _setFeedback('Checking "$word"...', error: false);

    final token = _roundToken;
    _checkOnline(word).then((result) => _onChecked(word, result, token));
  }

  void _onChecked(String word, WordCheck result, int token) {
    if (token != _roundToken) return; // answer from an old round

    pendingWords.remove(word);

    if (status.value != 'playing') return;

    if (result == WordCheck.valid) {
      _verified[word] = true;
      _acceptWord(word);
    } else if (result == WordCheck.invalid) {
      _verified[word] = false;
      _setFeedback('"$word" is not a valid word.', error: true);
    } else {
      _setFeedback(
        'Could not check "$word". Check your connection.',
        error: true,
      );
    }

    // Time already up and nothing left to wait for: end the round.
    if (isTimeUp.value && pendingWords.isEmpty && status.value == 'playing') {
      _finishRound(won: words.length >= wordsToWin);
    }
  }

  void _acceptWord(String word) {
    if (words.contains(word)) return;

    words.add(word);
    _setFeedback('${words.length} of $wordsToWin', error: false);

    if (words.length >= wordsToWin) {
      _timer?.cancel();
      _graceTimer?.cancel();
      _finishRound(won: true);
    }
  }

  void _setFeedback(String message, {required bool error}) {
    feedback.value = message;
    feedbackIsError.value = error;
  }

  Future<WordCheck> _checkOnline(String word) {
    final completer = Completer<WordCheck>();
    int answered = 0;
    bool anyInvalid = false;

    void handle(WordCheck r) {
      if (completer.isCompleted) return;
      answered++;

      if (r == WordCheck.valid) {
        completer.complete(WordCheck.valid); // first "yes" wins
        return;
      }
      if (r == WordCheck.invalid) anyInvalid = true;

      if (answered == 2) {
        completer.complete(
          anyInvalid ? WordCheck.invalid : WordCheck.unavailable,
        );
      }
    }

    _askDictionaryApi(word).then(handle);
    _askDatamuse(word).then(handle);

    return completer.future;
  }

  /// https://api.dictionaryapi.dev — 200 = found, 404 = no such word.
  Future<WordCheck> _askDictionaryApi(String word) async {
    try {
      final res = await http
          .get(
            Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'),
          )
          .timeout(_dictionaryApiTimeout);

      if (res.statusCode == 200) return WordCheck.valid;
      if (res.statusCode == 404) return WordCheck.invalid;
      return WordCheck.unavailable;
    } catch (_) {
      return WordCheck.unavailable;
    }
  }

  /// https://api.datamuse.com — "spelled like" returns the word itself
  /// when it exists, otherwise only similar spellings, so we require an
  /// exact match.
  Future<WordCheck> _askDatamuse(String word) async {
    try {
      final res = await http
          .get(Uri.parse('https://api.datamuse.com/words?sp=$word&max=5'))
          .timeout(_datamuseTimeout);

      if (res.statusCode != 200) return WordCheck.unavailable;

      final data = jsonDecode(res.body);
      if (data is! List) return WordCheck.unavailable;

      final found = data.any((e) => e is Map && e['word'] == word);
      return found ? WordCheck.valid : WordCheck.invalid;
    } catch (_) {
      return WordCheck.unavailable;
    }
  }

  Future<void> _finishRound({required bool won}) async {
    if (status.value != 'playing') return;

    _timer?.cancel();
    _graceTimer?.cancel();
    pendingWords.clear();

    final wordCount = words.length;
    final points = wordCount * pointsPerWord + (won ? winBonusPoints : 0);

    lastWon.value = won;
    lastPoints.value = points;
    lastRewarded.value = false;
    isSaving.value = true;
    status.value = 'finished';

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      // 🏆 Leaderboard points
      await _firestore.collection('gameScores').doc(user.uid).set({
        'uid': user.uid,
        'name': _currentName(),
        'totalPoints': FieldValue.increment(points),
        'wins': FieldValue.increment(won ? 1 : 0),
        'rounds': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      myPoints.value = myPoints.value + points;
      if (won) myWins.value = myWins.value + 1;

      // 🎁 Win reward (same RewardController as the status posts)
      if (won) {
        lastRewarded.value = await _claimWinReward(user.uid);
      }
    } catch (e) {
      if (kDebugMode) print('❌ Finish round error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> _claimWinReward(String uid) async {
    try {
      final ref = _dailyRef(uid);

      final canReward = await _firestore.runTransaction<bool>((tx) async {
        final snap = await tx.get(ref);
        final count = (snap.data()?['rewardedWins'] as num?)?.toInt() ?? 0;

        if (count >= maxRewardedWinsPerDay) return false;

        tx.set(ref, {'rewardedWins': count + 1}, SetOptions(merge: true));
        return true;
      });

      if (!canReward) return false;

      rewardedWinsToday.value = rewardedWinsToday.value + 1;
      await _rewardCtrl.incrementTinyReward(uid: uid);
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Win reward error: $e');
      return false;
    }
  }

  String _dateKey() {
    final n = DateTime.now();
    return '${n.year}-'
        '${n.month.toString().padLeft(2, '0')}-'
        '${n.day.toString().padLeft(2, '0')}';
  }

  DocumentReference<Map<String, dynamic>> _dailyRef(String uid) => _firestore
      .collection('e-users')
      .doc(uid)
      .collection('dailyWordThrone')
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

/// Answer from the word check.
enum WordCheck { valid, invalid, unavailable }
