import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/providers/pandal_provider.dart';

/// ============================================================
/// MANCHITRA — Location Picker Screen
/// Select active city context / Use live GPS position.
/// ============================================================

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<Map<String, dynamic>> _supportedCities = [
    {'name': 'Kolkata, West Bengal', 'subtitle': '150+ Pandals, Hop Routes & Live Navigation', 'supported': true},
    {'name': 'Howrah, WB', 'subtitle': 'Sister twin city, heritage pandal coverage', 'supported': true},
    {'name': 'Salt Lake, Kolkata', 'subtitle': 'Block pandals & modern theme setups', 'supported': true},
    {'name': 'Siliguri, WB', 'subtitle': 'North Bengal Durga Puja discovery', 'supported': false},
    {'name': 'Durgapur, WB', 'subtitle': 'Steel city puja festival trail', 'supported': false},
    {'name': 'Asansol, WB', 'subtitle': 'Paschim Bardhaman puja guide', 'supported': false},
    {'name': 'Dhaka, Bangladesh', 'subtitle': 'International Ramna Kali Bari Puja', 'supported': false},
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PandalProvider>();
    final filteredCities = _supportedCities.where((c) {
      final name = (c['name'] as String).toLowerCase();
      return name.contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Select Location',
          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Column(
        children: [
          // Search Input Container
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _query = val),
              decoration: InputDecoration(
                hintText: 'Search city or region...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Use Live GPS Option
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFFF2F0),
                child: Icon(Icons.my_location_rounded, color: AppColors.primary),
              ),
              title: const Text(
                'Use My Current Location',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              subtitle: const Text('Detect GPS location automatically'),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
              onTap: () async {
                await provider.determinePosition();
                if (mounted) {
                  provider.setSelectedLocation('Live Location (Kolkata)');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Updated active location to Live GPS Coordinates'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'POPULAR CITIES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: Colors.grey,
                ),
              ),
            ),
          ),

          // City List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredCities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final city = filteredCities[index];
                final String name = city['name'];
                final String subtitle = city['subtitle'];
                final bool isSupported = city['supported'];
                final bool isSelected = provider.selectedLocation == name;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[200]!,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.location_city_rounded,
                      color: isSupported ? AppColors.primary : Colors.grey,
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSupported ? Colors.black87 : Colors.grey[700],
                      ),
                    ),
                    subtitle: Text(
                      isSupported ? subtitle : '$subtitle • Coming Soon',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSupported ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                        : (isSupported
                            ? const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey)
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Soon',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                                ),
                              )),
                    onTap: () {
                      if (isSupported) {
                        provider.setSelectedLocation(name);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Active location set to $name'),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Coming Soon to $name'),
                            content: Text('Manchitra isn\'t available in $name yet — stay tuned for Puja 2026 expansion!'),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
