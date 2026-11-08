import 'package:flutter/material.dart';

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final String location;
  final String phone;
  final String experience;
  final double price;
  final List<String> availableDays;
  final String bio;
  final String workingHours;
  final String? hospitalId;
  final bool hospitalApproved;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.location,
    this.phone = '',
    required this.experience,
    required this.price,
    required this.availableDays,
    required this.bio,
    this.hospitalId,
    this.hospitalApproved = false,
    this.workingHours = '09:00 ص - 05:00 م',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'location': location,
      'phone': phone,
      'experience': experience,
      'price': price,
      'availableDays': availableDays.join(','),
      'bio': bio,
      'workingHours': workingHours,
      'hospitalId': hospitalId,
      'hospitalApproved': hospitalApproved ? 1 : 0,
    };
  }

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'],
      name: map['name'],
      specialty: map['specialty'],
      imageUrl: map['imageUrl'],
      rating: map['rating'],
      reviewCount: map['reviewCount'],
      location: map['location'],
      experience: map['experience'],
      price: map['price'],
      availableDays: map['availableDays'].toString().split(','),
      bio: map['bio'],
      phone: map['phone'] ?? '',
      hospitalId: map['hospitalId'],
      hospitalApproved: map['hospitalApproved'] == 1,
      workingHours: map['workingHours'] ?? '09:00 ص - 05:00 م',
    );
  }
}

class Appointment {
  final String id;
  final String userId; // added for Firestore
  final String bookingId;
  final String businessName;
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final String status;
  final String imageUrl;
  final double? price;
  final bool isHistory;
  final String? appointmentType;

  Appointment({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.businessName,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
    required this.imageUrl,
    this.price,
    this.isHistory = false,
    this.appointmentType,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'bookingId': bookingId,
      'businessName': businessName,
      'doctorName': doctorName,
      'specialty': specialty,
      'date': date,
      'time': time,
      'status': status,
      'imageUrl': imageUrl,
      'price': price,
      'isHistory': isHistory ? 1 : 0,
      'appointmentType': appointmentType,
    };
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      userId: map['userId'] ?? '',
      bookingId: map['bookingId'],
      businessName: map['businessName'],
      doctorName: map['doctorName'],
      specialty: map['specialty'],
      date: map['date'],
      time: map['time'],
      status: map['status'],
      imageUrl: map['imageUrl'],
      price: map['price'],
      isHistory: map['isHistory'] == 1,
      appointmentType: map['appointmentType'],
    );
  }
}

class ChatMessage {
  final String id;
  final String doctorId;
  final String text;
  final bool isFromUser;
  final DateTime sentAt;
  final bool isRead;

  ChatMessage({
    required this.id,
    required this.doctorId,
    required this.text,
    required this.isFromUser,
    required this.sentAt,
    this.isRead = false,
  });
}

class User {
  String id;
  final String name;
  final String phone;
  final String email;
  final String password;
  final String gender;
  final String role; // 'patient', 'doctor', or 'hospital'
  final String? hospitalId;
  final bool isProfileComplete;

  User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.gender,
    this.role = 'patient', // default to patient
    this.hospitalId,
    this.isProfileComplete = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
      'gender': gender,
      'role': role,
      'hospitalId': hospitalId,
      'isProfileComplete': isProfileComplete ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'] ?? '',
      password: map['password'],
      gender: map['gender'],
      role: map['role'] ?? 'patient',
      hospitalId: map['hospitalId'],
      isProfileComplete: map['isProfileComplete'] == null
          ? true
          : (map['isProfileComplete'] == 1 || map['isProfileComplete'] == true),
    );
  }
}

class Discount {
  final String title;
  final String description;
  final String imageUrl;
  final Color? startColor;
  final Color? endColor;

  Discount({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.startColor,
    this.endColor,
  });

  Discount copyWith({
    String? title,
    String? description,
    String? imageUrl,
    Color? startColor,
    Color? endColor,
  }) {
    return Discount(
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      startColor: startColor ?? this.startColor,
      endColor: endColor ?? this.endColor,
    );
  }
}
