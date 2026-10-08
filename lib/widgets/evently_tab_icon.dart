import 'package:flutter/material.dart';

enum EventlyTabGlyph { home, favorite, profile }

class EventlyTabIcon extends StatelessWidget {
  const EventlyTabIcon({super.key, required this.glyph, this.filled = false, this.size = 24});

  final EventlyTabGlyph glyph;
  final bool filled;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _EventlyTabPainter(
        glyph: glyph,
        filled: filled,
        color: IconTheme.of(context).color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _EventlyTabPainter extends CustomPainter {
  const _EventlyTabPainter({required this.glyph, required this.filled, required this.color});
  final EventlyTabGlyph glyph;
  final bool filled;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final Paint line = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final Paint paint = Paint()..color = color;
    switch (glyph) {
      case EventlyTabGlyph.home:
        final Path home = Path()
          ..moveTo(2.8, 10.5)
          ..lineTo(11, 3.7)
          ..quadraticBezierTo(12, 2.8, 13, 3.7)
          ..lineTo(21.2, 10.5)
          ..lineTo(21.2, 19.3)
          ..quadraticBezierTo(21.2, 21, 19.3, 21)
          ..lineTo(4.7, 21)
          ..quadraticBezierTo(2.8, 21, 2.8, 19.3)
          ..close();
        if (filled) {
          canvas.drawPath(home, paint);
          canvas.drawRRect(RRect.fromRectAndRadius(
            const Rect.fromLTWH(10, 13, 4, 8), const Radius.circular(1)),
            Paint()..color = Colors.white);
        } else {
          canvas.drawPath(home, line);
          canvas.drawLine(const Offset(12, 21), const Offset(12, 14), line);
        }
        break;
      case EventlyTabGlyph.favorite:
        final Path heart = Path()
          ..moveTo(12, 21)
          ..cubicTo(10, 19.1, 2, 13.7, 2, 8)
          ..cubicTo(2, 2.8, 8, 1.8, 12, 6.4)
          ..cubicTo(16, 1.8, 22, 2.8, 22, 8)
          ..cubicTo(22, 13.7, 14, 19.1, 12, 21)
          ..close();
        canvas.drawPath(heart, filled ? paint : line);
        break;
      case EventlyTabGlyph.profile:
        canvas.drawCircle(const Offset(12, 7.5), 4.2, filled ? paint : line);
        final Path shoulders = Path()
          ..moveTo(3.5, 21)
          ..cubicTo(3.5, 15.5, 8, 13.9, 12, 13.9)
          ..cubicTo(16, 13.9, 20.5, 15.5, 20.5, 21);
        canvas.drawPath(shoulders, line);
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _EventlyTabPainter old) =>
      old.glyph != glyph || old.filled != filled || old.color != color;
}
