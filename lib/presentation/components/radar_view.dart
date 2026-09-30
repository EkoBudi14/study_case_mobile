import 'package:flutter/material.dart';

import '../../common/rssi_helper.dart';

class RadarView extends StatefulWidget {
  final int rssi;
  final bool connected;

  const RadarView({super.key, required this.rssi, required this.connected});

  @override
  State<RadarView> createState() => _RadarViewState();
}

class _RadarViewState extends State<RadarView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  double? _displayProximity;
  Color _displayColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final targetProximity = widget.connected
              ? RssiHelper.proximity(widget.rssi)
              : 0.0;
          final targetColor = widget.connected
              ? RssiHelper.color(widget.rssi)
              : Colors.grey;

          _displayProximity = _displayProximity == null
              ? targetProximity
              : _displayProximity! +
                    (targetProximity - _displayProximity!) * 0.08;
          _displayColor =
              Color.lerp(_displayColor, targetColor, 0.08) ?? targetColor;

          return CustomPaint(
            painter: _RadarPainter(
              proximity: _displayProximity!,
              color: _displayColor,
              connected: widget.connected,
              pulse: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double proximity;
  final Color color;
  final bool connected;
  final double pulse;

  _RadarPainter({
    required this.proximity,
    required this.color,
    required this.connected,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 * 0.9;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.grey.withValues(alpha: 0.4);
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, maxRadius * i / 4, ringPaint);
    }

    canvas.drawLine(
      Offset(center.dx - maxRadius, center.dy),
      Offset(center.dx + maxRadius, center.dy),
      ringPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - maxRadius),
      Offset(center.dx, center.dy + maxRadius),
      ringPaint,
    );

    canvas.drawCircle(center, 6, Paint()..color = Colors.blueGrey);

    if (!connected) {
      _drawLabel(canvas, center, 'Sinyal Hilang', Colors.grey);
      return;
    }

    final distanceFromCenter = (1 - proximity) * maxRadius;
    final target = Offset(center.dx, center.dy - distanceFromCenter);

    final pulseRadius = 10 + pulse * 18;
    canvas.drawCircle(
      target,
      pulseRadius,
      Paint()..color = color.withValues(alpha: (1 - pulse) * 0.4),
    );

    canvas.drawCircle(target, 10, Paint()..color = color);
  }

  void _drawLabel(Canvas canvas, Offset center, String text, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) {
    return old.proximity != proximity ||
        old.color != color ||
        old.connected != connected ||
        old.pulse != pulse;
  }
}
