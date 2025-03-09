import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:restaurant_app/services/notification_service.dart';

class ReminderProvider extends ChangeNotifier {
  static const String _reminderKey = 'daily_reminder';
  late SharedPreferences _prefs;
  bool _isReminderEnabled = false;
  final NotificationService _notificationService;

  ReminderProvider({required NotificationService notificationService})
      : _notificationService = notificationService {
    _loadReminderState();
  }

  bool get isReminderEnabled => _isReminderEnabled;

  Future<void> _loadReminderState() async {
    _prefs = await SharedPreferences.getInstance();
    _isReminderEnabled = _prefs.getBool(_reminderKey) ?? false;
    notifyListeners();
  }

  void setReminderState(bool value) {
    _isReminderEnabled = value;
    notifyListeners();
  }

  Future<void> toggleReminder(BuildContext context, bool value) async {
    try {
      await _notificationService.scheduleDailyNotification(context, value);
      _isReminderEnabled = value;
      await _prefs.setBool(_reminderKey, value);
      notifyListeners();
    } catch (e) {
      _isReminderEnabled = false;
      await _prefs.setBool(_reminderKey, false);
      notifyListeners();
      rethrow;
    }
  }
}
