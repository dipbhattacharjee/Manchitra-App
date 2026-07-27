import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';

class FestivalHighlightsScreen extends StatefulWidget {
  final int initialTabIndex;
  const FestivalHighlightsScreen({super.key, this.initialTabIndex = 0});

  @override
  State<FestivalHighlightsScreen> createState() => _FestivalHighlightsScreenState();
}

class _FestivalHighlightsScreenState extends State<FestivalHighlightsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Dynamic Lists for User Contributions
  final List<Map<String, String>> _culturalEvents = [
    {
      'title': 'Maha Saptami Dhunuchi Naach',
      'location': 'Maddox Square',
      'time': '06:00 PM',
      'details': 'Traditional smoke dance competition featuring expert dhunuchi dancers from South Kolkata.',
    },
    {
      'title': 'Rabindra Sangeet Evening',
      'location': 'Bagbazar Sarbojanin',
      'time': '08:30 PM',
      'details': 'Devotional evening songs performed by Srabani Sen & local artists.',
    },
    {
      'title': 'Bangla Rock Night (Fossils)',
      'location': 'Suruchi Sangha',
      'time': '09:00 PM',
      'details': 'Festive rock concert celebrating modern Bengali music and youth culture.',
    },
  ];

  final List<Map<String, String>> _pandalAwards = [
    {
      'title': 'Best Concept & Theme',
      'winner': 'Sreebhumi Sporting Club',
      'theme': 'Vatican City Replica',
      'details': 'Stunning architectural replication of St. Peter\'s Basilica with golden temple lights.',
    },
    {
      'title': 'Best Traditional Idol',
      'winner': 'Kumartuli Park',
      'theme': 'Sabeki Durga idol',
      'details': 'Iconic clay idol sculpted using ancestral techniques by veteran artisans.',
    },
    {
      'title': 'Best Environmental Decor',
      'winner': 'Jodhpur Park',
      'theme': 'Reclaimed Eco-Materials',
      'details': 'Built entirely using leaves, jute fibers, and bio-degradable components.',
    },
  ];

  final List<Map<String, String>> _bhogTimings = [
    {
      'location': 'Bagbazar Sarbojanin',
      'time': '12:30 PM - 02:30 PM',
      'menu': 'Khichuri, Labra, Beguni, and Tomato Chatney.',
      'instructions': 'Passes available at the committee counter from 8:00 AM.',
    },
    {
      'location': 'Mohammad Ali Park',
      'time': '01:00 PM - 03:00 PM',
      'menu': 'Pulao, Chana Masala, and Rasgulla.',
      'instructions': 'Open community distribution. Expect a 20-minute queue.',
    },
    {
      'location': 'Maddox Square',
      'time': '12:00 PM - 02:00 PM',
      'menu': 'Khichuri, Alur Dom, and Payesh.',
      'instructions': 'Exclusively for registered members and neighborhood residents.',
    },
  ];

  final List<Map<String, String>> _trafficUpdates = [
    {
      'zone': 'North Kolkata (Shyambazar)',
      'status': 'HEAVY CONGESTION',
      'details': 'Pedestrian barricades placed. Heavy vehicles restricted. Visitors advised to take Metro to Shobhabazar Station.',
      'time': 'Updated 5 mins ago',
    },
    {
      'zone': 'South Kolkata (Rashbehari Avenue)',
      'status': 'ONE-WAY PEDESTRIAN FLOW',
      'details': 'One-way channels created from Gariahat Crossing towards Rashbehari. No parking permitted within 500m of pandals.',
      'time': 'Updated 15 mins ago',
    },
    {
      'zone': 'EM Bypass (Sreebhumi Crossing)',
      'status': 'SLOW MOVING',
      'details': 'Expect 15-20 min delays near Sreebhumi due to high footfall. Alternate routes through Salt Lake advised.',
      'time': 'Updated 20 mins ago',
    },
  ];

  // Notification states
  bool _showNotificationBanner = false;
  String _notificationTitle = '';
  String _notificationBody = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _triggerSimulatedAlert(String title, String body) {
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _notificationTitle = title;
          _notificationBody = body;
          _showNotificationBanner = true;
        });
        // Auto hide after 5 seconds
        Timer(const Duration(seconds: 6), () {
          if (mounted) {
            setState(() {
              _showNotificationBanner = false;
            });
          }
        });
      }
    });
  }

  // Open Form to Request Original Data from User
  void _openContributionSheet(int tabIndex) {
    final titleController = TextEditingController();
    final locationController = TextEditingController();
    final detailController = TextEditingController();
    final timeController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getFormTitle(tabIndex),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Please enter original, verified details for Kolkata Durga Puja 2026.',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: _getLabelText1(tabIndex),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: _getLabelText2(tabIndex),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: _getLabelText3(tabIndex),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: detailController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: _getLabelText4(tabIndex),
                  border: const OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFAF101A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    final title = titleController.text.trim();
                    final loc = locationController.text.trim();
                    final time = timeController.text.trim();
                    final det = detailController.text.trim();

                    if (title.isEmpty || loc.isEmpty || time.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all mandatory fields.')),
                      );
                      return;
                    }

                    setState(() {
                      if (tabIndex == 0) {
                        _culturalEvents.insert(0, {
                          'title': title,
                          'location': loc,
                          'time': time,
                          'details': det.isNotEmpty ? det : 'No additional details provided.',
                        });
                      } else if (tabIndex == 1) {
                        _pandalAwards.insert(0, {
                          'title': title,
                          'winner': loc,
                          'theme': time,
                          'details': det,
                        });
                      } else if (tabIndex == 2) {
                        _bhogTimings.insert(0, {
                          'location': title,
                          'time': loc,
                          'menu': time,
                          'instructions': det,
                        });
                      } else {
                        _trafficUpdates.insert(0, {
                          'zone': title,
                          'status': loc,
                          'details': time,
                          'time': 'Just now by User',
                        });
                      }
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Verification pending. Details added successfully!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );

                    // Setup user alert simulation
                    _triggerSimulatedAlert(
                      'Alert Set: $title',
                      'We will notify you 15 minutes before this scheduled event/timing starts.',
                    );
                  },
                  child: Text(
                    'Submit Verified Data',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormTitle(int index) {
    if (index == 0) return 'Submit Cultural Event';
    if (index == 1) return 'Report Award Winner';
    if (index == 2) return 'Add Bhog Timing';
    return 'Report Traffic Update';
  }

  String _getLabelText1(int index) {
    if (index == 0) return 'Event Name (e.g. Dhunuchi Naach)';
    if (index == 1) return 'Award Category (e.g. Best Decor)';
    if (index == 2) return 'Pandal/Temple Name';
    return 'Area/Crossing Name';
  }

  String _getLabelText2(int index) {
    if (index == 0) return 'Pandal Location (e.g. Maddox Square)';
    if (index == 1) return 'Winning Pandal (e.g. Sreebhumi)';
    if (index == 2) return 'Distribution Time (e.g. 12:00 PM)';
    return 'Status (e.g. Heavy Congestion, Closed)';
  }

  String _getLabelText3(int index) {
    if (index == 0) return 'Start Time (e.g. 06:30 PM)';
    if (index == 1) return 'Pandal Theme Description';
    if (index == 2) return 'Menu served (e.g. Khichuri Bhog)';
    return 'Specific detail/instructions';
  }

  String _getLabelText4(int index) {
    if (index == 0) return 'Event details/description';
    if (index == 1) return 'Additional jury remarks';
    if (index == 2) return 'Distribution pass details';
    return 'Alternate route suggested';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDFBF7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Festival Highlights',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFAF101A),
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: const Color(0xFFAF101A),
          indicatorWeight: 3,
          labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Events'),
            Tab(text: 'Awards'),
            Tab(text: 'Bhog'),
            Tab(text: 'Traffic'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildEventsTab(),
              _buildAwardsTab(),
              _buildBhogTab(),
              _buildTrafficTab(),
            ],
          ),

          // Slide down in-app alert banner
          if (_showNotificationBanner)
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: SafeArea(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C1A1A),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_active_rounded, color: Color(0xFFFFD37A), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _notificationTitle,
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _notificationBody,
                                style: GoogleFonts.manrope(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70, size: 16),
                          onPressed: () => setState(() => _showNotificationBanner = false),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
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

  Widget _buildEventsTab() {
    return _buildTabContainer(
      index: 0,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _culturalEvents.length,
        itemBuilder: (context, index) {
          final event = _culturalEvents[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1ECE3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2F0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        event['time']!,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFAF101A),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFFAF101A), size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reminder set for "${event['title']}" at ${event['time']}.'),
                            backgroundColor: const Color(0xFFAF101A),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        _triggerSimulatedAlert(
                          'Puja Event Notification',
                          'Your event "${event['title']}" at ${event['location']} starts in 15 minutes!',
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  event['title']!,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Colors.grey, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      event['location']!,
                      style: GoogleFonts.manrope(
                        color: Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFF1ECE3)),
                Text(
                  event['details']!,
                  style: GoogleFonts.manrope(
                    color: Colors.grey[700],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAwardsTab() {
    return _buildTabContainer(
      index: 1,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _pandalAwards.length,
        itemBuilder: (context, index) {
          final award = _pandalAwards[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1ECE3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded, color: Color(0xFFFDC003), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      award['title']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF785900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  award['winner']!,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Theme: "${award['theme']}"',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFAF101A),
                    fontSize: 13,
                  ),
                ),
                const Divider(height: 20, color: Color(0xFFF1ECE3)),
                Text(
                  award['details']!,
                  style: GoogleFonts.manrope(
                    color: Colors.grey[700],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBhogTab() {
    return _buildTabContainer(
      index: 2,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _bhogTimings.length,
        itemBuilder: (context, index) {
          final bhog = _bhogTimings[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1ECE3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bhog['location']!,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const Icon(Icons.restaurant_menu_rounded, color: Color(0xFFAF101A), size: 18),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: Colors.grey, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      bhog['time']!,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFAF101A),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20, color: Color(0xFFF1ECE3)),
                Text(
                  'Bhog Prasad Menu:',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bhog['menu']!,
                  style: GoogleFonts.manrope(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Instructions:',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bhog['instructions']!,
                  style: GoogleFonts.manrope(
                    color: Colors.grey[700],
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrafficTab() {
    return _buildTabContainer(
      index: 3,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _trafficUpdates.length,
        itemBuilder: (context, index) {
          final update = _trafficUpdates[index];
          final isHeavy = update['status'] == 'HEAVY CONGESTION' || update['status'] == 'CLOSED';
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1ECE3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        update['zone']!,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isHeavy ? const Color(0xFFFFF2F0) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isHeavy ? const Color(0xFFFFC6BD) : Colors.grey[300]!),
                      ),
                      child: Text(
                        update['status']!,
                        style: GoogleFonts.manrope(
                          color: isHeavy ? const Color(0xFFAF101A) : Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  update['details']!,
                  style: GoogleFonts.manrope(
                    color: Colors.grey[700],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const Divider(height: 20, color: Color(0xFFF1ECE3)),
                Text(
                  update['time']!,
                  style: GoogleFonts.manrope(
                    color: Colors.grey[400],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabContainer({required int index, required Widget child}) {
    return Column(
      children: [
        Expanded(child: child),
        // Add Verified/Original Data Action Button
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFAF101A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
                elevation: 4,
              ),
              onPressed: () => _openContributionSheet(index),
              label: Text(
                _getButtonLabel(index),
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getButtonLabel(int index) {
    if (index == 0) return 'Submit Cultural Event';
    if (index == 1) return 'Report Award Winner';
    if (index == 2) return 'Add Bhog Timing';
    return 'Report Traffic Update';
  }
}
