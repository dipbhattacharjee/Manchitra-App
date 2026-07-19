import 'dart:ui' as ui;
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../profile/profile_data.dart';

/// ============================================================
/// MANCHITRA — Glassmorphic Login Screen (Unified Input)
/// ============================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _inputController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String _loadingLabel = 'Please wait…';
  bool _otpSent = false;
  String _verificationId = '';

  @override
  void dispose() {
    _inputController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // 1. Google Sign-In Flow
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _loadingLabel = 'Signing in with Google…';
    });
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // User cancelled
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      // Update local profile data
      if (user != null) {
        ProfileData.email = user.email ?? googleUser.email;
        ProfileData.name = user.displayName ?? googleUser.displayName ?? ProfileData.name;
        if (user.photoURL != null || googleUser.photoUrl != null) {
          ProfileData.photoUrl = user.photoURL ?? googleUser.photoUrl!;
        }
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      debugPrint('Google Sign-in error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In: $e. Proceeding via preview bypass.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Preview fallback bypass
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. Phone Auth: Send OTP
  Future<void> _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingLabel = 'Sending OTP…';
    });
    final formattedPhone = '+91$phone';

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Firebase Phone verification failed: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification Failed: ${e.message}. Logging in via preview bypass.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Preview fallback bypass
          Navigator.of(context).pushReplacementNamed('/home');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _otpSent = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully to your mobile!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      debugPrint('verifyPhoneNumber error: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS OTP failed: $e. Proceeding via preview bypass.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Preview fallback bypass
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  // 3. Phone Auth: Verify OTP
  Future<void> _verifyOTP() async {
    final code = _otpController.text.trim();
    if (code.isEmpty || code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit OTP code'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingLabel = 'Verifying code…';
    });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: code,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      debugPrint('OTP code verification failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP mismatch: $e. Logging in via preview bypass.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Preview fallback bypass
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 4. Unified Submit handler
  Future<void> _handleUnifiedSubmit() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Email or Mobile number'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final isEmail = text.contains('@');
    final cleanPhone = text.replaceAll(RegExp(r'[^\d]'), '');
    final isPhone = !isEmail && cleanPhone.length >= 10;

    if (isEmail) {
      setState(() {
        _isLoading = true;
        _loadingLabel = 'Logging in with Email…';
      });
      try {
        // Save Gmail / Email
        ProfileData.email = text;
        ProfileData.name = text.split('@')[0];

        // Direct bypass log-in
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } catch (e) {
        debugPrint('Email bypass error: $e');
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else if (isPhone) {
      _phoneController.text = cleanPhone.substring(cleanPhone.length - 10);
      await _sendOTP();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Email address or 10-digit Mobile number'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _guestBrowse() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardMaxWidth = math.min(400.0, screenWidth - 48);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Dakshineswar Temple / Kolkata Sunset)
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1558431382-27e303142255?w=800',
              fit: BoxFit.cover,
            ),
          ),

          // Dark transparent overlay for contrast
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // Main Glassmorphic Container
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Container(
                      width: cardMaxWidth,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // 1. App Title
                                Center(
                                  child: Text(
                                    'Manchitra',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      color: const ui.Color(0xFFC8363C),
                                      letterSpacing: -0.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Center(
                                  child: Text(
                                    'PANDAL HOPPING, SIMPLIFIED',
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.6),
                                      letterSpacing: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // 2. Emblem
                                Center(
                                  child: SizedBox(
                                    width: 140,
                                    height: 140,
                                    child: ClipRect(
                                      child: CustomPaint(
                                        painter: _EmblemPainter(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // 3. Unified Inputs / Buttons Area
                                if (_otpSent) ...[
                                  // OTP Verification code input
                                  _buildGlassmorphicInput(
                                    controller: _otpController,
                                    hint: 'Enter 6-Digit OTP',
                                    icon: Icons.lock_outline_rounded,
                                    keyboardType: TextInputType.number,
                                    maxLength: 6,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildButton(
                                    text: 'Verify Code & Sign In',
                                    icon: Icons.verified_user_rounded,
                                    color: const Color(0xFFB32A2F),
                                    textColor: Colors.white,
                                    onTap: _verifyOTP,
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: _isLoading ? null : () => setState(() => _otpSent = false),
                                    child: Center(
                                      child: Text(
                                        'Change email or phone',
                                        style: GoogleFonts.manrope(
                                          fontSize: 12,
                                          color: Colors.white70,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  // Email / Phone unified field + Arrow Button next to it
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildGlassmorphicInput(
                                          controller: _inputController,
                                          hint: 'Email or Mobile Number',
                                          icon: Icons.alternate_email_rounded,
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: _isLoading ? null : _handleUnifiedSubmit,
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFC003),
                                            borderRadius: BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFFC003).withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.arrow_forward_rounded,
                                              color: Colors.black87,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                const SizedBox(height: 20),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'OR CONTINUE WITH',
                                        style: GoogleFonts.manrope(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white.withOpacity(0.55),
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Continue with Google Button
                                _buildButton(
                                  text: 'Continue with Google',
                                  imageIcon: 'G',
                                  color: Colors.white,
                                  textColor: Colors.black87,
                                  onTap: _handleGoogleSignIn,
                                ),
                                const SizedBox(height: 16),

                                // Skip explore link
                                GestureDetector(
                                  onTap: _isLoading ? null : _guestBrowse,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          'Skip and explore as Guest',
                                          style: GoogleFonts.manrope(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFFFC003),
                                          ),
                                          overflow: TextOverflow.ellipsis,
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
              ),
            ),
          ),

          // 6. Full-screen loading overlay
          if (_isLoading)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _isLoading ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  color: Colors.black.withOpacity(0.55),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFC003)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _loadingLabel,
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Builder for premium glassmorphic input fields
  Widget _buildGlassmorphicInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        enabled: !_isLoading,
        keyboardType: keyboardType,
        maxLength: maxLength,
        style: GoogleFonts.manrope(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.white70, size: 18),
          hintText: hint,
          hintStyle: GoogleFonts.manrope(color: Colors.white.withOpacity(0.5), fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          counterText: '',
        ),
      ),
    );
  }

  // Builder for premium login buttons
  Widget _buildButton({
    required String text,
    required VoidCallback onTap,
    IconData? icon,
    String? imageIcon,
    required Color color,
    required Color textColor,
  }) {
    return Opacity(
      opacity: _isLoading ? 0.5 : 1,
      child: GestureDetector(
        onTap: _isLoading ? null : onTap,
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
            boxShadow: color != Colors.white
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imageIcon != null)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      imageIcon,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF4285F4),
                      ),
                    ),
                  ),
                )
              else if (icon != null)
                Icon(
                  icon,
                  color: textColor.withOpacity(0.9),
                  size: 18,
                ),
              if (icon != null || imageIcon != null) const SizedBox(width: 10),
              Flexible(
                child: Text(
                  text,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A compact, strictly-bounded emblem (halo + trishul silhouette).
class _EmblemPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final shortestSide = math.min(size.width, size.height);

    // Soft halo glow
    final haloPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        shortestSide * 0.5,
        [
          const Color(0xFFF97316).withOpacity(0.4),
          const Color(0xFFF59E0B).withOpacity(0.12),
          Colors.transparent,
        ],
      );
    canvas.drawCircle(center, shortestSide * 0.5, haloPaint);

    // Outer ring
    final ringPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, shortestSide * 0.42, ringPaint);

    final markPaint = Paint()
      ..color = const Color(0xFFC8363C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = shortestSide * 0.045
      ..strokeCap = StrokeCap.round;

    // Simple trishul (trident) silhouette
    final baseY = center.dy + shortestSide * 0.28;
    final topY = center.dy - shortestSide * 0.30;
    final spread = shortestSide * 0.16;

    // Shaft
    canvas.drawLine(Offset(center.dx, baseY), Offset(center.dx, topY), markPaint);

    // Center prong
    canvas.drawLine(
      Offset(center.dx, topY),
      Offset(center.dx, topY - shortestSide * 0.14),
      markPaint,
    );

    // Left prong
    final leftPath = Path()
      ..moveTo(center.dx, topY)
      ..quadraticBezierTo(
        center.dx - spread * 0.6,
        topY - shortestSide * 0.02,
        center.dx - spread,
        topY - shortestSide * 0.12,
      );
    canvas.drawPath(leftPath, markPaint);

    // Right prong
    final rightPath = Path()
      ..moveTo(center.dx, topY)
      ..quadraticBezierTo(
        center.dx + spread * 0.6,
        topY - shortestSide * 0.02,
        center.dx + spread,
        topY - shortestSide * 0.12,
      );
    canvas.drawPath(rightPath, markPaint);

    // Crossbar near the base
    canvas.drawLine(
      Offset(center.dx - spread * 0.7, baseY - shortestSide * 0.08),
      Offset(center.dx + spread * 0.7, baseY - shortestSide * 0.08),
      markPaint,
    );

    // Small grounding dot
    final dotPaint = Paint()
      ..color = const Color(0xFFC8363C)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx, baseY), shortestSide * 0.025, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
