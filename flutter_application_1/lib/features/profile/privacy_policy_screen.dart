import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFAF101A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Manchitra',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFAF101A),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "Privacy First" Gold Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFDF9E), width: 0.5),
                  ),
                  child: Text(
                    'Privacy First',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF785900),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title: Your Trust is our Heritage.
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                    children: [
                      const TextSpan(text: 'Your Trust is our\n'),
                      TextSpan(
                        text: 'Heritage',
                        style: GoogleFonts.playfairDisplay(
                          fontStyle: FontStyle.italic,
                          color: const Color(0xFFAF101A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Last Updated Subtitle
                Text(
                  'Last Updated: October 14, 2024. We value the sanctity of your data as much as the sanctity of the festival.',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),

                // 1. Location Tracking Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF785900),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Location Tracking',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'PandalHop AI is designed to help you navigate the vibrant, often chaotic landscape of Durga Puja. To provide real-time crowd insights and \'Hop\' recommendations, we require access to your high-precision location data.',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // "Why we track location" Gold Container Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFDF9E)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why we track your location:',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF785900),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildBulletItem('Real-time crowd density calculation at Pandals.'),
                      _buildBulletItem('Personalized routing to avoid traffic blocks and police diversions.'),
                      _buildBulletItem('Automated "Pandal Check-ins" for your cultural diary.'),
                      _buildBulletItem('Safety alerts for weather-related changes in your specific vicinity.'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 2. Data Usage & Privacy Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.security,
                      color: Color(0xFF785900),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Data Usage & Privacy',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'We do not sell your personal movement patterns to third-party advertisers. Your data is anonymized and aggregated to improve the overall AI crowd-prediction engine for the benefit of all cultural enthusiasts.\n\nIdentity data including your name and profile picture is stored locally and on our secure cloud only to synchronize your \'Saved\' lotus-list across devices.',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Celebrating tradition with modern security.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 3. User Rights Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF785900),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'User Rights',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'You maintain absolute control over your digital footprint during the festival:',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),

                // Numbered Right Elements
                _buildRightItem(
                  number: '1',
                  title: 'Right to Deletion',
                  subtitle: 'Request the complete purge of your journey history and account data at any time via Settings.',
                ),
                const SizedBox(height: 16),
                _buildRightItem(
                  number: '2',
                  title: 'Data Portability',
                  subtitle: 'Export your "Saved" pandal list and route history as a beautifully designed digital souvenir PDF.',
                ),
                const SizedBox(height: 16),
                _buildRightItem(
                  number: '3',
                  title: 'Incognito Mode',
                  subtitle: 'Browse the map and crowd insights without any persistent data logging.',
                ),
                const SizedBox(height: 36),

                // Have questions card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3EF),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Have questions about your privacy?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Our cultural concierge team is available to explain our data practices in detail.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Contacting Privacy Officer...')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFAF101A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          elevation: 1,
                        ),
                        child: Text(
                          'Contact Privacy Officer',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Floating Circular Red Close Button in bottom right
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: () => Navigator.pop(context),
              backgroundColor: const Color(0xFFAF101A),
              elevation: 4,
              shape: const CircleBorder(),
              child: const Icon(Icons.close, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6.0, right: 10.0),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFF785900),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: const Color(0xFF785900),
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightItem({
    required String number,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFFFF2F0),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFAF101A),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: Colors.grey[600],
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
