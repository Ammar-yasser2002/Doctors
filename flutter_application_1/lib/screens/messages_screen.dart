import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/models.dart';
import 'package:flutter_application_1/providers/app_provider.dart';
import 'package:flutter_application_1/screens/chat_screen.dart';
import 'package:provider/provider.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showUnreadOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Doctor> _filterDoctors(AppProvider provider, List<Doctor> doctors) {
    final query = _searchController.text.trim();
    final filteredBySearch = query.isEmpty
        ? doctors
        : doctors.where((doctor) {
            return doctor.name.contains(query) ||
                doctor.specialty.contains(query) ||
                doctor.phone.contains(query);
          }).toList();

    if (!_showUnreadOnly) return filteredBySearch;
    return filteredBySearch
        .where((doctor) => provider.getUnreadCountForDoctor(doctor.id) > 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final doctors = provider.doctors;
        final visibleDoctors = _filterDoctors(provider, doctors);
        return SafeArea(
          top: false,
          bottom: true,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 40,
                  bottom: 10,
                  left: 16,
                  right: 16,
                ),
                child: Row(
                  children: [
                    if (provider.getTotalUnreadCount() > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1565C0),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${provider.getTotalUnreadCount()} غير مقروءة',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    const Spacer(),
                    const Text(
                      'الرسائل',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'ابحث باسم الطبيب، التخصص، أو رقم الهاتف',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontFamily: 'Cairo',
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF1565C0),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _searchController.clear()),
                      icon: const Icon(Icons.close_rounded),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 16, right: 16),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text(
                        'غير المقروءة',
                        style: TextStyle(fontFamily: 'Cairo'),
                      ),
                      selected: _showUnreadOnly,
                      onSelected: (value) =>
                          setState(() => _showUnreadOnly = value),
                      selectedColor: const Color(
                        0xFF1565C0,
                      ).withValues(alpha: 0.12),
                      checkmarkColor: const Color(0xFF1565C0),
                    ),
                  ],
                ),
              ),
              if (doctors.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF4A90D9,
                            ).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.forum_rounded,
                            size: 80,
                            color: Color(0xFF4A90D9),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'لا توجد رسائل بعد',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ابدأ الدردشة من صفحة الطبيب',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: visibleDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = visibleDoctors[index];
                      final lastMessage = provider.getLastMessageForDoctor(
                        doctor.id,
                      );
                      final lastText =
                          lastMessage?.text ?? 'ابدأ محادثة مع الطبيب الآن';
                      final unreadCount = provider.getUnreadCountForDoctor(
                        doctor.id,
                      );
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () {
                            provider.startConversationWithDoctor(doctor);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatScreen(doctor: doctor),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundImage:
                                      (!doctor.imageUrl.startsWith('http') &&
                                          doctor.imageUrl.isNotEmpty)
                                      ? FileImage(File(doctor.imageUrl))
                                      : NetworkImage(doctor.imageUrl)
                                            as ImageProvider,
                                  backgroundColor: Colors.grey.shade200,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              doctor.name,
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(
                                                fontFamily: 'Cairo',
                                                fontWeight: FontWeight.w800,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          if (unreadCount > 0)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1565C0),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                unreadCount.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  fontFamily: 'Cairo',
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        lastText,
                                        textAlign: TextAlign.right,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
