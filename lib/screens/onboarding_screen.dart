import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_settings.dart';
import '../theme/evently_theme.dart';
import '../widgets/evently_brand.dart';

/// The 375 × 812 reference coordinate system is scaled uniformly to the device.
/// All text and interactive elements remain real Flutter widgets.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  bool _finishing = false;

  static const List<String> _titles = <String>[
    'Personalize Your Experience',
    'Find Events That Inspire You',
    'Effortless Event Planning',
    'Connect with Friends & Share Moments',
  ];

  static const List<String> _descriptions = <String>[
    'Choose your preferred theme and language to get started with a comfortable, tailored experience that suits your style.',
    'Dive into a world of events crafted to fit your unique interests. Whether you’re into live music, art workshops, professional networking, or simply discovering new experiences, we have something for everyone. Our curated recommendations will help you explore, connect, and make the most of every opportunity around you.',
    'Take the hassle out of organizing events with our all-in-one planning tools. From setting up invites and managing RSVPs to scheduling reminders and coordinating details, we’ve got you covered. Plan with ease and focus on what matters – creating an unforgettable experience for you and your guests.',
    'Make every event memorable by sharing the experience with others. Our platform lets you invite friends, keep everyone in the loop, and celebrate moments together. Capture and share the excitement with your network, so you can relive the highlights and cherish the memories.',
  ];

  static const List<String> _illustrationNames = <String>[
    'personalize', 'discover', 'planning', 'connect',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    try {
      await AppSettings.instance.completeOnboarding();
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  Future<void> _next() async {
    if (_finishing) return;
    if (_currentPage == 3) {
      await _finish();
    } else {
      await _controller.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 310),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previous() {
    if (_currentPage == 0) return;
    _controller.animateToPage(
      _currentPage - 1,
      duration: const Duration(milliseconds: 310),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = Theme.of(context).brightness == Brightness.dark;
    final Color canvas = dark ? EventlyColors.navy : EventlyColors.lightBackground;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: canvas,
      ),
      child: Scaffold(
        backgroundColor: canvas,
        body: LayoutBuilder(
          builder: (context, limits) {
            return Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 375,
                  height: 812,
                  child: PageView.builder(
                    controller: _controller,
                    physics: const PageScrollPhysics(),
                    itemCount: 4,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemBuilder: (context, index) => _buildPage(context, index, dark),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context, int index, bool dark) {
    final Color primary = dark ? EventlyColors.accent : EventlyColors.deepBlue;
    final Color foreground = dark ? Colors.white : const Color(0xFF1B1B20);
    final Color copy = dark ? const Color(0xFFD7DCE9) : const Color(0xFF686868);
    final bool first = index == 0;
    final bool last = index == 3;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        // Figma header logo is a cutout of the original lettering only.
        Positioned(
          top: 62,
          left: 113,
          child: const EventlyBrand(size: 31),
        ),
        if (index >= 2)
          Positioned(
            left: 16,
            top: 65,
            child: _BackControl(onPressed: _previous, dark: dark),
          ),
        if (!first)
          Positioned(
            right: 16,
            top: 65,
            width: 62,
            height: 30,
            child: _SkipControl(dark: dark, onPressed: _finish),
          ),
        // The illustration is isolated artwork, not a screenshot of a UI page.
        Positioned(
          left: 0,
          top: first ? 109 : index == 2 ? 110 : 104,
          width: 375,
          height: first ? 355 : index == 2 ? 348 : index == 3 ? 357 : 354,
          child: Image.asset(
            'assets/images/onboarding/${_illustrationNames[index]}_${dark ? 'dark' : 'light'}.png',
            alignment: Alignment.center,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
        if (!first)
          Positioned(
            left: 0,
            right: 0,
            top: 470,
            child: _PageIndicator(activeIndex: index - 1, dark: dark),
          ),
        Positioned(
          top: first ? 485 : 498,
          left: 16,
          width: 343,
          child: Text(
            _titles[index],
            style: GoogleFonts.poppins(
              fontSize: first ? 19 : 17.7,
              height: first ? 1.45 : 1.43,
              letterSpacing: -0.15,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ),
        Positioned(
          left: 16,
          width: 343,
          top: first ? 523 : last ? 559 : 537,
          child: Text(
            _descriptions[index],
            maxLines: first ? 4 : last ? 8 : 9,
            overflow: TextOverflow.clip,
            style: GoogleFonts.poppins(
              fontSize: first ? 15.8 : 15.0,
              fontWeight: FontWeight.w400,
              height: first ? 1.51 : 1.57,
              letterSpacing: first ? -0.22 : -0.30,
              color: copy,
            ),
          ),
        ),
        if (first) ...<Widget>[
          Positioned(
            top: 631,
            left: 16,
            width: 343,
            height: 36,
            child: Row(
              children: <Widget>[
                Text('Language', style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500, fontSize: 16, color: primary,
                )),
                const Spacer(),
                _LanguageChoice(
                  selected: AppSettings.instance.language == 'en',
                  label: 'English',
                  dark: dark,
                  width: 82,
                  onPressed: () => AppSettings.instance.setLanguage('en'),
                ),
                const SizedBox(width: 8),
                _LanguageChoice(
                  selected: AppSettings.instance.language == 'ar',
                  label: 'Arabic',
                  dark: dark,
                  width: 77,
                  onPressed: () => AppSettings.instance.setLanguage('ar'),
                ),
              ],
            ),
          ),
          Positioned(
            top: 681,
            left: 16,
            width: 343,
            height: 35,
            child: Row(
              children: <Widget>[
                Text('Theme', style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500, fontSize: 16, color: primary,
                )),
                const Spacer(),
                _ThemeChoice(
                  dark: dark,
                  selected: !dark,
                  icon: _ThemeIcon.sun,
                  onPressed: () => AppSettings.instance.setDark(false),
                ),
                const SizedBox(width: 8),
                _ThemeChoice(
                  dark: dark,
                  selected: dark,
                  icon: _ThemeIcon.moon,
                  onPressed: () => AppSettings.instance.setDark(true),
                ),
              ],
            ),
          ),
        ],
        Positioned(
          left: 16,
          right: 16,
          top: first ? 737 : 742,
          height: 48,
          child: ElevatedButton(
            onPressed: _finishing ? null : _next,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: primary,
              disabledBackgroundColor: primary.withValues(alpha: .6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.zero,
              textStyle: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w500,
                letterSpacing: -.2,
              ),
            ),
            child: Text(first ? 'Let’s start' : last ? 'Get started' : 'Next'),
          ),
        ),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.activeIndex, required this.dark});
  final int activeIndex;
  final bool dark;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List<Widget>.generate(3, (i) {
      final bool active = i == activeIndex;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: active ? 21 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: active
              ? (dark ? EventlyColors.accent : EventlyColors.deepBlue)
              : (dark ? Colors.white : const Color(0xFFB7B8BC)),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }),
  );
}

class _LanguageChoice extends StatelessWidget {
  const _LanguageChoice({
    required this.selected,
    required this.label,
    required this.dark,
    required this.width,
    required this.onPressed,
  });

  final bool selected;
  final String label;
  final bool dark;
  final double width;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color primary = dark ? EventlyColors.accent : EventlyColors.deepBlue;
    return SizedBox(
      width: width,
      height: 33,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: selected ? primary : (dark ? EventlyColors.navy : Colors.white),
          foregroundColor: selected ? Colors.white : (dark ? Colors.white : primary),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: dark && !selected ? EventlyColors.borderBlue : Colors.transparent),
          ),
          textStyle: GoogleFonts.poppins(fontWeight: selected ? FontWeight.w600 : FontWeight.w400, fontSize: 12.5),
        ),
        child: Text(label),
      ),
    );
  }
}

enum _ThemeIcon { sun, moon }

class _ThemeChoice extends StatelessWidget {
  const _ThemeChoice({
    required this.dark,
    required this.selected,
    required this.icon,
    required this.onPressed,
  });

  final bool dark;
  final bool selected;
  final _ThemeIcon icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final Color primary = dark ? EventlyColors.accent : EventlyColors.deepBlue;
    final Color stroke = selected ? Colors.white : primary;
    return SizedBox(
      width: 55,
      height: 33,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? primary : (dark ? EventlyColors.navy : Colors.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: dark && !selected ? EventlyColors.borderBlue : Colors.transparent),
          ),
          child: Center(
            child: CustomPaint(
              size: const Size(24, 24),
              painter: _ThemeSymbolPainter(stroke, icon),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeSymbolPainter extends CustomPainter {
  const _ThemeSymbolPainter(this.color, this.icon);
  final Color color;
  final _ThemeIcon icon;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()
      ..color = color
      ..strokeWidth = 1.45
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final Offset center = Offset(size.width / 2, size.height / 2);
    if (icon == _ThemeIcon.sun) {
      canvas.drawCircle(center, 6.6, line);
      for (int i = 0; i < 8; i++) {
        final double angle = i * 3.141592653589793 / 4;
        final double dx = math.cos(angle);
        final double dy = math.sin(angle);
        canvas.drawLine(
          Offset(center.dx + dx * 9.4, center.dy + dy * 9.4),
          Offset(center.dx + dx * 11.8, center.dy + dy * 11.8),
          line,
        );
      }
    } else {
      final Path outer = Path()..addOval(Rect.fromCircle(center: center, radius: 9.8));
      final Path inner = Path()..addOval(Rect.fromCircle(
        center: const Offset(16.5, 7.4), radius: 9.1,
      ));
      final Path crescent = Path.combine(PathOperation.difference, outer, inner);
      canvas.drawPath(crescent, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _ThemeSymbolPainter old) =>
      color != old.color || icon != old.icon;
}

class _BackControl extends StatelessWidget {
  const _BackControl({required this.onPressed, required this.dark});
  final VoidCallback onPressed;
  final bool dark;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 28,
    height: 30,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: dark ? EventlyColors.navy : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: dark ? EventlyColors.borderBlue : Colors.transparent),
        ),
        child: Center(child: CustomPaint(
          size: const Size(16, 18),
          painter: _ChevronPainter(dark ? Colors.white : EventlyColors.deepBlue),
        )),
      ),
    ),
  );
}

class _ChevronPainter extends CustomPainter {
  const _ChevronPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
    Path()
      ..moveTo(11, 2.5)
      ..lineTo(5, 9)
      ..lineTo(11, 15.5),
    Paint()
      ..color = color
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke,
  );

  @override
  bool shouldRepaint(covariant _ChevronPainter old) => color != old.color;
}

class _SkipControl extends StatelessWidget {
  const _SkipControl({required this.dark, required this.onPressed});
  final bool dark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      backgroundColor: dark ? EventlyColors.navy : Colors.white,
      foregroundColor: dark ? Colors.white : EventlyColors.deepBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
        side: BorderSide(color: dark ? EventlyColors.borderBlue : Colors.transparent),
      ),
      textStyle: GoogleFonts.poppins(fontSize: 11.5, fontWeight: FontWeight.w500),
    ),
    child: const Text('Skip'),
  );
}
