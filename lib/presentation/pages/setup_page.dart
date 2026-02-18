import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/game_settings.dart';
import 'category_page.dart';
import 'feedback_page.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/tutorial_dialog.dart';

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  GameMode _selectedMode = GameMode.survival;
  int _teamCount = 2;
  int _survivalTime = 180;
  int _turnDuration = 60;
  int _roundsCount = 3;
  late List<TextEditingController> _nameControllers;

  final List<Map<String, dynamic>> _defaultTeams = [
    {'name': 'تیم آبی', 'color': Colors.blueAccent},
    {'name': 'تیم قرمز', 'color': Colors.redAccent},
    {'name': 'تیم سبز', 'color': Colors.green},
    {'name': 'تیم زرد', 'color': Colors.orangeAccent},
    {'name': 'تیم بنفش', 'color': Colors.purpleAccent},
    {'name': 'تیم فیروزه‌ای', 'color': Colors.tealAccent},
  ];

  @override
  void initState() {
    super.initState();
    _updateControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkTutorial());
  }

  Future<void> _checkTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    bool seen = prefs.getBool('seen_tutorial') ?? false;
    if (!seen && mounted) {
      _showTutorial();
    }
  }

  void _showTutorial() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => TutorialDialog(onClose: () => Navigator.pop(context)));
  }

  void _updateControllers() {
    _nameControllers = List.generate(_teamCount, (index) {
      String defaultName = index < _defaultTeams.length
          ? _defaultTeams[index]['name']
          : 'تیم ${index + 1}';
      return TextEditingController(text: defaultName);
    });
  }

  void _changeTeamCount(int change) {
    setState(() {
      int newCount = _teamCount + change;
      if (newCount >= 2 && newCount <= 6) {
        _teamCount = newCount;
        List<String> currentNames =
            _nameControllers.map((c) => c.text).toList();
        _nameControllers = List.generate(_teamCount, (index) {
          if (index < currentNames.length)
            return TextEditingController(text: currentNames[index]);
          String defaultName = index < _defaultTeams.length
              ? _defaultTeams[index]['name']
              : 'تیم ${index + 1}';
          return TextEditingController(text: defaultName);
        });
      }
    });
  }

  TextStyle get _numberStyle => const TextStyle(
      fontFamily: 'Peyda', fontWeight: FontWeight.bold, fontSize: 24);
  TextStyle get _labelStyle => const TextStyle(
      fontFamily: 'Hasti',
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Colors.grey);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FantasyBackground(
        child: SafeArea(
          child: Column(
            children: [
              // هدر
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const FeedbackPage()));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 5)
                            ]),
                        child: const Icon(Icons.mail_outline_rounded,
                            color: Color(0xFF6C63FF)),
                      ),
                    ),
                    const Text("تنظیمات نبرد",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Hasti')),
                    GestureDetector(
                      onTap: _showTutorial,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 5)
                            ]),
                        child: const Icon(Icons.question_mark_rounded,
                            color: Color(0xFF6C63FF)),
                      ),
                    ),
                  ],
                ),
              ),

              // انتخاب نوع بازی
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                        child: _modeSelector(
                            "بقا", Icons.timer_off_rounded, GameMode.survival)),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _modeSelector(
                            "امتیازی", Icons.star_rounded, GameMode.rounds)),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // تعداد تیم‌ها (اصلاح شده)
                    GameCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("تعداد تیم‌ها:",
                              style:
                                  _labelStyle.copyWith(color: Colors.black87)),

                          // ✅ کنترلر تعداد تیم (بهبود یافته)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // دکمه افزودن (راست - سبز)
                                _roundBtn(Icons.add, const Color(0xFF00C853),
                                    () => _changeTeamCount(1)),

                                // عدد وسط
                                SizedBox(
                                    width: 50,
                                    child: Center(
                                        child: Text("$_teamCount",
                                            style: _numberStyle))),

                                // دکمه کاهش (چپ - قرمز)
                                _roundBtn(Icons.remove, const Color(0xFFFF6584),
                                    () => _changeTeamCount(-1)),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // لیست اسامی
                    ...List.generate(_teamCount, (index) {
                      Color teamColor = index < _defaultTeams.length
                          ? _defaultTeams[index]['color']
                          : Colors.grey;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextField(
                          controller: _nameControllers[index],
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.circle, color: teamColor),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12)),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontFamily: 'Peyda'),
                        ),
                      );
                    }),
                    const SizedBox(height: 30),

                    if (_selectedMode == GameMode.rounds) ...[
                      Text("زمان هر نوبت (ثانیه)", style: _labelStyle),
                      const SizedBox(height: 10),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [45, 60, 90]
                              .map((sec) => _optionChip(
                                  "$sec",
                                  _turnDuration == sec,
                                  () => setState(() => _turnDuration = sec)))
                              .toList()),
                      const SizedBox(height: 20),
                      Text("تعداد دور (راند)", style: _labelStyle),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [1, 3, 5, 7]
                                  .map((r) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: _optionChip(
                                          "$r",
                                          _roundsCount == r,
                                          () => setState(
                                              () => _roundsCount = r))))
                                  .toList())),
                    ] else ...[
                      Text("بانک زمانی هر تیم (دقیقه)", style: _labelStyle),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [1, 2, 3, 4, 5]
                              .map((min) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: _optionChip(
                                        "$min",
                                        _survivalTime == min * 60,
                                        () => setState(
                                            () => _survivalTime = min * 60)),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ToonButton(
                    title: "ادامه",
                    icon: Icons.arrow_back_ios_new_rounded,
                    color: const Color(0xFF6C63FF),
                    isLarge: true,
                    onPressed: () {
                      List<String> finalNames = _nameControllers
                          .map((c) => c.text.trim().isEmpty ? "تیم ؟" : c.text)
                          .toList();
                      final settings = GameSettings(
                          mode: _selectedMode,
                          numberOfTeams: _teamCount,
                          turnDuration: _turnDuration,
                          timePerTeam: _survivalTime,
                          roundsCount: _roundsCount,
                          teamNames: finalNames);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  CategoryPage(settings: settings)));
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeSelector(String title, IconData icon, GameMode mode) {
    bool isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
                width: 2)),
        child: Column(children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.grey, size: 28),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Hasti'))
        ]),
      ),
    );
  }

  Widget _optionChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFFFC045) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected ? Colors.orange : Colors.grey.shade300,
                width: 2),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4))
                  ]
                : []),
        child: Text(label,
            style: _numberStyle.copyWith(
                color: isSelected ? Colors.white : Colors.black54,
                fontSize: 20)),
      ),
    );
  }

  // ✅ متد اصلاح شده با قابلیت دریافت رنگ
  Widget _roundBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10), // کمی بزرگتر برای لمس راحت‌تر
        decoration: BoxDecoration(
            color: color, // رنگ متغیر
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ]),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
