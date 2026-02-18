import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tapsell_plus/tapsell_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sound_manager.dart'; // برای کنترل موزیک

class AdManager {
  static const String _appId =
      'rlqkscbdqfrorbtemcqgfobcbhmajrqlajfamrjscdgbpsijragkgcbmhksnasbqaqgpbc';
  static const String _rewardZoneId = '698e592d8f329b41b224ebb7';
  static const String _interstitialZoneId = '698e598a8f329b41b224ebb8';
  static const String _bannerZoneId = '698e5a268f329b41b224ebb9';

  static const String _clickCountKey = 'ad_click_count';
  static String? _currentBannerId;

  static Future<void> initialize() async {
    try {
      await Future.delayed(const Duration(seconds: 2));
      await TapsellPlus.instance.initialize(_appId);
    } catch (e) {
      debugPrint("❌ Tapsell Init Failed: $e");
    }
  }

  // ✅ بنر (روش Callback - طبق آخرین تست موفق)
  static void showBannerAd() {
    try {
      TapsellPlus.instance.requestStandardBannerAd(
        _bannerZoneId,
        TapsellPlusBannerType.BANNER_320x50,
        onError: (map) => debugPrint("❌ Banner Request Error: $map"),
        onResponse: (Map<String, String> map) {
          String responseId = map['responseId'] ?? '';
          if (responseId.isNotEmpty) {
            _currentBannerId = responseId;
            TapsellPlus.instance.showStandardBannerAd(
              responseId,
              TapsellPlusHorizontalGravity.BOTTOM,
              TapsellPlusVerticalGravity.CENTER,
              margin: const EdgeInsets.only(bottom: 0),
            );
          }
        },
      );
    } catch (e) {
      debugPrint("❌ Banner General Error: $e");
    }
  }

  static void destroyBannerAd() {
    if (_currentBannerId != null) {
      TapsellPlus.instance.destroyStandardBanner(_currentBannerId!);
      _currentBannerId = null;
    }
  }

  // ✅ میان‌گره (روش Future - طبق آخرین خطاها)
  static Future<void> checkAndShowInterstitial() async {
    final prefs = await SharedPreferences.getInstance();
    int clicks = (prefs.getInt(_clickCountKey) ?? 0) + 1;

    if (clicks >= 2) {
      try {
        final responseId = await TapsellPlus.instance
            .requestInterstitialAd(_interstitialZoneId);
        if (responseId.isNotEmpty) {
          SoundManager().pauseMusic();
          TapsellPlus.instance.showInterstitialAd(responseId, onClosed: (map) {
            SoundManager().resumeMusic();
          }, onError: (map) {
            SoundManager().resumeMusic();
          });
        }
        await prefs.setInt(_clickCountKey, 0);
      } catch (e) {
        debugPrint("❌ Interstitial Error: $e");
      }
    } else {
      await prefs.setInt(_clickCountKey, clicks);
    }
  }

  // ✅ جایزه‌ای (روش Future - طبق آخرین خطاها)
  static Future<bool> showRewardedVideo() async {
    final Completer<bool> completer = Completer<bool>();
    try {
      final responseId =
          await TapsellPlus.instance.requestRewardedVideoAd(_rewardZoneId);

      if (responseId.isNotEmpty) {
        SoundManager().pauseMusic();
        TapsellPlus.instance.showRewardedVideoAd(responseId, onRewarded: (map) {
          if (!completer.isCompleted) completer.complete(true);
        }, onError: (map) {
          SoundManager().resumeMusic();
          if (!completer.isCompleted) completer.complete(false);
        }, onClosed: (map) {
          SoundManager().resumeMusic();
          if (!completer.isCompleted) completer.complete(false);
        });
      } else {
        completer.complete(false);
      }
    } catch (e) {
      if (!completer.isCompleted) completer.complete(false);
    }
    return completer.future;
  }
}
