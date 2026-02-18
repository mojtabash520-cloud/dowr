import 'package:shared_preferences/shared_preferences.dart';

class MonetizationManager {
  static const String _prefPremium = 'is_premium_user';
  static const String _prefUnlockPrefix = 'unlock_time_';

  static const List<String> freeCategories = ['objects', 'food', 'sports'];

  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefPremium) ?? false;
  }

  static Future<void> setPremiumUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefPremium, true);
  }

  static Future<bool> isCategoryUnlocked(String categoryId) async {
    if (freeCategories.contains(categoryId)) return true;

    final prefs = await SharedPreferences.getInstance();
    bool isPrem = prefs.getBool(_prefPremium) ?? false;
    if (isPrem) return true;

    int unlockTimestamp = prefs.getInt('$_prefUnlockPrefix$categoryId') ?? 0;
    int now = DateTime.now().millisecondsSinceEpoch;
    
    // ✅ ۱ ساعت = ۳,۶۰۰,۰۰۰ میلی‌ثانیه
    if (now - unlockTimestamp < 3600000) {
      return true;
    }
    return false;
  }

  static Future<void> unlockCategoryTemporarily(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_prefUnlockPrefix$categoryId', DateTime.now().millisecondsSinceEpoch);
  }
}
