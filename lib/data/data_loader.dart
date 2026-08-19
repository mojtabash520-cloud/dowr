import 'dart:async'; // 👈 برای استفاده از Timeout
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/category.dart';

class DataLoader {
  // 🔴 هش حذف شد تا همیشه آخرین نسخه خوانده شود
  static const String _serverUrl =
      'https://gist.githubusercontent.com/mojtabash520-cloud/2857f40003989ee5644d313746ded21a/raw/words.json';

  static const String _prefKeyData = 'cached_words_data';

  // بررسی و دانلود آپدیت جدید
  static Future<void> checkForUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 👈 اضافه شدن محدودیت زمانی (Timeout) برای جلوگیری از گیر کردن
      final response = await http
          .get(Uri.parse(_serverUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> onlineJson =
            json.decode(utf8.decode(response.bodyBytes));
        final int onlineVersion = onlineJson['version'];

        int currentVersion = 0;
        if (prefs.containsKey(_prefKeyData)) {
          final cachedData = json.decode(prefs.getString(_prefKeyData)!);
          currentVersion = cachedData['version'];
        } else {
          final String localString =
              await rootBundle.loadString('assets/data/words.json');
          final localJson = json.decode(localString);
          currentVersion = localJson['version'];
        }

        if (onlineVersion > currentVersion) {
          await prefs.setString(_prefKeyData, utf8.decode(response.bodyBytes));
          print("✅ کلمات آپدیت شدند به نسخه: $onlineVersion");
        } else {
          print("⚡ کلمات به‌روز هستند.");
        }
      }
    } catch (e) {
      print("❌ خطا در آپدیت کلمات: $e");
    }
  }

  // لود کردن دسته‌ها (اول کش، اگر نبود فایل اصلی)
  static Future<List<Category>> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> finalJson;

      if (prefs.containsKey(_prefKeyData)) {
        final String cachedString = prefs.getString(_prefKeyData)!;
        finalJson = json.decode(cachedString);
      } else {
        final String localString =
            await rootBundle.loadString('assets/data/words.json');
        finalJson = json.decode(localString);
      }

      final List<dynamic> dataList = finalJson['data'];
      return dataList.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      print("Error loading data: $e");
      return [];
    }
  }
}
