import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'colore_screen.dart';

class SimpleAnimatedIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final String animationType;

  const SimpleAnimatedIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 80,
    this.animationType = 'bounce',
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );

    switch (animationType) {
      case 'bounce':
        return Bounce(
          duration: const Duration(milliseconds: 1000),
          child: iconWidget,
        );
      case 'pulse':
        return Pulse(
          duration: const Duration(milliseconds: 1000),
          child: iconWidget,
        );
      case 'shake':
        return ShakeX(
          duration: const Duration(milliseconds: 1000),
          child: iconWidget,
        );
      case 'spin':
        return Spin(
          duration: const Duration(milliseconds: 2000),
          child: iconWidget,
        );
      default:
        return FadeIn(
          duration: const Duration(milliseconds: 500),
          child: iconWidget,
        );
    }
  }

  // Static factory methods for common icons
  static SimpleAnimatedIcon warning() => const SimpleAnimatedIcon(
    icon: Icons.warning_amber_rounded,
    color: Colors.orange,
    animationType: 'shake',
  );

  static SimpleAnimatedIcon success() => const SimpleAnimatedIcon(
    icon: Icons.check_circle,
    color: Colors.green,
    animationType: 'bounce',
  );

  static SimpleAnimatedIcon error() => const SimpleAnimatedIcon(
    icon: Icons.error,
    color: Colors.red,
    animationType: 'shake',
  );

  static SimpleAnimatedIcon star() => const SimpleAnimatedIcon(
    icon: Icons.star_rate_rounded,
    color: Colors.amber,
    animationType: 'pulse',
  );

  static SimpleAnimatedIcon payment() => SimpleAnimatedIcon(
    icon: Icons.payment,
    color: theamcolore,
    animationType: 'pulse',
  );

  static SimpleAnimatedIcon car() => SimpleAnimatedIcon(
    icon: Icons.directions_car,
    color: theamcolore,
    animationType: 'bounce',
  );

  static SimpleAnimatedIcon booking() => SimpleAnimatedIcon(
    icon: Icons.book_online,
    color: theamcolore,
    animationType: 'bounce',
  );
}