import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'animated_widgets.dart';

class TutorialDialog extends StatefulWidget {
  final VoidCallback onClose;
  const TutorialDialog({super.key, required this.onClose});

  @override
  State<TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<TutorialDialog> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // ✅ لیست کامل محتوا طبق متن شما
  final List<Map<String, dynamic>> _steps = [
    {
      "title": "🎯 هدف بازی",
      "image": "assets/images/guide_1.png",
      "desc":
          "• کلمه روی صفحه را فقط با توضیح گفتاری برای هم‌تیمی روبه‌روی خود توضیح دهید.\n• هر تیم باید زمان خودش را حفظ کند...\n• تیمی که زودتر زمانش تمام شود، حذف می‌شود!",
    },
    {
      "title": "🟢 چیدمان میدان نبرد",
      "image": "assets/images/guide_2.png",
      "desc":
          "• بازیکنان به شکل حلقه می‌نشینند.\n• هر دو نفرِ روبه‌رو، یک تیم هستند.\n• تعداد تیم‌ها: ۲ تا ۶ تیم.\n• تایمر اختصاصی هر تیم بالای صفحه است.",
    },
    {
      "title": "🟡 گردش گوشی و فشار",
      "image": "assets/images/guide_3.png",
      "desc":
          "• گوشی دست یکی از اعضای تیم است؟ تایمر شما کم می‌شود! ⏳\n• پاسخ درست دادید؟ تایمر متوقف می‌شود.\n• حالا سریع گوشی را به نفر بعدی بدهید!",
    },
    {
      "title": "🔴 دکمه‌های سرنوشت‌ساز",
      "image": "assets/images/guide_4.png",
      "desc":
          "✅ درست: وقتی هم‌تیمی درست حدس زد.\n⏩ تعویض: اگر کلمه سخت بود (با جریمه زمانی).\n❌ خطا: گفتن کلمه اصلی، کلمات ممنوعه یا پانتومیم (با جریمه زمانی).",
    },
    {
      "title": "💀 حالت بقا (Survival)",
      "image": "assets/images/guide_5.png",
      "desc":
          "• هر تیم یک «بانک زمانی» دارد (مثلاً ۳ دقیقه).\n• زمان فقط در نوبت تیم شما کم می‌شود.\n• زمان به صفر برسد = حذف تیم.\n• آخرین تیم زنده = قهرمان! 🏆",
    },
    {
      "title": "⭐️ حالت راندی (Rounds)",
      "image": "assets/images/guide_6.png",
      "desc":
          "• بازی در تعداد دور مشخص (۱ تا ۷) انجام می‌شود.\n• در پایان بازی:\nتیمی که بیشترین امتیاز را جمع کرده باشد، برنده نهایی است.\n• مناسب برای بازگشت به بازی!",
    },
    {
      "title": "⚔️ قوانین طلایی",
      "image": "assets/images/guide_7.png",
      "desc":
          "🚫 گفتن خود کلمه ممنوع\n🚫 مشتقات یا هم‌قافیه ممنوع\n🚫 اشاره به حروف اول ممنوع\n🚫 ترجمه به زبان دیگر ممنوع\n🚫 پانتومیم ممنوع\n✅ فقط توضیح کلامی آزاد است!",
    },
  ];

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_tutorial', true);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        // ارتفاع دینامیک ولی محدود
        constraints: const BoxConstraints(maxHeight: 650),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5)
          ],
        ),
        child: Column(
          children: [
            // فضای اصلی اسلایدر
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _steps.length,
                itemBuilder: (context, index) {
                  final step = _steps[index];
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // 🖼️ نمایش عکس ۱۶:۹
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28)),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.asset(
                              step['image'],
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(
                                color: const Color(
                                    0xFFFFFdd0), // رنگ کرمی (پیش‌فرض اگر عکس نبود)
                                child: const Center(
                                    child: Icon(Icons.image_not_supported,
                                        size: 50, color: Colors.grey)),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // عنوان
                              Text(
                                step['title'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Hasti',
                                  color: Color(0xFF6C63FF),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // توضیحات (با فونت وزیر برای خوانایی بهتر متن طولانی)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: Text(
                                  step['desc'],
                                  textAlign: TextAlign.right, // متن راست‌چین
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF2D2D2D),
                                      fontWeight: FontWeight.w600,
                                      height: 1.8, // فاصله خطوط برای خوانایی
                                      fontFamily: 'Vazirmatn'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // بخش پایین (نشانگر و دکمه‌ها)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // نشانگر صفحات (Dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_steps.length, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF6C63FF)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // دکمه‌های کنترل
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // دکمه رد کردن
                      TextButton(
                        onPressed: _completeTutorial,
                        child: const Text("رد کردن",
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),

                      // دکمه بعدی / فهمیدم
                      SizedBox(
                        width: 140,
                        child: ToonButton(
                          title: _currentPage == _steps.length - 1
                              ? "بزن بریم!"
                              : "بعدی",
                          color: _currentPage == _steps.length - 1
                              ? const Color(0xFF00C853)
                              : const Color(0xFF6C63FF),
                          onPressed: () {
                            if (_currentPage < _steps.length - 1) {
                              _controller.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut);
                            } else {
                              _completeTutorial();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
