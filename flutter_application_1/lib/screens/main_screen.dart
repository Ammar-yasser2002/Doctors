import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/appointments_screen.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/messages_screen.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'package:flutter_application_1/screens/doctor_dashboard_screen.dart';
import 'package:flutter_application_1/screens/hospital_dashboard_screen.dart';
import 'package:flutter_application_1/screens/doctor_onboarding_screen.dart';
import 'package:flutter_application_1/widgets/premium_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/app_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final isDoctor = provider.isDoctor;
        final isHospital = provider.isHospital;
        final isProfileComplete = provider.isDoctorProfileComplete;

        if (isDoctor && !isProfileComplete) {
          return const DoctorOnboardingScreen();
        }
        final screens = isHospital
            ? [
                const HospitalDashboardScreen(),
                const MessagesScreen(),
                const AppointmentsScreen(),
                const ProfileScreen(),
              ]
            : isDoctor
            ? [
                const DoctorDashboardScreen(),
                const MessagesScreen(),
                const AppointmentsScreen(),
                const ProfileScreen(),
              ]
            : [
                const HomeScreen(),
                const MessagesScreen(),
                const AppointmentsScreen(),
                const ProfileScreen(),
              ];

        return Scaffold(
          extendBody: true,
          body: screens[provider.currentTabIndex],
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: PremiumNavBar(
                    currentIndex: provider.currentTabIndex,
                    onTap: (index) => provider.setTabIndex(index),
                    items: isHospital
                        ? [
                            NavBarItem(
                              icon: Icons.local_hospital,
                              label: 'المستشفى',
                            ),
                            NavBarItem(icon: Icons.message, label: 'الرسائل'),
                            NavBarItem(
                              icon: Icons.calendar_today,
                              label: 'المواعيد',
                            ),
                            NavBarItem(
                              icon: Icons.person,
                              label: 'الملف الشخصي',
                            ),
                          ]
                        : isDoctor
                        ? [
                            NavBarItem(
                              icon: Icons.dashboard,
                              label: 'لوحة التحكم',
                            ),
                            NavBarItem(icon: Icons.message, label: 'الرسائل'),
                            NavBarItem(
                              icon: Icons.calendar_today,
                              label: 'المواعيد',
                            ),
                            NavBarItem(
                              icon: Icons.person,
                              label: 'الملف الشخصي',
                            ),
                          ]
                        : [
                            NavBarItem(icon: Icons.home, label: 'الرئيسية'),
                            NavBarItem(icon: Icons.message, label: 'الرسائل'),
                            NavBarItem(
                              icon: Icons.calendar_today,
                              label: 'المواعيد',
                            ),
                            NavBarItem(
                              icon: Icons.person,
                              label: 'الملف الشخصي',
                            ),
                          ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
