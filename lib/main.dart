import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/pages/setup_page.dart';
import 'core/utils/sound_manager.dart';
import 'data/data_loader.dart';
import 'core/utils/ad_manager.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DowrApp());
}

class DowrApp extends StatefulWidget {
  const DowrApp({super.key});

  @override
  State<DowrApp> createState() => _DowrAppState();
}

class _DowrAppState extends State<DowrApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SoundManager().startMusic();
    DataLoader.checkForUpdate();
    AdManager.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ✅ اضافه شدن حالت‌های جدید برای اطمینان ۱۰۰٪ از قطع موزیک در پس‌زمینه
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive || 
        state == AppLifecycleState.hidden || 
        state == AppLifecycleState.detached) {
      SoundManager().pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      SoundManager().resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DOWR',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fa', 'IR')],
      locale: const Locale('fa', 'IR'),
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Peyda',

        // 🔴 قدرت بی‌نهایت فلاتر برای القای فونت پیدا به تمام بخش‌ها
        typography: Typography.material2021(
          black: Typography.blackCupertino.apply(fontFamily: 'Peyda'),
          white: Typography.whiteCupertino.apply(fontFamily: 'Peyda'),
          englishLike: Typography.englishLike2021.apply(fontFamily: 'Peyda'),
          dense: Typography.dense2021.apply(fontFamily: 'Peyda'),
          tall: Typography.tall2021.apply(fontFamily: 'Peyda'),
        ),

        // ✅ تنظیمات دیالوگ‌ها (رنگ پس‌زمینه سفید و متن مشکی)
        dialogTheme: const DialogThemeData(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(fontFamily: 'Hasti', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          contentTextStyle: TextStyle(fontFamily: 'Peyda', fontSize: 16, color: Colors.black87),
        ),

        // ✅ زیبایی و گردی دکمه‌ها
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold, fontSize: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            elevation: 2,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
        
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
      ),
      
      // 🔴 لایه امنیتی نهایی: اگر ویجتی از تم فرار کرد، اینجا گیر می‌افتد
      builder: (context, child) {
        return DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Peyda', color: Colors.black87),
          child: child!,
        );
      },
      home: const SetupPage(),
    );
  }
}
