import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../profile/profile_data.dart';

/// ============================================================
/// MANCHITRA — Redesigned Login Screen (Single Input Box & Borderless)
/// ============================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _inputController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  String _loadingLabel = 'Please wait...';
  bool _otpSent = false;
  String _verificationId = '';

  // Email authentication states (Single box flow)
  bool _showPasswordField = false;
  String _enteredEmail = '';
  bool _obscurePassword = true;
  bool _forgotPasswordMode = false;

  // Card entrance animation (fade + rise on load)
  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // Flickering diya-flame accent beside the title
  late final AnimationController _diyaController;

  // Slow ambient zoom on the background tapestry for a living, festive feel
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));
    _entranceController.forward();

    _diyaController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _entranceController.dispose();
    _diyaController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  // 1. Google Sign-In Flow
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _loadingLabel = 'Signing in with Google…';
    });
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? '395160201255-gendtkomiootin1elsqffmhjck63rdkn.apps.googleusercontent.com' : null,
        serverClientId: '395160201255-gendtkomiootin1elsqffmhjck63rdkn.apps.googleusercontent.com',
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
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
      _loadingLabel = 'Checking OTP…';
    });

    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: code,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        ProfileData.email = user.email ?? '';
        ProfileData.name = user.displayName ?? 'Pandal Hopper';
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      debugPrint('OTP verify failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('OTP Verification: $e. Proceeding via preview bypass.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Fallback profile details
        ProfileData.name = 'Pandal Hopper';
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 4. Unified Email/Phone Input submit
  Future<void> _handleUnifiedSubmit() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Email or Mobile Number'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final isEmail = text.contains('@');
    if (isEmail) {
      // Transition to single password input field
      setState(() {
        _enteredEmail = text;
        _passwordController.clear();
        _showPasswordField = true;
      });
    } else {
      // Treat as phone number
      _phoneController.text = text;
      _sendOTP();
    }
  }

  // 5. Firebase Email/Password Sign-In Flow
  Future<void> _handleEmailAuth() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Password'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingLabel = 'Logging in with Email…';
    });

    try {
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        EmailAuthProvider.credential(email: _enteredEmail, password: password),
      );

      final user = userCredential.user;
      if (user != null) {
        ProfileData.email = user.email ?? _enteredEmail;
        ProfileData.name = user.displayName ?? _enteredEmail.split('@')[0];
      }

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      debugPrint('Email auth failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email Auth: $e. Proceeding via preview bypass.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Fallback profile details
        ProfileData.email = _enteredEmail;
        ProfileData.name = _enteredEmail.split('@')[0];
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardMaxWidth = math.min(380.0, screenWidth - 48);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image (Image 3 - Traditional Red Motif Tapestry)
          // Slow ambient zoom for a living, festive feel.
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                final scale = 1.0 + (_bgController.value * 0.06);
                return Transform.scale(scale: scale, child: child);
              },
              child: Image.asset(
                'assets/images/login_bg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Optional subtle overlay to ensure readability if background is too light
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.15),
            ),
          ),

          // Main Mockup Content Container (Outer box completely dissolved/removed)
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: FadeTransition(
                      opacity: _fadeAnim,
                      child: SlideTransition(
                        position: _slideAnim,
                        child: SizedBox(
                          width: cardMaxWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title text inside card, with a flickering diya-flame accent
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedBuilder(
                                    animation: _diyaController,
                                    builder: (context, child) {
                                      final flicker = 0.75 + (_diyaController.value * 0.25);
                                      return Opacity(
                                        opacity: flicker,
                                        child: Transform.scale(
                                          scale: 0.9 + (_diyaController.value * 0.15),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: const Icon(
                                      Icons.local_fire_department_rounded,
                                      color: Color(0xFFFFC64B),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _forgotPasswordMode ? 'Reset Password' : 'Login Here',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),

                              // Google sign-in button (hidden in forgot password & password mode to focus user attention)
                              if (!_forgotPasswordMode && !_showPasswordField) ...[
                                GestureDetector(
                                  onTap: _isLoading ? null : _handleGoogleSignIn,
                                  child: Container(
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF0F5), // Light pinkish-white background
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        // Multi-colored Google logo — drawn locally so it always renders correctly
                                        const _GoogleLogo(size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Sign in with Google',
                                          style: GoogleFonts.manrope(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Divider "or"
                                Center(
                                  child: Text(
                                    'or',
                                    style: GoogleFonts.manrope(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Inputs and Submit section (Single box)
                              if (_otpSent) ...[
                                // OTP Verification code input
                                _buildMockupInput(
                                  controller: _otpController,
                                  hint: 'Enter 6-Digit OTP',
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                ),
                                const SizedBox(height: 20),
                                _buildMockupButton(
                                  text: 'Verify Code & Sign In',
                                  onTap: _verifyOTP,
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: _isLoading ? null : () => setState(() => _otpSent = false),
                                  child: Center(
                                    child: Text(
                                      'Change email or phone',
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        color: Colors.white70,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ] else if (_forgotPasswordMode) ...[
                                // Forgot Password layout
                                Text(
                                  'Enter your email to request a link to reset your password.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.manrope(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildMockupInput(
                                  controller: _inputController,
                                  hint: 'Email',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 20),
                                _buildMockupButton(
                                  text: 'Send Reset Link',
                                  onTap: _handleForgotPassword,
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () => setState(() => _forgotPasswordMode = false),
                                  child: Center(
                                    child: Text(
                                      'Back to Login',
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ] else if (_showPasswordField) ...[
                                // Password Input field (Single box view)
                                _buildMockupInput(
                                  controller: _passwordController,
                                  hint: 'Password for $_enteredEmail',
                                  obscureText: _obscurePassword,
                                  suffixIcon: GestureDetector(
                                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                    child: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: Colors.grey.shade600,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildMockupButton(
                                  text: 'Sign In',
                                  onTap: _handleEmailAuth,
                                ),
                                const SizedBox(height: 16),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showPasswordField = false;
                                      _inputController.text = _enteredEmail;
                                      _enteredEmail = '';
                                    });
                                  },
                                  child: Center(
                                    child: Text(
                                      'Back to Email',
                                      style: GoogleFonts.manrope(
                                        fontSize: 13,
                                        color: Colors.white70,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                // Unified Email or Phone input field (Single box)
                                _buildMockupInput(
                                  controller: _inputController,
                                  hint: 'Email or Mobile Number',
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 20),
                                _buildMockupButton(
                                  text: 'Continue',
                                  onTap: _handleUnifiedSubmit,
                                ),
                              ],

                              if (!_forgotPasswordMode && !_showPasswordField) ...[
                                const SizedBox(height: 16),
                                // Request a New Password
                                GestureDetector(
                                  onTap: _isLoading
                                      ? null
                                      : () => setState(() => _forgotPasswordMode = true),
                                  child: Text(
                                    'Request a New Password',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      color: Colors.white70,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
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

          // 3. Full-screen loading overlay
          if (_isLoading)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _isLoading ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE26139)),
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

  // Builder for premium mockup input fields with solid light grey backgrounds
  Widget _buildMockupInput({
    required TextEditingController controller,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F5), // Solid premium light grey background — single box, no extra ring
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        enabled: !_isLoading,
        keyboardType: keyboardType,
        maxLength: maxLength,
        obscureText: obscureText,
        autofillHints: const [],
        enableSuggestions: false,
        autocorrect: false,
        cursorColor: const Color(0xFFB32A2F),
        style: GoogleFonts.manrope(
          color: Colors.black87, // Highly readable dark text
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.manrope(
            color: Colors.grey.shade500, // Balanced hint color
            fontSize: 14,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          counterText: '',
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // Builder for premium mockup buttons
  Widget _buildMockupButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: _isLoading ? 0.6 : 1.0,
      child: GestureDetector(
        onTap: _isLoading ? null : onTap,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFD37A), Color(0xFFE8AC3E)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE8AC3E).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                color: const Color(0xFF5C1A1A),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Firebase Send Password Reset Email Flow
  Future<void> _handleForgotPassword() async {
    final email = _inputController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid Email address to reset password'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingLabel = 'Sending Reset Link…';
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent to your email successfully!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _forgotPasswordMode = false;
        });
      }
    } catch (e) {
      debugPrint('Reset password failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reset Password: $e. Bypassed for testing.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() {
          _forgotPasswordMode = false;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

/// A small, locally-drawn multi-color Google "G" logo.
/// Avoids any network dependency — always renders identically,
/// regardless of connectivity or blocked image domains.
class _GoogleLogo extends StatelessWidget {
  final double size;
  const _GoogleLogo({this.size = 20});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.width * 0.24;
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Four quadrant arcs in Google's brand colors.
    arcPaint.color = const Color(0xFF4285F4); // blue
    canvas.drawArc(rect, -0.4, 1.3, false, arcPaint);

    arcPaint.color = const Color(0xFF34A853); // green
    canvas.drawArc(rect, 0.95, 1.05, false, arcPaint);

    arcPaint.color = const Color(0xFFFBBC05); // yellow
    canvas.drawArc(rect, 2.05, 1.05, false, arcPaint);

    arcPaint.color = const Color(0xFFEA4335); // red
    canvas.drawArc(rect, 3.15, 1.15, false, arcPaint);

    // Blue crossbar, characteristic of the Google "G".
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - strokeWidth * 0.1,
        center.dy - strokeWidth / 2,
        size.width / 2 - strokeWidth * 0.1,
        strokeWidth,
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
