import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _AuthBackgroundPainter(
                  color: Theme.of(context).colorScheme.primary,
                  desktop: constraints.maxWidth >= 700,
                ),
              ),
            ),
            child,
          ],
        );
      },
    );
  }
}

class _AuthBackgroundPainter extends CustomPainter {
  const _AuthBackgroundPainter({required this.color, required this.desktop});

  final Color color;
  final bool desktop;

  @override
  void paint(Canvas canvas, Size size) {
    if (desktop) {
      final paint = Paint()
        ..shader =
            RadialGradient(
              colors: [color.withValues(alpha: 0.08), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.12, size.height * 0.88),
                radius: size.shortestSide * 0.34,
              ),
            );
      canvas.drawRect(Offset.zero & size, paint);

      final secondPaint = Paint()
        ..shader =
            RadialGradient(
              colors: [color.withValues(alpha: 0.045), Colors.transparent],
            ).createShader(
              Rect.fromCircle(
                center: Offset(size.width * 0.88, size.height * 0.12),
                radius: size.shortestSide * 0.3,
              ),
            );
      canvas.drawRect(Offset.zero & size, secondPaint);
      return;
    }

    final dotPaint = Paint()..color = color.withValues(alpha: 0.075);
    const spacing = 20.0;
    for (var y = 10.0; y < size.height; y += spacing) {
      for (var x = 10.0; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AuthBackgroundPainter oldDelegate) {
    return color != oldDelegate.color || desktop != oldDelegate.desktop;
  }
}
