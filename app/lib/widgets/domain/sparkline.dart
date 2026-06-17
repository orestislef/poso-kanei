import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// A tiny price-history chart: a gradient-filled area, a stroked line that
/// draws on left→right on mount, and an optional dot popping in at the lowest
/// point once the line finishes.
class Sparkline extends StatefulWidget {
  final List<double> data;
  final double width;
  final double height;
  final double padding;
  final bool showLow;

  const Sparkline({
    super.key,
    required this.data,
    this.width = 140,
    this.height = 44,
    this.padding = 4,
    this.showLow = true,
  });

  @override
  State<Sparkline> createState() => _SparklineState();
}

class _SparklineState extends State<Sparkline> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: PkDur.spark);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
      _controller.value = 1.0;
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;

    if (widget.data.length < 2) {
      return SizedBox(width: widget.width, height: widget.height);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _SparklinePainter(
            data: widget.data,
            padding: widget.padding,
            showLow: widget.showLow,
            progress: _controller.value,
            line: pk.primary,
            dot: pk.save,
          ),
        );
      },
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final double padding;
  final bool showLow;
  final double progress;
  final Color line;
  final Color dot;

  _SparklinePainter({
    required this.data,
    required this.padding,
    required this.showLow,
    required this.progress,
    required this.line,
    required this.dot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = data.length;
    if (n < 2) return;

    double min = data.first;
    double max = data.first;
    int lowIndex = 0;
    for (var i = 0; i < n; i++) {
      if (data[i] < min) {
        min = data[i];
        lowIndex = i;
      }
      if (data[i] > max) max = data[i];
    }
    final range = (max - min) == 0 ? 1.0 : (max - min);

    final innerW = size.width - 2 * padding;
    final innerH = size.height - 2 * padding;

    double xAt(int i) => padding + i / (n - 1) * innerW;
    double yAt(double v) => padding + (1 - (v - min) / range) * innerH;

    final points = <Offset>[
      for (var i = 0; i < n; i++) Offset(xAt(i), yAt(data[i])),
    ];

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < n; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height - padding)
      ..lineTo(points.first.dx, size.height - padding)
      ..close();

    // Clip the canvas to a left→right growing rect for the draw-on animation.
    final lineProgress = progress.clamp(0.0, 1.0);
    final revealWidth = padding + innerW * lineProgress;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, revealWidth, size.height));

    final areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          line.withValues(alpha: 0.18),
          line.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(areaPath, areaPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = line
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    canvas.restore();

    // Low-point dot pops in after the line finishes drawing.
    if (showLow) {
      const dotStart = 0.85;
      final dotT = progress <= dotStart
          ? 0.0
          : ((progress - dotStart) / (1 - dotStart)).clamp(0.0, 1.0);
      if (dotT > 0) {
        // Spring-ish overshoot ease.
        final eased = PkCurve.spring.transform(dotT);
        final center = points[lowIndex];
        final dotPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = dot.withValues(alpha: dotT.clamp(0.0, 1.0));
        canvas.drawCircle(center, 3.2 * eased, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.progress != progress ||
      old.data != data ||
      old.line != line ||
      old.dot != dot ||
      old.showLow != showLow ||
      old.padding != padding;
}
