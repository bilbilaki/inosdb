import 'package:flutter/material.dart';
import 'package:particles_fly/particles_fly.dart';

class DynamicBackground extends StatelessWidget {
  final Widget child;
  final ParticlesTheme theme;
  
  const DynamicBackground({
    super.key,
    required this.child,
    this.theme = ParticlesTheme.blue,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    // Get theme configuration
    final config = _getThemeConfig(theme, size);
    
    return Stack(
      fit: StackFit.expand,
      children: [
        // Particles background
        ParticlesFly(
          height: size.height,
          width: size.width,
          numberOfParticles: config.numberOfParticles,
          speedOfParticles: config.speedOfParticles,
          particleColor: config.particleColor,
          isRandomColor: config.isRandomColor,
          randColorList: config.randColorList,
          maxParticleSize: config.maxParticleSize,
          isRandSize: config.isRandSize,
          onTapAnimation: config.onTapAnimation,
          enableHover: config.enableHover,
          hoverColor: config.hoverColor,
          hoverRadius: config.hoverRadius,
          connectDots: config.connectDots,
          lineColor: config.lineColor,
          lineStrokeWidth: config.lineStrokeWidth,
          awayRadius: config.awayRadius,
          awayAnimationDuration: config.awayAnimationDuration,
          awayAnimationCurve: config.awayAnimationCurve,
        ),
        
        // Content
        child,
      ],
    );
  }

  // Get configuration based on the selected theme
  ParticlesConfig _getThemeConfig(ParticlesTheme theme, Size size) {
    switch (theme) {
      case ParticlesTheme.blue:
        return ParticlesConfig(
          numberOfParticles: 100,
          speedOfParticles: 1.5,
          particleColor: Colors.blueAccent,
          isRandomColor: true,
          randColorList: const [
            Colors.blue,
            Colors.lightBlue,
            Colors.blueAccent,
            Colors.lightBlueAccent,
            Colors.indigoAccent,
          ],
          maxParticleSize: 4,
          isRandSize: true,
          onTapAnimation: true,
          enableHover: true,
          hoverColor: Colors.blueAccent.shade200,
          connectDots: true,
          lineColor: Colors.blue.withOpacity(0.2),
        );
        
      case ParticlesTheme.dark:
        return ParticlesConfig(
          numberOfParticles: 200,
          speedOfParticles: 0.75,
          particleColor: Colors.purpleAccent,
          isRandomColor: true,
          randColorList: const [
            Colors.white,
            Colors.grey,
            Colors.blueGrey,
          ],
          maxParticleSize: 3,
          isRandSize: true,
          onTapAnimation: true,
          enableHover: true,
          hoverColor: Colors.white,
          connectDots: true,
          lineColor: Colors.white.withOpacity(0.1),
        );
        
      case ParticlesTheme.colorful:
        return ParticlesConfig(
          numberOfParticles: 120,
          speedOfParticles: 2.0,
          isRandomColor: true,
          randColorList: const [
            Colors.red,
            Colors.green,
            Colors.blue,
            Colors.yellow,
            Colors.orange,
            Colors.purple,
          ],
          maxParticleSize: 5,
          isRandSize: true,
          onTapAnimation: true,
          enableHover: true,
          hoverColor: Colors.pinkAccent,
          connectDots: true,
          lineColor: Colors.white.withOpacity(0.15),
        );
        
      case ParticlesTheme.purple:
        return ParticlesConfig(
          numberOfParticles: 90,
          speedOfParticles: 1.7,
          particleColor: Colors.purpleAccent,
          isRandomColor: true,
          randColorList: const [
            Colors.purple,
            Colors.purpleAccent,
            Colors.deepPurple,
            Colors.deepPurpleAccent,
            Colors.pinkAccent,
          ],
          maxParticleSize: 4,
          isRandSize: true,
          onTapAnimation: true,
          enableHover: true,
          hoverColor: Colors.pinkAccent,
          connectDots: true,
          lineColor: Colors.purple.withOpacity(0.2),
        );
        
      case ParticlesTheme.custom:
        // Default values, to be overridden by developer
        return ParticlesConfig(
          numberOfParticles: 100,
          speedOfParticles: 2.0,
          particleColor: Colors.white,
          isRandomColor: false,
        );
    }
  }
}

// Available themes
enum ParticlesTheme {
  blue,
  dark,
  colorful,
  purple,
  custom,
}

// Configuration class for particles
class ParticlesConfig {
  final double numberOfParticles;
  final double speedOfParticles;
  final Color particleColor;
  final bool isRandomColor;
  final List<Color> randColorList;
  final double maxParticleSize;
  final bool isRandSize;
  final bool onTapAnimation;
  final bool enableHover;
  final Color hoverColor;
  final double hoverRadius;
  final bool connectDots;
  final Color lineColor;
  final double lineStrokeWidth;
  final double awayRadius;
  final Duration awayAnimationDuration;
  final Curve awayAnimationCurve;

  ParticlesConfig({
    this.numberOfParticles = 100,
    this.speedOfParticles = 2.0,
    this.particleColor = Colors.purple,
    this.isRandomColor = false,
    this.randColorList = const [Colors.orange, Colors.blue, Colors.teal, Colors.red, Colors.purple],
    this.maxParticleSize = 4.0,
    this.isRandSize = false,
    this.onTapAnimation = true,
    this.enableHover = false,
    this.hoverColor = Colors.orangeAccent,
    this.hoverRadius = 80.0,
    this.connectDots = false,
    this.lineColor = const Color.fromARGB(90, 155, 39, 176),
    this.lineStrokeWidth = 0.5,
    this.awayRadius = 200.0,
    this.awayAnimationDuration = const Duration(milliseconds: 100),
    this.awayAnimationCurve = Curves.easeIn,
  });
}

// Custom configuration builder for flexible customization
class DynamicBackgroundBuilder {
  static DynamicBackground custom({
    required Widget child,
    double? numberOfParticles,
    double? speedOfParticles,
    Color? particleColor,
    bool? isRandomColor,
    List<Color>? randColorList,
    double? maxParticleSize,
    bool? isRandSize,
    bool? onTapAnimation,
    bool? enableHover,
    Color? hoverColor,
    double? hoverRadius,
    bool? connectDots,
    Color? lineColor,
    double? lineStrokeWidth,
    double? awayRadius,
    Duration? awayAnimationDuration,
    Curve? awayAnimationCurve,
  }) {
    // Create a base config with the default values for custom theme
    final baseConfig = ParticlesConfig();
    
    // Build a new stack with the custom ParticlesFly
    return DynamicBackground(
      theme: ParticlesTheme.custom,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Builder(
              builder: (context) {
                final size = MediaQuery.of(context).size;
                return ParticlesFly(
                  height: size.height,
                  width: size.width,
                  numberOfParticles: numberOfParticles ?? baseConfig.numberOfParticles,
                  speedOfParticles: speedOfParticles ?? baseConfig.speedOfParticles,
                  particleColor: particleColor ?? baseConfig.particleColor,
                  isRandomColor: isRandomColor ?? baseConfig.isRandomColor,
                  randColorList: randColorList ?? baseConfig.randColorList,
                  maxParticleSize: maxParticleSize ?? baseConfig.maxParticleSize,
                  isRandSize: isRandSize ?? baseConfig.isRandSize,
                  onTapAnimation: onTapAnimation ?? baseConfig.onTapAnimation,
                  enableHover: enableHover ?? baseConfig.enableHover,
                  hoverColor: hoverColor ?? baseConfig.hoverColor,
                  hoverRadius: hoverRadius ?? baseConfig.hoverRadius,
                  connectDots: connectDots ?? baseConfig.connectDots,
                  lineColor: lineColor ?? baseConfig.lineColor,
                  lineStrokeWidth: lineStrokeWidth ?? baseConfig.lineStrokeWidth,
                  awayRadius: awayRadius ?? baseConfig.awayRadius,
                  awayAnimationDuration: awayAnimationDuration ?? baseConfig.awayAnimationDuration,
                  awayAnimationCurve: awayAnimationCurve ?? baseConfig.awayAnimationCurve,
                );
              },
            ),
          ),
          child,
        ],
      ),
    );
  }
}