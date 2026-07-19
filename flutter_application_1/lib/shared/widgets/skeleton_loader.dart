import 'package:flutter/material.dart';

/// Base skeleton widget with a pulsing fade animation.
class SkeletonWidget extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<SkeletonWidget> createState() => _SkeletonWidgetState();
}

class _SkeletonWidgetState extends State<SkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.35, end: 0.75).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for a featured pandal card (width: 280, height: 240) on the Home Screen.
class FeaturedPandalCardSkeleton extends StatelessWidget {
  const FeaturedPandalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Trending tag
          SkeletonWidget(width: 80, height: 18, borderRadius: 100),
          Spacer(),
          // Pandal name
          SkeletonWidget(width: 200, height: 22, borderRadius: 6),
          SizedBox(height: 8),
          // Location
          Row(
            children: [
              SkeletonWidget(width: 14, height: 14, borderRadius: 100),
              SizedBox(width: 6),
              SkeletonWidget(width: 100, height: 14, borderRadius: 4),
            ],
          ),
          SizedBox(height: 16),
          // Bottom stats
          Row(
            children: [
              Expanded(child: SkeletonWidget(width: double.infinity, height: 26, borderRadius: 12)),
              SizedBox(width: 8),
              Expanded(child: SkeletonWidget(width: double.infinity, height: 26, borderRadius: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton for a nearby pandal card (width: 220, height: 180) on the Home Screen.
class NearbyPandalCardSkeleton extends StatelessWidget {
  const NearbyPandalCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonWidget(width: 150, height: 18, borderRadius: 6),
          SizedBox(height: 8),
          Row(
            children: [
              SkeletonWidget(width: 8, height: 8, borderRadius: 100),
              SizedBox(width: 6),
              SkeletonWidget(width: 80, height: 12, borderRadius: 4),
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonWidget(width: 70, height: 24, borderRadius: 12),
              SkeletonWidget(width: 36, height: 36, borderRadius: 100),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton for a pandal card in directory or search list views (vertical lists).
class PandalDirectoryCardSkeleton extends StatelessWidget {
  const PandalDirectoryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
      ),
      padding: const EdgeInsets.all(12),
      child: const Row(
        children: [
          // 80x80 Pandal Thumbnail skeleton
          SkeletonWidget(width: 80, height: 80, borderRadius: 20),
          SizedBox(width: 14),
          // Details skeleton
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                SkeletonWidget(width: 180, height: 18, borderRadius: 6),
                SizedBox(height: 8),
                // Area
                Row(
                  children: [
                    SkeletonWidget(width: 12, height: 12, borderRadius: 100),
                    SizedBox(width: 4),
                    SkeletonWidget(width: 90, height: 12, borderRadius: 4),
                  ],
                ),
                SizedBox(height: 8),
                // Theme / Category
                Row(
                  children: [
                    SkeletonWidget(width: 60, height: 18, borderRadius: 8),
                    SizedBox(width: 8),
                    SkeletonWidget(width: 50, height: 18, borderRadius: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for the Weather Screen
class WeatherScreenSkeleton extends StatelessWidget {
  const WeatherScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Weather Card skeleton
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.all(24),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonWidget(width: 120, height: 16, borderRadius: 4),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonWidget(width: 80, height: 48, borderRadius: 8),
                    SkeletonWidget(width: 60, height: 60, borderRadius: 100),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonWidget(width: 100, height: 14, borderRadius: 4),
                    SkeletonWidget(width: 80, height: 14, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Heading skeleton
          const SkeletonWidget(width: 150, height: 20, borderRadius: 6),
          const SizedBox(height: 16),
          // 3-day forecast items skeleton
          Row(
            children: List.generate(3, (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == 2 ? 0 : 12),
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                padding: const EdgeInsets.all(12),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SkeletonWidget(width: 40, height: 12, borderRadius: 4),
                    SizedBox(height: 8),
                    SkeletonWidget(width: 24, height: 24, borderRadius: 100),
                    SizedBox(height: 8),
                    SkeletonWidget(width: 30, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            )),
          ),
          const SizedBox(height: 24),
          // warning alert card skeleton
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[200]!),
            ),
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                SkeletonWidget(width: 40, height: 40, borderRadius: 100),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkeletonWidget(width: 120, height: 14, borderRadius: 4),
                      SizedBox(height: 6),
                      SkeletonWidget(width: 180, height: 12, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

