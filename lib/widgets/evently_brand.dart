import 'package:flutter/material.dart';

/// Exact exported logo lettering isolated from the supplied design references.
/// `size` is the reference logo height; its aspect ratio remains unchanged.
class EventlyBrand extends StatelessWidget {
  const EventlyBrand({super.key, this.size = 27, this.color});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final String mode = Theme.of(context).brightness == Brightness.dark
        ? 'dark'
        : 'light';
    return Image.asset(
      'assets/images/branding/logo_header_$mode.png',
      width: 149 / 31 * size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Evently',
    );
  }
}
