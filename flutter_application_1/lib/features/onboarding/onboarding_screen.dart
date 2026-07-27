import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';

/// ============================================================
/// MANCHITRA — Animated Onboarding Flow with Durga Puja Photos
/// ============================================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _pulseController;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      header: 'EXPLORE KOLKATA',
      bgTitle: 'Welcome to Pandal Hopping',
      bgSubtitle: 'Discover the Grandeur of Durga Puja',
      title: 'Explore 150+ Pandals',
      subtitle: 'Navigate Kolkata with our interactive AI map, real photos, and live crowd tracking.',
      imageUrl: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784039272/inauguration-ceremony-of-the-57th-year-of-youth-association-of-mohammad-ali-park-durga-puja-6_culxki.jpg',
      tag: 'Festive Map 2026',
      activeColor: AppColors.primary,
      buttonBg: AppColors.primary,
      buttonTextColor: Colors.white,
    ),
    _OnboardingData(
      header: 'AI TRIP PLANNER',
      bgTitle: 'Smart Route Guidance',
      bgSubtitle: 'Save Hours of Traffic & Queueing',
      title: 'AI Personal Guide',
      subtitle: 'Get customized itineraries tailored to your dates, favorite pandals, and crowd preferences.',
      imageUrl: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784040526/pexels-kolkatarchobiwala-15873620_nswflq.jpg',
      tag: 'Crowd Intelligence',
      activeColor: AppColors.secondary,
      buttonBg: AppColors.secondary,
      buttonTextColor: Colors.black,
    ),
    _OnboardingData(
      header: 'LIVE DIRECTIONS',
      bgTitle: 'Metro, Walking & Cabs',
      bgSubtitle: 'Seamless City Transit Routes',
      title: 'Smart Navigation',
      subtitle: 'Open real-time step-by-step directions to any Barowari or Bonedi Bari pandal in Bengal.',
      imageUrl: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784040072/ed6f162b-dea4-40ea-90d8-6612efc37222_1_105_c_k0rks6.jpg',
      tag: 'Live Navigation',
      activeColor: Color(0xFF785900),
      buttonBg: AppColors.primary,
      buttonTextColor: Colors.white,
    ),
    _OnboardingData(
      header: 'JOIN THE CELEBRATION',
      bgTitle: 'Manchitra App',
      bgSubtitle: 'Your Complete Durga Puja Companion',
      title: 'The Puja Awaits',
      subtitle: 'Sign in to save your trip plans, sync hop lists, and experience the carnival like never before.',
      imageUrl: 'https://res.cloudinary.com/mizoda0v/image/upload/v1784785653/map_server_pandals/gz0mxgphysfyg0ykqiyb.jpg',
      tag: 'Grand Carnival',
      activeColor: AppColors.primary,
      buttonBg: AppColors.primary,
      buttonTextColor: Colors.white,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
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

          // Header Text
          Positioned(
            top: 54,
            left: 20,
            right: 20,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: Column(
                key: ValueKey<int>(_currentPage),
                children: [
                  Text(
                    page.header,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    page.bgTitle,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    page.bgSubtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // High-Res Image Carousel Area (Middle)
          Positioned(
            top: 130,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.44,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) {
                return _buildPhotoCard(_pages[i], i == _currentPage);
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
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),
            ),

          // Floating Card at bottom
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title with smooth transition
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _pages[_currentPage].title,
                      key: ValueKey<int>(_currentPage),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _pages[_currentPage].subtitle,
                      key: ValueKey<int>(_currentPage + 10),
                      style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bottom Controls
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
                            color: _currentPage == index ? page.activeColor : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Get Started Full Button
                    GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                        width: double.infinity,
                        height: 52,
                        decoration: BoxDecoration(
                          color: page.buttonBg,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: page.buttonBg.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
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
                                color: _currentPage == index ? page.activeColor : Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        // Next button
                        GestureDetector(
                          onTap: _nextPage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: page.buttonBg,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: page.buttonBg.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
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
                                  Icons.arrow_forward_rounded,
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

  Widget _buildPhotoCard(_OnboardingData page, bool isActive) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final double scale = isActive ? 1.0 + (_pulseController.value * 0.02) : 0.94;

        return Transform.scale(
          scale: scale,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    page.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: AppColors.primaryContainer,
                        child: const Center(
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.primaryContainer,
                      child: const Icon(Icons.temple_hindu, color: AppColors.primary, size: 64),
                    ),
                  ),

                  // Overlay Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.65),
                        ],
                      ),
                    ),
                  ),

                  // Tag Pill at top left
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AppColors.secondary, size: 12),
                          const SizedBox(width: 6),
                          Text(
                            page.tag,
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    required this.imageUrl,
    required this.tag,
    required this.activeColor,
    required this.buttonBg,
    required this.buttonTextColor,
  });

  final String header;
  final String bgTitle;
  final String bgSubtitle;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String tag;
  final Color activeColor;
  final Color buttonBg;
  final Color buttonTextColor;
}
