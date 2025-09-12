import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../common_code/colore_screen.dart';
import '../common_code/config.dart';

class ImageUtils {
  /// Creates a profile image widget with fallback and error handling
  static Widget buildProfileImage({
    required String? imageUrl,
    required double height,
    required double width,
    Color? backgroundColor,
    Color? iconColor,
    double? iconSize,
  }) {
    final bool hasValidImage = imageUrl != null && imageUrl.isNotEmpty;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.grey.shade300,
      ),
      child: hasValidImage
          ? ClipOval(
              child: Image.network(
                "${Config.imageurl}$imageUrl",
                height: height,
                width: width,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: iconSize ?? (height * 0.5),
                    color: iconColor ?? Colors.grey.shade600,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            )
          : Icon(
              Icons.person,
              size: iconSize ?? (height * 0.5),
              color: iconColor ?? Colors.grey.shade600,
            ),
    );
  }

  /// Creates a themed logo widget with fallback
  static Widget buildThemedLogo({
    required BuildContext context,
    required double height,
    required double width,
    String? lightLogoPath,
    String? darkLogoPath,
    String? fallbackLightPath = "assets/svgpicture/app_logo_light.svg",
    String? fallbackDarkPath = "assets/svgpicture/app_logo_dark.svg",
  }) {
    final notifier = Provider.of<ColorNotifier>(context, listen: true);

    final String logoPath = notifier.isDark == true
        ? (darkLogoPath ?? fallbackDarkPath!)
        : (lightLogoPath ?? fallbackLightPath!);

    return SvgPicture.asset(
      logoPath,
      height: height,
      width: width,
    );
  }

  /// Creates a general image widget with multiple fallback options and error handling
  static Widget buildImageWithFallback({
    required String? imageUrl,
    required double height,
    required double width,
    Widget? fallbackWidget,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Color? backgroundColor,
  }) {
    final bool hasValidImage = imageUrl != null && imageUrl.isNotEmpty;

    Widget defaultFallback = fallbackWidget ??
        Icon(
          Icons.image,
          size: height * 0.4,
          color: Colors.grey.shade400,
        );

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: backgroundColor,
      ),
      child: hasValidImage
          ? ClipRRect(
              borderRadius: borderRadius ?? BorderRadius.zero,
              child: Image.network(
                "${Config.imageurl}$imageUrl",
                height: height,
                width: width,
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return defaultFallback;
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            )
          : defaultFallback,
    );
  }

  /// Creates a vehicle image widget with themed logo fallback
  static Widget buildVehicleImage({
    required BuildContext context,
    required String? imageUrl,
    required double height,
    required double width,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
  }) {
    final bool hasValidImage = imageUrl != null && imageUrl.isNotEmpty;
    final notifier = Provider.of<ColorNotifier>(context, listen: false);

    Widget themedLogo = SvgPicture.asset(
      notifier.isDark == true
          ? "assets/svgpicture/app_logo_dark.svg"
          : "assets/svgpicture/app_logo_light.svg",
      height: height * 0.5,
      width: width * 0.5,
    );

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
      ),
      child: hasValidImage
          ? ClipRRect(
              borderRadius: borderRadius ?? BorderRadius.zero,
              child: Image.network(
                "${Config.imageurl}$imageUrl",
                height: height,
                width: width,
                fit: fit,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: themedLogo);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
              ),
            )
          : Center(child: themedLogo),
    );
  }
}
