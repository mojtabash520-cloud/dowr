import 'package:flutter/material.dart';

// ۱. پس‌زمینه کارتونی (ساده و تمیز با دایره‌های محو)
class FantasyBackground extends StatelessWidget {
  final Widget child;
  const FantasyBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF3F5F9), // رنگ زمینه روشن
      ),
      child: Stack(
        children: [
          // دایره‌های تزئینی پس‌زمینه
          Positioned(
            top: -50,
            right: -50,
            child: _buildCircle(200, const Color(0xFF6C63FF).withOpacity(0.1)),
          ),
          Positioned(
            bottom: 100,
            left: -30,
            child: _buildCircle(150, const Color(0xFFFF6584).withOpacity(0.1)),
          ),
          Positioned(
            top: 200,
            left: 50,
            child: _buildCircle(80, const Color(0xFFFFC045).withOpacity(0.15)),
          ),
          // محتوای اصلی صفحه
          child,
        ],
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ۲. دکمه کارتونی ۳ بعدی (Toon Button)
class ToonButton extends StatefulWidget {
  final String title;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;
  final bool isLarge;

  const ToonButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.color = const Color(0xFF6C63FF),
    this.icon,
    this.isLarge = false,
  });

  @override
  State<ToonButton> createState() => _ToonButtonState();
}

class _ToonButtonState extends State<ToonButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: widget.isLarge ? 80 : 60,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        margin: EdgeInsets.only(
            top: _isPressed ? 6 : 0,
            bottom: _isPressed ? 0 : 6), // افکت فرورفتن
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isPressed
              ? [] // وقتی فشرده شد سایه ندارد
              : [
                  BoxShadow(
                    color:
                        widget.color.withOpacity(0.5), // سایه تیره‌تر برای عمق
                    offset: const Offset(0, 6),
                    blurRadius: 0, // سایه تیز و کارتونی
                  )
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon,
                  color: Colors.white, size: widget.isLarge ? 32 : 24),
              const SizedBox(width: 10),
            ],
            Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: widget.isLarge ? 24 : 18,
                fontFamily: 'Vazirmatn',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ۳. کارت سفید با حاشیه نرم
class GameCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GameCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: child,
    );
  }
}
