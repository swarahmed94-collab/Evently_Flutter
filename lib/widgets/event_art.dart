import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/event_category.dart';
import '../theme/evently_theme.dart';

class EventArt extends StatelessWidget {
  const EventArt({super.key, required this.category, this.borderRadius = 14});
  final EventCategory category;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AspectRatio(
        aspectRatio: 343 / 193,
        child: SvgPicture.asset(
          category.banner(dark),
          fit: BoxFit.cover,
          placeholderBuilder: (context) => ColoredBox(color: dark ? EventlyColors.darkSurface : Colors.white),
        ),
      ),
    );
  }
}
