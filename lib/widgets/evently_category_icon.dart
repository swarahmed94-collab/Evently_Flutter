import 'package:flutter/material.dart';

import '../models/event_category.dart';

class EventlyCategoryIcon extends StatelessWidget {
  const EventlyCategoryIcon({super.key, this.category, required this.color, this.size = 22});

  final EventCategory? category;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _CategoryGlyphPainter(category, color),
  );
}

class _CategoryGlyphPainter extends CustomPainter {
  const _CategoryGlyphPainter(this.category, this.color);
  final EventCategory? category;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final Paint fill = Paint()..color = color;
    switch (category) {
      case null:
        for (final Offset p in <Offset>[
          const Offset(3, 3), const Offset(13, 3),
          const Offset(3, 13), const Offset(13, 13),
        ]) {
          canvas.drawRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(p.dx, p.dy, 8, 8), const Radius.circular(1.6)), fill);
        }
        break;
      case EventCategory.sport:
        canvas.drawCircle(const Offset(5, 18), 4, stroke);
        canvas.drawCircle(const Offset(20, 18), 4, stroke);
        canvas.drawPath(Path()
          ..moveTo(5, 18)..lineTo(9, 9)..lineTo(15, 18)..close()
          ..moveTo(9, 9)..lineTo(17, 9)..lineTo(20, 18)
          ..moveTo(15, 18)..lineTo(18, 9), stroke);
        canvas.drawLine(const Offset(7.5, 7), const Offset(10.8, 7), stroke);
        canvas.drawLine(const Offset(17, 7), const Offset(21, 7), stroke);
        break;
      case EventCategory.birthday:
        canvas.drawPath(Path()
          ..moveTo(3, 11)..lineTo(21, 11)
          ..lineTo(19, 20)..lineTo(5, 20)..close(), stroke);
        canvas.drawPath(Path()
          ..moveTo(3, 11)..quadraticBezierTo(5, 15, 8, 12)
          ..quadraticBezierTo(11, 15, 14, 12)
          ..quadraticBezierTo(18, 15, 21, 11), stroke);
        for (final double x in <double>[7, 12, 17]) {
          canvas.drawLine(Offset(x, 7), Offset(x, 10), stroke);
          canvas.drawOval(Rect.fromCenter(center: Offset(x, 4.8), width: 1.8, height: 3), stroke);
        }
        break;
      case EventCategory.bookClub:
        canvas.drawPath(Path()
          ..moveTo(12, 6)..quadraticBezierTo(8, 3, 2, 5)
          ..lineTo(2, 19)..quadraticBezierTo(8, 17, 12, 21)
          ..quadraticBezierTo(16, 17, 22, 19)
          ..lineTo(22, 5)..quadraticBezierTo(16, 3, 12, 6)
          ..lineTo(12, 21), stroke);
        canvas.drawLine(const Offset(5, 9), const Offset(9, 10), stroke);
        canvas.drawLine(const Offset(15, 10), const Offset(19, 9), stroke);
        break;
      case EventCategory.meeting:
        canvas.drawCircle(const Offset(12, 6), 3, stroke);
        canvas.drawCircle(const Offset(4.5, 10), 2.3, stroke);
        canvas.drawCircle(const Offset(19.5, 10), 2.3, stroke);
        canvas.drawPath(Path()
          ..moveTo(6, 20)..lineTo(7, 16)..quadraticBezierTo(12, 11, 17, 16)
          ..lineTo(18, 20)..close(), stroke);
        canvas.drawPath(Path()
          ..moveTo(4, 14)..quadraticBezierTo(.5, 14, 1, 19)
          ..moveTo(20, 14)..quadraticBezierTo(23.5, 14, 23, 19), stroke);
        break;
      case EventCategory.exhibition:
        canvas.drawRRect(RRect.fromRectAndRadius(
          const Rect.fromLTWH(3, 3, 18, 18), const Radius.circular(2)), stroke);
        canvas.drawCircle(const Offset(16.5, 8), 2, stroke);
        canvas.drawPath(Path()..moveTo(5, 18)..lineTo(10, 12)
          ..lineTo(13, 15)..lineTo(16, 12)..lineTo(20, 18), stroke);
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CategoryGlyphPainter old) =>
      old.category != category || old.color != color;
}
