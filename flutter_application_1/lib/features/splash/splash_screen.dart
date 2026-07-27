import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/theme.dart';
import '../profile/profile_data.dart';

/// ============================================================
/// MANCHITRA — Premium Durga Puja Animated Splash Screen
/// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _progressValue;
  bool _isSlowInit = false;
  Timer? _slowTimer;

  @override
  void initState() {
    super.initState();

    _slowTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _isSlowInit = true);
    });

    // Ripple rings animation (looping)
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Logo entrance animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // Text entrance animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<double>(begin: 25, end: 0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    // Progress bar animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _progressValue = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOutQuad),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _logoController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _textController.forward();
        _progressController.forward();
      }
    });

    // Auto navigate quickly after 1.5 seconds for instant app responsiveness
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          ProfileData.email = currentUser.email ?? '';
          ProfileData.name = currentUser.displayName ??
              (currentUser.email != null ? currentUser.email!.split('@')[0] : 'User');
          if (currentUser.photoURL != null) {
            ProfileData.photoUrl = currentUser.photoURL!;
          }
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pushReplacementNamed('/onboarding');
        }
      }
    });
  }

  @override
  void dispose() {
    _slowTimer?.cancel();
    _rippleController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF140306),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // High-Res Durga Puja Background Image
          Image.network(
            'https://res.cloudinary.com/mizoda0v/image/upload/v1784040526/pexels-kolkatarchobiwala-15873620_nswflq.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),

          // Dark Burgundy & Saffron Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF2A080C).withOpacity(0.75),
                  const Color(0xFF140306).withOpacity(0.92),
                  const Color(0xFF090103).withOpacity(0.98),
                ],
              ),
            ),
          ),

          // Main Center Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Durga Maa / Dhak Ripple Stack
                SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 3 Pulsating Dhak Rings
                      ...List.generate(3, (i) => _buildRippleRing(i)),

                      // Logo Badge
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) => Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: _buildDurgaLogo(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // App Title & Tagline with Gradient Shimmer
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) => Opacity(
                    opacity: _textOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _textSlide.value),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Manchitra',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.primary.withOpacity(0.8),
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 12),
                                const SizedBox(width: 6),
                                Text(
                                  'KOLKATA DURGA PUJA GUIDE & MAP',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.secondary,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // Animated Glowing Loading Bar
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) => Opacity(
                    opacity: _textOpacity.value,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 180,
                          height: 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) => LinearProgressIndicator(
                                value: _progressValue.value,
                                backgroundColor: Colors.white12,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) => Column(
                            children: [
                              Text(
                                'Loading 150+ Pandals... ${(_progressValue.value * 100).toInt()}%',
                                style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white60,
                                ),
                              ),
                              if (_isSlowInit) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Still loading... Please wait',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRippleRing(int index) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        final offset = index / 3.0;
        final value = (_rippleController.value + offset) % 1.0;
        final size = 110.0 + (value * 150.0);
        final opacity = (1.0 - value) * 0.45;

        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.secondary.withOpacity(opacity),
              width: 1.5,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDurgaLogo() {
    return Container(
      width: 115,
      height: 115,
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          colors: [Color(0xFFC8363C), Color(0xFF700B1A)],
          center: Alignment.center,
          radius: 0.85,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.secondary, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.5),
            blurRadius: 35,
            spreadRadius: 8,
          ),
        ],
      ),
      child: CustomPaint(
        painter: _AlponaRingPainter(),
        child: const Center(
          child: Icon(
            Icons.temple_hindu_rounded,
            size: 54,
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}

class _AlponaRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = AppColors.secondary.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * math.pi;
      final x = center.dx + (radius - 12) * math.cos(angle);
      final y = center.dy + (radius - 12) * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 2.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
