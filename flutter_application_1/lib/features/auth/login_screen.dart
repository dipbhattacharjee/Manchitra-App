import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';

/// ============================================================
/// MANCHITRA — Login / Authentication Screen (Glassmorphic Redesign)
/// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _getOTP() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _googleSignIn() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _guestBrowse() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Howrah Bridge / Kolkata sunset)
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1558431382-27e303142255?w=800',
              fit: BoxFit.cover,
            ),
          ),

          // Dark overlay to ensure readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.45),
            ),
          ),

          // Main Glassmorphic Container
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.18),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // App Title: Manchitra in Red/Crimson bold
                          Text(
                            'Manchitra',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFC8363C),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Durga Silhouette graphic painter container
                          SizedBox(
                            width: 220,
                            height: 200,
                            child: CustomPaint(
                              painter: _DurgaSilhouettePainter(),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // OR CONTINUE WITH divider line
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'OR CONTINUE WITH',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withOpacity(0.5),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.25),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Button 1: Continue with Google (White pill, black text)
                          GestureDetector(
                            onTap: _googleSignIn,
                            child: Container(
                              height: 54,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: const Center(
                                      child: Text(
                                        'G',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF4285F4),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Continue with Google',
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Button 2: Continue with Mobile (Charcoal pill, white text)
                          GestureDetector(
                            onTap: () {
                              // Focus input or show phone entry snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please enter mobile below')),
                              );
                            },
                            child: Container(
                              height: 54,
                              decoration: BoxDecoration(
                                color: const Color(0xFF282828),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.phone_iphone_outlined,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Continue with Mobile',
                                    style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Button 3: Send OTP (Red pill, white text)
                          GestureDetector(
                            onTap: _getOTP,
                            child: Container(
                              height: 54,
                              decoration: BoxDecoration(
                                color: const Color(0xFFB32A2F),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFB32A2F).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isLoading)
                                    const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  else ...[
                                    Text(
                                      'Send OTP',
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Bottom Guest Link (Gold text)
                          GestureDetector(
                            onTap: _guestBrowse,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Skip and explore as Guest',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFFFC003),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFFFFC003),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Paints the premium dark silhouette of Goddess Durga with ten arms
class _DurgaSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    // Draw central base/body silhouette (cone shape like in screenshot)
    final bodyPath = Path()
      ..moveTo(center.dx - 45, size.height - 15)
      ..lineTo(center.dx + 45, size.height - 15)
      ..lineTo(center.dx + 16, center.dy)
      ..lineTo(center.dx - 16, center.dy)
      ..close();
    canvas.drawPath(bodyPath, paint);

    // Draw Face circle
    canvas.drawCircle(center - const Offset(0, 16), 14, paint);

    // Draw glowing third eye in center
    final eyePaint = Paint()
      ..color = const Color(0xFFC8363C)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center - const Offset(0, 16), 2, eyePaint);

    // Draw crown triangle/arch
    final crownPath = Path()
      ..moveTo(center.dx - 18, center.dy - 30)
      ..lineTo(center.dx + 18, center.dy - 30)
      ..lineTo(center.dx, center.dy - 60)
      ..close();
    canvas.drawPath(crownPath, paint);

    // Draw 10 Symmetrical arms radiating outwards
    // 5 on left, 5 on right
    final armPaint = Paint()
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final double startY = center.dy - 5;

    // Symmetrical bezier paths for arms
    final armConfigs = [
      // config: (endXOffset, endYOffset, controlXOffset, controlYOffset)
      [-75.0, -40.0, -50.0, -70.0], // Top left
      [-85.0, -10.0, -70.0, -35.0], // Mid-high left
      [-90.0, 15.0, -75.0, 5.0],    // Mid left
      [-80.0, 45.0, -65.0, 35.0],   // Mid-low left
      [-65.0, 70.0, -45.0, 60.0],   // Low left
    ];

    for (var config in armConfigs) {
      final endXLeft = center.dx + config[0];
      final endYLeft = startY + config[1];
      final ctrlXLeft = center.dx + config[2];
      final ctrlYLeft = startY + config[3];

      final endXRight = center.dx - config[0];
      final endYRight = startY + config[1];
      final ctrlXRight = center.dx - config[2];
      final ctrlYRight = startY + config[3];

      // Left arm path
      final pathLeft = Path()
        ..moveTo(center.dx, startY)
        ..quadraticBezierTo(ctrlXLeft, ctrlYLeft, endXLeft, endYLeft);
      canvas.drawPath(pathLeft, armPaint);

      // Right arm path
      final pathRight = Path()
        ..moveTo(center.dx, startY)
        ..quadraticBezierTo(ctrlXRight, ctrlYRight, endXRight, endYRight);
      canvas.drawPath(pathRight, armPaint);

      // Draw mini weapon tip/dot at the end of each arm
      canvas.drawCircle(Offset(endXLeft, endYLeft), 4, paint);
      canvas.drawCircle(Offset(endXRight, endYRight), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
