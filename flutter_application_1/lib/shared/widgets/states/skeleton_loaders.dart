import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../loading/loading.dart';

/// ============================================================
/// MANCHITRA — Reusable Content-Matching Skeleton Loaders
/// Built using AppShimmer & SkeletonBox primitives
/// ============================================================

/// 1. Map Skeleton Loader
class MapSkeletonLoader extends StatelessWidget {
  const MapSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF4F0E8),
      child: Stack(
        children: [
          // Simulated map grid lines
          Positioned.fill(
            child: CustomPaint(
              painter: const _GridPainter(),
            ),
          ),
          // Pulsing placeholder map markers
          Positioned(
            top: 220,
            left: 80,
            child: SkeletonBox.circle(size: 42, color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          Positioned(
            top: 310,
            right: 90,
            child: SkeletonBox.circle(size: 46, color: AppColors.primary.withValues(alpha: 0.25)),
          ),
          Positioned(
            bottom: 260,
            left: 140,
            child: SkeletonBox.circle(size: 40, color: AppColors.primary.withValues(alpha: 0.2)),
          ),
          // Top search bar placeholder
          const Positioned(
            top: 54,
            left: 20,
            right: 20,
            child: SkeletonBox(height: 52, borderRadius: 30),
          ),
          // Filter chip placeholders
          Positioned(
            top: 120,
            left: 20,
            right: 20,
            child: Row(
              children: List.generate(
                3,
                (i) => const Padding(
                  padding: EdgeInsets.only(right: 10),
                  child: SkeletonBox(width: 90, height: 34, borderRadius: 18),
                ),
              ),
            ),
          ),
          // Center loading indicator badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppSpinner(size: 18, strokeWidth: 2.5),
                  SizedBox(width: 12),
                  Text(
                    'Loading Map & Pandals...',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 2. Route List Skeleton Loader (4–6 repeated route card skeletons)
class RouteListSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const RouteListSkeletonLoader({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF0EAE1)),
          ),
          child: const Row(
            children: [
              SkeletonBox(width: 60, height: 60, borderRadius: 14),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 170, height: 16, borderRadius: 4),
                    SizedBox(height: 8),
                    SkeletonBox(width: 110, height: 12, borderRadius: 4),
                    SizedBox(height: 10),
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
      },
    );
  }
}

/// 3. Pandal List / Directory Skeleton Loader
class PandalListSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const PandalListSkeletonLoader({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF0EAE1)),
          ),
          child: const Row(
            children: [
              SkeletonBox(width: 80, height: 80, borderRadius: 16),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 180, height: 16, borderRadius: 4),
                    SizedBox(height: 8),
                    SkeletonBox(width: 120, height: 12, borderRadius: 4),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        SkeletonBox(width: 70, height: 20, borderRadius: 8),
                        SizedBox(width: 8),
                        SkeletonBox(width: 50, height: 20, borderRadius: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 4. Notification List Skeleton Loader
class NotificationListSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const NotificationListSkeletonLoader({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFF0EAE1)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox.circle(size: 40),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 160, height: 15, borderRadius: 4),
                    SizedBox(height: 8),
                    SkeletonBox(width: double.infinity, height: 12, borderRadius: 4),
                    SizedBox(height: 6),
                    SkeletonBox(width: 120, height: 12, borderRadius: 4),
                    SizedBox(height: 10),
                    SkeletonBox(width: 70, height: 10, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 5. Pandal Detail Skeleton Loader
class PandalDetailSkeletonLoader extends StatelessWidget {
  const PandalDetailSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero banner skeleton
          const SkeletonBox(width: double.infinity, height: 280, borderRadius: 0),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 200, height: 24, borderRadius: 6),
                    SkeletonBox(width: 70, height: 24, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 12),
                const SkeletonBox(width: 140, height: 14, borderRadius: 4),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: SkeletonBox(height: 48, borderRadius: 16)),
                    SizedBox(width: 12),
                    Expanded(child: SkeletonBox(height: 48, borderRadius: 16)),
                  ],
                ),
                const SizedBox(height: 24),
                const SkeletonBox(width: 120, height: 18, borderRadius: 4),
                const SizedBox(height: 12),
                const SkeletonBox(width: double.infinity, height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const SkeletonBox(width: double.infinity, height: 14, borderRadius: 4),
                const SizedBox(height: 8),
                const SkeletonBox(width: 220, height: 14, borderRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 6. Profile Screen Skeleton Loader
class ProfileSkeletonLoader extends StatelessWidget {
  const ProfileSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const SkeletonBox.circle(size: 90),
          const SizedBox(height: 16),
          const SkeletonBox(width: 160, height: 20, borderRadius: 6),
          const SizedBox(height: 8),
          const SkeletonBox(width: 120, height: 14, borderRadius: 4),
          const SizedBox(height: 28),
          const Row(
            children: [
              Expanded(child: SkeletonBox(height: 70, borderRadius: 18)),
              SizedBox(width: 12),
              Expanded(child: SkeletonBox(height: 70, borderRadius: 18)),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            children: List.generate(
              4,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: SkeletonBox(width: double.infinity, height: 56, borderRadius: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 7. Pandal Sheet Skeleton Loader
class PandalSheetSkeletonLoader extends StatelessWidget {
  const PandalSheetSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonBox(width: 40, height: 4, borderRadius: 2),
          SizedBox(height: 20),
          SkeletonBox(width: double.infinity, height: 180, borderRadius: 16),
          SizedBox(height: 16),
          SkeletonBox(width: 200, height: 18, borderRadius: 6),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
