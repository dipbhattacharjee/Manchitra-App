import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';
import 'profile_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
          'Settings',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFAF101A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_outlined, color: Color(0xFFAF101A)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Syncing settings to cloud...')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 40),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Header Section: Profile Photo and Name info
            GestureDetector(
              onTap: () async {
                await Navigator.pushNamed(context, '/edit-profile');
                if (mounted) setState(() {});
              },
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFF2F0), width: 2),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFFFDF9E), width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundImage: NetworkImage(ProfileData.photoUrl),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFAF101A),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ProfileData.name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Premium Member • ${ProfileData.location}',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Group 1
            _buildSettingsGroup(
              [
                _buildListItem(
                  icon: Icons.link_rounded,
                  title: 'Linked Accounts',
                  subtitle: 'Manage Google, Apple & Social logins',
                  onTap: () {},
                ),
                _buildListItem(
                  icon: Icons.badge_outlined,
                  title: 'Travel Identity',
                  subtitle: 'Kolkata Metro Card & AI Pass',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Group 2
            _buildSettingsGroup(
              [
                _buildListItem(
                  icon: Icons.key_outlined,
                  title: 'Password & Authentication',
                  subtitle: 'Last changed 2 months ago',
                  onTap: () {},
                ),
                _buildListItem(
                  icon: Icons.shield_outlined,
                  title: 'Two-Factor Authentication',
                  subtitleSpan: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Enabled ',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFAF101A),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      TextSpan(
                        text: '(SMS & Authenticator)',
                        style: GoogleFonts.manrope(
                          color: Colors.grey[500],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Group 3
            _buildSettingsGroup(
              [
                _buildListItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notification Preferences',
                  subtitle: 'Crowd alerts, Route updates',
                  onTap: () {},
                ),
                _buildListItem(
                  icon: Icons.language_rounded,
                  title: 'App Language',
                  subtitle: 'Bengali & English (System)',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Group 4
            _buildSettingsGroup(
              [
                _buildListItem(
                  icon: Icons.storage_rounded,
                  title: 'Data Management',
                  subtitle: 'Export travel logs, clear AI cache',
                  onTap: () {},
                ),
                _buildListItem(
                  icon: Icons.do_not_disturb_on_outlined,
                  title: 'Account Deactivation',
                  titleColor: const Color(0xFFAF101A),
                  subtitle: 'Permanently delete your PandalHop ID',
                  subtitleColor: const Color(0xFFAF101A).withOpacity(0.8),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Log Out button
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logging out...')),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEEEA),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Log Out',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFAF101A),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Version info
            Text(
              'Version 2.4.0 (Build 9821)\n© 2024 Manchitra',
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
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
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
        children: children,
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    String? subtitle,
    InlineSpan? subtitleSpan,
    Color? titleColor,
    Color? subtitleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF2F0),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFFAF101A),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.manrope(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: titleColor ?? Colors.black87,
        ),
      ),
      subtitle: subtitleSpan != null
          ? RichText(text: subtitleSpan)
          : (subtitle != null
              ? Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 11,
                    color: subtitleColor ?? Colors.grey[500],
                  ),
                )
              : null),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey,
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title tapped')),
        );
        onTap();
      },
    );
  }
}
