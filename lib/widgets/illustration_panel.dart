import 'package:flutter/material.dart';
import '../theme/evently_theme.dart';

/// Scalable, fully widget-rendered artwork for screens whose Figma
/// illustration vectors were not present in the provided asset export.
class IllustrationPanel extends StatelessWidget {
  const IllustrationPanel({super.key, required this.variant});
  /// 0 = discovery, 1 = planning, 2 = community, 3 = preferences, 4 = reset.
  final int variant;

  @override
  Widget build(BuildContext context) {
    final blue = EventlyColors.primary(context);
    final dark = EventlyColors.isDark(context);
    final ink = dark ? Colors.white : EventlyColors.deepBlue;
    Widget bubble(IconData icon, double size, {bool filled = false}) =>
        Container(
          width: size, height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? blue : Colors.transparent,
            border: Border.all(color: ink.withValues(alpha: .65), width: 1.4),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: filled ? Colors.white : ink, size: size * .53),
        );
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Center(child: AspectRatio(
        aspectRatio: 1.05,
        child: LayoutBuilder(builder: (context, c) => Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: CustomPaint(
              painter: _IllustrationLines(ink, variant),
            )),
            if (variant == 0 || variant == 3 || variant == 4) ...[
              Transform.rotate(
                angle: -.12,
                child: Container(
                  width: c.maxWidth * .49,
                  height: c.maxHeight * .77,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    border: Border.all(color: ink, width: 3),
                    borderRadius: BorderRadius.circular(25),
                    color: dark ? EventlyColors.navy : Colors.white,
                    boxShadow: [BoxShadow(color: ink.withValues(alpha: .12), blurRadius: 1, offset: const Offset(4, 5))],
                  ),
                  child: Column(children: [
                    Container(height: 5, width: 35, decoration: BoxDecoration(
                      color: ink, borderRadius: BorderRadius.circular(10))),
                    const Spacer(),
                    Icon(variant == 4 ? Icons.settings_suggest_outlined :
                      variant == 3 ? Icons.tune_rounded : Icons.celebration_outlined,
                      size: 81, color: ink),
                    const Spacer(),
                    for (var i = 0; i < 3; i++) Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(height: 7, decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: ink.withValues(alpha: i == 1 ? .25 : .55),
                      )),
                    ),
                    const Spacer(),
                    Icon(Icons.circle_outlined, size: 19, color: ink),
                  ]),
                ),
              ),
              Positioned(top: 25, right: 22, child: bubble(
                variant == 4 ? Icons.checklist : Icons.favorite, 45, filled: true)),
              Positioned(bottom: 40, left: 10, child: bubble(
                variant == 4 ? Icons.lock_reset_outlined : Icons.auto_awesome, 43)),
            ] else if (variant == 1) ...[
              Positioned(top: 37, left: 12, child: bubble(Icons.date_range_outlined, 68)),
              Positioned(top: 14, right: 30, child: bubble(Icons.list_alt_rounded, 70, filled: true)),
              Positioned(bottom: 39, right: 5, child: bubble(Icons.notifications_active_outlined, 64)),
              Positioned(bottom: 28, left: 18, child: bubble(Icons.check_circle_outline, 76, filled: true)),
              Positioned(child: bubble(Icons.person_outline_rounded, 108)),
            ] else ...[
              Positioned(top: 14, left: 18, child: bubble(Icons.emoji_people_outlined, 68)),
              Positioned(top: 24, right: 20, child: bubble(Icons.people_alt_outlined, 67)),
              Positioned(bottom: 20, left: 16, child: bubble(Icons.favorite_outline, 61)),
              Positioned(bottom: 29, right: 21, child: bubble(Icons.chat_bubble_outline, 70)),
              Positioned(child: bubble(Icons.person_outline, 108, filled: true)),
            ],
          ],
        )),
      )),
    );
  }
}

class _IllustrationLines extends CustomPainter {
  const _IllustrationLines(this.color, this.variant);
  final Color color;
  final int variant;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: .52)
      ..strokeWidth = 1.45
      ..style = PaintingStyle.stroke;
    final mid = Offset(size.width / 2, size.height / 2);
    for (final p in [
      Offset(size.width * .12, size.height * .21),
      Offset(size.width * .82, size.height * .17),
      Offset(size.width * .9, size.height * .8),
      Offset(size.width * .14, size.height * .83),
    ]) {
      final path = Path()
        ..moveTo(mid.dx, mid.dy)
        ..quadraticBezierTo((mid.dx + p.dx) / 2, p.dy, p.dx, p.dy);
      canvas.drawPath(path, paint);
    }
    for (final p in [
      Offset(.12 * size.width, .5 * size.height),
      Offset(.85 * size.width, .38 * size.height),
      Offset(.63 * size.width, .9 * size.height),
    ]) {
      canvas.drawCircle(p, 3.5, paint);
    }
  }
  @override
  bool shouldRepaint(covariant _IllustrationLines oldDelegate) =>
      oldDelegate.color != color || oldDelegate.variant != variant;
}
