import 'dart:math';
import 'package:flutter/material.dart';

class FlowerShowerBackground extends StatefulWidget {
  final Widget child;
  final int flowerCount;

  const FlowerShowerBackground({
    super.key,
    required this.child,
    this.flowerCount = 40, // पाकळ्यांची संख्या हवी तशी बदलू शकता
  });

  @override
  State<FlowerShowerBackground> createState() => _FlowerShowerBackgroundState();
}

class _FlowerShowerBackgroundState extends State<FlowerShowerBackground> with SingleTickerProviderStateMixin {
  late AnimationController _flowerController;
  final List<FlowerParticle> _flowers = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _flowerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < widget.flowerCount; i++) {
        _flowers.add(FlowerParticle.random(size.width, size.height, _random));
      }
    });
  }

  @override
  void dispose() {
    _flowerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // १. पाकळ्यांचे बॅकग्राउंड ॲनिमेशन
        AnimatedBuilder(
          animation: _flowerController,
          builder: (context, child) {
            for (var flower in _flowers) {
              flower.update(size.height, size.width);
            }
            return CustomPaint(
              size: Size.infinite,
              painter: FlowerPainter(_flowers),
            );
          },
        ),
        // २. याच्या वर तुझा मूळ स्क्रीनचा कंटेंट रेंडर होईल
        widget.child,
      ],
    );
  }
}

class FlowerParticle {
  double x;
  double y;
  double size;
  double speed;
  double swing;
  double swingSpeed;
  double rotation;
  double rotationSpeed;
  Color color;

  FlowerParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.swing,
    required this.swingSpeed,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
  });

  factory FlowerParticle.random(double maxWidth, double maxHeight, Random random, {bool startAtTop = false}) {
    final colors = [
      const Color(0xFFF4B400),
      const Color(0xFFFF8F00),
      const Color(0xFFE6A100),
    ];
    return FlowerParticle(
      x: random.nextDouble() * maxWidth,
      y: startAtTop ? -20 : random.nextDouble() * maxHeight,
      size: random.nextDouble() * 5 + 7,
      speed: random.nextDouble() * 1.2 + 0.8,
      swing: random.nextDouble() * 15 + 5,
      swingSpeed: random.nextDouble() * 0.015 + 0.005,
      rotation: random.nextDouble() * pi * 2,
      rotationSpeed: (random.nextDouble() - 0.5) * 0.03,
      color: colors[random.nextInt(colors.length)].withValues(alpha: random.nextDouble() * 0.3 + 0.6),
    );
  }

  void update(double maxHeight, double maxWidth) {
    y += speed;
    x += sin(y * swingSpeed) * 0.4;
    rotation += rotationSpeed;

    if (y > maxHeight + 20) {
      y = -20;
      x = Random().nextDouble() * maxWidth;
      rotation = Random().nextDouble() * pi * 2;
    }
  }
}

class FlowerPainter extends CustomPainter {
  final List<FlowerParticle> flowers;

  FlowerPainter(this.flowers);

  @override
  void paint(Canvas canvas, Size size) {
    for (var flower in flowers) {
      final paint = Paint()
        ..color = flower.color
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(flower.x, flower.y);
      canvas.rotate(flower.rotation);

      final path = Path();
      path.moveTo(0, -flower.size);

      path.cubicTo(
        flower.size * 0.8, -flower.size * 0.8,
        flower.size * 0.9, flower.size * 0.2,
        0, flower.size,
      );

      path.cubicTo(
        -flower.size * 0.9, flower.size * 0.2,
        -flower.size * 0.8, -flower.size * 0.8,
        0, -flower.size,
      );

      path.close();
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}