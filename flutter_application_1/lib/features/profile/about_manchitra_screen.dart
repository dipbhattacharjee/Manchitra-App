import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutManchitraScreen extends StatelessWidget {
  const AboutManchitraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFAF101A)), // Modified back icon to allow return navigation
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_outlined, color: Color(0xFFAF101A)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manchitra Logo Text
            Center(
              child: Column(
                children: [
                  Text(
                    'Manchitra',
                    style: GoogleFonts.playfairDisplay(
                      color: const Color(0xFF785900),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The Vision of\nHeritage',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFAF101A),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // VERSION 2.4.0 • SHARODIYA EDITION Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDF9E),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'VERSION 2.4.0 • SHARODIYA EDITION',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF785900),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // "Our Soulful Mission" Card with thin red border
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFAF101A), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.015),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Our Soulful Mission',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFAF101A),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'PandalHop AI was born from the narrow lanes of Kumartuli and the vibrant energy of Gariahat. We believe that technology shouldn\'t replace tradition; it should amplify it. Our goal is to preserve the intricate tapestry of Bengali heritage by providing an effortless, premium digital companion for the world\'s largest public art festival.',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Core Pillars List
            // 1. Cultural Archiving Card
            _buildPillarCard(
              icon: Icons.museum_outlined,
              iconBgColor: const Color(0xFFFFF2F0),
              iconColor: const Color(0xFFAF101A),
              title: 'Cultural Archiving',
              description: 'Digitizing the ephemeral beauty of pandal architecture and idol craftsmanship for future generations.',
            ),
            const SizedBox(height: 16),

            // 2. Intelligent Routing Card
            _buildPillarCard(
              icon: Icons.psychology_outlined,
              iconBgColor: const Color(0xFFFFF9E6),
              iconColor: const Color(0xFF785900),
              title: 'Intelligent Routing',
              description: 'Our AI predicts crowd flows in real-time, ensuring your spiritual journey remains serene and sacred.',
            ),
            const SizedBox(height: 32),

            // "Connect with the" Section
            Text(
              'Connect with the',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFAF101A),
              ),
            ),
            const SizedBox(height: 16),

            // Row of Social buttons (Instagram / Threads)
            Row(
              children: [
                Expanded(
                  child: _buildOutlineButton(
                    icon: Icons.language_rounded,
                    label: 'Instagram',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOutlineButton(
                    icon: Icons.share_rounded,
                    label: 'Threads',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // "Contact" Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact support requested')),
                  );
                },
                icon: const Icon(Icons.mail_outline_rounded, color: Color(0xFFAF101A)),
                label: Text(
                  'Contact',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(0xFFAF101A),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE4E2DE), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'DESIGNED WITH DEVOTION',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey[500],
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2024 Manchitra.\nAll rights reserved. Kolkata, India.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.grey[500],
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.manrope(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlineButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.black87, size: 18),
      label: Text(
        label,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFE4E2DE), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}
