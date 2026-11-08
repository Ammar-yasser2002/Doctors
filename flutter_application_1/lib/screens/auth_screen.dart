import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_application_1/providers/app_provider.dart';
import 'package:flutter_application_1/screens/main_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerPhoneController =
      TextEditingController();
  final TextEditingController _registerEmailController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final List<String> _genderOptions = ['ذكر', 'أنثى', 'غير محدد'];
  String _selectedGender = 'ذكر';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerPhoneController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(context, 'يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await context.read<AppProvider>().signInWithEmail(
        email,
        password,
      );
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        _showSnackBar(
          context,
          'فشل تسجيل الدخول. تحقق من البيانات وحاول مرة أخرى',
        );
      }
    } catch (e) {
      _showSnackBar(context, _getAuthErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getAuthErrorMessage(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'لا يوجد حساب مسجل بهذا البريد الإلكتروني.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'بيانات تسجيل الدخول غير صحيحة (تحقق من البريد وكلمة المرور).';
        case 'email-already-in-use':
          return 'هذا البريد الإلكتروني مسجل بالفعل لمستخدم آخر.';
        case 'invalid-email':
          return 'صيغة البريد الإلكتروني غير صالحة.';
        case 'weak-password':
          return 'كلمة المرور ضعيفة جداً (يجب ألا تقل عن 6 أحرف/أرقام).';
        case 'operation-not-allowed':
          return 'طريقة تسجيل الدخول بالبريد غير مفعلة في لوحة تحكم Firebase Console.';
        case 'network-request-failed':
          return 'تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت.';
        case 'too-many-requests':
          return 'تم حظر المحاولات مؤقتاً بسبب كثرة الطلبات. يرجى المحاولة بعد قليل.';
        default:
          return error.message ?? 'حدث خطأ في عملية المصادقة.';
      }
    }
    return 'حدث خطأ: $error';
  }

  Future<void> _register(BuildContext context) async {
    final name = _registerNameController.text.trim();
    final phone = _registerPhoneController.text.trim();
    final email = _registerEmailController.text.trim();
    final password = _registerPasswordController.text;
    final gender = _selectedGender;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar(
        context,
        'يرجى إدخال الاسم والبريد الإلكتروني وكلمة المرور',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await context.read<AppProvider>().registerWithEmail(
        name,
        phone,
        email,
        password,
        gender,
      );
      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        _showSnackBar(context, 'فشل إنشاء الحساب. حاول مرة أخرى');
      }
    } catch (e) {
      _showSnackBar(context, _getAuthErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendPasswordReset(BuildContext context) async {
    final email = _loginEmailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar(context, 'يرجى إدخال البريد الإلكتروني لإعادة التعيين');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await context.read<AppProvider>().resetPassword(email);
    setState(() {
      _isLoading = false;
    });

    if (success) {
      _showSnackBar(
        context,
        'تم إرسال رابط إعادة تعيين كلمة المرور إلى البريد الإلكتروني إذا كان الحساب موجوداً',
      );
    } else {
      _showSnackBar(context, 'فشل إرسال البريد. حاول مرة أخرى لاحقاً');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      appBar: AppBar(
        title: const Text(
          'تسجيل الدخول / إنشاء حساب',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: const Color(0xFF1E88E5),
              ),
              tabs: const [
                Tab(text: 'تسجيل الدخول'),
                Tab(text: 'إنشاء حساب'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildLoginTab(context), _buildRegisterTab(context)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _loginEmailController,
            label: 'البريد الإلكتروني',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _loginPasswordController,
            label: 'كلمة المرور',
            obscureText: true,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading ? null : () => _sendPasswordReset(context),
              child: const Text(
                'نسيت كلمة المرور؟',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _login(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterTab(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _registerNameController,
            label: 'الاسم الكامل',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _registerPhoneController,
            label: 'رقم الهاتف',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _registerEmailController,
            label: 'البريد الإلكتروني',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _registerPasswordController,
            label: 'كلمة المرور',
            obscureText: true,
          ),
          const SizedBox(height: 12),
          InputDecorator(
            decoration: InputDecoration(
              labelText: 'الجنس',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGender,
                isExpanded: true,
                items: _genderOptions
                    .map(
                      (gender) => DropdownMenuItem(
                        value: gender,
                        child: Text(
                          gender,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGender = value;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _register(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'إنشاء حساب',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
