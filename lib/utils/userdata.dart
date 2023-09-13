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
    required this.hobby,
    required this.school,
    required this.favsubject,
    required this.reference,
    required this.lastLoginTime, // 追加: 最終ログイン時間
    required this.dailyStudyTime, // 追加: デイリーの学習時間
    required this.totalStudyTime, // 追加: これまでのトータル学習時間
    // required this.friendRequests,
    // required this.friends,
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
      hobby: map['hobby'],
      school: map['school'],
      favsubject: map['favsubject'],
      reference: snapshot.reference, // 注意。reference は map ではなく snapshot に入っています。
      lastLoginTime: map['lastLoginTime'], // 追加: 最終ログイン時間
      dailyStudyTime: map['dailyStudyTime'], // 追加: デイリーの学習時間
      totalStudyTime: map['totalStudyTime'], // 追加: これまでのトータル学習時間
      // friendRequests:map['friendRequests'],
      //   friends:map['friends']
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
      'hobby': hobby,
      'school': school,
      'favsubject': favsubject,
      'lastLoginTime':lastLoginTime,
      'dailyStudyTime':dailyStudyTime,
      'totalStudyTime':totalStudyTime,
      // 'friendRequests':friendRequests,
      // 'friends':friends,
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

  final String hobby;

  final String school;

  final String favsubject;

  /// Firestoreのどこにデータが存在するかを表すpath情報
  final DocumentReference reference;

  final Timestamp lastLoginTime; // 追加: 最終ログイン時間
  final int dailyStudyTime; // 追加: デイリーの学習時間（例: 分単位）
  final int totalStudyTime; // 追加: これまでのトータル学習時間（例: 分単位）

  // // フレンドリクエスト一覧
  // final List<String> friendRequests;
  //
  // // フレンドリスト
  // final List<String> friends;

  // // フレンドリクエストを送信
  // Future<void> sendFriendRequest(String userId) async {
  //   // Firestoreにフレンドリクエストを追加する処理
  // }
  //
  // // フレンドリクエストを受信
  // Future<void> acceptFriendRequest(String userId) async {
  //   // フレンドリクエストを承認してFirestoreのデータを更新する処理
  // }
  //
  // // フレンドリストからユーザーを削除
  // Future<void> removeFriend(String userId) async {
  //   // Firestoreからフレンドを削除する処理
  // }
}
