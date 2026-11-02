import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/arcade_colors.dart';

/// Widget de fondo retro vectorial animado en loop continuo.
/// Representa montañas/cerros vectoriales en el horizonte, estrellas/partículas espaciales
/// y una carretera infinita con perspectiva pseudo-3D y partículas en movimiento hacia la cámara.
class RetroHighwayBackground extends StatefulWidget {
  const RetroHighwayBackground({super.key});

  @override
  State<RetroHighwayBackground> createState() => _RetroHighwayBackgroundState();
}

class _RetroHighwayBackgroundState extends State<RetroHighwayBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animación continua y fluida de loop infinito
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _RetroHighwayPainter(progress: _controller.value),
        );
      },
    );
  }
}

class _RetroHighwayPainter extends CustomPainter {
  final double progress; // 0.0 a 1.0 en loop continuo

  _RetroHighwayPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Cielo negro espacial profundo
    final bgPaint = Paint()..color = const Color(0xFF090A10);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final horizonY = h * 0.44;
    final centerX = w * 0.5;

    // 2. Partículas y estrellas flotantes en el cielo (con parpadeo y desplazamiento sutil)
    _drawStarsAndSkyParticles(canvas, w, horizonY);

    // 3. Sol o núcleo vectorial retro en el horizonte
    _drawRetroSun(canvas, centerX, horizonY);

    // 4. Cerros y montañas vectoriales al fondo (dos cordilleras con estilo neón wireframe)
    _drawDistantMountains(canvas, w, horizonY);
    _drawForeMountains(canvas, w, horizonY);

    // 5. Carretera infinita hacia el horizonte con perspectiva cónica
    _drawInfiniteHighway(canvas, w, h, centerX, horizonY);

    // 6. Partículas veloces flotando sobre la carretera hacia la cámara
    _drawHighwayParticles(canvas, w, h, centerX, horizonY);
  }

  void _drawStarsAndSkyParticles(Canvas canvas, double w, double horizonY) {
    final starPaint = Paint()..style = PaintingStyle.fill;

    // Constelación determinista de 45 partículas
    for (int i = 0; i < 45; i++) {
      final seedX = ((i * 73) % 1000) / 1000.0;
      final seedY = ((i * 37) % 1000) / 1000.0;
      final x = seedX * w;
      final y = seedY * (horizonY - 20);

      // Parpadeo cíclico basado en seno
      final blink =
          (math.sin((progress * 2 * math.pi) + (i * 0.8)) + 1.0) / 2.0;
      final alpha = (0.2 + blink * 0.7).clamp(0.0, 1.0);
      final size = (i % 3 == 0) ? 2.0 : 1.2;

      starPaint.color =
          (i % 2 == 0 ? ArcadeColors.neonCyan : ArcadeColors.flashWhite)
              .withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), size, starPaint);
    }
  }

  void _drawRetroSun(Canvas canvas, double centerX, double horizonY) {
    const sunRadius = 48.0;
    final sunCenter = Offset(centerX, horizonY - 10);

    // Resplandor exterior neón magenta
    final glowPaint = Paint()
      ..color = ArcadeColors.arcadeMagenta.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(sunCenter, sunRadius + 12, glowPaint);

    // Círculo base del sol en magenta/ámbar
    final sunPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [ArcadeColors.electricAmber, ArcadeColors.arcadeMagenta],
      ).createShader(Rect.fromCircle(center: sunCenter, radius: sunRadius));

    canvas.drawCircle(sunCenter, sunRadius, sunPaint);

    // Ranuras horizontales vectoriales estilo sintetizador synthwave
    final slotPaint = Paint()
      ..color = const Color(0xFF090A10)
      ..strokeWidth = 2.5;

    for (int s = 1; s <= 4; s++) {
      final y = horizonY - 10 + (s * 8.0);
      final dx = math.sqrt(
        math.max(0, math.pow(sunRadius, 2) - math.pow(y - (horizonY - 10), 2)),
      );
      canvas.drawLine(
        Offset(centerX - dx, y),
        Offset(centerX + dx, y),
        slotPaint,
      );
    }
  }

  void _drawDistantMountains(Canvas canvas, double w, double horizonY) {
    // Cordillera posterior lejana (cyan oscuro con picos angulares)
    final path = Path()..moveTo(0, horizonY);
    const count = 7;
    final step = w / count;

    final heights = [50.0, 85.0, 60.0, 95.0, 70.0, 80.0, 45.0, 65.0];

    for (int i = 0; i < count; i++) {
      final px = i * step + (step * 0.5);
      final py = horizonY - heights[i % heights.length];
      path.lineTo(px, py);
      path.lineTo((i + 1) * step, horizonY);
    }
    path.close();

    final fillPaint = Paint()
      ..color = const Color(0xFF10142A).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = ArcadeColors.neonCyan.withValues(alpha: 0.3)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawForeMountains(Canvas canvas, double w, double horizonY) {
    // Cordillera frontal cercana (magenta/púrpura wireframe)
    final path = Path()..moveTo(0, horizonY);
    const count = 5;
    final step = w / count;

    final heights = [35.0, 60.0, 40.0, 65.0, 30.0, 50.0];

    for (int i = 0; i < count; i++) {
      final px = i * step + (step * 0.45);
      final py = horizonY - heights[i % heights.length];
      path.lineTo(px, py);
      path.lineTo((i + 1) * step, horizonY);
    }
    path.close();

    final fillPaint = Paint()
      ..color = const Color(0xFF160E28).withValues(alpha: 0.95)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = ArcadeColors.arcadeMagenta.withValues(alpha: 0.55)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawInfiniteHighway(
    Canvas canvas,
    double w,
    double h,
    double centerX,
    double horizonY,
  ) {
    // Línea de horizonte divisoria
    final horizonPaint = Paint()
      ..color = ArcadeColors.neonCyan.withValues(alpha: 0.8)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(0, horizonY), Offset(w, horizonY), horizonPaint);

    // Bordes exteriores de la carretera (convergencia cónica desde la base hacia el horizonte)
    const roadTopHalfW = 18.0; // Ancho en el horizonte
    final roadBottomHalfW = w * 0.48; // Ancho casi total en la base

    final roadPath = Path()
      ..moveTo(centerX - roadTopHalfW, horizonY)
      ..lineTo(centerX + roadTopHalfW, horizonY)
      ..lineTo(centerX + roadBottomHalfW, h)
      ..lineTo(centerX - roadBottomHalfW, h)
      ..close();

    // Relleno de superficie de asfalto oscuro
    final roadFill = Paint()
      ..color = const Color(0xFF0F111E)
      ..style = PaintingStyle.fill;
    canvas.drawPath(roadPath, roadFill);

    // Bordes neón de la carretera (izquierdo en cyan, derecho en magenta)
    final leftBorderPaint = Paint()
      ..color = ArcadeColors.neonCyan
      ..strokeWidth = 3.0;
    final rightBorderPaint = Paint()
      ..color = ArcadeColors.arcadeMagenta
      ..strokeWidth = 3.0;

    canvas.drawLine(
      Offset(centerX - roadTopHalfW, horizonY),
      Offset(centerX - roadBottomHalfW, h),
      leftBorderPaint,
    );
    canvas.drawLine(
      Offset(centerX + roadTopHalfW, horizonY),
      Offset(centerX + roadBottomHalfW, h),
      rightBorderPaint,
    );

    // Líneas transversales de la carretera con perspectiva no lineal y movimiento en loop
    const totalLines = 16;
    final roadHeight = h - horizonY;

    for (int i = 0; i < totalLines; i++) {
      // Cálculo de perspectiva cuadrática para dar sensación de velocidad y profundidad
      final rawT = (i + progress) / totalLines;
      final t = rawT % 1.0;
      final perspectiveFactor = math
          .pow(t, 2.8)
          .toDouble(); // mayor espaciado abajo
      final y = horizonY + (perspectiveFactor * roadHeight);

      final halfWAtY =
          roadTopHalfW + (roadBottomHalfW - roadTopHalfW) * perspectiveFactor;

      final alpha = (perspectiveFactor * 0.85).clamp(0.08, 0.85);
      final gridLinePaint = Paint()
        ..color = ArcadeColors.neonCyan.withValues(alpha: alpha)
        ..strokeWidth = 1.0 + (perspectiveFactor * 1.5);

      canvas.drawLine(
        Offset(centerX - halfWAtY, y),
        Offset(centerX + halfWAtY, y),
        gridLinePaint,
      );
    }

    // Línea central discontinua de la carretera en amarillo/ámbar eléctrico
    for (int i = 0; i < totalLines; i++) {
      final rawT = (i + progress) / totalLines;
      final t = rawT % 1.0;
      final p1 = math.pow(t, 2.8).toDouble();
      final p2 = math.pow((t + 0.035).clamp(0.0, 1.0), 2.8).toDouble();

      final y1 = horizonY + (p1 * roadHeight);
      final y2 = horizonY + (p2 * roadHeight);

      final alpha = (p1 * 0.9).clamp(0.1, 0.9);
      final centerDashPaint = Paint()
        ..color = ArcadeColors.electricAmber.withValues(alpha: alpha)
        ..strokeWidth = 1.5 + (p1 * 3.5);

      canvas.drawLine(
        Offset(centerX, y1),
        Offset(centerX, y2),
        centerDashPaint,
      );
    }
  }

  void _drawHighwayParticles(
    Canvas canvas,
    double w,
    double h,
    double centerX,
    double horizonY,
  ) {
    final particlePaint = Paint()..style = PaintingStyle.fill;
    final roadHeight = h - horizonY;
    const particleCount = 28;

    for (int i = 0; i < particleCount; i++) {
      // Determinista con semilla i
      final laneOffset = (((i * 47) % 100) / 50.0) - 1.0; // -1.0 a +1.0
      final speedFactor = 1.0 + ((i % 5) * 0.15);
      final rawProgress = (progress * speedFactor + (i / particleCount)) % 1.0;

      // La partícula se aproxima a la cámara acelerando en perspectiva
      final p = math.pow(rawProgress, 2.5).toDouble();
      final y = horizonY + (p * roadHeight);

      // Separación proporcional al ancho de la carretera a esa altura
      final roadTopHalfW = 18.0;
      final roadBottomHalfW = w * 0.46;
      final halfWAtY = roadTopHalfW + (roadBottomHalfW - roadTopHalfW) * p;
      final x = centerX + (laneOffset * halfWAtY * 0.85);

      final alpha = (p * 0.9).clamp(0.05, 0.9);
      final particleSize = 1.5 + (p * 4.0);

      final color = (i % 3 == 0)
          ? ArcadeColors.neonGreen
          : (i % 2 == 0 ? ArcadeColors.neonCyan : ArcadeColors.flashWhite);

      particlePaint.color = color.withValues(alpha: alpha);

      // Dibuja la partícula y una pequeña estela vertical ascendente de velocidad
      canvas.drawCircle(Offset(x, y), particleSize, particlePaint);

      final trailPaint = Paint()
        ..color = color.withValues(alpha: alpha * 0.4)
        ..strokeWidth = particleSize * 0.8;
      canvas.drawLine(Offset(x, y), Offset(x, y - (p * 18.0)), trailPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RetroHighwayPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
