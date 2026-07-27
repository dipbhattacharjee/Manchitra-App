import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:manchitra/core/models/models.dart';
import 'package:manchitra/core/theme/theme.dart';

/// ============================================================
/// MANCHITRA — Pandal Marker Layer with Photo Avatars & Clustering
/// ============================================================

class PandalMarkerLayer extends StatelessWidget {
  final List<Pandal> pandals;
  final Pandal? selectedPandal;
  final ValueChanged<Pandal> onPandalTapped;

  const PandalMarkerLayer({
    super.key,
    required this.pandals,
    this.selectedPandal,
    required this.onPandalTapped,
  });

  @override
  Widget build(BuildContext context) {
    final List<Marker> markers = pandals.map<Marker>((pandal) {
      final isSelected = selectedPandal?.id == pandal.id;
      final isFeatured = pandal.isFeatured2026;

      return Marker(
        width: isSelected ? 56.0 : (isFeatured ? 48.0 : 44.0),
        height: isSelected ? 56.0 : (isFeatured ? 48.0 : 44.0),
        point: LatLng(pandal.latitude, pandal.longitude),
        child: GestureDetector(
          onTap: () => onPandalTapped(pandal),
          child: AnimatedScale(
            scale: isSelected ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: _buildPandalPhotoMarker(pandal, isSelected, isFeatured),
          ),
        ),
      );
    }).toList();

    return MarkerClusterLayerWidget(
      options: MarkerClusterLayerOptions(
        maxClusterRadius: 45,
        size: const Size(44, 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(50),
        markers: markers,
        builder: (context, clusterMarkers) {
          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: Center(
              child: Text(
                clusterMarkers.length.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPandalPhotoMarker(Pandal pandal, bool isSelected, bool isFeatured) {
    final photoUrl = pandal.coverPhotoUrl ??
        (pandal.photoUrls.isNotEmpty ? pandal.photoUrls.first : null);
    final hasPhoto = photoUrl != null && photoUrl.trim().isNotEmpty;

    // Ring border color coding logic
    final borderColor = isSelected
        ? AppColors.secondary
        : (isFeatured ? AppColors.primary : AppColors.tertiary);

    final double size = isSelected ? 54.0 : (isFeatured ? 46.0 : 42.0);

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Circular Avatar Marker Frame (Photo with Ring & Drop Shadow)
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: borderColor,
              width: isSelected ? 3.0 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.secondary.withOpacity(0.45)
                    : Colors.black.withOpacity(0.25),
                blurRadius: isSelected ? 10 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: hasPhoto
                ? Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildFallbackIcon(isSelected, isFeatured),
                  )
                : _buildFallbackIcon(isSelected, isFeatured),
          ),
        ),

        // Rating Star Badge on top-right of marker
        if (pandal.rating != null || isFeatured)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFFDC003),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 11,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallbackIcon(bool isSelected, bool isFeatured) {
    final bgColor = isSelected
        ? AppColors.secondary
        : (isFeatured ? AppColors.primary : Colors.white);
    final iconColor = isSelected || isFeatured ? Colors.white : AppColors.primary;

    return Container(
      color: bgColor,
      child: Center(
        child: Icon(
          Icons.temple_hindu,
          size: isSelected ? 24 : (isFeatured ? 20 : 18),
          color: iconColor,
        ),
      ),
    );
  }
}
