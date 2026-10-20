import 'package:spiiiq/controllers/ads_controller.dart';

import 'package:spiiiq/controllers/moderation_controller.dart';

import 'package:spiiiq/controllers/referral_controller.dart';
import 'package:spiiiq/controllers/reward_controller.dart';
import 'package:spiiiq/controllers/status_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:spiiiq/controllers/user_controller.dart';
import 'package:spiiiq/pages/home.dart';
import 'package:spiiiq/controllers/user_presence_controller.dart';
import 'package:spiiiq/controllers/verified_controller.dart';
import 'package:spiiiq/pages/forgotpassword.dart';
import 'package:spiiiq/services/fcm_background.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:spiiiq/controllers/account_controller.dart';

import 'package:spiiiq/controllers/e_login_controller.dart';

import 'package:spiiiq/pages/earn_login.dart';

import 'package:spiiiq/pages/onboarding.dart';
import 'package:spiiiq/pages/policy.dart';
import 'package:spiiiq/pages/profile.dart';

import 'package:url_strategy/url_strategy.dart';

import 'firebase_options.dart';

final FluroRouter router = FluroRouter();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Web clean URL
  setPathUrlStrategy();

  // ✅ Initialize Firebase ONLY (keep startup light)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ✅ Run app immediately (VERY IMPORTANT for low RAM)
  runApp(const MyApp());

  // 🔥 Initialize heavy services AFTER UI loads
  _initBackgroundServices();
}

Future<void> _initBackgroundServices() async {
  await GetStorage.init();

  await Future.wait([
    // FCMService.init(),
    // LocalNotificationService.init(),
  ]);
}

/// 🔥 LAZY CONTROLLER INITIALIZATION
void initControllers() {
  Get.lazyPut(() => AuthController(), fenix: true);

  Get.lazyPut(() => ModerationController(), fenix: true);

  Get.lazyPut(() => AccountController(), fenix: true);

  Get.lazyPut(() => ThemeController(), fenix: true);
  Get.lazyPut(() => VerifiedController(), fenix: true);
  Get.lazyPut(() => RewardController(), fenix: true);
  Get.lazyPut(() => ReferController(), fenix: true);

  // 🔥 Social / heavy controllers (NO permanent)
  Get.lazyPut(() => UserPresenceController(), fenix: true);
  Get.lazyPut(() => UserController(), fenix: true);
  //Get.lazyPut(() => ChatController(), fenix: true);
  Get.lazyPut(() => StatusController(), fenix: true);

  Get.lazyPut(() => AdsController(), fenix: true);

  // 🔹 HotGist category controllers — lazy so each is only created
  // when its screen is first opened, and disposed (listeners
  // cancelled via onClose) when no longer referenced.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Color getMainColor(BuildContext context) {
    bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return isDarkMode ? Colors.black : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Initialize controllers lazily
    initControllers();
    return GetMaterialApp(
      title: 'spiiiq',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: router.generator,
      initialRoute: '/',
      routes: {
        '/': (context) => const Onboarding(),
        '/onboarding': (context) => const Onboarding(),

        '/home': (context) => Home(userName: '', userEmail: ''),
        // '/history': (context) => TransactionHistory(),
        // '/documentation': (context) => Documentation(),
        '/login': (context) => const EarnLogin(),
        '/signup': (context) => const EarnSignUp(),
        '/forgotpassword': (context) => ForgotPassword(),
        '/profile': (context) => ProfileScreen(),
        '/policy': (context) => spiiiqRewardPolicyScreen(),
      },
    );
  }
}
