import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/models.dart';
import 'package:flutter_application_1/providers/app_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BannersControlScreen extends StatefulWidget {
  const BannersControlScreen({super.key});

  @override
  State<BannersControlScreen> createState() => _BannersControlScreenState();
}

class _BannersControlScreenState extends State<BannersControlScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final List<Discount> _discounts;
  late final List<Map<String, String>> _hospitals;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final provider = Provider.of<AppProvider>(context, listen: false);
    _discounts = List.from(provider.discounts);
    _hospitals = List.from(provider.hospitals);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveAndApply() {
    Provider.of<AppProvider>(
      context,
      listen: false,
    ).updateBannersAndPartners(discounts: _discounts, hospitals: _hospitals);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم حفظ التغييرات بنجاح',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: const Color(0xFF1565C0),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  // ── Discount Dialog ──────────────────────────────────
  void _showDiscountDialog({Discount? existing, int? index}) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    Color startColor = existing?.startColor ?? Colors.blue.shade800;
    Color endColor = existing?.endColor ?? Colors.blue.shade400;
    String? imageUrl = existing?.imageUrl;
    File? selectedImage;
    bool isUploading = false;

    final colorPairs = <List<Color>>[
      [Colors.blue.shade800, Colors.blue.shade400],
      [Colors.teal.shade700, Colors.teal.shade300],
      [Colors.purple.shade700, Colors.purple.shade300],
      [Colors.orange.shade800, Colors.orange.shade400],
      [Colors.red.shade700, Colors.red.shade400],
      [Colors.green.shade700, Colors.green.shade400],
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            existing != null ? 'تعديل البنر' : 'إضافة بنر جديد',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildField(
                  'العنوان',
                  titleCtrl,
                  hint: 'مثال: احصل على خصم 30%',
                ),
                const SizedBox(height: 12),
                _buildField(
                  'الوصف',
                  descCtrl,
                  hint: 'مثال: على أول حجز هذا الأسبوع',
                ),
                const SizedBox(height: 16),

                // --- Image Picker ---
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: isUploading
                        ? null
                        : () async {
                            final picker = ImagePicker();
                            final pickedFile = await picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            if (pickedFile != null) {
                              setS(() {
                                selectedImage = File(pickedFile.path);
                                imageUrl =
                                    null; // Clear URL since we have local file
                              });
                            }
                          },
                    icon: const Icon(Icons.image_outlined, size: 20),
                    label: const Text(
                      'اختيار صورة من المعرض',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                      backgroundColor: Colors.blue.shade50,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                if (selectedImage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          selectedImage!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                else if (imageUrl != null && imageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            (imageUrl!.startsWith('http://') ||
                                imageUrl!.startsWith('https://'))
                            ? Image.network(
                                imageUrl!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(imageUrl!),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'لون البنر',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: colorPairs.map((pair) {
                    final selected = startColor == pair[0];
                    return GestureDetector(
                      onTap: () => setS(() {
                        startColor = pair[0];
                        endColor = pair[1];
                      }),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [pair[0], pair[1]]),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? Colors.black87
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: selected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isUploading
                  ? null
                  : () async {
                      if (titleCtrl.text.isEmpty) return;
                      setS(() {
                        isUploading = true;
                      });

                      String finalImageUrl = imageUrl ?? '';
                      if (selectedImage != null) {
                        final provider = Provider.of<AppProvider>(
                          context,
                          listen: false,
                        );
                        final uploadUrl = await provider.firebaseService
                            .uploadImage(selectedImage!, 'banners');
                        if (uploadUrl != null) {
                          finalImageUrl = uploadUrl;
                        } else {
                          finalImageUrl = selectedImage!.path;
                        }
                      }

                      final newD = Discount(
                        title: titleCtrl.text,
                        description: descCtrl.text,
                        imageUrl: finalImageUrl,
                        startColor: startColor,
                        endColor: endColor,
                      );
                      setState(() {
                        if (index != null) {
                          _discounts[index] = newD;
                        } else {
                          _discounts.add(newD);
                        }
                      });
                      Navigator.pop(ctx);
                    },
              child: isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'حفظ',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hospital Dialog ──────────────────────────────────
  void _showHospitalDialog({Map<String, String>? existing, int? index}) {
    final nameCtrl = TextEditingController(text: existing?['name'] ?? '');
    String? logoUrl = existing?['logoUrl'];
    File? selectedLogo;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            existing != null ? 'تعديل المستشفى' : 'إضافة مستشفى',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildField('اسم المستشفى', nameCtrl, hint: 'مثال: مستشفى الأمل'),
              const SizedBox(height: 16),

              // --- Image Picker ---
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: isUploading
                      ? null
                      : () async {
                          final picker = ImagePicker();
                          final pickedFile = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null) {
                            setS(() {
                              selectedLogo = File(pickedFile.path);
                              logoUrl = null;
                            });
                          }
                        },
                  icon: const Icon(Icons.image_outlined, size: 20),
                  label: const Text(
                    'شعار المستشفى',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFF1565C0),
                    backgroundColor: Colors.blue.shade50,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              if (selectedLogo != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        selectedLogo!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                )
              else if (logoUrl != null && logoUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          (logoUrl!.startsWith('http://') ||
                              logoUrl!.startsWith('https://'))
                          ? Image.network(
                              logoUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              File(logoUrl!),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: isUploading
                  ? null
                  : () async {
                      if (nameCtrl.text.isEmpty) return;
                      setS(() {
                        isUploading = true;
                      });

                      String finalLogoUrl = logoUrl ?? '';
                      if (selectedLogo != null) {
                        final provider = Provider.of<AppProvider>(
                          context,
                          listen: false,
                        );
                        final uploadUrl = await provider.firebaseService
                            .uploadImage(selectedLogo!, 'hospital_logos');
                        if (uploadUrl != null) {
                          finalLogoUrl = uploadUrl;
                        } else {
                          finalLogoUrl = selectedLogo!.path;
                        }
                      }

                      setState(() {
                        final entry = {
                          'id':
                              existing?['id'] ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
                          'name': nameCtrl.text,
                          'logoUrl': finalLogoUrl,
                        };
                        if (index != null) {
                          _hospitals[index] = entry;
                        } else {
                          _hospitals.add(entry);
                        }
                      });
                      Navigator.pop(ctx);
                    },
              child: isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'حفظ',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    String hint = '',
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
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Cairo'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Cairo',
              color: Colors.black38,
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'إدارة البنرات',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveAndApply,
            icon: const Icon(Icons.save_rounded, color: Colors.white, size: 20),
            label: const Text(
              'حفظ',
              style: TextStyle(color: Colors.white, fontFamily: 'Cairo'),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
          tabs: const [
            Tab(text: 'العروض والخصومات'),
            Tab(text: 'شركاء موثوقون'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildDiscountsTab(), _buildHospitalsTab()],
      ),
    );
  }

  // ── Discounts Tab ────────────────────────────────────
  Widget _buildDiscountsTab() {
    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _discounts.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _discounts.removeAt(oldIndex);
                _discounts.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              final d = _discounts[index];
              return Container(
                key: ValueKey('disc_$index'),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      d.startColor ?? Colors.blue.shade800,
                      d.endColor ?? Colors.blue.shade400,
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      // Actions
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.white70,
                          size: 22,
                        ),
                        onPressed: () =>
                            setState(() => _discounts.removeAt(index)),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () =>
                            _showDiscountDialog(existing: d, index: index),
                      ),
                      const Spacer(),
                      // Title + desc
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              d.title,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cairo',
                                fontSize: 14,
                              ),
                            ),
                            if (d.description.isNotEmpty)
                              Text(
                                d.description,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.drag_handle_rounded,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _showDiscountDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'إضافة بنر عرض جديد',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Hospitals Tab ────────────────────────────────────
  Widget _buildHospitalsTab() {
    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _hospitals.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _hospitals.removeAt(oldIndex);
                _hospitals.insert(newIndex, item);
              });
            },
            itemBuilder: (context, index) {
              final h = _hospitals[index];
              return Container(
                key: ValueKey('hosp_$index'),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      // Actions
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                        onPressed: () =>
                            setState(() => _hospitals.removeAt(index)),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: Color(0xFF1565C0),
                          size: 22,
                        ),
                        onPressed: () =>
                            _showHospitalDialog(existing: h, index: index),
                      ),
                      const Spacer(),
                      // Name
                      Flexible(
                        child: Text(
                          h['name'] ?? '',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child:
                            h['logoUrl'] != null &&
                                h['logoUrl']!.startsWith('/')
                            ? Image.file(
                                File(h['logoUrl']!),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.local_hospital,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                              )
                            : Image.network(
                                h['logoUrl'] ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.local_hospital,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.drag_handle_rounded,
                        color: Colors.black38,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _showHospitalDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text(
                'إضافة مستشفى جديد',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
