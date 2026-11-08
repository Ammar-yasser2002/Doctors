import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/models.dart';
import 'package:flutter_application_1/providers/app_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/screens/doctor_details_screen.dart';
import 'package:flutter_application_1/screens/notifications_screen.dart';
import 'package:flutter_application_1/screens/video_call_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final upcomingAppointments = provider.appointments
              .where(
                (a) => a.status == 'قادم' || a.status == 'بانتظار تأكيد الطبيب',
              )
              .toList();
          final historyAppointments = provider.appointments
              .where((a) => a.status != 'قادم')
              .toList();

          return Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 40, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 48),
                    const Text(
                      'حجوزاتي',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Tabs
              Container(
                color: Colors.white,
                child: TabBar(
                  indicatorColor: const Color(0xFF1565C0),
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorWeight: 4,
                  labelColor: const Color(0xFF1565C0),
                  unselectedLabelColor: Colors.grey.shade400,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                  tabs: const [
                    Tab(text: 'القادمة'),
                    Tab(text: 'السابقة'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAppointmentList(upcomingAppointments, provider, true),
                    _buildAppointmentList(historyAppointments, provider, false),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentList(
    List<Appointment> list,
    AppProvider provider,
    bool isUpcoming,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.event_busy_rounded : Icons.history_rounded,
              size: 80,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'لا توجد حجوزات قادمة' : 'لا توجد حجوزات سابقة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final appointment = list[index];
        return AppointmentCard(
          appointment: appointment,
          isUpcoming: isUpcoming,
          onCancel: () {
            provider.cancelAppointment(appointment.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'تم إلغاء الحجز بنجاح',
                  textAlign: TextAlign.right,
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          },
          onReschedule: () {
            // Find the doctor for this appointment to reschedule
            final doctor = provider.doctors.firstWhere(
              (d) => d.name == appointment.doctorName,
              orElse: () => provider.doctors.first,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorDetailsScreen(doctor: doctor),
              ),
            );
          },
        );
      },
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isUpcoming;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.isUpcoming,
    required this.onCancel,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Text(
                '#${appointment.bookingId}',
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(appointment.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appointment.status,
                  style: TextStyle(
                    color: _statusColor(appointment.status),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  appointment.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: Colors.grey.shade100,
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      appointment.doctorName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A2E),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      appointment.specialty,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoTile(
                Icons.calendar_month_outlined,
                appointment.date,
                'التاريخ',
              ),
              _buildInfoTile(
                Icons.access_time_rounded,
                appointment.time,
                'الوقت',
              ),
              if (appointment.appointmentType != null) ...[
                _buildInfoTile(
                  (appointment.appointmentType!.contains('Online') || appointment.appointmentType!.contains('أونلاين'))
                      ? Icons.videocam_rounded
                      : Icons.home_work_rounded,
                  appointment.appointmentType!,
                  'النوع',
                ),
              ],
            ],
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 20),
            if ((appointment.appointmentType?.toLowerCase().contains('online') ?? false) ||
                (appointment.appointmentType?.contains('أونلاين') ?? false)) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallScreen(
                          callPartnerName: appointment.doctorName,
                          callPartnerImage: appointment.imageUrl,
                          isDoctorSide: false,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.videocam_rounded, color: Colors.white),
                  label: const Text(
                    'ابدأ مكالمة الفيديو (أونلاين)',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.red.shade100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Text(
                      'إلغاء الموعد',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Cairo',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReschedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'تعديل الموعد',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Cairo',
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String value, String label) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: Color(0xFF1A1A2E),
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1565C0), size: 16),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    if (status == 'قادم') return const Color(0xFF1565C0);
    if (status == 'بانتظار تأكيد الطبيب') return const Color(0xFFF57C00);
    return Colors.grey.shade500;
  }
}
