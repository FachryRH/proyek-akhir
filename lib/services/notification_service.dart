import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:restaurant_app/services/api_service.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static const String _channelId = 'daily_reminder';
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    if (!kIsWeb) {
      final String timeZoneName = await _getLocalTimeZone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    }

    const androidInitialize =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidInitialize,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future<String> _getLocalTimeZone() async {
    try {
      if (Platform.isAndroid) {
        const platform = MethodChannel('com.example.restaurant_app/timezone');
        final String timezone = await platform
            .invokeMethod('getTimeZone')
            .catchError((_) => 'Asia/Jakarta');
        return timezone;
      }
      return 'Asia/Jakarta';
    } catch (e) {
      debugPrint('Error getting timezone: $e');
      return 'Asia/Jakarta';
    }
  }

  Future<bool> _requestExactAlarmPermission(BuildContext context) async {
    final platform =
        _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (platform == null) return false;

    try {
      bool canSchedule =
          await platform.canScheduleExactNotifications() ?? false;
      if (!canSchedule) {
        if (!context.mounted) return false;
        final shouldOpenSettings = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Izin Diperlukan'),
                content: const Text(
                    'Untuk mengaktifkan pengingat, ikuti langkah berikut:\n\n'
                    '1. Tekan tombol "Buka Pengaturan"\n'
                    '2. Pilih "Izin Tambahan"\n'
                    '3. Aktifkan "Jadwalkan alarm yang tepat"\n'
                    '4. Kembali ke aplikasi'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Nanti Saja'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Buka Pengaturan'),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldOpenSettings) {
          await platform.requestExactAlarmsPermission();

          const methodChannel =
              MethodChannel('com.example.restaurant_app/settings');
          try {
            await methodChannel.invokeMethod('openAlarmSettings');
          } catch (e) {
            debugPrint('Failed to open settings: $e');
          }

          await Future.delayed(const Duration(milliseconds: 500));
          canSchedule = await platform.canScheduleExactNotifications() ?? false;
        }
      }
      return canSchedule;
    } catch (e) {
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

  Future<void> scheduleDailyNotification(
      BuildContext context, bool isEnabled) async {
    if (!isEnabled) {
      await cancelDailyNotification();
      return;
    }

    final hasPermission = await _requestExactAlarmPermission(context);
    if (!hasPermission) {
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
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

    try {
      final apiService = ApiService();
      final restaurants = await apiService.getRestaurants();
      final random = Random();
      final randomRestaurant = restaurants[random.nextInt(restaurants.length)];

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
    } catch (e) {
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
    }
  }

  Future<void> cancelDailyNotification() async {
    await _flutterLocalNotificationsPlugin.cancel(1);
  }
}
