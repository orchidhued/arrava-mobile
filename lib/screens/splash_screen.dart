import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login.dart';

/// Arrava Editorial Splash — 1:1 port dari HTML splash screen
/// Background putih, emblem 152px, wordmark ARRAVA + tagline,
/// dengan koreografi logoReveal / wordmarkEntrance / taglineEntrance
/// dan exit dissolve 2350ms → Login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _wordmarkCtrl;
  late final AnimationController _taglineCtrl;
  late final AnimationController _exitCtrl;

  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _wordmarkOpacity;
  late final Animation<Offset> _wordmarkOffset;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineOffset;
  late final Animation<double> _exitOpacity;
  late final Animation<double> _exitScale;
  late final Animation<Offset> _exitOffset;
  late final Animation<double> _veilOpacity;

  static const _easeEmphasized = Cubic(0.16, 1, 0.3, 1);
  static const _easeExit = Cubic(0.4, 0, 0.2, 1);

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _wordmarkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _logoOpacity = CurvedAnimation(parent: _logoCtrl, curve: _easeEmphasized);
    _logoScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: _easeEmphasized),
    );

    _wordmarkOpacity = CurvedAnimation(parent: _wordmarkCtrl, curve: _easeEmphasized);
    _wordmarkOffset = Tween<Offset>(
      begin: const Offset(0, 12 / 400), // ~12px translateY
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _wordmarkCtrl, curve: _easeEmphasized));

    _taglineOpacity = CurvedAnimation(parent: _taglineCtrl, curve: _easeEmphasized);
    _taglineOffset = Tween<Offset>(
      begin: const Offset(0, 8 / 400),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _taglineCtrl, curve: _easeEmphasized));

    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitCtrl, curve: _easeExit),
    );
    _exitScale = Tween<double>(begin: 1.0, end: 1.025).animate(
      CurvedAnimation(parent: _exitCtrl, curve: _easeExit),
    );
    _exitOffset = Tween<Offset>(begin: Offset.zero, end: const Offset(0, -4 / 400)).animate(
      CurvedAnimation(parent: _exitCtrl, curve: _easeExit),
    );
    _veilOpacity = CurvedAnimation(parent: _exitCtrl, curve: _easeExit);

    _runChoreography();
  }

  void _runChoreography() {
    // HTML: logo 0.3s delay, wordmark 0.8s, tagline 1.3s, exit 2.35s
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _logoCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _wordmarkCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (mounted) _taglineCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 2350), () {
      if (!mounted) return;
      _exitCtrl.forward().whenComplete(_navigateToLogin);
    });
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _wordmarkCtrl.dispose();
    _taglineCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect prefers-reduced-motion → accessibleNavigation / disableAnimations
    final reduceMotion = MediaQuery.of(context).accessibleNavigation ||
        MediaQuery.of(context).disableAnimations;

    // Jika reduceMotion, langsung tampil tanpa animasi, tapi tetap dissolve 2.35s
    if (reduceMotion) {
      return _buildStaticScaffold();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Brand content dengan exit transition (opacity + scale + translateY)
          AnimatedBuilder(
            animation: _exitCtrl,
            builder: (context, child) {
              return Opacity(
                opacity: _exitOpacity.value,
                child: Transform.translate(
                  offset: Offset(0, _exitOffset.value.dy * MediaQuery.of(context).size.height),
                  child: Transform.scale(
                    scale: _exitScale.value,
                    child: child,
                  ),
                ),
              );
            },
            child: _buildBrandCore(),
          ),
          // Transition veil (fixed inset-0 pointerEvents none, bg white opacity 0→100, 500ms)
          AnimatedBuilder(
            animation: _veilOpacity,
            builder: (_, __) => IgnorePointer(
              child: Container(
                color: Colors.white.withOpacity(_veilOpacity.value),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticScaffold() {
    // Tanpa animasi sama sekali, tapi tetap auto-navigate 2.35s
    Future.delayed(const Duration(milliseconds: 2350), _navigateToLogin);
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBrandCoreStatic(),
    );
  }

  Widget _buildBrandCore() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              // px-8 = 32, padding-bottom 5vh (optical center ~46%)
              padding: EdgeInsets.fromLTRB(
                32,
                0,
                32,
                MediaQuery.of(context).size.height * 0.05,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Emblem — 152px, p-[3px], ring slate-100, shadow
                  FadeTransition(
                    opacity: _logoOpacity,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        width: 152,
                        height: 152,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x140F172A), // 0F172A @ 8%
                              blurRadius: 32,
                              offset: Offset(0, 12),
                              spreadRadius: -8,
                            ),
                            BoxShadow(
                              color: Color(0x0A0F172A), // 0F172A @ 4%
                              blurRadius: 12,
                              offset: Offset(0, 4),
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo_arrava.jpg',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFE2E8F0),
                              child: const Icon(Icons.school_rounded, size: 56, color: Color(0xFF0F172A)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32), // mb-8
                  // Wordmark ARRAVA — 28px/30px, 700, tracking 0.24em + pl 0.24em untuk centering
                  FadeTransition(
                    opacity: _wordmarkOpacity,
                    child: SlideTransition(
                      position: _wordmarkOffset,
                      child: Transform.translate(
                        // kompensasi pl-[0.24em] agar optically center
                        offset: const Offset(3.6, 0),
                        child: Text(
                          'ARRAVA',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 0.24 * 28 * 0.07, // ~0.24em (≈6.7px)
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14), // mt-3.5
                  // Tagline — 15px/16px, 400, #475569, tracking 0.015em
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: SlideTransition(
                      position: _taglineOffset,
                      child: Text(
                        'Temukan cara belajarmu.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF475569),
                          letterSpacing: 0.015 * 15,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandCoreStatic() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(32, 0, 32, MediaQuery.of(context).size.height * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 152,
                    height: 152,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                      boxShadow: const [
                        BoxShadow(color: Color(0x140F172A), blurRadius: 32, offset: Offset(0, 12), spreadRadius: -8),
                        BoxShadow(color: Color(0x0A0F172A), blurRadius: 12, offset: Offset(0, 4), spreadRadius: -4),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/images/logo_arrava.jpg', fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Transform.translate(
                    offset: const Offset(3.6, 0),
                    child: Text(
                      'ARRAVA',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: 6.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Temukan cara belajarmu.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF475569),
                      letterSpacing: 0.225,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
