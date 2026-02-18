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
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      SoundManager().pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      SoundManager().resumeMusic();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ۱. ساخت یک تم پایه
    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Peyda',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
    );

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
      
      // 🔴 روش قطعی اول: تزریق مستقیم و بی‌رحمانه فونت روی تمام لایه‌های تم با متد apply
      theme: baseTheme.copyWith(
        textTheme: baseTheme.textTheme.apply(fontFamily: 'Peyda'),
        primaryTextTheme: baseTheme.primaryTextTheme.apply(fontFamily: 'Peyda'),
        
        // اجبار فونت برای پنجره‌های پاپ‌آپ و دیالوگ‌ها
        dialogTheme: const DialogThemeData(
          titleTextStyle: TextStyle(fontFamily: 'Peyda', fontSize: 22, fontWeight: FontWeight.bold),
          contentTextStyle: TextStyle(fontFamily: 'Peyda', fontSize: 16),
        ),
        
        // اجبار فونت برای تمام مدل‌های دکمه
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(textStyle: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold)),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(textStyle: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(textStyle: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold)),
        ),
        snackBarTheme: const SnackBarThemeData(
          contentTextStyle: TextStyle(fontFamily: 'Peyda', fontSize: 14),
        ),
      ),

      // 🔴 روش قطعی دوم (Nuclear Option): پیچیدن کل اپلیکیشن در یک استایل پیش‌فرض
      // اگر ویجتی از تم فرار کند، در این تله گیر می‌افتد!
      builder: (context, child) {
        return DefaultTextStyle(
          style: const TextStyle(fontFamily: 'Peyda'),
          child: child!,
        );
      },
      
      home: const SetupPage(),
    );
  }
}
