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
  final TextEditingController _passcodeController = TextEditingController();

  bool publicSetting = true;
  bool error = false;
  String errorText = "未入力の箇所があります";

  bool areAllFieldsFilled() {
    return _titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        !publicSetting || (!_passcodeController.text.isNotEmpty || _passcodeController.text.length == 4); // パスコードが空でないかつ4桁であることを確認
  }

  void _createChatRoom(BuildContext context) async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final passcord = _passcodeController.text;
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
        'passcode': passcord,
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
        passcode: passcord,
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
        title: const Text('新しいチャットルーム作成'),
        backgroundColor: GlobalColors.mainColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'タイトル'),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: '説明'),
            ),
            const SizedBox(height: 16.0),
            ListTile(
              leading: null,
              title: const Text("公開 / 非公開"),
              trailing: CupertinoSwitch(
                value: publicSetting,
                onChanged: (newValue) {
                  setState(() {
                    publicSetting = newValue;
                  });
                },
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // もし showPasscodeField が true の場合にのみ表示
                if (!publicSetting)
                  TextFormField(
                    controller: _passcodeController,
                    decoration: const InputDecoration(labelText: '4桁のパスコードを入力してください'),
                    keyboardType: TextInputType.number, // 数字のみ入力可能にする
                    maxLength: 4, // 4桁のみ入力可能にする
                  ),
                const SizedBox(height: 16.0),
              ],
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: (){
                if (areAllFieldsFilled()) {
                  _createChatRoom(context);
                } else {
                  error = true;
                  setState(() {});
                }
              },
              child: const Text('作成'),
            ),
            Text(
              error? errorText : "",
              style: const TextStyle(
                color:Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



