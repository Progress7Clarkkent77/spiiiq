import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spiiiq/controllers/Startup_controller.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineFade;
  late final Animation<double> _footerFade;

  final StartupController startupCtrl = Get.put(StartupController());

  @override
  void initState() {
    super.initState();

    // One orchestrated entrance: logo, then tagline, then footer.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    Animation<double> interval(double begin, double end) => CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );

    _logoFade = interval(0.0, 0.5);
    _logoScale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(interval(0.0, 0.6));
    _taglineFade = interval(0.35, 0.75);
    _footerFade = interval(0.6, 1.0);

    _controller.forward();

    /// ✅ Start app initialization silently
    startupCtrl.initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    final bg = dark ? const Color(0xFF0B0B0D) : const Color(0xFFF5F5F3);
    final text = dark ? const Color(0xFFF4F4F5) : const Color(0xFF111113);
    final sub = dark ? const Color(0xFF8E8E96) : const Color(0xFF6B6B73);
    final gold = dark ? const Color(0xFFD4B26A) : const Color(0xFF9A7B3A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            // Soft gold glow behind the logo
                            Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    gold.withAlpha(dark ? 0x2E : 0x26),
                                    gold.withAlpha(0x00),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: gold.withAlpha(0x55)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(
                                      dark ? 0x66000000 : 0x1F000000,
                                    ),
                                    blurRadius: 32,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(29),
                                child: Image.asset(
                                  'assets/images/spiiq Logo.png',
                                  width: 112,
                                  height: 112,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FadeTransition(
                      opacity: _taglineFade,
                      child: Text(
                        'A voice-first social platform',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
                          color: sub,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Powered-by footer
            FadeTransition(
              opacity: _footerFade,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 1,
                      color: gold.withAlpha(0x88),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Powered by',
                      style: TextStyle(
                        fontSize: 11.5,
                        letterSpacing: 0.4,
                        color: sub,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AFIA SPLENDID LTD',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.8,
                        color: text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
