import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/app_provider.dart';
import 'package:flutter_application_1/models/models.dart';
import 'package:provider/provider.dart';

class HospitalDashboardScreen extends StatelessWidget {
  const HospitalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final selectedHospitalId = provider.selectedHospitalId;
        final selectedHospital = selectedHospitalId != null
            ? provider.getHospitalById(selectedHospitalId)
            : null;
        final hospitals = provider.hospitals;

        return Scaffold(
          backgroundColor: const Color(0xFFF6F8FB),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              selectedHospital != null
                  ? 'إدارة ${selectedHospital['name']}'
                  : 'لوحة إدارة المستشفى',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 22,
                color: Color(0xFF1A1A2E),
                fontFamily: 'Cairo',
              ),
            ),
            centerTitle: true,
            actions: [
              if (selectedHospital != null)
                TextButton(
                  onPressed: () => provider.setSelectedHospitalId(null),
                  child: const Text(
                    'تغيير المستشفى',
                    style: TextStyle(
                      color: Color(0xFF1565C0),
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: selectedHospital == null
                ? _buildHospitalSelection(context, provider, hospitals)
                : _buildHospitalOverview(context, provider, selectedHospital),
          ),
        );
      },
    );
  }

  Widget _buildHospitalSelection(
    BuildContext context,
    AppProvider provider,
    List<Map<String, String>> hospitals,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'اختر المستشفى لإدارة طلبات الموافقة',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 18),
        Expanded(
          child: ListView.separated(
            itemCount: hospitals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final hospital = hospitals[index];
              return ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                tileColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(hospital['logoUrl'] ?? ''),
                  backgroundColor: Colors.grey.shade200,
                ),
                title: Text(
                  hospital['name'] ?? '',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    provider.setSelectedHospitalId(hospital['id']);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'اختر',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalOverview(
    BuildContext context,
    AppProvider provider,
    Map<String, String> hospital,
  ) {
    final selectedHospitalId = provider.selectedHospitalId!;
    final pendingDoctors = provider.getPendingDoctorsForHospital(
      selectedHospitalId,
    );
    final approvedDoctors = provider.doctors
        .where((d) => d.hospitalId == selectedHospitalId && d.hospitalApproved)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                hospital['name'] ?? '',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يمكنك هنا الموافقة على الأطباء المرتبطين بهذا المستشفى.',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'قيد الموافقة',
                      value: pendingDoctors.length.toString(),
                      color: const Color(0xFFF57C00),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: 'المفعلون',
                      value: approvedDoctors.length.toString(),
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => _showInviteDoctorDialog(context, provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.person_add_alt_1, size: 20),
                label: const Text(
                  'إضافة طبيب جديد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: pendingDoctors.isEmpty
              ? Center(
                  child: Text(
                    'لا توجد طلبات انتظار في الوقت الحالي.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.grey.shade700,
                      fontSize: 15,
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: pendingDoctors.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final doctor = pendingDoctors[index];
                    return _buildDoctorCard(context, provider, doctor);
                  },
                ),
        ),
      ],
    );
  }

  void _showInviteDoctorDialog(BuildContext context, AppProvider provider) {
    final nameController = TextEditingController();
    final specialtyController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'إضافة طبيب جديد',
            textAlign: TextAlign.right,
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'اسم الطبيب',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specialtyController,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  labelText: 'التخصص',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final specialty = specialtyController.text.trim();
                final email = emailController.text.trim();
                if (name.isEmpty || specialty.isEmpty || email.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'يرجى ملء جميع الحقول',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final success = await provider.inviteDoctorFromHospital(
                  name: name,
                  specialty: specialty,
                  email: email,
                );
                Navigator.of(context).pop();

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم إنشاء حساب الطبيب وإرسال رابط تعيين كلمة المرور',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      backgroundColor: Color(0xFF2E7D32),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'فشل إنشاء حساب الطبيب. تأكد من اختيار مستشفى صالح وتوصيل Firebase.',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
              ),
              child: const Text(
                'إرسال الدعوة',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDoctorCard(
    BuildContext context,
    AppProvider provider,
    Doctor doctor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: doctor.imageUrl.isNotEmpty
                ? (doctor.imageUrl.startsWith('http')
                      ? NetworkImage(doctor.imageUrl) as ImageProvider
                      : FileImage(File(doctor.imageUrl)) as ImageProvider)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'الحالة: في انتظار الموافقة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.orange.shade900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              provider.setDoctorHospitalApproval(doctor.id, true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تمت الموافقة على ${doctor.name}',
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  backgroundColor: const Color(0xFF2E7D32),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('موافقة', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
