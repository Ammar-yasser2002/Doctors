import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/app_provider.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final unreadMessages = provider.getTotalUnreadCount();
        final pendingAppointments = provider.appointments
            .where((a) => a.status == 'بانتظار تأكيد الطبيب')
            .length;

        final items = <_NotificationItem>[
          if (pendingAppointments > 0)
            _NotificationItem(
              title: 'لديك $pendingAppointments مواعيد بانتظار تأكيد الطبيب',
              subtitle: 'تابع حالة الحجوزات من قسم مواعيدي',
              icon: Icons.calendar_month_rounded,
              color: const Color(0xFFF57C00),
            ),
          if (unreadMessages > 0)
            _NotificationItem(
              title: 'لديك $unreadMessages رسائل غير مقروءة',
              subtitle: 'يمكنك الرد مباشرة من قسم الرسائل',
              icon: Icons.mark_chat_unread_rounded,
              color: const Color(0xFF1565C0),
            ),
          _NotificationItem(
            title: 'مرحبًا بك في تطبيق الأطباء',
            subtitle: 'استكشف الأطباء، واحجز موعدك بسهولة',
            icon: Icons.favorite_rounded,
            color: const Color(0xFF26C6DA),
          ),
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: const Text(
              'الإشعارات',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            centerTitle: true,
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item.title,
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _NotificationItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
