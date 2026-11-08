import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/app_provider.dart';
import 'package:flutter_application_1/screens/main_screen.dart';

class DoctorOnboardingScreen extends StatefulWidget {
  const DoctorOnboardingScreen({super.key});

  @override
  State<DoctorOnboardingScreen> createState() => _DoctorOnboardingScreenState();
}

class _DoctorOnboardingScreenState extends State<DoctorOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _workingHoursController = TextEditingController(
    text: '09:00 ص - 05:00 م',
  );
  final TextEditingController _bioController = TextEditingController();

  // Specialty options based on sample data
  final List<String> _specialties = [
    'جلدية',
    'أسنان',
    'أطفال',
    'عظام',
    'عيون',
    'قلب',
    'تجميل',
    'باطنية',
    'نساء وتوليد',
    'أنف وأذن',
    'مسالك بولية',
    'طب عام',
  ];
  String? _selectedSpecialty;

  // Available days selection
  final List<String> _weekDays = [
    'السبت',
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
  ];
  final List<String> _selectedDays = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _experienceController.dispose();
    _priceController.dispose();
    _workingHoursController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSpecialty == null) {
      _showSnackBar('يرجى اختيار التخصص الطبي');
      return;
    }

    if (_selectedDays.isEmpty) {
      _showSnackBar('يرجى اختيار يوم واحد على الأقل للعمل');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final double price = double.tryParse(_priceController.text) ?? 0.0;
      final provider = Provider.of<AppProvider>(context, listen: false);

      await provider.completeDoctorProfile(
        availableDays: _selectedDays,
        workingHours: _workingHoursController.text.trim(),
        price: price,
        experience: _experienceController.text.trim(),
        bio: _bioController.text.trim(),
        specialty: _selectedSpecialty!,
      );

      if (mounted) {
        // Success Dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF4CAF50),
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'تم إكمال الملف بنجاح!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Cairo',
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ملفك الآن بانتظار تفعيل وموافقة إدارة المستشفى أو المشرف لبدء استقبال المرضى.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'Cairo',
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'دخول للوحة التحكم',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Cairo',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء حفظ الملف: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Greeting / Intro Header ---
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1565C0).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.medical_services_outlined,
                            color: Color(0xFF1565C0),
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'أهلاً بك يا دكتور! 👋',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1A1A2E),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'يرجى إكمال معلوماتك الطبية والمهنية لبناء ملفك التعريفي واستقبل المواعيد بنجاح.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            fontFamily: 'Cairo',
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Card containing the form controls
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Specialty Dropdown
                        const Text(
                          'التخصص الطبي',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSpecialty,
                          onChanged: (val) {
                            setState(() {
                              _selectedSpecialty = val;
                            });
                          },
                          items: _specialties
                              .map(
                                (spec) => DropdownMenuItem(
                                  value: spec,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      spec,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF1565C0),
                          ),
                          decoration: InputDecoration(
                            hintText: 'اختر تخصصك الرئيسي',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontFamily: 'Cairo',
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) =>
                              val == null ? 'يرجى اختيار التخصص' : null,
                        ),

                        const SizedBox(height: 24),

                        // Experience Field
                        const Text(
                          'سنوات الخبرة (أو تفصيل الخبرة)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _experienceController,
                          keyboardType: TextInputType.text,
                          decoration: _buildInputDecoration(
                            hint: 'مثال: 10 سنوات خبرة، استشاري جراحة',
                            icon: Icons.workspace_premium_outlined,
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'يرجى إدخال الخبرة'
                              : null,
                        ),

                        const SizedBox(height: 24),

                        // Consultation Price Field
                        const Text(
                          'سعر الجلسة / الكشفية (ر.س)',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: _buildInputDecoration(
                            hint: 'مثال: 250',
                            icon: Icons.payments_outlined,
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'يرجى إدخال السعر';
                            }
                            if (double.tryParse(val) == null) {
                              return 'يرجى إدخال رقم صحيح';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Working Hours Field
                        const Text(
                          'ساعات العمل اليومية',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _workingHoursController,
                          decoration: _buildInputDecoration(
                            hint: 'مثال: 09:00 ص - 05:00 م',
                            icon: Icons.access_time_outlined,
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'يرجى إدخال ساعات العمل'
                              : null,
                        ),

                        const SizedBox(height: 24),

                        // Bio Field
                        const Text(
                          'نبذة تعريفية مهنية',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _bioController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText:
                                'اكتب نبذة مختصرة عن مؤهلاتك وتخصصك الدقيق لمساعدتك المرضى في التعرف عليك...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontFamily: 'Cairo',
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8F9FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'يرجى كتابة النبذة التعريفية'
                              : null,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Working Days Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'أيام تواجدك واستقبال المواعيد',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A2E),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'اختر الأيام التي ترغب في تفعيل الحجز بها للمرضى:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _weekDays.map((day) {
                            final isSelected = _selectedDays.contains(day);
                            return FilterChip(
                              label: Text(
                                day,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E),
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedDays.add(day);
                                  } else {
                                    _selectedDays.remove(day);
                                  }
                                });
                              },
                              selectedColor: const Color(0xFF1565C0),
                              checkmarkColor: Colors.white,
                              backgroundColor: const Color(0xFFF8F9FA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFF1565C0)
                                      : Colors.grey.shade200,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'حفظ وإرسال الملف للمراجعة',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Cairo',
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontFamily: 'Cairo',
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF1565C0), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }
}
