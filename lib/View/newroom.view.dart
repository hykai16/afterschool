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
            !publicSetting ||
        (!_passcodeController.text.isNotEmpty ||
            _passcodeController.text.length == 4); // パスコードが空でないかつ4桁であることを確認
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

      final newDocumentReference = FirebaseFirestore.instance
          .collection('chat_rooms') // チャットルームコレクションにアクセス
          .doc();

      final newSeatsReference = newDocumentReference.collection('seats');

      // 新しいチャットルームのインスタンスを作成
      final chatRoom = ChatRoom(
        id: userID,
        title: title,
        introduce: description,
        creator: currentUser,
        participants: [],
        public: publicSetting,
        passcode: passcord,
        createdAt: Timestamp.now(),
        reference: newDocumentReference,
        seatsRef: newSeatsReference, // seatsコレクションへの参照をセット
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
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/picture5.png'),
              fit: BoxFit.fill
            )
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 70, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 250),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.navigate_before_rounded,
                    color: GlobalColors.mainColor,
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                child: Text(
                  'Make your own room!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    fontFamily: 'Dosis',
                    color: GlobalColors.mainColor,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 300,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'room name/ルーム名',
                    labelStyle: TextStyle(
                      fontSize: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: 300,
                child: TextFormField(
                  textAlign: TextAlign.center,
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'room description/ルームの説明',
                    labelStyle: TextStyle(
                      fontSize: 13,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                leading: null,
                title: Text(
                  "public / private",
                ),
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
                      decoration:
                          const InputDecoration(labelText: '4-digit passcode/4桁のパスコード',
                          labelStyle: TextStyle(
                            fontSize: 13,
                          )),
                      keyboardType: TextInputType.number, // 数字のみ入力可能にする
                      maxLength: 4, // 4桁のみ入力可能にする
                    ),
                  const SizedBox(height: 16.0),
                ],
              ),
              const SizedBox(height: 16.0),
              SizedBox(
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
                    if (areAllFieldsFilled()) {
                      _createChatRoom(context);
                    } else {
                      error = true;
                      setState(() {});
                    }
                  },
                  child: const Text('create'),
                ),
              ),
              Text(
                error ? errorText : "",
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
