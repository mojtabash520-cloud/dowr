import 'package:flutter/material.dart';

// 🔴 دکمه‌های پایین بازی (درست، خطا، رد)
class ToonButton extends StatefulWidget {
  final String title;
  final IconData? icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isLarge;

  const ToonButton({
    super.key,
    required this.title,
    this.icon,
    required this.color,
    required this.onPressed,
    this.isLarge = false,
  });

  @override
  State<ToonButton> createState() => _ToonButtonState();
}

class _ToonButtonState extends State<ToonButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(widget.isLarge ? 20 : 16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                offset: const Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: Colors.white, size: widget.isLarge ? 28 : 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'Peyda', // ✅ میخکوب کردن تضمینی فونت پیدا
                    fontSize: widget.isLarge ? 22 : 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🔴 کارت سفید رنگ پشت کلمات
class GameCard extends StatelessWidget {
  final Widget child;
  const GameCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

// 🔴 پس‌زمینه صفحات
class FantasyBackground extends StatelessWidget {
  final Widget child;
  const FantasyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF4F6F9),
      ),
      child: child,
    );
  }
}
