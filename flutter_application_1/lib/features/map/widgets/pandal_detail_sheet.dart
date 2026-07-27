import 'package:flutter/material.dart';
import 'package:manchitra/core/models/models.dart';
import 'package:manchitra/core/theme/theme.dart';
import 'package:manchitra/core/services/crowd_analyzer_service.dart';

/// ============================================================
/// MANCHITRA — Pandal Detail Bottom Sheet
/// ============================================================

class PandalDetailSheet extends StatefulWidget {
  final Pandal pandal;
  final String distanceText;
  final String etaText;
  final VoidCallback onStartNavigation;
  final VoidCallback onAddToHop;
  final VoidCallback onClose;

  const PandalDetailSheet({
    super.key,
    required this.pandal,
    required this.distanceText,
    required this.etaText,
    required this.onStartNavigation,
    required this.onAddToHop,
    required this.onClose,
  });

  @override
  State<PandalDetailSheet> createState() => _PandalDetailSheetState();
}

class _PandalDetailSheetState extends State<PandalDetailSheet> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      snap: true,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: AppColors.primaryContainer,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: (widget.pandal.coverPhotoUrl != null &&
                            widget.pandal.coverPhotoUrl!.isNotEmpty)
                        ? Image.network(
                            widget.pandal.coverPhotoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.temple_hindu,
                              color: AppColors.primary,
                              size: 36,
                            ),
                          )
                        : const Icon(
                            Icons.temple_hindu,
                            color: AppColors.primary,
                            size: 36,
                          ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.pandal.name,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              onPressed: widget.onClose,
                              icon: const Icon(Icons.close_rounded, color: Colors.grey),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.pandal.area,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        Wrap(
                          spacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF2F0),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                widget.pandal.category.label,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Builder(
                              builder: (context) {
                                final aggregatedCrowd = CrowdAnalyzerService.instance.getAggregatedCrowdLevel(widget.pandal);
                                return GestureDetector(
                                  onTap: () => CrowdAnalyzerService.showReportDialog(context, widget.pandal, () {
                                    setState(() {});
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: aggregatedCrowd.color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: aggregatedCrowd.color.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.people_alt_rounded, size: 12, color: aggregatedCrowd.color),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${aggregatedCrowd.label} Crowd',
                                          style: TextStyle(
                                            color: aggregatedCrowd.color,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.straighten_rounded,
                      label: 'Distance',
                      value: widget.distanceText,
                    ),
                    Container(height: 28, width: 1, color: Colors.grey[300]),
                    _buildStatItem(
                      icon: Icons.access_time_rounded,
                      label: 'Estimated ETA',
                      value: widget.etaText,
                    ),
                    Container(height: 28, width: 1, color: Colors.grey[300]),
                    _buildStatItem(
                      icon: Icons.star_rounded,
                      label: 'Rating',
                      value: widget.pandal.rating != null
                          ? widget.pandal.rating!.toStringAsFixed(1)
                          : '4.8 ★',
                    ),
                  ],
                ),
              ),

              if (widget.pandal.description != null && widget.pandal.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'About this Pandal',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.pandal.description!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: _isExpanded ? null : 3,
                  overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
                if (widget.pandal.description!.length > 90)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _isExpanded ? 'Read less' : 'Read more',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],

              const SizedBox(height: 24),

              Row(
                children: [
                  OutlinedButton(
                    onPressed: widget.onAddToHop,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: const Icon(Icons.bookmark_add_outlined, size: 22),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.onStartNavigation,
                      icon: const Icon(Icons.navigation_rounded, color: Colors.white),
                      label: const Text(
                        'Start Turn-by-Turn',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
