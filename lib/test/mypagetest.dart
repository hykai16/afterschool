import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyPagedayo extends StatefulWidget {
  const MyPagedayo({super.key});

  @override
  State<MyPagedayo> createState() => _MyPagedayoState();
}

class _MyPagedayoState extends State<MyPagedayo> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  List<Map<String, dynamic>> _profileData = []; // プロフィールデータを格納するリスト

  @override
  void initState() {
    super.initState();
    _getProfileData(); // 初期化時にデータを取得
  }

  Future<void> _getProfileData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('profiles')
          .where('userID', isEqualTo: userId)
          .get();

      setState(() {
        print(userId);
        _profileData = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        print(_profileData);
      });
    } catch (error) {
      // エラー処理
      print("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Page'),
      ),
      body: Column(
        children: [
          // ここにデータを表示するUIを構築するコードを追加
          // 例: ListView.builderやColumnなどを使ってデータを表示
          if (_profileData.isEmpty) // データがない場合の表示
            CircularProgressIndicator()
          else
            Expanded(
              child: ListView.builder(
                itemCount: _profileData.length,
                itemBuilder: (context, index) {
                  final data = _profileData[index];
                  return ListTile(
                    title: Text(data['name']),
                    // 他のデータを表示する部分も追加
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
