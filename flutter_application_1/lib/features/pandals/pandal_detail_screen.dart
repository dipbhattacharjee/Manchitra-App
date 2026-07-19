import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/theme.dart';
import '../../core/models/models.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../core/services/route_service.dart';
import '../../core/services/cloudinary_service.dart';
import '../../core/services/supabase_service.dart';
import '../profile/profile_data.dart';
import 'package:url_launcher/url_launcher.dart';

/// ============================================================
/// MANCHITRA — Pandal Detail Screen
/// ============================================================

class PandalDetailScreen extends StatefulWidget {
  const PandalDetailScreen({super.key, required this.pandal});
  final Pandal pandal;

  @override
  State<PandalDetailScreen> createState() => _PandalDetailScreenState();
}

class _PandalDetailScreenState extends State<PandalDetailScreen> {
  bool _isFavorited = false;
  bool _isInHop = false;
  late List<String> _photoUrls;
  String? _coverPhotoUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _isInHop = HopListManager.selectedPandals.any((p) => p.id == widget.pandal.id);
    _photoUrls = List.from(widget.pandal.photoUrls);
    _coverPhotoUrl = widget.pandal.coverPhotoUrl;
    _isFavorited = ProfileData.isFavorite(widget.pandal.id);
  }

  Future<void> _launchMaps() async {
    final lat = widget.pandal.latitude;
    final lng = widget.pandal.longitude;
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    final appleMapsUrl = Uri.parse('maps://?q=$lat,$lng');

    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(appleMapsUrl)) {
          await launchUrl(appleMapsUrl);
          return;
        }
      }
      
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl);
      } else {
        throw 'Could not launch maps URL';
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open maps application.'),
            backgroundColor: AppColors.tertiary,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                'Upload Photo',
                style: AppTextStyles.titleMedium,
              ),
              const Divider(color: AppColors.border),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.primary),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.primary),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );

      if (source == null) return;

      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1080,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final file = File(pickedFile.path);
      final imageUrl = await CloudinaryService.uploadImage(
        file,
        folder: 'pandals/${widget.pandal.id}',
      );

      if (imageUrl == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image to Cloudinary'),
              backgroundColor: AppColors.tertiary,
            ),
          );
        }
        setState(() => _isUploading = false);
        return;
      }

      final isFirstPhoto = _photoUrls.isEmpty && (_coverPhotoUrl == null || _coverPhotoUrl!.isEmpty);
      final success = await SupabaseService.instance.addPandalPhoto(
        widget.pandal.id,
        imageUrl,
        isCover: isFirstPhoto,
      );

      if (success) {
        setState(() {
          if (isFirstPhoto) {
            _coverPhotoUrl = imageUrl;
          } else {
            _photoUrls.add(imageUrl);
          }
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo uploaded and saved to Supabase!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        setState(() => _isUploading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Uploaded to Cloudinary but failed to register in Supabase'),
              backgroundColor: AppColors.tertiary,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking/uploading photo: $e');
      setState(() => _isUploading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero image sliver
          _buildSliverHero(),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPandalInfo(),
                _buildDividerLine(),
                _buildAboutSection(),
                _buildDividerLine(),
                _buildTimingsGrid(),
                _buildDividerLine(),
                _buildPhotosSection(),
                _buildDividerLine(),
                _buildLocationSection(),
                const SizedBox(height: 100), // space for sticky bottom bar
              ],
            ),
          ),
        ],
      ),

      // Sticky action bar
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverHero() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.background,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.modalOverlay,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isFavorited = !_isFavorited;
                if (_isFavorited) {
                  ProfileData.addFavorite(widget.pandal);
                } else {
                  ProfileData.removeFavorite(widget.pandal.id);
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isFavorited
                      ? 'Saved ${widget.pandal.name} to favorites!'
                      : 'Removed ${widget.pandal.name} from favorites!'),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.modalOverlay,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isFavorited ? Icons.favorite : Icons.favorite_border,
                color: _isFavorited ? AppColors.tertiary : Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.modalOverlay,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (_photoUrls.isNotEmpty)
              PageView.builder(
                itemCount: _photoUrls.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    _photoUrls[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.primaryContainer,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined, color: AppColors.primary, size: 48),
                      ),
                    ),
                  );
                },
              )
            else if (_coverPhotoUrl != null && _coverPhotoUrl!.isNotEmpty)
              Image.network(
                _coverPhotoUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.primaryContainer,
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined, color: AppColors.primary, size: 48),
                  ),
                ),
              )
            else
              // Gradient hero image placeholder
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryContainer, AppColors.tertiaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.temple_hindu, size: 80, color: AppColors.secondary),
                ),
              ),
            // Overlay
            const DecoratedBox(
              decoration: BoxDecoration(gradient: AppColors.featuredCardOverlay),
            ),
            // Featured badge
            if (widget.pandal.isFeatured2026)
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryButtonGradient,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '★ FEATURED 2026',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.onPrimary,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPandalInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text(widget.pandal.name, style: AppTextStyles.headlineSmall),

          if (widget.pandal.committeeName != null) ...[
            const SizedBox(height: 4),
            Text(widget.pandal.committeeName!, style: AppTextStyles.bodySmall),
          ],

          const SizedBox(height: 12),

          // Tags row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              GlowChip(label: widget.pandal.area, icon: Icons.location_on_outlined),
              GlowChip(
                  label: widget.pandal.category.label,
                  activeColor: AppColors.tertiary),
              if (widget.pandal.theme != null)
                GlowChip(label: widget.pandal.theme!, activeColor: AppColors.secondary),
            ],
          ),

          const SizedBox(height: 12),

          // Rating
          if (widget.pandal.rating != null)
            StarRatingRow(
              rating: widget.pandal.rating!,
              reviewCount: widget.pandal.reviewCount ~/ 1000,
            ),
        ],
      ),
    );
  }

  Widget _buildTimingsGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Info', icon: Icons.info_outline),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _infoCard(
                Icons.access_time,
                'Opens',
                widget.pandal.visitStartTime ?? 'All day',
              ),
              _infoCard(
                Icons.people_outline,
                'Crowd',
                widget.pandal.crowdLevel.label,
                valueColor: widget.pandal.crowdLevel.color,
              ),
              _infoCard(
                Icons.wb_sunny_outlined,
                'Best Time',
                'Morning / Evening',
              ),
              _infoCard(
                Icons.directions_walk,
                'Distance',
                widget.pandal.distanceText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: AppTextStyles.labelSmall),
                Text(
                  value,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: valueColor ?? AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'About This Pandal', icon: Icons.article_outlined),
          const SizedBox(height: 8),
          Text(
            widget.pandal.description ??
                'This is one of the celebrated Durga Puja pandals in Kolkata, known for its spectacular theme and community spirit.',
            style: AppTextStyles.bodyMedium,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          TextButton(
            onPressed: () {},
            child: const Text('Read More'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'Location', icon: Icons.map_outlined),
          const SizedBox(height: 12),

          // Map placeholder
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              children: [
                // Dark map placeholder
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const RadialGradient(
                      colors: [Color(0xFF1A2030), Color(0xFF0D1218)],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppColors.glowSaffron, blurRadius: 12),
                          ],
                        ),
                        child: const Icon(Icons.location_pin, color: Colors.white, size: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.pandal.area}',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          OutlinedGoldButton(
            onPressed: _launchMaps,
            text: 'Get Directions',
            icon: const Icon(Icons.directions, color: AppColors.secondary, size: 18),
            height: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildDividerLine() {
    return Container(
      height: 6,
      color: AppColors.background,
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GradientButton(
              onPressed: () {
                setState(() {
                  _isInHop = !_isInHop;
                  if (_isInHop) {
                    HopListManager.add(widget.pandal);
                  } else {
                    HopListManager.remove(widget.pandal.id);
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isInHop
                        ? 'Added ${widget.pandal.name} to your Hop List!'
                        : 'Removed ${widget.pandal.name} from your Hop List!'),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              text: _isInHop ? '✓ In Hop List' : '+ Add to Hop List',
              height: 52,
              hasGlow: true,
            ),
          ),
          const SizedBox(width: 12),
          OutlinedGoldButton(
            onPressed: _launchMaps,
            text: 'Navigate',
            icon: const Icon(Icons.navigation, color: AppColors.secondary, size: 18),
            height: 52,
            width: null,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    final allPhotos = [
      if (_coverPhotoUrl != null && _coverPhotoUrl!.isNotEmpty) _coverPhotoUrl!,
      ..._photoUrls,
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SectionHeader(
                title: 'Pandal Gallery',
                icon: Icons.photo_library_outlined,
              ),
              if (_isUploading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.add_a_photo_outlined, color: AppColors.secondary),
                  onPressed: _pickAndUploadPhoto,
                  tooltip: 'Upload Photo',
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (allPhotos.isEmpty)
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  'No photos yet. Be the first to share one!',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[500]),
                ),
              ),
            )
          else
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: allPhotos.length,
                itemBuilder: (context, index) {
                  final url = allPhotos[index];
                  final isCover = url == _coverPhotoUrl;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            url,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                width: 110,
                                height: 110,
                                color: AppColors.surface,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                          ),
                        ),
                        if (isCover)
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'COVER',
                                style: AppTextStyles.labelSmall.copyWith(
                                  fontSize: 8,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
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
