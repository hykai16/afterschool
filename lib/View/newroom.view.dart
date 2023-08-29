import 'package:afterschool/utils/chatroomdata.dart';
import 'package:afterschool/utils/global.colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/firebase_service.dart';

class CreateNewRoom extends StatefulWidget {
  const CreateNewRoom({super.key});

  @override
  State<CreateNewRoom> createState() => _CreateNewRoomState();
}

class _CreateNewRoomState extends State<CreateNewRoom> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool publicSetting = true;

  void _createChatRoom(BuildContext context) async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    late String userID;
    late String currentUser;

    if (title.isNotEmpty && description.isNotEmpty) {
      final firebaseService = FirebaseService();
      final user = FirebaseAuth.instance.currentUser!;
      userID = user.uid; // ログイン中のユーザーのIDがとれます
      currentUser = user.displayName!;

      // Firestoreのコレクション参照を取得
      CollectionReference chatRoomsCollection = FirebaseFirestore.instance.collection('chatRooms');

      // 新しいチャットルームのドキュメントを作成
      DocumentReference newChatRoomRef = await chatRoomsCollection.add({
        'title': title,
        'introduce': description,
        'creator': currentUser,
        'participants': [],
        'public': publicSetting,
        'createdAt': Timestamp.now(),
        // 他のフィールドも初期値を設定
      });

      // seatsコレクションへの参照を取得
      CollectionReference seatsCollection = newChatRoomRef.collection('seats');

      // 新しいチャットルームのインスタンスを作成
      final chatRoom = ChatRoom(
        id: newChatRoomRef.id,
        title: title,
        introduce: description,
        creator: currentUser,
        participants: [],
        public: publicSetting,
        createdAt: Timestamp.now(),
        reference: newChatRoomRef,
        seatsRef: seatsCollection, // seatsコレクションへの参照をセット
      );

      //ファイアーベースに登録
      await firebaseService.createNewRoom(chatRoom);

      // チャットルーム作成後に前の画面に戻る
      //TODO:画面更新されないのをなんとかする
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('新しいチャットルーム作成'),
        backgroundColor: GlobalColors.mainColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'タイトル'),
            ),
            SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: '説明'),
            ),
            SizedBox(height: 16.0),
            ListTile(
              leading: null,
              title: Text("公開 / 非公開"),
              trailing: CupertinoSwitch(
                value: publicSetting,
                onChanged: (newValue) {
                  setState(() {
                    publicSetting = newValue;
                  });
                },
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _createChatRoom(context),
              child: Text('作成'),
            ),
          ],
        ),
      ),
    );
  }
}



