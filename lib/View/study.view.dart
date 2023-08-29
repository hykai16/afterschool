import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/chatroomdata.dart';
import '../utils/getProfileData.dart';
import '../utils/global.colors.dart';
import 'chat.view.dart';

class StudyView extends StatefulWidget {
  final ChatRoom chatRoom;
  StudyView({required this.chatRoom});

  @override
  _StudyViewState createState() => _StudyViewState();
}

class _StudyViewState extends State<StudyView> {
  bool isStudyMode = true; // 勉強モードかどうかのフラグ
  late DateTime startTime; // タイマー開始時間
  late Duration remainingTime; // 残り時間
  late Timer timer; // タイマーオブジェクト
  late DateTime currentTime;
  //var currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _getProfileData();
    //widgetはStatefulで使用
    startTime = widget.chatRoom.createdAt.toDate();
    startTimer();
    checkUserOccupiedSeat();
  }

  void updateCurrentTime() {
    setState(() {
      currentTime = DateTime.now();
    });
  }

  void startTimer() {
    final modeDurationStudy = Duration(minutes: 50);
    final modeDurationBreak = Duration(minutes: 10);

    //2023-08-11 01:56:09.9999
    final createdAt = widget.chatRoom.createdAt.toDate();
    //2023-08-22 //
    final currentTime = DateTime.now();
    //258:15:12:0.362
    final elapsedTime = currentTime.difference(createdAt);

    //258時間が残る（258クールタイムが終わった）
    final elapsedPeriods = elapsedTime.inMinutes ~/ (modeDurationStudy + modeDurationBreak).inMinutes;
    //0:21:20　分以下が残る
    final remainingPeriodTime = elapsedTime - Duration(minutes: elapsedPeriods * (modeDurationStudy + modeDurationBreak).inMinutes);

    //remainingPeriodTimeによって、モードを分けたい
    if(remainingPeriodTime < modeDurationStudy){
      isStudyMode = true;
        remainingTime = modeDurationStudy - remainingPeriodTime;
    }else{
      isStudyMode = false;
        remainingTime = modeDurationBreak - (remainingPeriodTime - modeDurationStudy);
    }

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      updateCurrentTime();
      //258:33:46.00000
      // final elapsedDuration = currentTime.difference(startTime);
      // print(isStudyMode);

      if (remainingTime.inMinutes == 0 && remainingTime.inSeconds == 0) {
        timer.cancel();
        startTimer(); // タイマーを先に再スタート
        print("リセット実行");
        //
        // final currentModeDuration = isStudyMode ? modeDurationStudy : modeDurationBreak;
        // final newElapsedTime = elapsedDuration - remainingTime;
        //
        // final elapsedPeriods = newElapsedTime.inMinutes ~/ (modeDurationStudy + modeDurationBreak).inMinutes;
        // final remainingPeriodTime = newElapsedTime - Duration(minutes: elapsedPeriods * (modeDurationStudy + modeDurationBreak).inMinutes);
        //
        // remainingTime = currentModeDuration + remainingPeriodTime;
      } else {
        setState(() {
          remainingTime = remainingTime - Duration(seconds: 1);
          print(remainingTime);
        });
      }
    });
  }
  //時間ここまで

  bool isCurrentUserOccupyingSeat = false;
  int currentUserOccupiedSeatNumber = -1;
  List<bool> someoneOccupyingSeats = [false,false,false,false,false,false,false,false];

  //シート設定
  Future<void> checkUserOccupiedSeat() async {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    final seatRefs = widget.chatRoom.seatsRef;
    // ユーザーが席に座っているかどうかを確認するためのフラグ

    for (int seatNumber = 1; seatNumber <= 8; seatNumber++) {
      final seatDoc = seatRefs.doc('$seatNumber');
      final seatSnapshot = await seatDoc.get();
      //座席があって、ユーザーIDが一致する
      if (seatSnapshot.exists && seatSnapshot['userID'] == userID) {
        someoneOccupyingSeats[seatNumber-1] = true;
        setState(() {
          isCurrentUserOccupyingSeat = true;
          currentUserOccupiedSeatNumber = seatNumber;
        });
        break;
      } else if (seatSnapshot.exists && seatSnapshot['userID'] != null) {
        // 別のユーザーが席に座っている場合、フラグを設定
        someoneOccupyingSeats[seatNumber-1] = true;
        break;
      }
    }
  }

  void occupySeat(int seatNumber,String textInput) async {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    final seatDoc = widget.chatRoom.seatsRef.doc('$seatNumber');

    // すでに座っている席がある場合、その席を解放する
    if (isCurrentUserOccupyingSeat) {
      vacateSeat(currentUserOccupiedSeatNumber);
    }

    await seatDoc.set({'userID': userID});
    await seatDoc.set({'aim':textInput});
    setState(() {
      isCurrentUserOccupyingSeat = true;
      currentUserOccupiedSeatNumber = seatNumber;
    });
  }


  void vacateSeat(int seatNumber) async {
    final seatDoc = widget.chatRoom.seatsRef.doc('$seatNumber');
    await seatDoc.update({'userID': null}); // ユーザーIDをnullに設定
    await seatDoc.update({'aim':null});
    setState(() {
      isCurrentUserOccupyingSeat = false;
      currentUserOccupiedSeatNumber = -1;
    });
  }

  //personaldata取得
  final user = FirebaseAuth.instance.currentUser!;
  final imano_loginshiteru_userno_id = FirebaseAuth.instance.currentUser!.uid;
  //List<Map<String, dynamic>> _profileData = [];
  String nameText = "";
  String iconImageURL = "";

  void _getProfileData() async {
    List<String>? profileData = await ProfileUtils.getProfileData(imano_loginshiteru_userno_id);
    setState(() {
      if (profileData != null) {
        nameText = profileData[0];
        iconImageURL = profileData[1];
      } else {
        print('Profile data not available or an error occurred.');
      }
    });
    // ProfileUtils.getProfileData(imano_loginshiteru_userno_id, (name, iconUrl) {
    //   setState(() {
    //     nameText = name;
    //     iconImageURL = iconUrl;
    //   });
    // });
  }


  //改良の必要性
  Stream<List<String>?> getSomeoneProfileDataStream(int seatNumber) {
    final seatRefs = widget.chatRoom.seatsRef;
    final seatDoc = seatRefs.doc('$seatNumber');

    return seatDoc.snapshots().asyncMap((seatSnapshot) async {
      if (seatSnapshot.exists) {
        List<String>? profileData = await ProfileUtils.getProfileData(seatSnapshot["userID"]);
        return profileData;
      } else {
        print('Seat document does not exist.');
        return null;
      }
    });
  }




  //戻るボタンで離席
  void _onBackButtonPressed()  {
    // 離席処理を行う
    if (isCurrentUserOccupyingSeat) {
      vacateSeat(currentUserOccupiedSeatNumber);
    }

    // 前のページに戻る
    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 20, // 変数部分のフォントサイズを調整
            ),
            children: [
              TextSpan(
                text: isStudyMode? '休憩まで　':'休憩中　',
              ),
              TextSpan(
                text: '${remainingTime.inMinutes}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 30, // 変数部分のフォントサイズを大きく設定
                  fontWeight: FontWeight.bold, // ボールド体に設定
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: isStudyMode ? GlobalColors.mainColor : GlobalColors.restcolor,
        automaticallyImplyLeading: false, // 戻るボタンを非表示にする
        leading: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: _onBackButtonPressed,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: isStudyMode ? GlobalColors.mainColor : GlobalColors.restcolor,
        onPressed: () {},
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        color:isStudyMode ? GlobalColors.mainColor : GlobalColors.restcolor,
        //color: Theme.of(context).primaryColor,
        notchMargin: 6.0,
        shape: AutomaticNotchedShape(
          RoundedRectangleBorder(),
          StadiumBorder(
            side: BorderSide(),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.person_outline,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.info_outline,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.0),
          Text(
            widget.chatRoom.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24.0),
          // 生成したウィジェットのリストを使用して展開
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: generateSeatWidgets(),
            ),
          ),
          SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatView(chatRoom: widget.chatRoom)),
              );
            },
            child: Text('休憩モードへ'),
          ),
          SizedBox(height: 32.0),
        ],
      ),
    );
  }

  // 着席ボタンを押した際のテキスト入力のコントローラー
  final TextEditingController _textInputController = TextEditingController();
  String _textInput = ""; // テキスト入力内容

  @override
  void dispose() {
    _textInputController.dispose(); // コントローラーを解放
    super.dispose();
  }

  List<Widget> generateSeatWidgets() {
    return List.generate(8, (index) {
      final seatNumber = index + 1;
      final isOccupied = someoneOccupyingSeats[index];
      final currentUserOccupied = currentUserOccupiedSeatNumber == seatNumber;
      final buttonText = currentUserOccupied ? nameText : isOccupied
          ? '誰か'
          : '着席';

      void onPressed() {
        if (currentUserOccupied) {
          vacateSeat(seatNumber);
        } else if (!isOccupied) {
          // テキスト入力フォームを表示し、テキストを座席に登録
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('目標を入力しよう！'),
                  content: TextField(
                    controller: _textInputController,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _textInput = _textInputController.text;

                          occupySeat(seatNumber, _textInput); // テキストを座席に登録
                          Navigator.pop(context); // ダイアログを閉じる
                        });
                      },
                      child: Text('登録'),
                    ),
                  ],
                );
              });
        }
      }

      return Column(
        children: [
          Center(
            child: GestureDetector(
              onTap: onPressed,
              child: StreamBuilder<List<String>?>(
                stream: getSomeoneProfileDataStream(index),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage("https://yt3.googleusercontent.com/CK6GCZPybwzJwuQfPFiL0b9-Ep7tAZ_MQf_GhZgq2POTULUNyeVUa5ERhebNGBIf-bM0ukipxow=s900-c-k-c0x00ffffff-no-rj"),
                    );
                  } else if (snapshot.hasData && snapshot.data != null) {
                    List<String> profileData = snapshot.data!;
                    return CircleAvatar(
                      backgroundImage: (isCurrentUserOccupyingSeat && currentUserOccupiedSeatNumber == seatNumber)
                          ? NetworkImage(user.photoURL!)
                          : NetworkImage(profileData[1]),
                    );
                  } else {
                    return CircleAvatar(
                      backgroundImage: NetworkImage("https://yt3.googleusercontent.com/CK6GCZPybwzJwuQfPFiL0b9-Ep7tAZ_MQf_GhZgq2POTULUNyeVUa5ERhebNGBIf-bM0ukipxow=s900-c-k-c0x00ffffff-no-rj"),
                    );
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 2.0),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              primary: (isCurrentUserOccupyingSeat && currentUserOccupiedSeatNumber == seatNumber)
                  ? Colors.green
                  : Colors.red,
              elevation: 16,
            ),
            child: Text(buttonText),
          )
        ],
      );
    });



// List<Widget> generateSeatWidgets() {
  //   return List.generate(8, (index) {
  //     final seatNumber = index + 1;
  //     final isOccupied = someoneOccupyingSeats[index];
  //     final currentUserOccupied = currentUserOccupiedSeatNumber == seatNumber;
  //     final buttonText = currentUserOccupied ? nameText : isOccupied ? '誰か' : '着席';
  //     onPressed() {
  //       if (currentUserOccupied) {
  //         vacateSeat(seatNumber);
  //       } else if (!isOccupied) {
  //         // テキスト入力フォームを表示し、テキストを座席に登録
  //         showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return AlertDialog(
  //                 title: Text('目標を入力しよう！'),
  //                 content: TextField(
  //                   controller: _textInputController,
  //                 ),
  //                 actions: [
  //                   TextButton(
  //                     onPressed: () {
  //                       setState(() {
  //                         _textInput = _textInputController.text;
  //
  //                         occupySeat(seatNumber, _textInput); // テキストを座席に登録
  //                         Navigator.pop(context); // ダイアログを閉じる
  //                       });
  //                     },
  //                     child: Text('登録'),
  //                   ),
  //                 ],
  //               );
  //             });
  //       }
  //     }
  //     // final onPressed = currentUserOccupied
  //     //     ? () => vacateSeat(seatNumber)
  //     //     : isOccupied
  //     //     ? () => null
  //     //     : () => occupySeat(seatNumber);
  //
  //
  //
  //
  //     return Column(
  //       children: [
  //         Center(
  //           child: GestureDetector(
  //             onTap: onPressed,
  //             child: CircleAvatar (
  //               backgroundImage: (isCurrentUserOccupyingSeat && currentUserOccupiedSeatNumber == seatNumber)
  //                   ? NetworkImage(user.photoURL!)
  //                   : someoneOccupyingSeats[index]
  //                   ? null//TODO:ここに他の人のアイコンをFirebaseから引っ張ってくる
  //                   : NetworkImage("https://yt3.googleusercontent.com/CK6GCZPybwzJwuQfPFiL0b9-Ep7tAZ_MQf_GhZgq2POTULUNyeVUa5ERhebNGBIf-bM0ukipxow=s900-c-k-c0x00ffffff-no-rj"),
  //             ),
  //           ),
  //         ),
  //         SizedBox(height: 2.0),
  //         ElevatedButton(
  //           onPressed: onPressed,
  //           style: ElevatedButton.styleFrom(
  //             primary: (isCurrentUserOccupyingSeat && currentUserOccupiedSeatNumber == seatNumber)
  //                 ? Colors.green
  //                 : Colors.red,
  //             elevation: 16,
  //           ),
  //           child: Text(buttonText),
  //         )
  //       ],
  //     );
  //   });
  }
}
