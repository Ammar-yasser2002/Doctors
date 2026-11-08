import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/models.dart';
import 'package:flutter_application_1/data/sample_data.dart';
import 'package:flutter_application_1/data/database_helper.dart';
import 'package:flutter_application_1/data/firebase_service.dart';

class AppProvider extends ChangeNotifier {
  User? _currentUser;
  int _currentTabIndex = 0;
  String? _selectedHospitalId;
  final List<Map<String, String>> _paymentCards = [];
  final List<Appointment> _appointments = [];
  final List<Doctor> _doctors = sampleDoctors;
  final Map<String, List<ChatMessage>> _doctorChats = {};
  final List<Discount> _discounts = List.from(sampleDiscounts);
  final List<Map<String, String>> _hospitals = [
    {
      'id': 'razy',
      'name': 'مستشفى الرازي',
      'logoUrl':
          'https://images.unsplash.com/photo-1580281657521-7251464dbab2?auto=format&fit=crop&w=800&q=80',
    },
    {
      'id': 'amal',
      'name': 'مستشفى الأمل',
      'logoUrl':
          'https://images.unsplash.com/photo-1496317899792-9d7dbcd928a1?auto=format&fit=crop&w=800&q=80',
    },
    {
      'id': 'shifa',
      'name': 'مجمع الشفاء',
      'logoUrl':
          'https://images.unsplash.com/photo-1580281657831-ff3e16f85b63?auto=format&fit=crop&w=800&q=80',
    },
    {
      'id': 'madina',
      'name': 'مستشفى المدينة',
      'logoUrl':
          'https://images.unsplash.com/photo-1597750371506-a2a684baf984?auto=format&fit=crop&w=800&q=80',
    },
  ];
  final Map<String, bool> _doctorPermissions = {
    'قبول المواعيد': true,
    'الرد على الرسائل': true,
    'عرض بيانات المريض': true,
    'إدارة الجدول': true,
    // Additional toggles to control optional features
    'المفضلة': true,
    'المساعدة': true,
    'زيارة أونلاين': true,
  };
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _appointmentSubscription;

  AppProvider() {
    _loadDataFromDb();
  }

  @override
  void dispose() {
    _appointmentSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadDataFromDb() async {
    // Load User (Local Backup)
    _currentUser ??= await _dbHelper.getUser();

    // Clean up any stale simulated fallback user from old tests
    if (_currentUser != null &&
        (_currentUser!.id.startsWith('google_fallback') ||
            _currentUser!.name.contains('تجريبي') ||
            _currentUser!.email == 'doctor@gmail.com')) {
      await _dbHelper.clearUser();
      _currentUser = null;
    }

    if (_currentUser == null) {
      // Set default guest user
      _currentUser = User(
        id: 'default',
        name: 'ضيف',
        phone: '',
        email: '',
        password: '',
        gender: 'غير محدد',
        role: 'patient',
      );
      await _dbHelper.saveUser(_currentUser!);
    }

    // Load Appointments
    final dbAppointments = await _dbHelper.getAppointments();
    if (dbAppointments.isNotEmpty) {
      _appointments.addAll(dbAppointments);
    } else {
      // If no appointments in DB, add some sample ones for first time
      _appointments.addAll([
        Appointment(
          id: '1',
          userId: '0', // Sample user
          bookingId: 'BK9283',
          businessName: 'مركز الشفاء الطبي',
          doctorName: 'د. محمد العلي',
          specialty: 'أخصائي قلب',
          date: '2026-03-05',
          time: '10:30 ص',
          status: 'قادم',
          imageUrl:
              'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=2070&auto=format&fit=crop',
          price: 250,
          appointmentType: 'زيارة عيادة',
        ),
        Appointment(
          id: '2',
          userId: '0', // Sample user
          bookingId: 'BK4721',
          businessName: 'مجمع صحتي المتخصص',
          doctorName: 'د. سارة الأحمد',
          specialty: 'أخصائية أطفال',
          date: '2026-03-01',
          time: '04:15 م',
          status: 'قادم',
          imageUrl:
              'https://images.unsplash.com/photo-1594824813573-c10fe527d31e?q=80&w=1974&auto=format&fit=crop',
          price: 200,
          appointmentType: 'كشف أونلاين',
        ),
      ]);
      for (var app in _appointments) {
        await _dbHelper.insertAppointment(app);
      }
    }

    // Load Cards
    final dbCards = await _dbHelper.getCards();
    if (dbCards.isNotEmpty) {
      _paymentCards.addAll(dbCards);
    } else {
      // Default sample cards for first time
      _paymentCards.addAll([
        {
          'type': 'Visa',
          'number': '**** **** **** 4242',
          'expiry': '12/26',
          'holder': 'MOHAMMED AL-ALI',
          'color': '0xFF1565C0',
        },
        {
          'type': 'MasterCard',
          'number': '**** **** **** 8888',
          'expiry': '08/25',
          'holder': 'MOHAMMED AL-ALI',
          'color': '0xFF1A1A2E',
        },
      ]);
      for (var card in _paymentCards) {
        await _dbHelper.insertCard(card);
      }
    }
    notifyListeners();
  }

  User? get currentUser => _currentUser;
  int get currentTabIndex => _currentTabIndex;
  List<Map<String, String>> get paymentCards => _paymentCards;
  List<Appointment> get appointments => _appointments;
  List<Doctor> get doctors => _doctors;
  Map<String, List<ChatMessage>> get doctorChats => _doctorChats;
  List<Discount> get discounts => _discounts;
  List<Map<String, String>> get hospitals => _hospitals;
  FirebaseService get firebaseService => _firebaseService;

  Doctor? get currentDoctorProfile {
    if (_currentUser == null || _currentUser!.role != 'doctor') return null;
    try {
      return _doctors.firstWhere((d) => d.id == _currentUser!.id);
    } catch (_) {
      final defaultDoc = Doctor(
        id: _currentUser!.id,
        name: _currentUser!.name.startsWith('د.')
            ? _currentUser!.name
            : 'د. ${_currentUser!.name}',
        specialty: 'جلدية',
        imageUrl:
            'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=2070&auto=format&fit=crop',
        rating: 5.0,
        reviewCount: 0,
        location: 'الرياض',
        phone: _currentUser!.phone,
        experience: 'سنتان خبرة',
        price: 200,
        availableDays: ['السبت', 'الاثنين', 'الأربعاء'],
        bio: 'استشاري متخصص.',
        workingHours: '09:00 ص - 05:00 م',
      );
      _doctors.add(defaultDoc);
      return defaultDoc;
    }
  }

  void updateDoctorProfile(Doctor updatedDoc) {
    final idx = _doctors.indexWhere((d) => d.id == updatedDoc.id);
    final previousHospitalId = idx != -1 ? _doctors[idx].hospitalId : null;
    final previousHospitalApproved = idx != -1
        ? _doctors[idx].hospitalApproved
        : updatedDoc.hospitalApproved;
    final hospitalId = updatedDoc.hospitalId ?? previousHospitalId;
    final hospitalApproved =
        (previousHospitalId != null &&
            updatedDoc.hospitalId != null &&
            updatedDoc.hospitalId != previousHospitalId)
        ? false
        : previousHospitalApproved;
    final savedPhone = updatedDoc.phone.isNotEmpty
        ? updatedDoc.phone
        : (idx != -1 ? _doctors[idx].phone : '');
    final doctorToSave = Doctor(
      id: updatedDoc.id,
      name: updatedDoc.name,
      specialty: updatedDoc.specialty,
      imageUrl: updatedDoc.imageUrl,
      rating: updatedDoc.rating,
      reviewCount: updatedDoc.reviewCount,
      location: updatedDoc.location,
      phone: savedPhone,
      experience: updatedDoc.experience,
      price: updatedDoc.price,
      availableDays: updatedDoc.availableDays,
      bio: updatedDoc.bio,
      workingHours: updatedDoc.workingHours,
      hospitalId: hospitalId,
      hospitalApproved: hospitalApproved,
    );

    if (idx != -1) {
      _doctors[idx] = doctorToSave;
    } else {
      _doctors.add(doctorToSave);
    }

    if (_currentUser != null && _currentUser!.id == updatedDoc.id) {
      String cleanName = updatedDoc.name
          .replaceAll(RegExp(r'^د[\.\s]+'), '')
          .trim();
      _currentUser = User(
        id: _currentUser!.id,
        name: cleanName,
        phone: _currentUser!.phone,
        email: _currentUser!.email,
        password: _currentUser!.password,
        gender: _currentUser!.gender,
        role: _currentUser!.role,
      );
      _dbHelper.saveUser(_currentUser!);
    }
    notifyListeners();
  }

  void updateBannersAndPartners({
    required List<Discount> discounts,
    required List<Map<String, String>> hospitals,
  }) {
    _discounts.clear();
    _discounts.addAll(discounts);
    // Sync sampleDiscounts global to match the updated list
    sampleDiscounts.clear();
    sampleDiscounts.addAll(discounts);

    _hospitals.clear();
    _hospitals.addAll(hospitals);
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  String? get selectedHospitalId => _selectedHospitalId;

  void setSelectedHospitalId(String? hospitalId) {
    _selectedHospitalId = hospitalId;
    notifyListeners();
  }

  void requestHospitalLink(String doctorId, String hospitalId) {
    final index = _doctors.indexWhere((d) => d.id == doctorId);
    if (index == -1) return;
    final doctor = _doctors[index];
    _doctors[index] = Doctor(
      id: doctor.id,
      name: doctor.name,
      specialty: doctor.specialty,
      imageUrl: doctor.imageUrl,
      rating: doctor.rating,
      reviewCount: doctor.reviewCount,
      location: doctor.location,
      phone: doctor.phone,
      experience: doctor.experience,
      price: doctor.price,
      availableDays: doctor.availableDays,
      bio: doctor.bio,
      workingHours: doctor.workingHours,
      hospitalId: hospitalId,
      hospitalApproved: false,
    );
    notifyListeners();
  }

  void addPaymentCard(Map<String, String> card) async {
    _paymentCards.add(card);
    await _dbHelper.insertCard(card);
    notifyListeners();
  }

  void removePaymentCard(int index) async {
    if (index >= 0 && index < _paymentCards.length) {
      // Note: In real app we'd need a stable ID for card deletion
      // For now, let's clear all and re-save or just update in-memory
      _paymentCards.removeAt(index);
      await _dbHelper.clearCards();
      for (var card in _paymentCards) {
        await _dbHelper.insertCard(card);
      }
      notifyListeners();
    }
  }

  void setUser(User user) async {
    _currentUser = user;
    await _dbHelper.saveUser(user);
    await _firebaseService.saveUserData(user); // Sync to Cloud
    notifyListeners();
  }

  void setUserRole(String role) async {
    if (_currentUser == null) return;
    _currentUser = User(
      id: _currentUser!.id,
      name: _currentUser!.name,
      phone: _currentUser!.phone,
      email: _currentUser!.email,
      password: _currentUser!.password,
      gender: _currentUser!.gender,
      role: role,
    );
    await _dbHelper.saveUser(_currentUser!);
    await _firebaseService.saveUserData(_currentUser!); // Sync to Cloud
    notifyListeners();
  }

  void addAppointment(Appointment appointment) async {
    // Add locally for instant UI update
    if (!_appointments.any((a) => a.id == appointment.id)) {
      _appointments.add(appointment);
    }
    await _dbHelper.insertAppointment(appointment);
    await _firebaseService.bookAppointment(appointment); // Sync to Cloud
    notifyListeners();
  }

  Future<bool> isDoctorSlotAvailable({
    required String doctorName,
    required String date,
    required String time,
  }) async {
    final hasLocalConflict = _appointments.any(
      (a) =>
          a.doctorName == doctorName &&
          a.date == date &&
          a.time == time &&
          (a.status == 'قادم' || a.status == 'بانتظار تأكيد الطبيب'),
    );
    if (hasLocalConflict) return false;

    try {
      return await _firebaseService.isDoctorSlotAvailable(
        doctorName: doctorName,
        date: date,
        time: time,
      );
    } catch (_) {
      // Fallback to local validation if network check fails.
      return true;
    }
  }

  Future<bool> addAppointmentWithValidation(Appointment appointment) async {
    final isAvailable = await isDoctorSlotAvailable(
      doctorName: appointment.doctorName,
      date: appointment.date,
      time: appointment.time,
    );
    if (!isAvailable) return false;

    addAppointment(appointment);
    return true;
  }

  Future<void> confirmAppointmentByDoctor(String appointmentId) async {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return;

    final current = _appointments[index];
    final updated = Appointment(
      id: current.id,
      userId: current.userId,
      bookingId: current.bookingId,
      businessName: current.businessName,
      doctorName: current.doctorName,
      specialty: current.specialty,
      date: current.date,
      time: current.time,
      status: 'قادم',
      imageUrl: current.imageUrl,
      price: current.price,
      isHistory: current.isHistory,
      appointmentType: current.appointmentType,
    );

    _appointments[index] = updated;
    await _dbHelper.insertAppointment(updated);
    await _firebaseService.updateAppointmentStatus(appointmentId, 'قادم');
    notifyListeners();
  }

  void cancelAppointment(String appointmentId) async {
    _appointments.removeWhere((a) => a.id == appointmentId);
    await _dbHelper.deleteAppointment(appointmentId);
    await _firebaseService.cancelAppointment(appointmentId); // Sync to Cloud
    notifyListeners();
  }

  void logout() async {
    await _firebaseService.signOut();
    _currentUser = null;
    await _dbHelper.clearUser();
    notifyListeners();
  }

  Future<void> signInAnonymously() async {
    final user = await _firebaseService.signInAnonymously();
    if (user != null) {
      _currentUser = user;
      await _dbHelper.saveUser(user);
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    final user = await _firebaseService.signInWithGoogle();
    if (user != null) {
      _currentUser = user;
      await _dbHelper.saveUser(user);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> signInWithEmail(String email, String password) async {
    final user = await _firebaseService.loginWithEmail(email, password);
    if (user != null) {
      _currentUser = user;
      await _dbHelper.saveUser(user);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _firebaseService.sendPasswordResetEmail(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> registerWithEmail(
    String name,
    String phone,
    String email,
    String password,
    String gender,
  ) async {
    final newUser = User(
      id: '',
      name: name,
      phone: phone,
      email: email,
      password: password,
      gender: gender,
    );
    final user = await _firebaseService.signUpWithEmail(
      email,
      password,
      newUser,
    );
    if (user != null) {
      _currentUser = user;
      await _dbHelper.saveUser(user);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> registerAsDoctor(
    String name,
    String phone,
    String email,
    String password,
    String gender,
  ) async {
    final newUser = User(
      id: '',
      name: name,
      phone: phone,
      email: email,
      password: password,
      gender: gender,
      role: 'doctor',
      isProfileComplete: false,
    );

    // Try Firebase registration first, but fallback to local registration if unavailable.
    final user = await _firebaseService.signUpAsDoctor(
      email,
      password,
      newUser,
    );
    if (user != null) {
      _currentUser = user;
      await _dbHelper.saveUser(user);
      notifyListeners();
      return true;
    }

    // Local-only fallback registration when Firebase is not configured or unavailable.
    newUser.id = DateTime.now().millisecondsSinceEpoch.toString();
    _currentUser = newUser;
    await _dbHelper.saveUser(newUser);
    notifyListeners();
    return true;
  }

  Future<bool> inviteDoctorFromHospital({
    required String name,
    required String specialty,
    required String email,
  }) async {
    final hospitalId = _selectedHospitalId;
    if (hospitalId == null || !_isHospitalAdmin()) {
      return false;
    }

    final tempPassword =
        'Temp#${DateTime.now().millisecondsSinceEpoch % 1000000}';
    final newUser = User(
      id: '',
      name: name,
      phone: '',
      email: email,
      password: tempPassword,
      gender: 'غير محدد',
      role: 'doctor',
      hospitalId: hospitalId,
      isProfileComplete: false,
    );

    final user = await _firebaseService.signUpAsDoctor(
      email,
      tempPassword,
      newUser,
    );

    if (user == null) {
      return false;
    }

    await _firebaseService.sendPasswordResetEmail(email);

    final doctorProfile = Doctor(
      id: user.id,
      name: name,
      specialty: specialty,
      imageUrl:
          'https://images.unsplash.com/photo-1580281657521-7251464dbab2?auto=format&fit=crop&w=400&q=80',
      rating: 4.8,
      reviewCount: 0,
      location: 'الرياض',
      phone: '',
      experience: 'خبرة سابقة',
      price: 0,
      availableDays: ['السبت', 'الأحد'],
      bio: 'يرجى إكمال الملف الشخصي بعد تسجيل الدخول.',
      hospitalId: hospitalId,
      hospitalApproved: false,
      workingHours: 'لم يتم التحديد',
    );

    _doctors.add(doctorProfile);
    notifyListeners();
    return true;
  }

  bool _isHospitalAdmin() {
    return _currentUser?.role == 'hospital';
  }

  bool get isDoctor => _currentUser?.role == 'doctor';
  bool get isHospital => _currentUser?.role == 'hospital';
  bool get isPatient =>
      _currentUser?.role == 'patient' || _currentUser?.role == null;

  bool get isDoctorProfileComplete {
    if (_currentUser == null || _currentUser!.role != 'doctor') return true;
    return _currentUser!.isProfileComplete;
  }

  Future<void> completeDoctorProfile({
    required List<String> availableDays,
    required String workingHours,
    required double price,
    required String experience,
    required String bio,
    required String specialty,
  }) async {
    if (_currentUser == null || _currentUser!.role != 'doctor') return;

    // 1. Update the User profile properties locally and in Firestore
    _currentUser = User(
      id: _currentUser!.id,
      name: _currentUser!.name,
      phone: _currentUser!.phone,
      email: _currentUser!.email,
      password: _currentUser!.password,
      gender: _currentUser!.gender,
      role: _currentUser!.role,
      hospitalId: _currentUser!.hospitalId,
      isProfileComplete: true,
    );
    await _dbHelper.saveUser(_currentUser!);
    await _firebaseService.saveUserData(_currentUser!);

    // 2. Build and update the Doctor profile
    final currentDoc = currentDoctorProfile;
    final updatedDoc = Doctor(
      id: _currentUser!.id,
      name: currentDoc?.name ?? _currentUser!.name,
      specialty: specialty.isNotEmpty ? specialty : (currentDoc?.specialty ?? 'طب عام'),
      imageUrl: currentDoc?.imageUrl ?? 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?q=80&w=2070&auto=format&fit=crop',
      rating: currentDoc?.rating ?? 5.0,
      reviewCount: currentDoc?.reviewCount ?? 0,
      location: currentDoc?.location ?? 'الرياض',
      phone: _currentUser!.phone,
      experience: experience.isNotEmpty ? experience : (currentDoc?.experience ?? 'خبرة سابقة'),
      price: price,
      availableDays: availableDays,
      bio: bio.isNotEmpty ? bio : (currentDoc?.bio ?? 'طبيب ممارس.'),
      workingHours: workingHours,
      hospitalId: _currentUser!.hospitalId,
      hospitalApproved: currentDoc?.hospitalApproved ?? false,
    );

    updateDoctorProfile(updatedDoc);
    await _firebaseService.saveDoctorProfile(updatedDoc);
    notifyListeners();
  }

  bool get isDoctorApproved => currentDoctorProfile?.hospitalApproved ?? false;

  List<Doctor> get approvedDoctors =>
      _doctors.where((d) => d.hospitalApproved).toList();

  List<Doctor> getPendingDoctorsForHospital(String hospitalId) {
    return _doctors
        .where((d) => d.hospitalId == hospitalId && !d.hospitalApproved)
        .toList();
  }

  void setDoctorHospitalApproval(String doctorId, bool approved) {
    final index = _doctors.indexWhere((d) => d.id == doctorId);
    if (index == -1) return;

    final doctor = _doctors[index];
    _doctors[index] = Doctor(
      id: doctor.id,
      name: doctor.name,
      specialty: doctor.specialty,
      imageUrl: doctor.imageUrl,
      rating: doctor.rating,
      reviewCount: doctor.reviewCount,
      location: doctor.location,
      phone: doctor.phone,
      experience: doctor.experience,
      price: doctor.price,
      availableDays: doctor.availableDays,
      bio: doctor.bio,
      workingHours: doctor.workingHours,
      hospitalId: doctor.hospitalId,
      hospitalApproved: approved,
    );
    notifyListeners();
  }

  List<Doctor> getDoctorsForHospital(String hospitalId) {
    return _doctors
        .where((d) => d.hospitalId == hospitalId && d.hospitalApproved)
        .toList();
  }

  Map<String, String>? getHospitalById(String hospitalId) {
    for (final hospital in _hospitals) {
      if (hospital['id'] == hospitalId) return hospital;
    }
    return null;
  }

  Map<String, bool> get doctorPermissions =>
      Map.unmodifiable(_doctorPermissions);

  void setDoctorPermission(String permission, bool value) {
    if (_doctorPermissions.containsKey(permission)) {
      _doctorPermissions[permission] = value;
      notifyListeners();
    }
  }

  List<Doctor> getDoctorsBySpecialty(String specialty) {
    if (specialty == 'الكل') return _doctors;
    return _doctors.where((d) => d.specialty == specialty).toList();
  }

  List<Doctor> getDoctorsWithChats() {
    final doctorsWithLastTime = _doctorChats.entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) {
          final doctor = _doctors.firstWhere(
            (d) => d.id == entry.key,
            orElse: () => _doctors.first,
          );
          final lastTime = entry.value.last.sentAt;
          return {'doctor': doctor, 'lastTime': lastTime};
        })
        .toList();

    doctorsWithLastTime.sort(
      (a, b) =>
          (b['lastTime'] as DateTime).compareTo(a['lastTime'] as DateTime),
    );
    return doctorsWithLastTime.map((e) => e['doctor'] as Doctor).toList();
  }

  List<ChatMessage> getMessagesForDoctor(String doctorId) {
    return List.unmodifiable(_doctorChats[doctorId] ?? []);
  }

  ChatMessage? getLastMessageForDoctor(String doctorId) {
    final messages = _doctorChats[doctorId];
    if (messages == null || messages.isEmpty) return null;
    return messages.last;
  }

  int getUnreadCountForDoctor(String doctorId) {
    final messages = _doctorChats[doctorId] ?? [];
    return messages.where((m) => !m.isFromUser && !m.isRead).length;
  }

  int getTotalUnreadCount() {
    return _doctorChats.keys.fold<int>(
      0,
      (sum, doctorId) => sum + getUnreadCountForDoctor(doctorId),
    );
  }

  void markConversationAsRead(String doctorId) {
    final messages = _doctorChats[doctorId];
    if (messages == null || messages.isEmpty) return;

    bool changed = false;
    final updated = messages.map((m) {
      if (!m.isFromUser && !m.isRead) {
        changed = true;
        return ChatMessage(
          id: m.id,
          doctorId: m.doctorId,
          text: m.text,
          isFromUser: m.isFromUser,
          sentAt: m.sentAt,
          isRead: true,
        );
      }
      return m;
    }).toList();

    if (changed) {
      _doctorChats[doctorId] = updated;
      notifyListeners();
    }
  }

  void startConversationWithDoctor(Doctor doctor) {
    final messages = _doctorChats.putIfAbsent(doctor.id, () => []);
    if (messages.isEmpty) {
      messages.add(
        ChatMessage(
          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
          doctorId: doctor.id,
          text: 'مرحباً، أنا ${doctor.name}. كيف أقدر أساعدك؟',
          isFromUser: false,
          sentAt: DateTime.now(),
          isRead: false,
        ),
      );
      notifyListeners();
    }
  }

  void sendMessageToDoctor({required Doctor doctor, required String text}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final messages = _doctorChats.putIfAbsent(doctor.id, () => []);
    messages.add(
      ChatMessage(
        id: 'm_${DateTime.now().millisecondsSinceEpoch}',
        doctorId: doctor.id,
        text: trimmed,
        isFromUser: true,
        sentAt: DateTime.now(),
        isRead: true,
      ),
    );
    notifyListeners();

    // Simulate a quick doctor response for demo mode.
    Future.delayed(const Duration(milliseconds: 800), () {
      final activeMessages = _doctorChats.putIfAbsent(doctor.id, () => []);
      activeMessages.add(
        ChatMessage(
          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
          doctorId: doctor.id,
          text: 'تم استلام رسالتك، وسأرد عليك بأقرب وقت.',
          isFromUser: false,
          sentAt: DateTime.now(),
          isRead: false,
        ),
      );
      notifyListeners();
    });
  }
}
