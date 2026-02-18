import 'package:flutter/material.dart';
import '../../domain/entities/game_settings.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/word.dart';
import '../../data/data_loader.dart';
import '../../core/utils/monetization_manager.dart';
import '../../core/utils/ad_manager.dart';
import 'game_page.dart';
import '../widgets/animated_widgets.dart';

class CategoryPage extends StatefulWidget {
  final GameSettings settings;
  const CategoryPage({super.key, required this.settings});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late Future<List<Category>> _categoriesFuture;
  final Set<String> _selectedCategoryIds = {};
  List<Category> _allLoadedCategories = [];

  @override
  void initState() {
    super.initState();
    _categoriesFuture = DataLoader.loadCategories().then((value) {
      _allLoadedCategories = value;
      return value;
    });
    // نمایش بنر پایین صفحه
    AdManager.showBannerAd();
  }

  @override
  void dispose() {
    // از بین بردن بنر وقتی میره تو بازی
    AdManager.destroyBannerAd();
    super.dispose();
  }

  void _handleCategoryTap(Category category, bool isSelected) async {
    bool isUnlocked = await MonetizationManager.isCategoryUnlocked(category.id);

    if (isUnlocked) {
      setState(() {
        isSelected
            ? _selectedCategoryIds.remove(category.id)
            : _selectedCategoryIds.add(category.id);
      });
    } else {
      _showUnlockDialog(category);
    }
  }

  void _showUnlockDialog(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("قفل ${category.name}",
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Hasti')),
        content: const Text(
          "این دسته قفل است.\n\n"
          "۱. خرید نسخه کامل (۴۹ هزار تومان) و باز شدن همیشگی همه دسته‌ها\n\n"
          "۲. دیدن ۲ تبلیغ کوتاه برای باز شدن ۳ ساعته این دسته",
          textAlign: TextAlign.center,
          style: TextStyle(fontFamily: 'Peyda'),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.pop(context);
                _purchaseFullVersion();
              },
              child: const Text("خرید نسخه کامل",
                  style: TextStyle(color: Colors.white, fontFamily: 'Peyda')),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.amber[800]),
              onPressed: () {
                Navigator.pop(context);
                _showAdScenario(category.id);
              },
              child: const Text("دیدن تبلیغ (باز شدن موقت)",
                  style: TextStyle(color: Colors.white, fontFamily: 'Peyda')),
            ),
          ),
        ],
      ),
    );
  }

  void _purchaseFullVersion() async {
    // شبیه‌سازی خرید بازار
    await MonetizationManager.setPremiumUser();
    setState(() {});
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("نسخه کامل فعال شد! 🎉")));
  }

  void _showAdScenario(String categoryId) async {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("در حال آماده‌سازی تبلیغ اول...")));
    bool watchedFirst = await AdManager.showRewardedVideo();

    if (!watchedFirst) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("خطا در بارگذاری تبلیغ!")));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("در حال آماده‌سازی تبلیغ دوم...")));
    await Future.delayed(const Duration(seconds: 1));
    bool watchedSecond = await AdManager.showRewardedVideo();

    if (watchedSecond) {
      await MonetizationManager.unlockCategoryTemporarily(categoryId);
      setState(() {
        _selectedCategoryIds.add(categoryId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("دسته برای ۳ ساعت باز شد! 🔓")));
    }
  }

  void _startGame() {
    if (_selectedCategoryIds.isEmpty) return;
    List<String> combinedWords = [];
    for (var cat in _allLoadedCategories) {
      if (_selectedCategoryIds.contains(cat.id))
        combinedWords.addAll(cat.words);
    }
    combinedWords.shuffle();
    List<Word> gameWords =
        combinedWords.map((w) => Word(text: w, forbidden: [])).toList();

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                GamePage(gameWords: gameWords, settings: widget.settings)));
  }

  Map<String, dynamic> _getCategoryStyle(String id) {
    switch (id) {
      case 'objects':
        return {'icon': Icons.lightbulb_outline, 'color': Colors.amber};
      case 'places':
        return {'icon': Icons.map_outlined, 'color': Colors.blue};
      case 'animals':
        return {'icon': Icons.pets, 'color': Colors.green};
      case 'personality':
        return {'icon': Icons.psychology, 'color': Colors.purple};
      case 'food':
        return {'icon': Icons.fastfood, 'color': Colors.orange};
      case 'tech':
        return {'icon': Icons.computer, 'color': Colors.cyan};
      case 'sports':
        return {'icon': Icons.sports_soccer, 'color': Colors.redAccent};
      case 'proverbs':
        return {'icon': Icons.format_quote, 'color': Colors.brown};
      case 'celebrities':
        return {'icon': Icons.star_border, 'color': Colors.pinkAccent};
      case 'movies_series':
        return {'icon': Icons.movie_creation_outlined, 'color': Colors.indigo};
      case 'football_world':
        return {'icon': Icons.sports, 'color': Colors.teal};
      default:
        return {'icon': Icons.category, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FantasyBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black12, blurRadius: 5)
                                ]),
                            child: const Icon(Icons.arrow_forward_ios_rounded,
                                size: 20))),
                    const Expanded(
                        child: Text("انتخاب موضوع",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Hasti'))),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Category>>(
                  future: _categoriesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const Center(child: CircularProgressIndicator());
                    final categories = snapshot.data!;

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          16, 0, 16, 100), // فاصله زیاد برای بنر و دکمه
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.2),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected =
                            _selectedCategoryIds.contains(category.id);
                        final style = _getCategoryStyle(category.id);

                        return FutureBuilder<bool>(
                          future: MonetizationManager.isCategoryUnlocked(
                              category.id),
                          builder: (context, lockSnapshot) {
                            bool isUnlocked = lockSnapshot.data ?? false;
                            return GestureDetector(
                              onTap: () =>
                                  _handleCategoryTap(category, isSelected),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? style['color'].withOpacity(0.15)
                                      : (isUnlocked
                                          ? Colors.white
                                          : Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                      color: isSelected
                                          ? style['color']
                                          : (isUnlocked
                                              ? Colors.grey.shade200
                                              : Colors.grey),
                                      width: isSelected ? 3 : 2),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                          Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? style['color']
                                                      : (isUnlocked
                                                          ? style['color']
                                                              .withOpacity(0.1)
                                                          : Colors
                                                              .grey.shade300),
                                                  shape: BoxShape.circle),
                                              child: Icon(style['icon'],
                                                  size: 36,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : (isUnlocked
                                                          ? style['color']
                                                          : Colors.grey))),
                                          const SizedBox(height: 10),
                                          Text(category.name,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  fontFamily: 'Hasti',
                                                  color: isUnlocked
                                                      ? Colors.black
                                                      : Colors.grey),
                                              textAlign: TextAlign.center),
                                        ])),
                                    if (!isUnlocked)
                                      Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Icon(Icons.lock,
                                              color: Colors.grey.shade500)),
                                    if (isSelected)
                                      Positioned(
                                          top: 10,
                                          right: 10,
                                          child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: const BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle),
                                              child: const Icon(Icons.check,
                                                  size: 16,
                                                  color: Colors.white))),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _selectedCategoryIds.isNotEmpty
          ? Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 0, 20, 60), // بالاتر از بنر
              child: SizedBox(
                width: double.infinity,
                child: ToonButton(
                    title: "شروع بازی",
                    icon: Icons.play_arrow_rounded,
                    color: const Color(0xFF6C63FF),
                    isLarge: true,
                    onPressed: _startGame),
              ),
            )
          : null,
    );
  }
}
