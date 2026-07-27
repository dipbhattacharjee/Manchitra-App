import 'package:flutter/material.dart';
import 'loading/loading.dart';
export 'loading/loading.dart';

/// Legacy compatibility wrapper for SkeletonWidget using shared AppShimmer & SkeletonBox primitives.
class SkeletonWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: borderRadius,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      padding: const EdgeInsets.all(24),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SkeletonBox(width: 80, height: 18, borderRadius: 100),
          Spacer(),
          SkeletonBox(width: 200, height: 22, borderRadius: 6),
          SizedBox(height: 8),
          Row(
            children: [
              SkeletonBox.circle(size: 14),
              SizedBox(width: 6),
              SkeletonBox(width: 100, height: 14, borderRadius: 4),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: SkeletonBox(height: 26, borderRadius: 12)),
              SizedBox(width: 8),
              Expanded(child: SkeletonBox(height: 26, borderRadius: 12)),
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
        border: Border.all(color: const Color(0xFFF0EAE1)),
      ),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 150, height: 18, borderRadius: 6),
          SizedBox(height: 8),
          Row(
            children: [
              SkeletonBox.circle(size: 8),
              SizedBox(width: 6),
              SkeletonBox(width: 80, height: 12, borderRadius: 4),
            ],
          ),
          Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonBox(width: 70, height: 24, borderRadius: 12),
              SkeletonBox.circle(size: 36),
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
        border: Border.all(color: const Color(0xFFF0EAE1)),
      ),
      padding: const EdgeInsets.all(12),
      child: const Row(
        children: [
          SkeletonBox(width: 80, height: 80, borderRadius: 20),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 180, height: 18, borderRadius: 6),
                SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonBox.circle(size: 12),
                    SizedBox(width: 4),
                    SkeletonBox(width: 90, height: 12, borderRadius: 4),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonBox(width: 60, height: 18, borderRadius: 8),
                    SizedBox(width: 8),
                    SkeletonBox(width: 50, height: 18, borderRadius: 8),
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
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.all(24),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 16, borderRadius: 4),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 80, height: 48, borderRadius: 8),
                    SkeletonBox.circle(size: 60),
                  ],
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 100, height: 14, borderRadius: 4),
                    SkeletonBox(width: 80, height: 14, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SkeletonBox(width: 150, height: 20, borderRadius: 6),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              3,
              (index) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 12),
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFF0EAE1)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SkeletonBox(width: 40, height: 12, borderRadius: 4),
                      SizedBox(height: 8),
                      SkeletonBox.circle(size: 24),
                      SizedBox(height: 8),
                      SkeletonBox(width: 30, height: 12, borderRadius: 4),
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
}
