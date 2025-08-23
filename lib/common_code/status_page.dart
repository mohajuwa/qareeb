import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:provider/provider.dart';

import 'package:get/get.dart'; // ✅ For .tr support

import 'colore_screen.dart';

import 'network_service.dart';

enum StatusType {
  noInternet,

  serverError,

  timeout,

  noData,

  loading,

  success,

  error,

  maintenance,
}

class ModernStatusPage extends StatefulWidget {
  final StatusType statusType;

  final String? customTitle;

  final String? customSubtitle;

  final String? customButtonText;

  final VoidCallback? onRetry;

  final Widget? customIcon;

  final Color? customAccentColor;

  final bool showRetryButton;

  final bool isFullScreen;

  const ModernStatusPage({
    super.key,
    required this.statusType,
    this.customTitle,
    this.customSubtitle,
    this.customButtonText,
    this.onRetry,
    this.customIcon,
    this.customAccentColor,
    this.showRetryButton = true,
    this.isFullScreen = true,
  });

  @override
  State<ModernStatusPage> createState() => _ModernStatusPageState();
}

class _ModernStatusPageState extends State<ModernStatusPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  late AnimationController _fadeController;

  late Animation<double> _pulseAnimation;

  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();

    _fadeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = Provider.of<ColorNotifier>(context);

    final config = _getStatusConfig(widget.statusType, notifier);

    Widget content = _buildContent(context, notifier, config);

    return widget.isFullScreen
        ? Scaffold(
            backgroundColor: Colors.transparent,
            body: content,
          )
        : content;
  }

  Widget _buildContent(
      BuildContext context, ColorNotifier notifier, StatusConfig config) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: notifier.isDark
              ? [
                  const Color(0xFF1a1a1a),
                  const Color(0xFF2d2d2d),
                  const Color(0xFF1f1f1f),
                ]
              : [
                  const Color(0xFFF8F9FA),
                  const Color(0xFFFFFFFF),
                  const Color(0xFFF1F3F4),
                ],
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo with glow effect

                  _buildAppLogo(notifier, config),

                  const SizedBox(height: 50),

                  // Status Icon with animation

                  _buildStatusIcon(config),

                  const SizedBox(height: 40),

                  // Title

                  _buildTitle(notifier, config),

                  const SizedBox(height: 20),

                  // Subtitle

                  _buildSubtitle(notifier, config),

                  const SizedBox(height: 60),

                  // Action Button

                  if (widget.showRetryButton && widget.onRetry != null)
                    _buildActionButton(config),

                  const SizedBox(height: 30),

                  // Connection Status

                  _buildConnectionStatus(notifier),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppLogo(ColorNotifier notifier, StatusConfig config) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.statusType == StatusType.loading
              ? _pulseAnimation.value
              : 1.0,
          child: Container(
            width: 140,
            height: 140,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: config.accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: config.accentColor.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: config.accentColor.withOpacity(0.1),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
            child: _buildLogoSvg(notifier),
          ),
        );
      },
    );
  }

  Widget _buildLogoSvg(ColorNotifier notifier) {
    try {
      return notifier.isDark
          ? SvgPicture.asset(
              "assets/svgpicture/app_logo_light.svg",
              fit: BoxFit.contain,
            )
          : SvgPicture.asset(
              "assets/svgpicture/app_logo_dark.svg",
              fit: BoxFit.contain,
            );
    } catch (e) {
      // Fallback if SVG not found

      return Container(
        decoration: BoxDecoration(
          color: notifier.isDark ? Colors.white : Colors.black,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            "ق", // ✅ Arabic letter for Qareeb

            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: notifier.isDark ? Colors.black : Colors.white,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildStatusIcon(StatusConfig config) {
    return widget.customIcon ??
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: config.accentColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: config.accentColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                config.icon,
                size: 50,
                color: config.accentColor,
              ),
            );
          },
        );
  }

  Widget _buildTitle(ColorNotifier notifier, StatusConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Text(
        (widget.customTitle ?? config.title).tr, // ✅ Added .tr

        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: notifier.textColor,
          letterSpacing: -1.0,
          height: 1.2,
        ),

        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubtitle(ColorNotifier notifier, StatusConfig config) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Text(
        (widget.customSubtitle ?? config.subtitle).tr, // ✅ Added .tr

        style: TextStyle(
          fontSize: 16,
          color: notifier.textColor.withOpacity(0.7),
          height: 1.6,
          letterSpacing: 0.2,
        ),

        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButton(StatusConfig config) {
    return Container(
      width: 220,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: config.accentColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: widget.onRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: config.accentColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              config.buttonIcon,
              size: 24,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Text(
              (widget.customButtonText ?? config.buttonText).tr, // ✅ Added .tr

              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(ColorNotifier notifier) {
    return StreamBuilder<bool>(
      stream: NetworkService().connectionStream,
      initialData: NetworkService().isConnected,
      builder: (context, snapshot) {
        bool isConnected = snapshot.data ?? false;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: notifier.containercolore.withOpacity(0.8),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isConnected ? Colors.green : Colors.red,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (isConnected ? Colors.green : Colors.red).withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isConnected ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isConnected ? Colors.green : Colors.red)
                          .withOpacity(0.5),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isConnected
                    ? "${"Connected".tr} • ${NetworkService().connectionType}"
                    : "No Connection".tr,
                style: TextStyle(
                  color: notifier.textColor.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  StatusConfig _getStatusConfig(StatusType type, ColorNotifier notifier) {
    switch (type) {
      case StatusType.noInternet:
        return StatusConfig(
          title: "No Internet Connection", // ✅ Will be localized with .tr

          subtitle:
              "Please check your internet connection and try again. Make sure you're connected to Wi-Fi or mobile data.",

          icon: Icons.wifi_off_rounded,

          accentColor: Colors.orange,

          buttonText: "Try Again",

          buttonIcon: Icons.refresh,
        );

      case StatusType.serverError:
        return StatusConfig(
          title: "Server Error",
          subtitle:
              "We're having trouble connecting to our servers. Our team has been notified and is working on a fix.",
          icon: Icons.dns_rounded,
          accentColor: Colors.red,
          buttonText: "Retry",
          buttonIcon: Icons.refresh,
        );

      case StatusType.timeout:
        return StatusConfig(
          title: "Request Timeout",
          subtitle:
              "The request is taking longer than expected. Please check your connection and try again.",
          icon: Icons.access_time_rounded,
          accentColor: Colors.amber,
          buttonText: "Try Again",
          buttonIcon: Icons.refresh,
        );

      case StatusType.noData:
        return StatusConfig(
          title: "No Data Available",
          subtitle:
              "There's no data to show right now. Please try again later or refresh to check for updates.",
          icon: Icons.inbox_rounded,
          accentColor: theamcolore,
          buttonText: "Refresh",
          buttonIcon: Icons.refresh,
        );

      case StatusType.loading:
        return StatusConfig(
          title: "Loading...",
          subtitle:
              "Please wait while we fetch your data. This should only take a moment.",
          icon: Icons.hourglass_empty_rounded,
          accentColor: theamcolore,
          buttonText: "Loading",
          buttonIcon: Icons.hourglass_empty,
        );

      case StatusType.maintenance:
        return StatusConfig(
          title: "Under Maintenance",
          subtitle:
              "We're currently performing maintenance to improve your experience. Please try again shortly.",
          icon: Icons.build_rounded,
          accentColor: Colors.purple,
          buttonText: "Check Again",
          buttonIcon: Icons.refresh,
        );

      case StatusType.error:
      default:
        return StatusConfig(
          title: "Something Went Wrong",
          subtitle:
              "We encountered an unexpected error. Please try again or contact support if the problem persists.",
          icon: Icons.error_outline_rounded,
          accentColor: Colors.red,
          buttonText: "Try Again",
          buttonIcon: Icons.refresh,
        );
    }
  }
}

class StatusConfig {
  final String title;

  final String subtitle;

  final IconData icon;

  final Color accentColor;

  final String buttonText;

  final IconData buttonIcon;

  StatusConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.buttonText,
    required this.buttonIcon,
  });
}
