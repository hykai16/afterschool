import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  UserProfile({
    required this.name,
    required this.grade,
    required this.iconImageUrl,
    required this.location,
    required this.bio,
    required this.userID,
    required this.reference,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final map = snapshot.data()!; // data() の中には Map 型のデータが入っています。
    // data()! この ! 記号は nullable な型を non-nullable として扱うよ！ という意味です。
    // data の中身はかならず入っているだろうという仮説のもと ! をつけています。
    // map データが得られているのでここからはいつもと同じです。
    return UserProfile(
      name: map['name'],
      grade: map['grade'],
      iconImageUrl: map['iconImageUrl'],
      location: map['location'],
      bio: map['bio'],
      userID: map['userID'],
      reference: snapshot.reference, // 注意。reference は map ではなく snapshot に入っています。
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'grade': grade,
      'iconImageUrl': iconImageUrl,
      'location': location,
      'bio': bio,
      'userID':userID,
      // 'reference': reference, reference は field に含めなくてよい
      // field に含めなくても DocumentSnapshot に reference が存在するため
    };
  }

  final String name;

  final String grade;

  final String iconImageUrl;

  final String location;

  final String bio;

  final String userID;

  /// Firestoreのどこにデータが存在するかを表すpath情報
  final DocumentReference reference;
}