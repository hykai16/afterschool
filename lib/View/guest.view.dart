import 'dart:math';

import 'package:afterschool/View/home.view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import '../utils/firebase_service.dart';
import '../utils/global.colors.dart';
import '../utils/userdata.dart';

class ProfileInputScreen extends StatefulWidget {
  @override
  _ProfileInputScreenState createState() => _ProfileInputScreenState();
}

class _ProfileInputScreenState extends State<ProfileInputScreen> {
  late String _name;
  String _grade = "中学1年";
  late String _iconImageUrl;
  late String _location;
  late String _bio;
  late String _userID;
  late String _hobby;
  late String _school;
  late String _favsubject;
  String defaultIconURL =
      "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.veryicon.com%2Ficons%2Fmiscellaneous%2Fyouyinzhibo%2Fguest.html&psig=AOvVaw0rpKrksIpZuD53rxkybiUO&ust=1692921289644000&source=images&cd=vfe&opi=89978449&ved=0CBAQjRxqFwoTCLDdxbD984ADFQAAAAAdAAAAABAE";

  String generateRandomUserID(int length) {
    final random = Random();
    const String chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

    String result = "";
    for (int i = 0; i < length; i++) {
      int randomIndex = random.nextInt(chars.length);
      result += chars[randomIndex];
    }
    return result;
  }

  bool checkInputFields() {
    if (_name.isEmpty ||
        _location.isEmpty ||
        _bio.isEmpty ||
        _school.isEmpty ||
        _favsubject.isEmpty ||
        _hobby.isEmpty) {
      return false; // どれかの入力項目が空
    }
    return true; // 全ての入力項目が埋まっている
  }

  void _saveProfile() async {
    final firebaseService = FirebaseService();

    //TODO:そもそもcurrentUserは存在しないが、ゲストアカウントを生成したい
    final user = FirebaseAuth.instance.currentUser!;
    _userID = user.uid; // もしuser.uidがnullなら'defaultUserID'を使う
    print(_userID);
    _iconImageUrl = user.photoURL ??
        defaultIconURL; // もしuser.photoURLがnullなら'defaultIconURL'を使う

    final userProfile = UserProfile(
      name: _name,
      grade: _grade,
      iconImageUrl: _iconImageUrl,
      location: _location,
      bio: _bio,
      userID: _userID,
      hobby: _hobby,
      school: _school,
      favsubject: _favsubject,
      reference: firebaseService.getUserProfileReference(_userID),
      lastLoginTime: Timestamp.now(),
      // 追加: 最終ログイン時間
      dailyStudyTime: 0,
      // 追加: デイリーの学習時間（例: 分単位）
      totalStudyTime: 0, // 追加: これまでのトータル学習時間（例: 分単位）
      // friendRequests: [],
      // friends: [],
    );

    await firebaseService.saveUserProfile(userProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/profile3.png'),
              fit: BoxFit.fill
            )
          ),
        ),
        SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Column(
                  children: [
                    Center(
                      child: SizedBox(
                        width: 300,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                              labelText: 'name/名前',
                              labelStyle: TextStyle(
                                fontSize: 13
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(13),),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              )),
                          onChanged: (value) => _name = value,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 235),
                      child: Text(
                        'grade/学年',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 220),
                      child: DropdownButton(
                        value: _grade,
                        items: const [
                          DropdownMenuItem(
                            child: Text('小学4年'),
                            value: '小学4年',
                          ),
                          DropdownMenuItem(
                            child: Text('小学5年'),
                            value: '小学5年',
                          ),
                          DropdownMenuItem(
                            child: Text('小学6年'),
                            value: '小学6年',
                          ),
                          DropdownMenuItem(
                            child: Text('中学1年'),
                            value: '中学1年',
                          ),
                          DropdownMenuItem(
                            child: Text('中学2年'),
                            value: '中学2年',
                          ),
                          DropdownMenuItem(
                            child: Text('中学3年'),
                            value: '中学3年',
                          ),
                          DropdownMenuItem(
                            child: Text('高校1年'),
                            value: '高校1年',
                          ),
                          DropdownMenuItem(
                            child: Text('高校2年'),
                            value: '高校2年',
                          ),
                          DropdownMenuItem(
                            child: Text('高校3年'),
                            value: '高校3年',
                          ),
                          DropdownMenuItem(
                            child: Text('その他'),
                            value: 'その他',
                          ),
                        ],
                        onChanged: (String? value) {
                          setState(() {
                            _grade = value!;
                          });
                        },
                        underline: Container(
                          height: 1,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'city/住んでいる地域',
                          labelStyle: TextStyle(
                              fontSize: 13
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13)),
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (value) => _location = value,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'about yourself/自己紹介',
                          labelStyle: TextStyle(
                              fontSize: 13
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13)),
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (value) => _bio = value,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'school/通っている学校',
                          labelStyle: TextStyle(
                              fontSize: 13
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13)),
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (value) => _school = value,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'favorite subject/好きな科目',
                          labelStyle: TextStyle(
                              fontSize: 13
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13)),
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (value) => _favsubject = value,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: 300,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'hobby/趣味',
                          labelStyle: TextStyle(
                              fontSize: 13
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(13)),
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (value) => _hobby = value,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                      child: SizedBox(
                        width: 300,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            primary: GlobalColors.mainColor,
                          ),
                          onPressed: () {
                            if (checkInputFields()) {
                              _saveProfile();
                              Get.to(() => HomeView());
                            } else {
                              // 入力が完了していない場合の処理（エラーメッセージ表示など）
                              // 例えば、Snackbarを表示してユーザーに入力を促すことができます。
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('全ての入力項目を埋めてください。'),
                                ),
                              );
                            }
                          },
                          child: Text(
                            'save',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
