import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../auth/login_page.dart' show LoginPage;
import 'painters/grid_painter.dart';
import 'painters/particles_painter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _backgroundController;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  Timer? _navigationTimer;

  static const _particles = <ParticleSpec>[
    ParticleSpec(
      xFactor: 0.08,
      yFactor: 0.20,
      radius: 1.8,
      speed: 1.0,
      drift: 0.1,
    ),
    ParticleSpec(
      xFactor: 0.12,
      yFactor: 0.70,
      radius: 1.5,
      speed: 1.1,
      drift: 0.3,
    ),
    ParticleSpec(
      xFactor: 0.18,
      yFactor: 0.45,
      radius: 1.7,
      speed: 1.2,
      drift: 0.5,
    ),
    ParticleSpec(
      xFactor: 0.24,
      yFactor: 0.15,
      radius: 1.4,
      speed: 1.3,
      drift: 0.8,
    ),
    ParticleSpec(
      xFactor: 0.28,
      yFactor: 0.82,
      radius: 1.9,
      speed: 1.0,
      drift: 1.1,
    ),
    ParticleSpec(
      xFactor: 0.35,
      yFactor: 0.35,
      radius: 1.6,
      speed: 1.4,
      drift: 1.3,
    ),
    ParticleSpec(
      xFactor: 0.42,
      yFactor: 0.62,
      radius: 1.8,
      speed: 1.1,
      drift: 1.6,
    ),
    ParticleSpec(
      xFactor: 0.48,
      yFactor: 0.25,
      radius: 1.5,
      speed: 1.0,
      drift: 1.9,
    ),
    ParticleSpec(
      xFactor: 0.55,
      yFactor: 0.75,
      radius: 2.0,
      speed: 1.2,
      drift: 2.2,
    ),
    ParticleSpec(
      xFactor: 0.62,
      yFactor: 0.30,
      radius: 1.4,
      speed: 1.3,
      drift: 2.5,
    ),
    ParticleSpec(
      xFactor: 0.69,
      yFactor: 0.52,
      radius: 1.7,
      speed: 1.0,
      drift: 2.9,
    ),
    ParticleSpec(
      xFactor: 0.74,
      yFactor: 0.18,
      radius: 1.6,
      speed: 1.2,
      drift: 3.1,
    ),
    ParticleSpec(
      xFactor: 0.78,
      yFactor: 0.86,
      radius: 1.5,
      speed: 1.1,
      drift: 3.4,
    ),
    ParticleSpec(
      xFactor: 0.84,
      yFactor: 0.41,
      radius: 1.9,
      speed: 1.0,
      drift: 3.8,
    ),
    ParticleSpec(
      xFactor: 0.90,
      yFactor: 0.66,
      radius: 1.6,
      speed: 1.3,
      drift: 4.1,
    ),
    ParticleSpec(
      xFactor: 0.95,
      yFactor: 0.23,
      radius: 1.4,
      speed: 1.0,
      drift: 4.4,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.05, 0.9, curve: Curves.easeOutCubic),
    );
    _logoScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    _logoController.forward();
    _backgroundController.forward();

    _navigationTimer = Timer(const Duration(milliseconds: 1600), _goNext);
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _logoController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final fade = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          final slide =
              Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          return FadeTransition(
            opacity: fade,
            child: SlideTransition(position: slide, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0B0B0B),
                  Color(0xFF0F0F10),
                  Color(0xFF121212),
                ],
              ),
            ),
          ),
          RepaintBoundary(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.70,
                child: CustomPaint(painter: const GridPainter()),
              ),
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, _) {
                return IgnorePointer(
                  child: CustomPaint(
                    painter: ParticlesPainter(
                      particles: _particles,
                      t: _backgroundController.value * 6.28318,
                    ),
                  ),
                );
              },
            ),
          ),
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, _) {
                final v = _backgroundController.value;
                if (v >= 0.72) return const SizedBox.shrink();
                final progress = Curves.easeOutCubic.transform(v / 0.72);
                final top = lerpDouble(
                  -70,
                  MediaQuery.of(context).size.height * 0.55,
                  progress,
                )!;
                final opacity = (1.0 - progress).clamp(0.0, 1.0) * 0.30;

                return Positioned(
                  top: top,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: opacity),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFFF2A2A,
                            ).withValues(alpha: 0.26),
                            blurRadius: 24,
                            spreadRadius: 1.5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo-sem-nome.png',
                        width: 132,
                        height: 132,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'SYSTEX WMS',
                      style: TextStyle(
                        color: Color(0xFFF2F4F7),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.6,
                        fontSize: 21,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Inteligência Operacional',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
