import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/evently_theme.dart';

/// Splash screen built from layout widgets and isolated brand artwork.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color background = dark ? EventlyColors.navy : EventlyColors.lightBackground;
    final String variant = dark ? 'dark' : 'light';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: background,
      ),
      child: Scaffold(
        backgroundColor: background,
        body: LayoutBuilder(
          builder: (context, size) => Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 375,
                height: 812,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 374,
                      left: 26,
                      width: 323,
                      height: 67,
                      child: Image.asset(
                        'assets/images/branding/logo_splash_$variant.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    Positioned(
                      top: 685,
                      left: 146,
                      width: 81,
                      height: 42,
                      child: Image.asset(
                        'assets/images/branding/route_$variant.png',
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    Positioned(
                      top: 728,
                      left: 0,
                      right: 0,
                      child: Text(
                        'Supervised by Mohamed Nabil',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          height: 1.45,
                          letterSpacing: -.2,
                          color: dark ? Colors.white : const Color(0xFF17171C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
