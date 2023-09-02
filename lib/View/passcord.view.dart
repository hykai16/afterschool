import 'package:afterschool/View/study.view.dart';
import 'package:afterschool/utils/chatroomdata.dart';
import 'package:flutter/material.dart';

import '../view/chat.view.dart';

class PasscodeScreen extends StatefulWidget {
  final ChatRoom chatRoom;
  const PasscodeScreen({super.key, required this.chatRoom});

  @override
  _PasscodeScreenState createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  final TextEditingController _passcodeController = TextEditingController();
  String _errorText = '';

  void _verifyPasscode() {
    final passcode = _passcodeController.text;
    final correctPasscord = widget.chatRoom.passcode;
    if (passcode.length != 4) {
      setState(() {
        _errorText = '4桁のパスコードを入力してください';
      });
    } else {
      // ここでパスコードを検証するロジックを実装します
      // 例: 正しいパスコードが "1234" の場合
      if (passcode == correctPasscord) {
        // 正しい場合、適切な処理を行います
        setState(() {
          _errorText = ''; // エラーテキストをクリア
          print("right");
          // ここに正しいパスコードの場合の処理を追加
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                StudyView(
                    chatRoom: widget.chatRoom)), // パラメータを渡して遷移
          );// パラメータを渡して遷移
        });
      } else {
        // 不正な場合、エラーテキストを表示します
        setState(() {
          _errorText = 'パスコードが正しくありません';
          print("wrong");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('パスコード入力'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _passcodeController,
              decoration: InputDecoration(
                labelText: '4桁のパスコードを入力してください',
                errorText: _errorText,
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true, // パスコードを隠す
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _verifyPasscode,
              child: const Text('確認'),
            ),
          ],
        ),
      ),
    );
  }
}
