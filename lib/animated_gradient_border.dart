import 'package:flutter/material.dart';

class AnimatedGradientBorder extends StatefulWidget {
  const AnimatedGradientBorder({
    super.key,
    this.radius = 30,
    this.blurRadius = 30,
    this.spreadRadius = 1,
    this.topColor = Colors.red,
    this.bottomColor = Colors.blue,
    this.glowOpacity = 1,
    this.duration = const Duration(seconds: 2),
    this.thickness = 3,
    this.child,
  });

  // The radius of the border
  final double radius;

  // Blur radius of the glow effect
  final double blurRadius;

  // Spread radius of the glow effect
  final double spreadRadius;

  // The color of the top of the gradient
  final Color topColor;

  // The color of the bottom of the gradient
  final Color bottomColor;

  // The opacity of the glow effect
  final double glowOpacity;

  // The duration of the animation. The default is 500 milliseconds
  final Duration duration;

  // The thickness of the border
  final double thickness;
  
  // The child widget
  final Widget? child;

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  late Animation<Alignment> _tlAlignAnim;
  late Animation<Alignment> _brAlignAnim;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: widget.duration.inMilliseconds),
      vsync: this,
    );

    _tlAlignAnim = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1
      ),
    ]).animate(_controller);

    _brAlignAnim = TweenSequence<Alignment>([
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1
      ),
      TweenSequenceItem<Alignment>(
        tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            widget.child != null
                ? ClipRRect(
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.radius),
                    ),
                    child: widget.child,
                  )
                : const SizedBox.shrink(),
            ClipPath(
              clipper: _CenterCutPath(radius: widget.radius, thickness: widget.thickness),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Stack(
                    children: [
                      Opacity(
                        opacity: widget.glowOpacity,
                        child: Container(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.all(
                              Radius.circular(widget.radius),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: widget.topColor,
                                offset: const Offset(0, 0),
                                blurRadius: widget.blurRadius,
                                spreadRadius: widget.spreadRadius,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: _brAlignAnim.value,
                        child: Opacity(
                          opacity: widget.glowOpacity,
                          child: Container(
                            width: constraints.maxWidth * 0.95,
                            height: constraints.maxHeight * 0.95,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.all(
                                Radius.circular(widget.radius),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.bottomColor,
                                  offset: const Offset(0, 0),
                                  blurRadius: widget.blurRadius,
                                  spreadRadius: widget.spreadRadius,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(widget.radius)
                          ),
                          gradient: LinearGradient(
                            begin: _tlAlignAnim.value,
                            end: _brAlignAnim.value,
                            colors: [widget.topColor, widget.bottomColor],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
          ],
        );
      }
    );
  }
}

class _CenterCutPath extends CustomClipper<Path> {
  final double radius;
  final double thickness;

  _CenterCutPath({
    this.radius = 0,
    this.thickness = 1,
  });

  @override
  Path getClip(Size size) {
    final rect = Rect.fromLTRB(
      -size.width, -size.width, size.width * 2, size.height * 2
    );

    final double width = size.width - thickness * 2;
    final double height = size.height - thickness * 2;

    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(thickness, thickness, width, height),
          Radius.circular(radius - thickness),
        ),
      )
      ..addRect(rect);

    return path;
  }

  @override
  bool shouldReclip(covariant _CenterCutPath oldClipper) {
    return oldClipper.radius != radius || oldClipper.thickness != thickness;
  }
}