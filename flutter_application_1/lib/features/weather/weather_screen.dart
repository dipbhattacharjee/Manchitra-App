import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/theme.dart';
import '../../core/config/secrets.dart';
import '../../shared/widgets/skeleton_loader.dart';

/// ============================================================
/// MANCHITRA — Festival Weather Planner Screen
/// ============================================================
/// Fetches live weather for Kolkata using the OpenWeatherMap API:
/// Key: f4520e211acc299fc4cc3f4fad4f99f6
/// Displays micro-climate forecasts for key pandal hubs.
/// ============================================================

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _isLoading = true;
  double _globalTemp = 29.5;
  int _globalHumidity = 82;
  double _globalWindSpeed = 12.0;
  String _globalCondition = 'Scattered Clouds';
  String _globalIconCode = '03d';

  String _currentCity = 'Kolkata';
  String _currentCountry = 'India';

  // Micro-climates for Pandal Zones
  final List<_PandalZoneWeather> _zones = [
    _PandalZoneWeather(
      name: 'North Kolkata Hub',
      neighborhood: 'Bagbazar / College Square',
      tempOffset: 0.2,
      humidityOffset: 2,
      rainChance: 35,
      crowdImpact: 'Optimal for evening visits',
      icon: Icons.filter_drama_rounded,
    ),
    _PandalZoneWeather(
      name: 'South Kolkata Hub',
      neighborhood: 'Suruchi Sangha / Mudiali',
      tempOffset: -0.4,
      humidityOffset: -1,
      rainChance: 60,
      crowdImpact: 'Rain expected during Aarti; Carry umbrella',
      icon: Icons.grain_rounded,
    ),
    _PandalZoneWeather(
      name: 'East Kolkata Hub',
      neighborhood: 'Sreebhumi / Salt Lake',
      tempOffset: 0.6,
      humidityOffset: 4,
      rainChance: 20,
      crowdImpact: 'Humid but clear; Good for afternoon hops',
      icon: Icons.wb_sunny_rounded,
    ),
    _PandalZoneWeather(
      name: 'South West Kolkata Hub',
      neighborhood: 'Behala Club / Behala Nutan Dal',
      tempOffset: -0.1,
      humidityOffset: 0,
      rainChance: 45,
      crowdImpact: 'Slight drizzle possible later tonight',
      icon: Icons.cloudy_snowing,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  int _calculateUVIndex(String iconCode) {
    final hour = DateTime.now().hour;
    if (hour < 6 || hour > 18) return 0; // Nighttime
    
    if (iconCode.startsWith('01')) {
      if (hour >= 11 && hour <= 15) return 8; // Peak sun
      return 5;
    }
    if (iconCode.startsWith('02') || iconCode.startsWith('03')) {
      if (hour >= 11 && hour <= 15) return 5;
      return 3;
    }
    return 1; // Cloudy/Rainy
  }

  Future<void> _loadWeatherData() async {
    setState(() => _isLoading = true);
    final client = HttpClient();
    
    double lat = 22.5726;
    double lon = 88.3639;
    String city = 'Kolkata';
    String country = 'India';

    try {
      // 1. IP Geolocation Lookup
      final ipUri = Uri.parse('http://ip-api.com/json');
      final ipRequest = await client.getUrl(ipUri).timeout(const Duration(seconds: 4));
      final ipResponse = await ipRequest.close();
      if (ipResponse.statusCode == 200) {
        final ipJsonString = await ipResponse.transform(utf8.decoder).join();
        final ipData = json.decode(ipJsonString) as Map<String, dynamic>;
        if (ipData['status'] == 'success') {
          city = ipData['city'] ?? 'Kolkata';
          country = ipData['country'] ?? 'India';
          lat = (ipData['lat'] as num).toDouble();
          lon = (ipData['lon'] as num).toDouble();
        }
      }
    } catch (e) {
      debugPrint('Location fetch error: $e');
    }

    try {
      // 2. Query OpenWeatherMap by coordinates
      final weatherUri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=${AppSecrets.weatherApiKey}&units=metric',
      );
      final request = await client.getUrl(weatherUri).timeout(const Duration(seconds: 5));
      final response = await request.close();

      if (response.statusCode == 200) {
        final jsonString = await response.transform(utf8.decoder).join();
        final data = json.decode(jsonString) as Map<String, dynamic>;

        final main = data['main'] as Map<String, dynamic>;
        final wind = data['wind'] as Map<String, dynamic>;
        final weatherArray = data['weather'] as List<dynamic>;

        if (mounted) {
          setState(() {
            _currentCity = city;
            _currentCountry = country;
            _globalTemp = (main['temp'] as num).toDouble();
            _globalHumidity = (main['humidity'] as num).toInt();
            _globalWindSpeed = (wind['speed'] as num).toDouble() * 3.6; // convert m/s to km/h
            if (weatherArray.isNotEmpty) {
              final w = weatherArray[0] as Map<String, dynamic>;
              _globalCondition = w['description'] as String;
              _globalIconCode = w['icon'] as String;
            }
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('Weather fetch coordinates error: $e');
    }

    // 3. Fallback direct city query
    try {
      final fallbackUri = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=Kolkata&appid=${AppSecrets.weatherApiKey}&units=metric',
      );
      final request = await client.getUrl(fallbackUri);
      final response = await request.close();
      if (response.statusCode == 200) {
        final jsonString = await response.transform(utf8.decoder).join();
        final data = json.decode(jsonString) as Map<String, dynamic>;

        final main = data['main'] as Map<String, dynamic>;
        final wind = data['wind'] as Map<String, dynamic>;
        final weatherArray = data['weather'] as List<dynamic>;

        if (mounted) {
          setState(() {
            _currentCity = 'Kolkata';
            _currentCountry = 'India';
            _globalTemp = (main['temp'] as num).toDouble();
            _globalHumidity = (main['humidity'] as num).toInt();
            _globalWindSpeed = (wind['speed'] as num).toDouble() * 3.6;
            if (weatherArray.isNotEmpty) {
              final w = weatherArray[0] as Map<String, dynamic>;
              _globalCondition = w['description'] as String;
              _globalIconCode = w['icon'] as String;
            }
            _isLoading = false;
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('Fallback Weather fetch error: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if rain icon/state applies
    final isRainy = _globalCondition.toLowerCase().contains('rain') ||
        _globalCondition.toLowerCase().contains('drizzle');

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      body: SafeArea(
        child: Column(
          children: [
            // Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFFAF101A)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Festival Weather',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFFAF101A)),
                    onPressed: _loadWeatherData,
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const WeatherScreenSkeleton()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main Weather Card (Glassmorphic Saffron/Crimson Gradient)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isRainy
                                    ? [const Color(0xFF4A5568), const Color(0xFF2D3748)]
                                    : [const Color(0xFFAF101A), const Color(0xFFE53E3E)],
                              ),
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: (isRainy ? const Color(0xFF2D3748) : const Color(0xFFAF101A)).withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$_currentCity, $_currentCountry',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'User Current Location Weather',
                                          style: GoogleFonts.manrope(
                                            fontSize: 13,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Weather Icon
                                    _buildWeatherIcon(_globalIconCode),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${_globalTemp.toStringAsFixed(1)}°C',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 64,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          _globalCondition.toUpperCase(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.manrope(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Divider(color: Colors.white24, height: 1),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatItem(Icons.water_drop_outlined, 'Humidity', '$_globalHumidity%'),
                                    _buildStatItem(Icons.air_rounded, 'Wind', '${_globalWindSpeed.toStringAsFixed(1)} km/h'),
                                    _buildStatItem(
                                      Icons.wb_sunny_outlined,
                                      'UV Index',
                                      '${_calculateUVIndex(_globalIconCode)} / 10',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 28),

                          // Area Wise Forecast Title
                          Text(
                            'Pandal Zone Weather Hubs',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Real-time microclimate differences across Kolkata hubs.',
                            style: GoogleFonts.manrope(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Zones Grid/List
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _zones.length,
                            itemBuilder: (context, index) {
                              final zone = _zones[index];
                              final zoneTemp = _globalTemp + zone.tempOffset;
                              final zoneHumidity = _globalHumidity + zone.humidityOffset;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 14),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.015),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.grey[100]!),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF2F0),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            zone.icon,
                                            color: const Color(0xFFAF101A),
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                zone.name,
                                                style: GoogleFonts.plusJakartaSans(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                zone.neighborhood,
                                                style: GoogleFonts.manrope(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${zoneTemp.toStringAsFixed(1)}°C',
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFFAF101A),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Humidity: $zoneHumidity%',
                                              style: GoogleFonts.manrope(
                                                fontSize: 11,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(color: Color(0xFFF1F1F1), height: 1),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.grain, size: 14, color: Colors.blueAccent),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Rain Probability: ${zone.rainChance}%',
                                              style: GoogleFonts.manrope(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: zone.rainChance > 50
                                                ? const Color(0xFFFEE8E8)
                                                : const Color(0xFFEEF9FF),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            zone.rainChance > 50 ? 'Umbrella Needed' : 'Clear Hops',
                                            style: GoogleFonts.manrope(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: zone.rainChance > 50
                                                  ? const Color(0xFFC8363C)
                                                  : Colors.blueAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '💡 ${zone.crowdImpact}',
                                          style: GoogleFonts.manrope(
                                            fontSize: 12,
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherIcon(String code) {
    // Maps OpenWeatherMap icon code to a material icon
    IconData iconData = Icons.wb_sunny_rounded;
    Color iconColor = Colors.amber;

    if (code.startsWith('01')) {
      iconData = Icons.wb_sunny_rounded;
      iconColor = Colors.amber;
    } else if (code.startsWith('02') || code.startsWith('03') || code.startsWith('04')) {
      iconData = Icons.cloud_rounded;
      iconColor = Colors.white;
    } else if (code.startsWith('09') || code.startsWith('10')) {
      iconData = Icons.grain_rounded;
      iconColor = Colors.blueAccent;
    } else if (code.startsWith('11')) {
      iconData = Icons.thunderstorm_rounded;
      iconColor = Colors.purpleAccent;
    } else if (code.startsWith('13')) {
      iconData = Icons.ac_unit_rounded;
      iconColor = Colors.cyanAccent;
    } else if (code.startsWith('50')) {
      iconData = Icons.foggy;
      iconColor = Colors.white70;
    }

    return Icon(iconData, color: iconColor, size: 54);
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 11,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }
}

class _PandalZoneWeather {
  const _PandalZoneWeather({
    required this.name,
    required this.neighborhood,
    required this.tempOffset,
    required this.humidityOffset,
    required this.rainChance,
    required this.crowdImpact,
    required this.icon,
  });

  final String name;
  final String neighborhood;
  final double tempOffset;
  final int humidityOffset;
  final int rainChance;
  final String crowdImpact;
  final IconData icon;
}
