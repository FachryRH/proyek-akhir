import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/providers/theme_provider.dart';
import 'package:restaurant_app/providers/reminder_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDark = themeProvider.themeMode == ThemeMode.dark;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: const Text('Tema Gelap'),
                  subtitle: Text(
                    isDark ? 'Aktif' : 'Tidak Aktif',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<ReminderProvider>(
                builder: (context, reminderProvider, child) {
                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Pengingat Harian Restoran'),
                          subtitle: Text(
                            reminderProvider.isReminderEnabled
                                ? 'Aktif - ${reminderProvider.getFormattedReminderTime()}'
                                : 'Tidak Aktif',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          trailing: Switch(
                            value: reminderProvider.isReminderEnabled,
                            onChanged: (value) async {
                              try {
                                await reminderProvider.toggleReminder(
                                    context, value);
                                if (value && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Pengingat restoran harian diaktifkan'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } catch (e) {
                                reminderProvider.setReminderState(!value);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Gagal mengatur pengingat: $e'),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tentang Pengaturan',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tema: Anda dapat mengubah tampilan aplikasi menjadi tema terang atau gelap. Pengaturan tema akan tersimpan dan tetap aktif setelah aplikasi ditutup.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pengingat Restoran: Jika diaktifkan, Anda akan menerima notifikasi setiap hari pukul 11:00 WIB yang menampilkan rekomendasi restoran secara acak dari API. Pengingat ini akan tetap aktif bahkan setelah perangkat di-restart.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
