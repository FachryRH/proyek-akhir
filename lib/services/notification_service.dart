import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:restaurant_app/services/api_service.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const String _channelId = 'daily_reminder';
  static const String _reminderKey = 'daily_reminder';
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();

  Future<void> init() async {
    tz.initializeTimeZones();

    if (!kIsWeb) {
      try {
        final String timeZoneName = await _getLocalTimeZone();
        debugPrint('Device timezone: $timeZoneName');
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        debugPrint('Error setting timezone: $e');
        tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
      }
    }

    const androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidInitialize,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _checkAndRescheduleNotifications();
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    debugPrint('Notifikasi diklik: ${notificationResponse.payload}');
  }

  Future<void> _checkAndRescheduleNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isReminderEnabled = prefs.getBool(_reminderKey) ?? false;

      if (isReminderEnabled) {
        await _scheduleRandomRestaurantNotification(null);
      }
    } catch (e) {
      debugPrint('Error saat memeriksa penjadwalan notifikasi: $e');
    }
  }

  Future<String> _getLocalTimeZone() async {
    if (Platform.isAndroid) {
      try {
        const platform = MethodChannel('com.example.restaurant_app/timezone');
        final String timezone = await platform.invokeMethod('getTimeZone');
        return timezone;
      } catch (e) {
        debugPrint('Error getting device timezone: $e');
        return _getDefaultTimezone();
      }
    }
    return _getDefaultTimezone();
  }

  String _getDefaultTimezone() {
    final offset = DateTime.now().timeZoneOffset.inMinutes;

    if (offset == 420) {
      return 'Asia/Jakarta';
    } else if (offset == 480) {
      return 'Asia/Makassar';
    } else if (offset == 540) {
      return 'Asia/Jayapura';
    }

    return 'Asia/Jakarta';
  }

  Future<bool> _requestExactAlarmPermission(BuildContext? context) async {
    if (context == null) return true;

    final platform =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (platform == null) return false;

    try {
      bool canSchedule =
          await platform.canScheduleExactNotifications() ?? false;
      if (!canSchedule) {
        if (context.mounted) {
          final shouldOpenSettings = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Izin Diperlukan'),
                  content: const Text(
                      'Untuk mengaktifkan pengingat, ikuti langkah berikut:\n\n'
                      '1. Tekan tombol "Buka Pengaturan"\n'
                      '2. Pilih "Izin Tambahan"\n'
                      '3. Aktifkan "Jadwalkan alarm yang tepat"\n'
                      '4. Kembali ke aplikasi'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Nanti Saja'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text('Buka Pengaturan'),
                    ),
                  ],
                ),
              ) ??
              false;

          if (shouldOpenSettings && context.mounted) {
            await platform.requestExactAlarmsPermission();

            const methodChannel =
                MethodChannel('com.example.restaurant_app/settings');
            try {
              await methodChannel.invokeMethod('openAlarmSettings');
            } catch (e) {
              debugPrint('Failed to open settings: $e');
            }

            await Future.delayed(const Duration(milliseconds: 500));
            canSchedule =
                await platform.canScheduleExactNotifications() ?? false;
          }
        } else {
          return false;
        }
      }
      return canSchedule;
    } catch (e) {
      debugPrint('Error requesting permission: $e');
      return false;
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Daily Reminder',
      channelDescription: 'Restaurant daily reminder notification',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      1,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> _scheduleRandomRestaurantNotification(
      BuildContext? context) async {
    final now = tz.TZDateTime.now(tz.local);
    debugPrint('Current local time: $now');

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      11,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    debugPrint('Scheduled notification time: $scheduledDate');

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Daily Reminder',
      channelDescription: 'Restaurant daily reminder notification',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    try {
      final restaurants = await _apiService.getRestaurants();

      if (restaurants.isNotEmpty) {
        final random = Random();
        final randomRestaurant =
            restaurants[random.nextInt(restaurants.length)];

        await _flutterLocalNotificationsPlugin.zonedSchedule(
          1,
          'Rekomendasi Restoran Hari Ini!',
          '${randomRestaurant.name} di ${randomRestaurant.city} - Rating: ${randomRestaurant.rating}',
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );

        debugPrint(
            'Notifikasi restoran acak dijadwalkan: ${randomRestaurant.name} pada $scheduledDate');
      } else {
        await _scheduleFallbackNotification(scheduledDate, notificationDetails);
      }
    } catch (e) {
      debugPrint('Error saat mengambil data restoran: $e');
      await _scheduleFallbackNotification(scheduledDate, notificationDetails);
    }
  }

  Future<void> _scheduleFallbackNotification(tz.TZDateTime scheduledDate,
      NotificationDetails notificationDetails) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Waktunya Makan Siang!',
      'Yuk cek rekomendasi restoran untuk makan siang kamu hari ini.',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('Notifikasi fallback dijadwalkan');
  }

  Future<void> scheduleDailyNotification(
      BuildContext? context, bool isEnabled) async {
    if (!isEnabled) {
      await cancelDailyNotification();
      return;
    }

    if (context != null && context.mounted) {
      final hasPermission = await _requestExactAlarmPermission(context);
      if (!hasPermission) {
        throw Exception('Izin penjadwalan notifikasi tidak diberikan');
      }
    }

    await _scheduleRandomRestaurantNotification(null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderKey, true);
  }

  Future<void> cancelDailyNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(1);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_reminderKey, false);

    debugPrint('Notifikasi harian dibatalkan');
  }
}
