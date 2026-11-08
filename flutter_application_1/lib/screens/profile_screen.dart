import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/app_provider.dart';
import 'package:flutter_application_1/screens/banners_control_screen.dart';
import 'package:flutter_application_1/screens/main_screen.dart';
import 'package:flutter_application_1/screens/notifications_screen.dart';
import 'package:flutter_application_1/screens/payment_methods_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final user = provider.currentUser;
        final pendingAppointments = provider.appointments
            .where((a) => a.status == 'بانتظار تأكيد الطبيب')
            .length;
        final totalUnread = provider.getTotalUnreadCount();

        return Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        const Color(0xFF1565C0),
                        const Color(0xFF1565C0).withValues(alpha: 0.9),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'حسابي',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: Image.network(
                                'https://i.pravatar.cc/150?u=mohammed',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showImagePickerOptions(context),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF26C6DA),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        (user?.name != null && user!.name.isNotEmpty)
                            ? user!.name
                            : 'المستخدم',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          provider.isHospital
                              ? 'مستشفى'
                              : provider.isDoctor
                              ? 'طبيب'
                              : 'مريض',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        (user?.email != null && user!.email.isNotEmpty)
                            ? user!.email
                            : 'لا يوجد بريد مسجل',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      if (user?.phone != null && user!.phone.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          user!.phone,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      OutlinedButton(
                        onPressed: () =>
                            _showEditAccountDialog(context, provider),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'تعديل الحساب',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildQuickStat(
                          title: 'غير مقروءة',
                          value: totalUnread.toString(),
                          icon: Icons.mark_chat_unread_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildQuickStat(
                          title: 'بانتظار التأكيد',
                          value: pendingAppointments.toString(),
                          icon: Icons.pending_actions_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildQuickStat(
                          title: 'المواعيد',
                          value: provider.appointments.length.toString(),
                          icon: Icons.calendar_month_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'إدارة الحساب',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        elevation: 2,
                        child: Column(
                          children: [
                            _buildMenuItem(
                              context,
                              Icons.person_outline,
                              'معلوماتي',
                              () => _navigateToInfo(context),
                            ),
                            _buildMenuItem(
                              context,
                              Icons.calendar_today_outlined,
                              'مواعيدي',
                              () => _navigateToAppointments(context),
                            ),
                            _buildMenuItem(
                              context,
                              Icons.favorite_outline,
                              'المفضلة',
                              () {
                                final enabled =
                                    provider.doctorPermissions['المفضلة'] ??
                                    true;
                                if (enabled) {
                                  _navigateToFavorites(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'الميزة معطلة في إعدادات الطبيب',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            _buildMenuItem(
                              context,
                              Icons.payment_outlined,
                              'طرق الدفع',
                              () => _navigateToPayment(context),
                            ),
                            _buildMenuItem(
                              context,
                              provider.isHospital
                                  ? Icons.person_outline
                                  : Icons.business,
                              provider.isHospital
                                  ? 'العودة إلى مريض'
                                  : 'العمل كمستشفى',
                              () => _toggleHospitalRole(context, provider),
                            ),
                            _buildMenuItem(
                              context,
                              Icons.notifications_outlined,
                              'الإشعارات',
                              () => _navigateToNotifications(context),
                            ),
                            if (provider.isDoctor)
                              _buildMenuItem(
                                context,
                                Icons.tune_rounded,
                                'إدارة البنرات',
                                () => _navigateToBanners(context),
                              ),
                            if (provider.isDoctor)
                              _buildMenuItem(
                                context,
                                Icons.shield_outlined,
                                'صلاحيات الطبيب',
                                () => _navigateToDoctorPermissions(
                                  context,
                                  provider,
                                ),
                              ),
                            _buildMenuItem(
                              context,
                              Icons.help_outline,
                              'المساعدة',
                              () {
                                final enabled =
                                    provider.doctorPermissions['المساعدة'] ??
                                    true;
                                if (enabled) {
                                  _navigateToHelp(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'الميزة معطلة في إعدادات الطبيب',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: provider.currentUser?.id == 'default'
                      ? ListTile(
                          tileColor: Colors.blue.withOpacity(0.06),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          leading: Image.network(
                            'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.login, color: Colors.blue),
                          ),
                          title: const Text(
                            'تسجيل الدخول باستخدام جوجل',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          onTap: () async {
                            // Call Google Sign in
                            final success = await provider.signInWithGoogle();
                            if (success) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'تم تسجيل الدخول بنجاح',
                                      style: TextStyle(fontFamily: 'Cairo'),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          },
                        )
                      : ListTile(
                          tileColor: Colors.red.withOpacity(0.06),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          onTap: () => _handleLogout(context, provider),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStat({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF1565C0), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.w800,
              fontSize: 16,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF1565C0).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF1565C0), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(Icons.arrow_back_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'تغيير الصورة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text(
                'التقاط صورة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              onTap: () {
                Navigator.pop(context);
                _captureImage(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text(
                'اختيار من المعرض',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _captureImage(BuildContext context) {
    // TODO: Implement actual image capture using image_picker package
    // For now, show a feedback message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'ميزة التقاط الصورة تتطلب إضافة حزمة image_picker',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: Color(0xFF26C6DA),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _pickFromGallery(BuildContext context) {
    // TODO: Implement actual image picking using image_picker package
    // For now, show a feedback message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'ميزة اختيار الصورة تتطلب إضافة حزمة image_picker',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: Color(0xFF26C6DA),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showEditAccountDialog(BuildContext context, AppProvider provider) {
    final user = provider.currentUser;
    final nameController = TextEditingController(
      text: user?.name ?? 'محمد العلي',
    );
    final phoneController = TextEditingController(
      text: user?.phone ?? '+966 123456789',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تعديل الحساب',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontFamily: 'Cairo'),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              // Update user info in provider
              if (user != null) {
                // For demo purposes, just show success message
                // In real app, you would update the user object
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم تحديث المعلومات بنجاح',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
            ),
            child: const Text(
              'حفظ',
              style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToInfo(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final user = provider.currentUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
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
              'المعلومات الشخصية',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 30),
            _buildInfoField(
              'الاسم الكامل',
              user?.name ?? 'محمد العلي',
              Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              'رقم الهاتف',
              user?.phone ?? '+966 123456789',
              Icons.phone_android_outlined,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              'البريد الإلكتروني',
              user?.email ?? 'mohammed@example.com',
              Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            _buildInfoField(
              'العنوان',
              'الرياض، المملكة العربية السعودية',
              Icons.location_on_outlined,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'تعديل البيانات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Icon(icon, color: const Color(0xFF1565C0)),
        ],
      ),
    );
  }

  void _navigateToAppointments(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.setTabIndex(2); // Index 2 is AppointmentsScreen
  }

  void _navigateToFavorites(BuildContext context) {
    _showPlaceholderSheet(
      context,
      'المفضلة',
      Icons.favorite_outline,
      'لم تقم بإضافة أي أطباء للمفضلة بعد',
    );
  }

  void _navigateToPayment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );
  }

  void _navigateToBanners(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BannersControlScreen()),
    );
  }

  void _navigateToHelp(BuildContext context) {
    _showPlaceholderSheet(
      context,
      'المساعدة',
      Icons.help_outline_rounded,
      'كيف يمكننا مساعدتك اليوم؟',
    );
  }

  void _toggleUserRole(BuildContext context, AppProvider provider) {
    final isDoctor = provider.isDoctor;
    final newRole = isDoctor ? 'patient' : 'doctor';
    provider.setUserRole(newRole);
    provider.setTabIndex(0); // Navigate to tab 0 (Home/Dashboard) automatically

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDoctor ? 'تم تحويل الحساب إلى مريض' : 'تم تحويل الحساب إلى طبيب',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  void _toggleHospitalRole(BuildContext context, AppProvider provider) {
    final isHospital = provider.isHospital;
    provider.setUserRole(isHospital ? 'patient' : 'hospital');
    provider.setTabIndex(0);
    if (!isHospital) {
      provider.setSelectedHospitalId(null);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isHospital
              ? 'تم إعادة الحساب إلى مريض'
              : 'تم تحويل الحساب إلى دور المستشفى',
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  void _navigateToDoctorPermissions(
    BuildContext context,
    AppProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
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
              'صلاحيات الطبيب',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك تفعيل أو تعطيل صلاحيات الطبيب حسب حاجة العمل.',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<AppProvider>(
                builder: (context, provider, child) => ListView.separated(
                  itemCount: provider.doctorPermissions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = provider.doctorPermissions.entries.elementAt(
                      index,
                    );
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          entry.key,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: const Text(
                          'تحكم بصلاحية الوصول لهذه الميزة.',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        value: entry.value,
                        onChanged: (value) {
                          provider.setDoctorPermission(entry.key, value);
                        },
                        activeThumbColor: const Color(0xFF1565C0),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                  'حفظ التغييرات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showPlaceholderSheet(
    BuildContext context,
    String title,
    IconData icon,
    String message,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 350,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 40),
            Icon(
              icon,
              size: 80,
              color: const Color(0xFF1565C0).withOpacity(0.1),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'تسجيل الخروج',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        content: const Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () {
              // Call logout from provider
              provider.logout();
              Navigator.pop(context);
              // Navigate to main screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainScreen()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم تسجيل الخروج بنجاح',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
