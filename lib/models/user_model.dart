import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final int age;
  final String gender;
  final String college;
  final String major;
  final String year;
  final String bio;
  final List<String> interests;
  final List<String> photoUrls;
  final String? profilePicUrl;
  final String? bannerUrl;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime createdAt;
  final List<String> likedUsers;
  final List<String> dislikedUsers;
  final List<String> matches;
  final List<String> superLikedUsers;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.age,
    required this.gender,
    required this.college,
    required this.major,
    required this.year,
    required this.bio,
    required this.interests,
    required this.photoUrls,
    this.profilePicUrl,
    this.bannerUrl,
    this.isVerified = false,
    this.isOnline = false,
    this.lastSeen,
    required this.createdAt,
    this.likedUsers = const [],
    this.dislikedUsers = const [],
    this.matches = const [],
    this.superLikedUsers = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'age': age,
      'gender': gender,
      'college': college,
      'major': major,
      'year': year,
      'bio': bio,
      'interests': interests,
      'photoUrls': photoUrls,
      'profilePicUrl': profilePicUrl,
      'bannerUrl': bannerUrl,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'lastSeen': lastSeen != null ? Timestamp.fromDate(lastSeen!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'likedUsers': likedUsers,
      'dislikedUsers': dislikedUsers,
      'matches': matches,
      'superLikedUsers': superLikedUsers,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 18,
      gender: map['gender'] ?? '',
      college: map['college'] ?? '',
      major: map['major'] ?? '',
      year: map['year'] ?? '',
      bio: map['bio'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
      profilePicUrl: map['profilePicUrl'],
      bannerUrl: map['bannerUrl'],
      isVerified: map['isVerified'] ?? false,
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null
          ? (map['lastSeen'] as Timestamp).toDate()
          : null,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      likedUsers: List<String>.from(map['likedUsers'] ?? []),
      dislikedUsers: List<String>.from(map['dislikedUsers'] ?? []),
      matches: List<String>.from(map['matches'] ?? []),
      superLikedUsers: List<String>.from(map['superLikedUsers'] ?? []),
    );
  }

  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    int? age,
    String? gender,
    String? college,
    String? major,
    String? year,
    String? bio,
    List<String>? interests,
    List<String>? photoUrls,
    String? profilePicUrl,
    String? bannerUrl,
    bool? isVerified,
    bool? isOnline,
    DateTime? lastSeen,
    DateTime? createdAt,
    List<String>? likedUsers,
    List<String>? dislikedUsers,
    List<String>? matches,
    List<String>? superLikedUsers,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      college: college ?? this.college,
      major: major ?? this.major,
      year: year ?? this.year,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      photoUrls: photoUrls ?? this.photoUrls,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      likedUsers: likedUsers ?? this.likedUsers,
      dislikedUsers: dislikedUsers ?? this.dislikedUsers,
      matches: matches ?? this.matches,
      superLikedUsers: superLikedUsers ?? this.superLikedUsers,
    );
  }
}