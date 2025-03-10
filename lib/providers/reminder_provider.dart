import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_app/services/notification_service.dart';
import 'package:intl/intl.dart';

class ReminderProvider extends ChangeNotifier {
  static const String _reminderKey = 'daily_reminder';
  static const String _reminderTimeKey = 'reminder_time';
  late SharedPreferences _prefs;
  bool _isReminderEnabled = false;
  String _reminderTime = '11:00';
  final NotificationService _notificationService;

  ReminderProvider({required NotificationService notificationService})
      : _notificationService = notificationService {
    _loadReminderState();
  }

  bool get isReminderEnabled => _isReminderEnabled;
  String get reminderTime => _reminderTime;

  Future<void> _loadReminderState() async {
    _prefs = await SharedPreferences.getInstance();
    _isReminderEnabled = _prefs.getBool(_reminderKey) ?? false;
    _reminderTime = _prefs.getString(_reminderTimeKey) ?? '11:00';
    notifyListeners();
  }

  void setReminderState(bool value) {
    _isReminderEnabled = value;
    notifyListeners();
  }

  Future<void> setReminderTime(String time) async {
    _reminderTime = time;
    await _prefs.setString(_reminderTimeKey, time);
    notifyListeners();

    if (_isReminderEnabled) {
      await toggleReminder(null, true);
    }
  }

  Future<void> toggleReminder(BuildContext? context, bool value) async {
    try {
      if (value) {
        await _notificationService.scheduleDailyNotification(context, true);
      } else {
        await _notificationService.cancelDailyNotification();
      }

      _isReminderEnabled = value;
      await _prefs.setBool(_reminderKey, value);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saat mengaktifkan reminder: $e');
      _isReminderEnabled = false;
      await _prefs.setBool(_reminderKey, false);
      notifyListeners();
      rethrow;
    }
  }

  String getFormattedReminderTime() {
    try {
      final time = DateFormat('HH:mm').parse(_reminderTime);
      return DateFormat('hh:mm a').format(time);
    } catch (e) {
      return '11:00 AM';
    }
  }
}
