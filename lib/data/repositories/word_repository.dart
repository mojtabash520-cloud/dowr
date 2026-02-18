import 'dart:convert';
import 'package:flutter/services.dart'; // برای rootBundle
import '../../domain/entities/category.dart';

class WordRepository {
  // متد برای خواندن دسته‌بندی‌ها از فایل JSON
  Future<List<WordCategory>> getCategories() async {
    try {
      // 1. خواندن فایل متنی
      final String response = await rootBundle.loadString(
        'assets/data/words.json',
      );

      // 2. تبدیل متن به فرمت JSON
      final List<dynamic> data = json.decode(response);

      // 3. تبدیل JSON به لیست اشیاء WordCategory
      return data.map((json) => WordCategory.fromJson(json)).toList();
    } catch (e) {
      // اگر خطایی رخ داد (مثلاً فایل نبود یا فرمت غلط بود)
      print("Error loading categories: $e");
      return []; // لیست خالی برگردان
    }
  }
}
