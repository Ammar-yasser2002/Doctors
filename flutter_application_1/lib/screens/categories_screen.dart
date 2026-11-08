import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/sample_data.dart';
import 'package:flutter_application_1/widgets/doctor_card.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'أطباء',
      'icon': Icons.medical_services_outlined,
      'color': 0xFF1565C0,
    },
    {
      'name': 'أسنان',
      'icon': Icons.health_and_safety_outlined,
      'color': 0xFF4CAF50,
    },
    {
      'name': 'تجميل',
      'icon': Icons.face_retouching_natural_outlined,
      'color': 0xFFE91E63,
    },
    {'name': 'عيون', 'icon': Icons.visibility_outlined, 'color': 0xFF2196F3},
    {'name': 'جلدية', 'icon': Icons.spa_outlined, 'color': 0xFF9C27B0},
    {
      'name': 'عظام',
      'icon': Icons.accessibility_new_outlined,
      'color': 0xFFFF9800,
    },
    {
      'name': 'قلب',
      'icon': Icons.favorite_border_outlined,
      'color': 0xFFF44336,
    },
    {'name': 'أطفال', 'icon': Icons.child_care_outlined, 'color': 0xFF00BCD4},
    {
      'name': 'نساء وتوليد',
      'icon': Icons.pregnant_woman_outlined,
      'color': 0xFFFF5722,
    },
    {'name': 'أنف وأذن', 'icon': Icons.hearing_outlined, 'color': 0xFF3F51B5},
    {
      'name': 'باطنية',
      'icon': Icons.local_hospital_outlined,
      'color': 0xFF009688,
    },
    {
      'name': 'مسالك بولية',
      'icon': Icons.water_drop_outlined,
      'color': 0xFF03A9F4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'التخصصات',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'اختر التخصص المطلوب',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryDoctorsScreen(
                          categoryName: category['name'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Color(category['color']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            category['icon'],
                            color: Color(category['color']),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          category['name'],
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryDoctorsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDoctorsScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final categoryDoctors = sampleDoctors
        .where((d) => d.specialty == categoryName)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            fontFamily: 'Cairo',
          ),
        ),
        centerTitle: true,
      ),
      body: categoryDoctors.isEmpty
          ? const Center(
              child: Text(
                'لا يوجد أطباء في هذا التخصص',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Cairo',
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: categoryDoctors.length,
              itemBuilder: (context, index) {
                final doctor = categoryDoctors[index];
                return DoctorCard(doctor: doctor);
              },
            ),
    );
  }
}
