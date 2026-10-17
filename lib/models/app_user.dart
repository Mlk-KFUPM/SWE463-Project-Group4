import 'package:cloud_firestore/cloud_firestore.dart';

/// A Sufrah account, stored in the `users` collection.
/// The document id is the Firebase Auth uid. The email is not stored here
/// because other users read this document; S6 gets it from Firebase Auth.
/// Saves and likes live in the user's `saves` and `likes` subcollections.
class AppUser {
  final String id;
  final String name;
  final DateTime createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  /// First letter of the name, shown in the avatar circle.
  String get initial => name.isEmpty ? '?' : name[0].toUpperCase();

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      name: map['name'] as String? ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppUser copyWith({String? name}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
    );
  }
}
