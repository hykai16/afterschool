// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/firebase_service.dart';
import '../utils/global.colors.dart';
import '../utils/userdata.dart';

class ProfileInputScreen extends StatefulWidget {
  const ProfileInputScreen({super.key});

  @override
  _ProfileInputScreenState createState() => _ProfileInputScreenState();
}

class _ProfileInputScreenState extends State<ProfileInputScreen> {
  // ユーザーが入力するプロフィールデータを保持する変数
  late String _name;
  String _grade = '中学1年';
  late String _iconImageUrl;
  late String _location;
  late String _bio;
  late String _userID;
  late String _hobby;
  late String _school;
  late String _favsubject;

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
      hobby: _hobby,
      school: _school,
      favsubject: _favsubject,
      reference: firebaseService.getUserProfileReference(_userID),
      lastLoginTime:Timestamp.now(), // 追加: 最終ログイン時間
      dailyStudyTime:0, // 追加: デイリーの学習時間（例: 分単位）
      totalStudyTime:0, // 追加: これまでのトータル学習時間（例: 分単位）
      // friendRequests: [],
      // friends: [],
    );
    // プロフィールデータをFirebaseに保存
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
                    Padding(
                      padding: const EdgeInsets.only(right: 250),
                      child: IconButton(onPressed: (){
                        Navigator.pop(context);
                      }, icon: Icon(Icons.navigate_before_rounded,
                        color: GlobalColors.mainColor,),),
                    ),
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
                            _saveProfile();
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
    // return Scaffold(
    //   body: SingleChildScrollView(
    //     padding: const EdgeInsets.all(16.0),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         TextFormField(
    //           decoration: const InputDecoration(labelText: '名前'),
    //           onChanged: (value) => _name = value,
    //         ),
    //         TextFormField(
    //           decoration: const InputDecoration(labelText: '学年'),
    //           onChanged: (value) => _grade = value,
    //         ),
    //         TextFormField(
    //           decoration: const InputDecoration(labelText: '趣味'),
    //           onChanged: (value) => _hobby = value,
    //         ),
    //         TextFormField(
    //           decoration: const InputDecoration(labelText: '通っている学校'),
    //           onChanged: (value) => _school = value,
    //         ),
    //         TextFormField(
    //           decoration: const InputDecoration(labelText: '得意科目'),
    //           onChanged: (value) => _favsubject = value,
    //         ),
    //         TextFormField(
    //           decoration: const InputDecoration(labelText: '自己紹介文'),
    //           onChanged: (value) => _bio = value,
    //         ),
    //         const SizedBox(height: 16.0),
    //         ElevatedButton(
    //           onPressed: _saveProfile,
    //           child: const Text('保存'),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}

