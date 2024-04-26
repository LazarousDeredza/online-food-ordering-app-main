import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNo;
  final String password;
  final String? level;
  final String? image;
  final List? groups;
  final String? createdAt;
  final List instGroups;
  final String about;
  final bool isOnline;
  final String lastActive;
  final String pushToken;

  const UserModel({
    this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNo,
    required this.password,
    required this.instGroups,
    this.level,
    this.groups,
    this.image,
    this.createdAt,
    required this.about,
    required this.isOnline,
    required this.lastActive,
    required this.pushToken,
  });

  toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'name': name,
      'email': email,
      'phone': phoneNo,
      'password': password,
      'level': level,
      'groups': groups,
      'instGroups': instGroups,
      'image': image,
      'created_at': createdAt,
      'about': about,
      'is_online': isOnline,
      'last_active': lastActive,
      'push_token': pushToken,
    };
  }

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    return UserModel(
      id: document.id,
      firstName: document.data()!['firstName'],
      lastName: document.data()!['lastName'],
      name: document.data()!['name'],
      email: document.data()!['email'],
      phoneNo: document.data()!['phone'],
      password: document.data()!['password'],
      level: document.data()!['level'],
      groups: document.data()!['groups'],
      instGroups: document.data()!['instGroups'],
      image: document.data()!['image'],
      createdAt: document.data()!['created_at'],
      about: document.data()!['about'] ?? '',
      isOnline: document.data()!['is_online'],
      lastActive: document.data()!['last_active'],
      pushToken: document.data()!['push_token'],
    );
  }
}
