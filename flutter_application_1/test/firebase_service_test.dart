import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/data/firebase_service.dart';

void main() {
  test('buildUserFromAuthProfile uses fallback email and defaults', () {
    final user = FirebaseService.buildUserFromAuthProfile(
      uid: 'abc123',
      displayName: null,
      phoneNumber: null,
      email: null,
      fallbackEmail: 'doctor@example.com',
    );

    expect(user.id, 'abc123');
    expect(user.email, 'doctor@example.com');
    expect(user.name, '');
    expect(user.gender, 'غير محدد');
  });
}
