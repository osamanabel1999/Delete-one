// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

Future checkWeeklyDiscordSheet(BuildContext context) async {
  const String discordInviteUrl = 'https://discord.com/invite/3jJkuQeKaz';
  const String lastShownKey = 'weekly_discord_sheet_last_shown_ms';
  const int intervalDays = 7;

  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? lastShownMs = prefs.getInt(lastShownKey);
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final int intervalMs = const Duration(days: intervalDays).inMilliseconds;

    // لو لسه معداش 7 أيام من آخر مرة ظهرت فيها، اخرج فوراً
    if (lastShownMs != null && (nowMs - lastShownMs) < intervalMs) {
      return;
    }

    // انتظار بسيط عشان لو فيه إشعار تحديث من GitHub يظهر هو الأول وميحصلش تداخل
    await Future.delayed(const Duration(milliseconds: 1500));

    // تأكد إن الصفحة لسه مفتوحة ومفيش BottomSheet تاني مفتوح فوقها حالياً
    if (!context.mounted) return;
    if (ModalRoute.of(context)?.isCurrent != true) return;

    // تسجيل التوقيت لحظة الظهور عشان متظهرش تاني غير بعد 7 أيام
    await prefs.setInt(lastShownKey, nowMs);

    _showWeeklyDiscordSheet(context, discordInviteUrl);
  } catch (e) {
    debugPrint('Weekly Discord Sheet Error: $e');
  }
}

void _showWeeklyDiscordSheet(BuildContext context, String discordUrl) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF101923),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      side: BorderSide(color: Color(0xFF26364D), width: 1.5),
    ),
    builder: (context) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // شريط السحب العلوي
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF26364D),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // أيقونة الديسكورد بنفس هوية وألوان التطبيق
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0x1F639DF0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0x4D639DF0),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.discord,
                  color: Color(0xFF639DF0),
                  size: 30,
                ),
              ),
              const SizedBox(height: 20),

              // العنوان
              const Text(
                'Join Our Official Discord',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),

              // النص
              const Text(
                'Have a question, need help, or want to suggest features for future updates? Join our official Discord server and reach us directly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF8B949E),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // زرار فتح لينك الديسكورد فوراً
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF639DF0),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    final Uri url = Uri.parse(discordUrl);
                    try {
                      final bool launched = await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                      if (!launched) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.platformDefault,
                        );
                      }
                    } catch (e) {
                      debugPrint('Discord Launch Error: $e');
                    }
                  },
                  icon: const Icon(Icons.discord, size: 22),
                  label: const Text(
                    'Join Official Discord',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // زرار الإغلاق
              SizedBox(
                width: double.infinity,
                height: 46,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Not Now',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B949E),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
