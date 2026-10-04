import 'package:spiiiq/controllers/e_login_controller.dart';
import 'package:spiiiq/controllers/theme_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class spiiiqRewardPolicyScreen extends StatefulWidget {
  spiiiqRewardPolicyScreen({super.key});

  @override
  State<spiiiqRewardPolicyScreen> createState() =>
      _spiiiqRewardPolicyScreenState();
}

class _spiiiqRewardPolicyScreenState extends State<spiiiqRewardPolicyScreen> {
  final ThemeController themeCtrl = Get.find<ThemeController>();
  final AuthController authController = Get.find<AuthController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _markPolicyAsSeen();
  }

  Future<void> _markPolicyAsSeen() async {
    final userId = authController.currentUser!.uid;

    await _firestore.collection('e-users').doc(userId).update({
      'policySeen': true,
      'policySeenAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = themeCtrl.isDarkMode.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: isDark ? Colors.black : Colors.white,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              Get.offNamed('/home');
            },
          ),
          title: Text(
            'About SPIIIQ',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          child: Center(
            child: Container(
              width: 720,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: _policyContent(isDark),
            ),
          ),
        ),
      );
    });
  }

  Widget _policyContent(bool isDark) {
    TextStyle header = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: isDark ? Colors.white : Colors.black,
    );

    TextStyle body = TextStyle(
      fontSize: 14,
      height: 1.8,
      color: isDark ? Colors.white70 : Colors.black87,
    );

    TextStyle italicBody = TextStyle(
      fontSize: 12.5,
      height: 1.5,
      fontStyle: FontStyle.italic,
      color: isDark ? Colors.white60 : Colors.black54,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Icon(
            Icons.public,
            size: 55,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),

        const SizedBox(height: 18),

        Center(
          child: Text(
            'Welcome to SPIIIQ',
            style: header.copyWith(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'SPIIIQ is a modern social-sharing platform designed '
          'to make expressing yourself, sharing ideas, and '
          'connecting with others simple and engaging.\n\n'
          'Whether you want to share your thoughts, publish '
          'pictures, discover interesting content, or interact '
          'with a community, SPIIIQ provides a space where '
          'your voice and creativity matter.',
          style: body,
          textAlign: TextAlign.justify,
        ),

        const SizedBox(height: 26),

        Text('Our Vision', style: header.copyWith(fontSize: 16)),

        const SizedBox(height: 10),

        Text(
          'We believe social platforms should make communication '
          'more meaningful, encourage creativity, and bring '
          'people closer together.\n\n'
          'SPIIIQ aims to create a simple and engaging digital '
          'environment where people can express themselves, '
          'discover new perspectives, and build connections.',
          style: body,
          textAlign: TextAlign.justify,
        ),

        const SizedBox(height: 26),

        Text('About AFIA SPLENDID LTD', style: header.copyWith(fontSize: 16)),

        const SizedBox(height: 10),

        Text(
          'SPIIIQ is a product of AFIA SPLENDID LTD, a Nigerian '
          'technology company dedicated to building innovative '
          'digital platforms that connect people, empower '
          'businesses, and strengthen communities.\n\n'
          'Through technology and innovation, AFIA SPLENDID LTD '
          'is building an ecosystem of digital products designed '
          'to create meaningful experiences and contribute to '
          'the future of technology in Africa.',
          style: body,
          textAlign: TextAlign.justify,
        ),

        const SizedBox(height: 26),

        Center(
          child: Column(
            children: [
              Text(
                'AFIA SPLENDID LTD',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Innovate. Connect. Empower.',
                style: italicBody,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Divider(color: isDark ? Colors.white24 : Colors.black12),

              const SizedBox(height: 12),

              Text(
                'SPIIIQ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                'Powered by AFIA SPLENDID LTD',
                style: italicBody,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text('In God We Trust', style: italicBody),
            ],
          ),
        ),
      ],
    );
  }
}
