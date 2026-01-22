import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SOSSliderButton extends StatefulWidget {
  final Future<void> Function() onSlideComplete;
  final String text;
  final Color baseColor;
  final Color highlightColor;

  const SOSSliderButton({
    super.key,
    required this.onSlideComplete,
    this.text = 'Slide to SOS',
    this.baseColor = const Color(0xFFFF4B4B), // Vibrant Red
    this.highlightColor = Colors.white,
  });

  @override
  State<SOSSliderButton> createState() => _SOSSliderButtonState();
}

class _SOSSliderButtonState extends State<SOSSliderButton>
    with SingleTickerProviderStateMixin {
  double _dragValue = 0.0;
  bool _isCompleted = false;
  late AnimationController _shimmerController;

  final double _height = 64.0;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (_isCompleted) return;

    final effectiveMaxDrag = maxWidth - _height;

    setState(() {
      _dragValue = (_dragValue + details.delta.dx).clamp(0.0, effectiveMaxDrag);
    });

    if (_dragValue >= effectiveMaxDrag * 0.95) {
      _dragValue = effectiveMaxDrag;
      _completeSlide();
    }
  }

  void _onDragEnd(DragEndDetails details, double maxWidth) {
    if (_isCompleted) return;

    final maxDrag = maxWidth - _height;
    if (_dragValue < maxDrag * 0.95) {
      setState(() {
        _dragValue = 0.0;
      });
    }
  }

  Future<void> _completeSlide() async {
    if (_isCompleted) return;
    setState(() {
      _isCompleted = true;
    });

    await widget.onSlideComplete();

    if (mounted) {
      setState(() {
        _isCompleted = false;
        _dragValue = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;

      return Container(
        height: _height,
        width: maxWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_height / 2),
          gradient: LinearGradient(
            colors: [
              widget.baseColor.withValues(alpha: 0.1),
              widget.baseColor.withValues(alpha: 0.05),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: widget.baseColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.baseColor.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              width: _dragValue + _height,
              height: _height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_height / 2),
                color: widget.baseColor.withValues(alpha: 0.1),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: [
                          widget.baseColor,
                          widget.baseColor.withValues(alpha: 0.5),
                          widget.baseColor,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin:
                            Alignment(-1.0 + (_shimmerController.value * 2), 0),
                        end: Alignment(0.0 + (_shimmerController.value * 2), 0),
                      ).createShader(bounds);
                    },
                    child: Text(
                      widget.text.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: widget.baseColor,
                      ),
                    ),
                  );
                },
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 50),
              curve: Curves.easeOut,
              left: _dragValue,
              child: GestureDetector(
                onHorizontalDragUpdate: (details) =>
                    _onDragUpdate(details, maxWidth),
                onHorizontalDragEnd: (details) => _onDragEnd(details, maxWidth),
                child: Container(
                  height: _height,
                  width: _height,
                  decoration: BoxDecoration(
                    color: widget.baseColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: _isCompleted
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
