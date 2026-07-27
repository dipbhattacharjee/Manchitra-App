import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../core/theme/theme.dart';
import 'state_base_layout.dart';

/// ============================================================
/// MANCHITRA — No Internet Screen with Live Connectivity Listener
/// ============================================================

class NoInternetScreen extends StatefulWidget {
  final VoidCallback? onRetry;
  final Widget? child;

  const NoInternetScreen({
    super.key,
    this.onRetry,
    this.child,
  });

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final isDisconnected = results.contains(ConnectivityResult.none);
      if (mounted) {
        setState(() {
          _isOffline = isDisconnected;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    if (mounted) {
      setState(() {
        _isOffline = results.contains(ConnectivityResult.none);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOffline && widget.child != null) {
      return widget.child!;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StateBaseLayout(
          iconWidget: const Icon(
            Icons.wifi_off_rounded,
            size: 48,
            color: AppColors.primary,
          ),
          title: "You're Offline",
          message: 'Please check your internet connection and try again. Manchitra requires connection to fetch live pandal details and maps.',
          primaryButtonText: 'Retry Connection',
          onPrimaryAction: () async {
            await _checkConnectivity();
            if (widget.onRetry != null) widget.onRetry!();
          },
        ),
      ),
    );
  }
}
