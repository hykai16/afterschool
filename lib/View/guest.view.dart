import 'dart:math';

import 'package:afterschool/View/home.view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  late String _grade;
  late String _iconImageUrl;
  late String _location;
  late String _bio;
  late String _userID;
  String selectedvalue = "中学1年";
  String defaultIconURL = "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.veryicon.com%2Ficons%2Fmiscellaneous%2Fyouyinzhibo%2Fguest.html&psig=AOvVaw0rpKrksIpZuD53rxkybiUO&ust=1692921289644000&source=images&cd=vfe&opi=89978449&ved=0CBAQjRxqFwoTCLDdxbD984ADFQAAAAAdAAAAABAE";

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



  void _saveProfile() async{
    final firebaseService = FirebaseService();

    //TODO:そもそもcurrentUserは存在しないが、ゲストアカウントを生成したい
    final user = FirebaseAuth.instance.currentUser!;
    _userID = user.uid ?? generateRandomUserID(28); // もしuser.uidがnullなら'defaultUserID'を使う
    print(_userID);
    _iconImageUrl = user.photoURL ?? defaultIconURL; // もしuser.photoURLがnullなら'defaultIconURL'を使う


    final userProfile = UserProfile(
      name: _name,
      grade: _grade,
      iconImageUrl: _iconImageUrl,
      location: _location,
      bio: _bio,
      userID: _userID,
      reference: firebaseService.getUserProfileReference(_userID),
    );


    await firebaseService.saveUserProfile(userProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Text("after school",
                style: TextStyle(
                  color: GlobalColors.mainColor,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Dosis',
                ),
              ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '名前(必須)',),
                onChanged: (value) => _name = value,
              ),
              SizedBox(height: 10,),
              Text('学年(必須)',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),
              DropdownButton(
                value: selectedvalue,
                items: const [
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
                ], onChanged: (String? value) {
                setState(() {
                  selectedvalue = value!;
                  _grade = value!;
                });
              },
                underline: Container(
                  height: 1,
                  color: Colors.black38,
                ),

              ),
              TextFormField(
                decoration: InputDecoration(labelText: '住んでいる地域(必須)'),
                onChanged: (value) => _location = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '自己紹介文'),
                onChanged: (value) => _bio = value,
              ),
              SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: GlobalColors.mainColor,
                  ),
                  onPressed:() {
                    _saveProfile();
                    print("ああああああああああああああ");
                    Get.to(()=>HomeView());
                  },
                  child: Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}