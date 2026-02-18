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
    return MaterialApp(
      title: 'DOWR', // نام داخلی برنامه
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
        
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Peyda'),
          displayMedium: TextStyle(fontFamily: 'Peyda'),
          displaySmall: TextStyle(fontFamily: 'Peyda'),
          headlineLarge: TextStyle(fontFamily: 'Peyda'),
          headlineMedium: TextStyle(fontFamily: 'Peyda'),
          headlineSmall: TextStyle(fontFamily: 'Peyda'),
          titleLarge: TextStyle(fontFamily: 'Peyda'),
          titleMedium: TextStyle(fontFamily: 'Peyda'),
          titleSmall: TextStyle(fontFamily: 'Peyda'),
          bodyLarge: TextStyle(fontFamily: 'Peyda'),
          bodyMedium: TextStyle(fontFamily: 'Peyda'),
          bodySmall: TextStyle(fontFamily: 'Peyda'),
          labelLarge: TextStyle(fontFamily: 'Peyda'),
          labelMedium: TextStyle(fontFamily: 'Peyda'),
          labelSmall: TextStyle(fontFamily: 'Peyda'),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            textStyle: const TextStyle(fontFamily: 'Peyda', fontWeight: FontWeight.bold),
          ),
        ),

        // ✅ خطای بیلد گیت‌هاب در این خط برطرف شد
        dialogTheme: const DialogThemeData(
          titleTextStyle: TextStyle(fontFamily: 'Hasti', fontSize: 22, fontWeight: FontWeight.bold),
          contentTextStyle: TextStyle(fontFamily: 'Peyda', fontSize: 16),
        ),

        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C63FF)),
      ),
      home: const SetupPage(),
    );
  }
}
