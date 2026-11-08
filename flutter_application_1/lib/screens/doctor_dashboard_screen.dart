import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/app_provider.dart';
import 'package:flutter_application_1/models/models.dart';
import 'package:flutter_application_1/screens/banners_control_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int _activeTab = 0; // 0: Confirmed/Upcoming, 1: Pending

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final doctorProfile = provider.currentDoctorProfile;
        final doctorNameQuery = provider.currentUser?.name.trim() ?? '';

        // Clean prefixes to ensure robust name matching
        String cleanName(String name) {
          return name.replaceAll(RegExp(r'^د[\.\s]+'), '').trim();
        }

        final cleanQuery = cleanName(doctorNameQuery);

        // Fallback for default or demo user roles
        final isDefaultDoctor =
            doctorNameQuery.isEmpty ||
            cleanQuery == 'مستخدم افتراضي' ||
            cleanQuery == 'زائر' ||
            cleanQuery == 'حساب جوجل' ||
            cleanQuery == 'حساب جوجل (تجريبي)';

        final bool isPendingApproval =
            provider.isDoctor && !provider.isDoctorApproved;

        final doctorAppointments = isDefaultDoctor
            ? provider.appointments
            : provider.appointments
                  .where(
                    (a) =>
                        cleanName(a.doctorName).contains(cleanQuery) ||
                        cleanQuery.contains(cleanName(a.doctorName)),
                  )
                  .toList();

        // Separate pending and upcoming appointments
        final pendingAppointments = doctorAppointments
            .where((a) => a.status == 'بانتظار تأكيد الطبيب')
            .toList();

        final upcomingAppointments = doctorAppointments
            .where((a) => a.status == 'مؤكد' || a.status == 'قادم')
            .toList();

        // Calculate dynamic weekly counts for the custom statistics chart
        final weekDays = [
          'السبت',
          'الأحد',
          'الاثنين',
          'الثلاثاء',
          'الأربعاء',
          'الخميس',
          'الجمعة',
        ];
        final counts = List<int>.filled(7, 0);

        for (var app in doctorAppointments) {
          try {
            final parsedDate = DateTime.parse(app.date);
            int idx = 0;
            switch (parsedDate.weekday) {
              case DateTime.saturday:
                idx = 0;
                break;
              case DateTime.sunday:
                idx = 1;
                break;
              case DateTime.monday:
                idx = 2;
                break;
              case DateTime.tuesday:
                idx = 3;
                break;
              case DateTime.wednesday:
                idx = 4;
                break;
              case DateTime.thursday:
                idx = 5;
                break;
              case DateTime.friday:
                idx = 6;
                break;
            }
            counts[idx]++;
          } catch (_) {
            if (app.date.contains('السبت')) {
              counts[0]++;
            } else if (app.date.contains('الأحد')) {
              counts[1]++;
            } else if (app.date.contains('الاثنين')) {
              counts[2]++;
            } else if (app.date.contains('الثلاثاء')) {
              counts[3]++;
            } else if (app.date.contains('الأربعاء')) {
              counts[4]++;
            } else if (app.date.contains('الخميس')) {
              counts[5]++;
            } else if (app.date.contains('الجمعة')) {
              counts[6]++;
            } else {
              counts[app.bookingId.hashCode % 7]++;
            }
          }
        }

        if (isPendingApproval) {
          final linkedHospital = doctorProfile?.hospitalId != null
              ? provider.getHospitalById(doctorProfile!.hospitalId!)
              : null;

          return Scaffold(
            backgroundColor: const Color(0xFFF6F8FB),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'في انتظار موافقة المستشفى',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: Color(0xFF1A1A2E),
                  fontFamily: 'Cairo',
                ),
              ),
              centerTitle: true,
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 92,
                      color: Color(0xFF1565C0),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'حسابك الطبي ينتظر موافقة المستشفى',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      linkedHospital != null
                          ? 'تم إرسال طلب الربط إلى ${linkedHospital['name']}. سيتم تفعيل الحساب بعد الموافقة.'
                          : 'يجب ربط حسابك بمستشفى موثوق قبل أن تتمكن من إدخال بيانات الطبيب.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        'العودة للرئيسية',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FB),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'لوحة تحكم الطبيب',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Color(0xFF1A1A2E),
                fontFamily: 'Cairo',
              ),
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Color(0xFF1565C0),
                  ),
                  onPressed: _showDoctorSettingsSheet,
                  tooltip: 'إعدادات الطبيب والملف المهني',
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Elegant Header Card (Doctor Profile)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E3C72).withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned(
                        right: -40,
                        top: -40,
                        child: CircleAvatar(
                          radius: 90,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      Positioned(
                        left: -20,
                        bottom: -20,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white.withValues(alpha: 0.04),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 26,
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 34,
                                backgroundImage:
                                    doctorProfile != null &&
                                        doctorProfile.imageUrl.isNotEmpty
                                    ? (doctorProfile.imageUrl.startsWith('http')
                                          ? NetworkImage(doctorProfile.imageUrl)
                                          : FileImage(
                                                  File(doctorProfile.imageUrl),
                                                )
                                                as ImageProvider)
                                    : const NetworkImage(
                                        'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=2070&auto=format&fit=crop',
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'د. ${provider.currentUser?.name ?? 'الطبيب'}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.verified,
                                        color: Color(0xFF26C6DA),
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    provider.currentUser?.email ??
                                        'doctor@example.com',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontSize: 13,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: provider.isDoctorApproved
                                          ? Colors.greenAccent.shade400
                                          : Colors.orangeAccent.shade400,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      provider.isDoctorApproved
                                          ? 'الحساب مفعل من المستشفى'
                                          : 'في انتظار موافقة المستشفى',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.18,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'لوحة تحكم الطبيب النشطة',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Metrics Statistics (Grid Layout)
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'مواعيد اليوم',
                        value: upcomingAppointments.length.toString(),
                        change: '+15%',
                        icon: Icons.calendar_month_rounded,
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'المعلقة',
                        value: pendingAppointments.length.toString(),
                        change: 'بانتظار التأكيد',
                        icon: Icons.pending_actions_rounded,
                        color: const Color(0xFFF57C00),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'إجمالي الزيارات',
                        value: doctorAppointments.length.toString(),
                        change: 'هذا الشهر',
                        icon: Icons.people_outline_rounded,
                        color: const Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'التقييم العام',
                        value: '4.9',
                        change: '120 تقييم',
                        icon: Icons.star_border_rounded,
                        color: const Color(0xFF00B0FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Custom Statistics Chart Box
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.show_chart, color: Colors.grey),
                          Row(
                            children: [
                              const Text(
                                'معدل الحجوزات الأسبوعية',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1A1A2E),
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1565C0),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 150,
                        child: CustomPaint(
                          painter: _WeeklyAppointmentsPainter(counts, weekDays),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(7, (index) {
                          return Expanded(
                            child: Center(
                              child: Text(
                                weekDays[index],
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          );
                        }).reversed.toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Quick Actions
                const Text(
                  'إجراءات سريعة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 14),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildQuickActionCard(
                        icon: Icons.calendar_today_rounded,
                        label: 'جدولة موعد',
                        color: const Color(0xFF1565C0),
                        onTap: () => _showAddAppointmentSheet(context),
                      ),
                      const SizedBox(width: 12),
                      _buildQuickActionCard(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'رسائل المرضى',
                        color: const Color(0xFF8E24AA),
                        onTap: () =>
                            provider.setTabIndex(1), // switch to messages tab
                      ),
                      const SizedBox(width: 12),
                      _buildQuickActionCard(
                        icon: Icons.insert_chart_outlined,
                        label: 'تقارير سريعة',
                        color: const Color(0xFF009688),
                        onTap: () => _showQuickReportsDialog(
                          context,
                          doctorAppointments.length,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildQuickActionCard(
                        icon: Icons.tune_rounded,
                        label: 'إدارة البنرات',
                        color: const Color(0xFFFF9800),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BannersControlScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),

                // 5. Sliding Tab Selector for Appointments
                _buildTabSelector(
                  pendingAppointments.length,
                  upcomingAppointments.length,
                ),
                const SizedBox(height: 16),

                // 6. Appointments list
                if (_activeTab == 0) ...[
                  if (upcomingAppointments.isEmpty)
                    _buildEmptyState('لا توجد مواعيد معتمدة قريباً')
                  else
                    ...upcomingAppointments.map(
                      (app) => _buildAppointmentCard(app, false),
                    ),
                ] else ...[
                  if (pendingAppointments.isEmpty)
                    _buildEmptyState('لا توجد مواعيد معلقة بانتظار التأكيد')
                  else
                    ...pendingAppointments.map(
                      (app) => _buildAppointmentCard(app, true),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade50, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.01),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector(int pendingCount, int confirmedCount) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _activeTab == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _activeTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF57C00),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          pendingCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      'المعلقة',
                      style: TextStyle(
                        color: _activeTab == 1
                            ? const Color(0xFFF57C00)
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _activeTab == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _activeTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (confirmedCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF1565C0),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          confirmedCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Text(
                      'القادمة والمؤكدة',
                      style: TextStyle(
                        color: _activeTab == 0
                            ? const Color(0xFF1565C0)
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment, bool isPending) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final canAccept = provider.doctorPermissions['قبول المواعيد'] ?? true;
    final isOnline =
        appointment.appointmentType?.toLowerCase().contains('online') ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade50, width: 1.5),
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
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isOnline
                      ? const Color(0xFF00BCD4).withValues(alpha: 0.08)
                      : const Color(0xFF673AB7).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isOnline
                          ? Icons.videocam_rounded
                          : Icons.home_work_rounded,
                      size: 14,
                      color: isOnline
                          ? const Color(0xFF00BCD4)
                          : const Color(0xFF673AB7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isOnline ? 'كشف أونلاين' : 'زيارة عيادة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isOnline
                            ? const Color(0xFF00BCD4)
                            : const Color(0xFF673AB7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      appointment.businessName, // patient name
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A1A2E),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'تخصص: ${appointment.specialty}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade100, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    appointment.imageUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.person, color: Color(0xFF1565C0)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1, color: Color(0xFFF6F8FB)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    appointment.time,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    appointment.date,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Provider.of<AppProvider>(
                        context,
                        listen: false,
                      ).cancelAppointment(appointment.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم إلغاء طلب الموعد',
                            textAlign: TextAlign.right,
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    },
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text(
                      'رفض الموعد',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (canAccept) {
                        Provider.of<AppProvider>(
                          context,
                          listen: false,
                        ).confirmAppointmentByDoctor(appointment.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'تم تأكيد الموعد بنجاح',
                              textAlign: TextAlign.right,
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'ليس لديك صلاحية قبول المواعيد',
                              textAlign: TextAlign.right,
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.check_rounded, size: 16),
                    label: const Text(
                      'تأكيد وقبول',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
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

  void _showAddAppointmentSheet(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final patientNameController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedTime = '09:00 ص';
    String selectedType = 'Online Visit';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'جدولة موعد جديد',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Cairo',
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'اسم المريض',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: patientNameController,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'أدخل اسم المريض بالكامل',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'نوع العيادة / الموعد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: selectedType,
                            dropdownColor: Colors.white,
                            items: const [
                              DropdownMenuItem(
                                value: 'Online Visit',
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'كشف أونلاين',
                                    style: TextStyle(fontFamily: 'Cairo'),
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Clinic Visit',
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'زيارة عيادة',
                                    style: TextStyle(fontFamily: 'Cairo'),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedType = val);
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'تاريخ الموعد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 30),
                                ),
                              );
                              if (picked != null) {
                                setModalState(() => selectedDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Icon(Icons.calendar_month, size: 20),
                                  Text(
                                    intl.DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(selectedDate),
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'وقت الموعد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedTime,
                  dropdownColor: Colors.white,
                  items: const [
                    DropdownMenuItem(
                      value: '09:00 ص',
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '09:00 صباحاً',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: '10:00 ص',
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '10:00 صباحاً',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: '11:00 ص',
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '11:00 صباحاً',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: '04:00 م',
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '04:00 مساءً',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: '05:00 م',
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '05:00 مساءً',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: '06:00 م',
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '06:00 مساءً',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setModalState(() => selectedTime = val);
                    }
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = patientNameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'الرجاء إدخال اسم المريض',
                              textAlign: TextAlign.right,
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      final newApp = Appointment(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: '0',
                        bookingId:
                            'BK${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                        businessName: name,
                        doctorName:
                            provider.currentUser?.name ?? 'د. سارة أحمد',
                        specialty: 'تجميل',
                        date: intl.DateFormat(
                          'yyyy-MM-dd',
                        ).format(selectedDate),
                        time: selectedTime,
                        status: 'قادم',
                        imageUrl:
                            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200',
                        price: 250,
                        appointmentType: selectedType,
                      );

                      provider.addAppointment(newApp);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تمت جدولة الموعد بنجاح!',
                            textAlign: TextAlign.right,
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'حفظ الموعد وجدولته',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showQuickReportsDialog(BuildContext context, int totalCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'التقرير السريع للأداء',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildReportRow(
              'إجمالي الأرباح المتوقعة',
              '${totalCount * 250} ر.س',
              Icons.monetization_on,
              Colors.green,
            ),
            const Divider(height: 24),
            _buildReportRow(
              'تقييم المرضى العام',
              '4.9 / 5.0',
              Icons.star,
              Colors.orange,
            ),
            const Divider(height: 24),
            _buildReportRow(
              'نسبة رضا المرضى',
              '98%',
              Icons.favorite,
              Colors.red,
            ),
            const Divider(height: 24),
            _buildReportRow(
              'معدل إكمال الجلسات',
              '96%',
              Icons.task_alt,
              Colors.blue,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'إغلاق',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1565C0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1A1A2E),
          ),
        ),
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            Icon(icon, color: color, size: 20),
          ],
        ),
      ],
    );
  }

  void _showDoctorSettingsSheet() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final doctor = provider.currentDoctorProfile;

    String? selectedHospitalId = doctor?.hospitalId;
    // Controllers
    final nameCtrl = TextEditingController(
      text: doctor?.name ?? provider.currentUser?.name ?? '',
    );
    final specialtyCtrl = TextEditingController(
      text: doctor?.specialty ?? 'عام',
    );
    final bioCtrl = TextEditingController(text: doctor?.bio ?? '');
    final experienceCtrl = TextEditingController(
      text: doctor?.experience ?? 'خبرة سنتين',
    );
    final locationCtrl = TextEditingController(
      text: doctor?.location ?? 'الرياض',
    );
    final priceCtrl = TextEditingController(
      text: doctor?.price.toString() ?? '200',
    );
    final imageUrlCtrl = TextEditingController(text: doctor?.imageUrl ?? '');
    File? selectedImage;
    if (doctor?.imageUrl.isNotEmpty == true &&
        !doctor!.imageUrl.startsWith('http')) {
      selectedImage = File(doctor.imageUrl);
    }

    // For available days
    final List<String> allDays = [
      'السبت',
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
    ];
    final List<String> selectedDays = List<String>.from(
      doctor?.availableDays ?? ['السبت', 'الاثنين', 'الأربعاء'],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DefaultTabController(
        length: 2,
        child: StatefulBuilder(
          builder: (context, setModalState) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const TabBar(
                  labelColor: Color(0xFF1565C0),
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Color(0xFF1565C0),
                  labelStyle: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: [
                    Tab(text: 'الملف المهني'),
                    Tab(text: 'الصلاحيات والإعدادات'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab 1: Edit profile
                      SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 24,
                          right: 24,
                          top: 20,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildField('الاسم الكامل', nameCtrl),
                            const SizedBox(height: 12),
                            _buildField('التخصص', specialtyCtrl),
                            const SizedBox(height: 12),
                            _buildField(
                              'الخبرة (مثال: 5 سنوات خبرة)',
                              experienceCtrl,
                            ),
                            const SizedBox(height: 12),
                            _buildField(
                              'موقع العيادة (مثال: الرياض، حي الياسمين)',
                              locationCtrl,
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: selectedHospitalId,
                              decoration: InputDecoration(
                                labelText: 'اختر المستشفى لطلب الموافقة',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items: provider.hospitals
                                  .map(
                                    (hospital) => DropdownMenuItem(
                                      value: hospital['id'],
                                      child: Text(hospital['name'] ?? ''),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                setModalState(() {
                                  selectedHospitalId = value;
                                });
                              },
                              hint: const Text('اختر مستشفى'),
                            ),
                            const SizedBox(height: 12),
                            _buildField(
                              'سعر الكشف (ر.س)',
                              priceCtrl,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 12),
                            _buildField(
                              'رابط الصورة الشخصية أو اختر صورة',
                              imageUrlCtrl,
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 80,
                                  );
                                  if (pickedFile != null) {
                                    setModalState(() {
                                      selectedImage = File(pickedFile.path);
                                      imageUrlCtrl.text = '';
                                    });
                                  }
                                },
                                icon: const Icon(
                                  Icons.photo_library_outlined,
                                  size: 18,
                                ),
                                label: const Text(
                                  'اختيار صورة من المعرض',
                                  style: TextStyle(fontFamily: 'Cairo'),
                                ),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.blue.shade50,
                                  foregroundColor: const Color(0xFF1565C0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                ),
                              ),
                            ),
                            if (selectedImage != null) ...[
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    selectedImage!,
                                    width: 92,
                                    height: 92,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            const Text(
                              'أيام العمل المتاحة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Directionality(
                              textDirection: TextDirection.rtl,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: allDays.map((day) {
                                  final isSelected = selectedDays.contains(day);
                                  return FilterChip(
                                    label: Text(
                                      day,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                      ),
                                    ),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setModalState(() {
                                        if (selected) {
                                          selectedDays.add(day);
                                        } else {
                                          selectedDays.remove(day);
                                        }
                                      });
                                    },
                                    selectedColor: const Color(0xFF1565C0),
                                    checkmarkColor: Colors.white,
                                    backgroundColor: Colors.grey.shade100,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(
                                        color: isSelected
                                            ? Colors.transparent
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildField(
                              'نبذة مهنية (Bio)',
                              bioCtrl,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () {
                                  final double price =
                                      double.tryParse(priceCtrl.text) ?? 200.0;
                                  final updatedDoctor = Doctor(
                                    id:
                                        doctor?.id ??
                                        provider.currentUser?.id ??
                                        'default_doc',
                                    name: nameCtrl.text.trim(),
                                    specialty: specialtyCtrl.text.trim(),
                                    imageUrl:
                                        selectedImage?.path ??
                                        (imageUrlCtrl.text.trim().isNotEmpty
                                            ? imageUrlCtrl.text.trim()
                                            : (doctor?.imageUrl ??
                                                  'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=2070&auto=format&fit=crop')),
                                    rating: doctor?.rating ?? 5.0,
                                    reviewCount: doctor?.reviewCount ?? 120,
                                    location: locationCtrl.text.trim(),
                                    experience: experienceCtrl.text.trim(),
                                    price: price,
                                    availableDays: selectedDays.isEmpty
                                        ? ['الأحد']
                                        : selectedDays,
                                    bio: bioCtrl.text.trim(),
                                    hospitalId: selectedHospitalId,
                                  );

                                  provider.updateDoctorProfile(updatedDoctor);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'تم تحديث ملفك المهني بنجاح',
                                        textAlign: TextAlign.right,
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1565C0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'حفظ التغييرات المهنية',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tab 2: Permissions
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'صلاحيات وتفعيل الميزات',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'يمكنك تفعيل أو تعطيل صلاحيات الطبيب حسب حاجة العمل.',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.separated(
                                itemCount: provider.doctorPermissions.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final entry = provider
                                      .doctorPermissions
                                      .entries
                                      .elementAt(index);
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: SwitchListTile(
                                      title: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      value: entry.value,
                                      onChanged: (value) {
                                        setModalState(() {
                                          provider.setDoctorPermission(
                                            entry.key,
                                            value,
                                          );
                                        });
                                      },
                                      activeThumbColor: const Color(0xFF1565C0),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1565C0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'تم وحفظ الإعدادات',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          textAlign: TextAlign.right,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.black38,
              fontSize: 12,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1565C0)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Painter for drawing the weekly bar chart elegantly
class _WeeklyAppointmentsPainter extends CustomPainter {
  final List<int> dailyCounts;
  final List<String> daysOfWeek;

  _WeeklyAppointmentsPainter(this.dailyCounts, this.daysOfWeek);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final double width = size.width;
    final double height = size.height;

    final int maxCount = dailyCounts.reduce((a, b) => a > b ? a : b);
    final double maxVal = maxCount == 0 ? 5.0 : maxCount.toDouble();

    final int numBars = dailyCounts.length;
    final double spacing = 16.0;
    final double totalSpacing = spacing * (numBars - 1);
    final double barWidth = (width - totalSpacing) / numBars;

    // Draw background horizontal lines
    final gridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1.2;

    for (int i = 0; i <= 4; i++) {
      final double y = height - (height * (i / 4.0));
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Draw bar columns (RTL arrangement for Arabic)
    for (int i = 0; i < numBars; i++) {
      // Map RTL: day 0 (السبت) is on the rightmost side, day 6 (الجمعة) on leftmost side
      final int dataIndex = i;
      final int visualIndex = numBars - 1 - i;

      final double count = dailyCounts[dataIndex].toDouble();
      final double barHeight = (count / maxVal) * (height * 0.85);
      final double x = visualIndex * (barWidth + spacing);
      final double y = height - barHeight;

      if (count > 0) {
        // Draw elegant soft shadow behind each bar
        final shadowPaint = Paint()
          ..color = const Color(0xFF1565C0).withValues(alpha: 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 1, y + 2, barWidth, barHeight),
            const Radius.circular(8.0),
          ),
          shadowPaint,
        );

        // Gradient color for bars
        final rect = Rect.fromLTWH(x, y, barWidth, barHeight);
        final gradient = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF1E3C72),
            const Color(0xFF00BCD4).withValues(alpha: 0.9),
          ],
        );
        paint.shader = gradient.createShader(rect);

        // Draw rounded bar
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(8.0)),
          paint,
        );
      } else {
        // Draw a tiny placeholder indicator for 0 count to keep visual rhythm
        final placeholderPaint = Paint()
          ..color = Colors.grey.shade200
          ..style = PaintingStyle.fill;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, height - 6, barWidth, 6),
            const Radius.circular(3.0),
          ),
          placeholderPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyAppointmentsPainter oldDelegate) {
    return oldDelegate.dailyCounts != dailyCounts;
  }
}
