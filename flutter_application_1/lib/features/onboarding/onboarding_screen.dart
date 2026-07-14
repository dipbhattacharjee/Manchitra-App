import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================
/// MANCHITRA — Onboarding Flow (Premium 4-Page Redesign)
/// ============================================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      header: 'Explore Kolkata',
      bgTitle: 'Welcome to Pandal Hopping',
      bgSubtitle: 'Discover the Grandeur of Durga Puja',
      title: 'Explore in 3D',
      subtitle: 'Navigate the city with our interactive AI-powered map. Discover famous pandals and hidden gems.',
      illustrationType: 'explore_3d',
      activeColor: Color(0xFFAF101A),
      buttonBg: Color(0xFFAF101A),
      buttonTextColor: Colors.white,
    ),
    _OnboardingData(
      header: '',
      bgTitle: '',
      bgSubtitle: '',
      title: 'AI Personal Guide',
      subtitle: 'Get personalized recommendations based on your favorites, weather, and live crowd insights.',
      illustrationType: 'lotus',
      activeColor: Color(0xFFFDC003),
      buttonBg: Color(0xFFFDC003),
      buttonTextColor: Colors.black,
    ),
    _OnboardingData(
      header: '',
      bgTitle: '',
      bgSubtitle: '',
      title: 'Smart Trip Planning',
      subtitle: 'Optimize your routes to avoid crowds. Choose your dates and let AI craft your perfect itinerary.',
      illustrationType: 'smart_nav',
      activeColor: Color(0xFF785900),
      buttonBg: Color(0xFFB32A2F),
      buttonTextColor: Colors.white,
    ),
    _OnboardingData(
      header: 'Manchitra',
      bgTitle: '',
      bgSubtitle: '',
      title: 'The Puja Awaits',
      subtitle: 'Sign in to save your plans and sync across devices. Experience the festival like never before.',
      illustrationType: 'phone_lotus',
      activeColor: Color(0xFFAF101A),
      buttonBg: Color(0xFFAF101A),
      buttonTextColor: Colors.white,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic);
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  void _skipOnboarding() {
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: Stack(
        children: [
          // Background soft gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFEFDFB),
                    Color(0xFFF5F2EA),
                  ],
                ),
              ),
            ),
          ),

          // Background Texts for Page 1
          if (_currentPage == 0 && page.bgTitle.isNotEmpty)
            Positioned(
              top: 72,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text(
                    page.header,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF785900),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    page.bgTitle,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF785900),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    page.bgSubtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          // Background Title for Page 4
          if (_currentPage == 3 && page.header.isNotEmpty)
            Positioned(
              top: 72,
              left: 20,
              right: 20,
              child: Center(
                child: Text(
                  page.header,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFAF101A),
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),

          // Illustration Area (Middle/Top)
          Positioned(
            top: _currentPage == 0 ? 110 : 60,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.52,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) {
                return _buildIllustration(_pages[i]);
              },
            ),
          ),

          // Skip Button at top right
          if (_currentPage < 3)
            Positioned(
              top: 48,
              right: 16,
              child: GestureDetector(
                onTap: _skipOnboarding,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),

          // Floating white card at the bottom
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _pages[_currentPage].title,
                      key: ValueKey<int>(_currentPage),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _pages[_currentPage].subtitle,
                      key: ValueKey<int>(_currentPage + 10),
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // If page 4, render the full-width layout
                  if (_currentPage == 3) ...[
                    // Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index ? page.activeColor : Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Full-width Get Started Button
                    GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: page.buttonBg,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sign In text link
                    GestureDetector(
                      onTap: _skipOnboarding,
                      child: Text(
                        'Sign In',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFAF101A),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Pages 1, 2, 3 side-by-side controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Dots Indicator
                        Row(
                          children: List.generate(
                            _pages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(right: 6),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index ? page.activeColor : Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        // Next button
                        GestureDetector(
                          onTap: _nextPage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                            decoration: BoxDecoration(
                              color: page.buttonBg,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Next',
                                  style: TextStyle(
                                    color: page.buttonTextColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward,
                                  color: page.buttonTextColor,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(_OnboardingData page) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glowing background (only for pages 2, 3, 4)
          if (page.illustrationType != 'explore_3d')
            Container(
              width: 290,
              height: 290,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFF7E0).withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

          // Illustration card / circle
          if (page.illustrationType == 'explore_3d')
            // Page 1 Isometric map style container
            Container(
              width: 320,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CustomPaint(
                  painter: _IllustrationPainter(page.illustrationType),
                ),
              ),
            )
          else
            // Circles for pages 2, 3, 4
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFFFFF2F0),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: CustomPaint(
                  painter: _IllustrationPainter(page.illustrationType),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.header,
    required this.bgTitle,
    required this.bgSubtitle,
    required this.title,
    required this.subtitle,
    required this.illustrationType,
    required this.activeColor,
    required this.buttonBg,
    required this.buttonTextColor,
  });

  final String header;
  final String bgTitle;
  final String bgSubtitle;
  final String title;
  final String subtitle;
  final String illustrationType;
  final Color activeColor;
  final Color buttonBg;
  final Color buttonTextColor;
}

class _IllustrationPainter extends CustomPainter {
  _IllustrationPainter(this.type);
  final String type;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (type == 'explore_3d') {
      // Draw 3D Isometric Map background
      final roadPaint = Paint()
        ..color = const Color(0xFFF3EDE0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      final buildingPaint = Paint()
        ..color = const Color(0xFFEFECE5)
        ..style = PaintingStyle.fill;

      final buildingBorder = Paint()
        ..color = const Color(0xFFE2DDD5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      // Draw stylized grid lines representing isometric blocks
      for (int i = -4; i < 8; i++) {
        canvas.drawLine(
          Offset(0, i * 40.0),
          Offset(size.width, i * 40.0 + 80),
          roadPaint,
        );
        canvas.drawLine(
          Offset(i * 50.0, 0),
          Offset(i * 50.0 - 100, size.height),
          roadPaint,
        );
      }

      // Draw some isometric building shapes
      void drawBlock(double cx, double cy) {
        final path = Path()
          ..moveTo(cx, cy - 15)
          ..lineTo(cx + 25, cy - 5)
          ..lineTo(cx + 25, cy + 15)
          ..lineTo(cx, cy + 25)
          ..lineTo(cx - 25, cy + 15)
          ..lineTo(cx - 25, cy - 5)
          ..close();
        canvas.drawPath(path, buildingPaint);
        canvas.drawPath(path, buildingBorder);
      }

      drawBlock(80, 80);
      drawBlock(240, 100);
      drawBlock(140, 170);

      // Draw some location pin markers (like gold pin in screenshot 1)
      final pinPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFDF9E), Color(0xFFFABD00)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      void drawPin(double px, double py) {
        final pinPath = Path()
          ..moveTo(px, py)
          ..cubicTo(px - 10, py - 18, px - 12, py - 26, px, py - 32)
          ..cubicTo(px + 12, py - 26, px + 10, py - 18, px, py)
          ..close();
        canvas.drawPath(pinPath, pinPaint);

        // draw center circle
        final centerPaint = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(px, py - 22), 4, centerPaint);
      }

      drawPin(100, 120);
      drawPin(220, 150);
      drawPin(150, 200);

    } else if (type == 'lotus') {
      // Golden lotus (Screenshot 2)
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFDF9E),
            Color(0xFFFABD00),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      // Draw central glow particles
      final particlePaint = Paint()..color = const Color(0xFFFABD00).withOpacity(0.5);
      canvas.drawCircle(center + const Offset(-45, -50), 3, particlePaint);
      canvas.drawCircle(center + const Offset(55, -45), 4, particlePaint);
      canvas.drawCircle(center + const Offset(-35, 45), 2, particlePaint);
      canvas.drawCircle(center + const Offset(50, 35), 3, particlePaint);

      // Draw circular glow waves
      final wavePaint = Paint()
        ..color = const Color(0xFFFFDF9E).withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, 90, wavePaint);
      canvas.drawCircle(center, 110, wavePaint);

      // Lotus petals
      final path = Path();
      path.moveTo(center.dx, center.dy - 55);
      path.quadraticBezierTo(center.dx - 22, center.dy - 5, center.dx, center.dy + 35);
      path.quadraticBezierTo(center.dx + 22, center.dy - 5, center.dx, center.dy - 55);

      path.moveTo(center.dx, center.dy - 45);
      path.quadraticBezierTo(center.dx - 50, center.dy - 15, center.dx - 18, center.dy + 30);
      path.quadraticBezierTo(center.dx - 5, center.dy + 10, center.dx, center.dy - 45);

      path.moveTo(center.dx, center.dy - 45);
      path.quadraticBezierTo(center.dx + 50, center.dy - 15, center.dx + 18, center.dy + 30);
      path.quadraticBezierTo(center.dx + 5, center.dy + 10, center.dx, center.dy - 45);

      canvas.drawPath(path, paint);

      final supportPaint = Paint()
        ..color = const Color(0xFF785900).withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawArc(
        Rect.fromCenter(center: center + const Offset(0, 25), width: 90, height: 30),
        0,
        3.14,
        false,
        supportPaint,
      );

    } else if (type == 'smart_nav') {
      // Smart Navigation (Screenshot 3)
      final roadPaint = Paint()
        ..color = const Color(0xFF785900).withOpacity(0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      // Draw overlapping futuristic route paths
      final path1 = Path()
        ..moveTo(center.dx - 70, center.dy - 20)
        ..cubicTo(center.dx - 30, center.dy - 50, center.dx + 30, center.dy + 50, center.dx + 70, center.dy + 20);
      canvas.drawPath(path1, roadPaint);

      final path2 = Path()
        ..moveTo(center.dx - 70, center.dy + 30)
        ..cubicTo(center.dx - 20, center.dy - 60, center.dx + 40, center.dy - 30, center.dx + 70, center.dy - 10);
      canvas.drawPath(path2, roadPaint);

      // Draw a mini train & vehicle shapes
      final vehiclePaint = Paint()..color = const Color(0xFF785900);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center + const Offset(-20, -10), width: 34, height: 16),
          const Radius.circular(4),
        ),
        vehiclePaint,
      );

      final trainPaint = Paint()..color = const Color(0xFFAF101A);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center + const Offset(20, 15), width: 44, height: 14),
          const Radius.circular(4),
        ),
        trainPaint,
      );

      // Pedestrian icon dot
      canvas.drawCircle(center + const Offset(-45, 20), 6, Paint()..color = const Color(0xFF785900));

    } else if (type == 'phone_lotus') {
      // Phone frame containing golden lotus (Screenshot 4)
      final phonePaint = Paint()
        ..color = const Color(0xFFE4E2DE)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      // Draw Phone frame
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: 110, height: 180),
          const Radius.circular(16),
        ),
        phonePaint,
      );

      // Draw camera notch
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(center.dx - 20, center.dy - 82, 40, 6),
          const Radius.circular(3),
        ),
        Paint()..color = const Color(0xFFE4E2DE),
      );

      // Draw mini lotus inside phone
      final miniLotusPaint = Paint()
        ..style = PaintingStyle.fill
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFDF9E),
            Color(0xFFFABD00),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      final miniLotusPath = Path();
      final miniCenter = center + const Offset(0, 10);
      miniLotusPath.moveTo(miniCenter.dx, miniCenter.dy - 30);
      miniLotusPath.quadraticBezierTo(miniCenter.dx - 12, miniCenter.dy - 3, miniCenter.dx, miniCenter.dy + 20);
      miniLotusPath.quadraticBezierTo(miniCenter.dx + 12, miniCenter.dy - 3, miniCenter.dx, miniCenter.dy - 30);
      canvas.drawPath(miniLotusPath, miniLotusPaint);

      // Draw Blessings Await subtext inside phone
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'Blessings\nAwait!',
          style: TextStyle(
            color: Color(0xFF785900),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy - 45),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


