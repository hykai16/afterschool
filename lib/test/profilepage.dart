import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/firebase_service.dart';
import '../utils/userdata.dart';

class ProfileInputScreen extends StatefulWidget {
  @override
  _ProfileInputScreenState createState() => _ProfileInputScreenState();
}

class _ProfileInputScreenState extends State<ProfileInputScreen> {
  // ユーザーが入力するプロフィールデータを保持する変数
  late String _name;
  late String _grade;
  late String _iconImageUrl;
  late String _location;
  late String _bio;
  late String _userID;

  // プロフィールデータをFirebaseに保存するメソッド
  void _saveProfile() async{
    final firebaseService = FirebaseService();
    final user = FirebaseAuth.instance.currentUser!;
    _userID = user.uid; // ログイン中のユーザーのIDがとれます
    _iconImageUrl = user.photoURL!; // Googleアカウントのアイコンデータがとれます

    final userProfile = UserProfile(
      name: _name,
      grade: _grade,
      iconImageUrl: _iconImageUrl,
      location: _location,
      bio: _bio,
      userID: _userID,
      reference: firebaseService.getUserProfileReference(_userID),
    );

    // TODO: Firebaseにプロフィールデータを保存するロジックを追加
    // プロフィールデータをFirebaseに保存
    await firebaseService.saveUserProfile(userProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('プロフィール入力'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: '名前'),
              onChanged: (value) => _name = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '学年'),
              onChanged: (value) => _grade = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '住んでいる地域'),
              onChanged: (value) => _location = value,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '自己紹介文'),
              onChanged: (value) => _bio = value,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}

