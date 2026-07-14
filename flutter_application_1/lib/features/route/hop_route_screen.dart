import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

/// ============================================================
/// MANCHITRA — Hop Route Planner Screen (Image 3 Redesign)
/// ============================================================

class HopRouteScreen extends StatefulWidget {
  const HopRouteScreen({super.key});

  @override
  State<HopRouteScreen> createState() => _HopRouteScreenState();
}

class _HopRouteScreenState extends State<HopRouteScreen> {
  int _selectedTransportIndex = 0; // 0: walk, 1: train, 2: car, 3: cab
  int _selectedDurationIndex = 0; // 0: 1-Day, 1: 3-Day, 2: 5-Day

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header (Title + Tagline)
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plan Your Pandal Hop',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'AI optimized routes to experience the best of the festival with minimal crowds.',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. Transport Mode Selector
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRANSPORT MODE',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F2EA),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _buildTransportTab(0, Icons.directions_walk_rounded),
                        _buildTransportTab(1, Icons.train_rounded),
                        _buildTransportTab(2, Icons.directions_car_rounded),
                        _buildTransportTab(3, Icons.local_taxi_rounded),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 3. Plan Duration Selector
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PLAN DURATION',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F2EA),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _buildDurationTab(0, '1-Day'),
                        _buildDurationTab(1, '3-Day'),
                        _buildDurationTab(2, '5-Day'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 4. Statistics Indicators Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatIndicator(
                    icon: Icons.alt_route,
                    value: '4.2',
                    unit: 'km',
                    label: 'Total Dist.',
                    circleColor: Colors.white,
                  ),
                  _buildStatIndicator(
                    icon: Icons.access_time_rounded,
                    value: '3',
                    unit: 'hrs',
                    label: 'Est. Time',
                    circleColor: Colors.white,
                  ),
                  _buildStatIndicator(
                    icon: Icons.people_outline,
                    value: 'Low',
                    unit: '',
                    label: 'Crowd Factor',
                    circleColor: Colors.white,
                    hasCrowdRing: true,
                  ),
                ],
              ),
            ),

            // 5. Named Route Headline
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  const Text(
                    'North Kolkata Classic',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.edit_outlined, size: 18, color: Colors.grey[600]),
                ],
              ),
            ),

            // 6. Timeline List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Stop 1
                  _buildTimelineStop(
                    title: 'Ahiritola Sarbojanin',
                    sub: 'Heritage theme, traditional idol.',
                    crowd: 'Moderate',
                    duration: '30 min view',
                    badgeText: 'Start',
                    badgeBg: const Color(0xFFFEF0D4),
                    badgeTextColor: const Color(0xFFB37400),
                    markerWidget: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on, color: Colors.white, size: 14),
                    ),
                  ),
                  _buildTimelineConnector(
                    text: '15 min walk via Sovabazar St.',
                    icon: Icons.directions_walk,
                  ),

                  // Stop 2
                  _buildTimelineStop(
                    title: 'Kumartuli Park',
                    sub: 'Artisans\' district, intricate craftsmanship.',
                    crowd: 'High',
                    duration: '45 min view',
                    markerWidget: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 4),
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildTimelineConnector(
                    text: '20 min walk along Hooghly',
                    icon: Icons.directions_walk,
                  ),

                  // Stop 3
                  _buildTimelineStop(
                    title: 'Bagbazar Sarbojanin',
                    sub: 'Classic Ekchala idol, famous Sindoor Khela.',
                    crowd: 'Very High',
                    duration: '60 min view',
                    badgeText: 'End',
                    badgeBg: Colors.grey[200],
                    badgeTextColor: Colors.black54,
                    markerWidget: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDC003),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.flag_rounded, color: Colors.white, size: 14),
                    ),
                  ),
                ],
              ),
            ),

            // 7. Navigation Action Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFC8363C),
                        Color(0xFFE8531A),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.explore_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Start Navigation',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportTab(int index, IconData icon) {
    final isSelected = _selectedTransportIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTransportIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.black54,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDurationTab(int index, String label) {
    final isSelected = _selectedDurationIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDurationIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatIndicator({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
    required Color circleColor,
    bool hasCrowdRing = false,
  }) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: circleColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[150] ?? Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Stat Ring/Icon
          Stack(
            alignment: Alignment.center,
            children: [
              if (hasCrowdRing)
                SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    value: 0.25,
                    strokeWidth: 3,
                    color: const Color(0xFFFDC003),
                    backgroundColor: Colors.grey[100],
                  ),
                ),
              Icon(icon, color: Colors.grey[700], size: 18),
            ],
          ),
          const SizedBox(height: 8),
          // Value
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 1),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStop({
    required String title,
    required String sub,
    required String crowd,
    required String duration,
    String? badgeText,
    Color? badgeBg,
    Color? badgeTextColor,
    required Widget markerWidget,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dot column
        Column(
          children: [
            const SizedBox(height: 12),
            markerWidget,
          ],
        ),
        const SizedBox(width: 16),
        // Stop Card details
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            color: badgeTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Crowd badge
                    Icon(Icons.people_outline, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      crowd,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Duration badge
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector({
    required String text,
    required IconData icon,
  }) {
    return Row(
      children: [
        // Marker connector line
        const SizedBox(
          width: 28,
          child: Center(
            child: SizedBox(
              height: 44,
              child: VerticalDivider(
                color: Color(0xFFE4BEBA),
                thickness: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Helper transport text
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

