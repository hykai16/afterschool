// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:ui';

import 'package:afterschool/Widget/timer.dart';
import 'package:afterschool/provider/someoneprofile.provider.dart';
import 'package:afterschool/utils/userdata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/chatroomdata.dart';
import '../utils/getProfileData.dart';
import '../utils/global.colors.dart';
import 'chat.view.dart';

class StudyView extends StatefulWidget {
  final ChatRoom chatRoom;
  const StudyView({super.key, required this.chatRoom});

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
    final chatRoom = widget.chatRoom;
    startTime = chatRoom.createdAt.toDate();
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

    await seatDoc.set({'userID': userID,'aim':textInput});
    setState(() {
      isCurrentUserOccupyingSeat = true;
      currentUserOccupiedSeatNumber = seatNumber;
    });
  }

  void vacateSeat(int seatNumber) async {
    final seatDoc = widget.chatRoom.seatsRef.doc('$seatNumber');
    await seatDoc.update({'userID': null,'aim':null}); // ユーザーIDをnullに設定
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

  /*　超課題
  final someoneProfileDataStreamProvider = StreamProvider.autoDispose.family<List<String>?, int>((ref, seatNumber) {
    final currentChatRoom = ref.watch(currentChatRoomProvider(何が入る？));
    final seatRefs = currentChatRoom.seatsRef;
    final seatDoc = seatRefs.doc('$seatNumber');

    return seatDoc.snapshots().asyncMap((seatSnapshot) async {
      if (seatSnapshot.exists) {

        // List<String>? profileData = await ProfileUtils.getProfileData(seatSnapshot['userID']);
        // return profileData;
      } else {
        print('Seat document does not exist.');
        return null;
      }
    });
  });
  */

  // StreamBuilder<UserProfile?> getSomeoneProfileDataStream(int seatNumber) {
  //   final seatRefs = widget.chatRoom.seatsRef;
  //   final seatDoc = seatRefs.doc('$seatNumber');

  //   return StreamBuilder<UserProfile?>(
  //     stream: seatDoc.snapshots().asyncMap((seatSnapshot) async {
  //       if (seatSnapshot.exists) {
  //         return someoneProfileProvider(seatSnapshot);
  //       } else {
  //         print('Seat document does not exist.');
  //         return null;
  //       }
  //     }),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return CircularProgressIndicator(); // データ読み込み中はローディング表示
  //       } else if (snapshot.hasError) {
  //         return Text('Error: ${snapshot.error}');
  //       } else if (!snapshot.hasData) {
  //         return Text('No data available.');
  //       } else {
  //         final profileData = snapshot.data;
  //         // profileData を使ってウィジェットを構築
  //         // 例えば、CircleAvatar などのウィジェットを返す
  //       }
  //     },
  //   );
  // }


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
        title:TimerDisplay(
          isStudyMode: isStudyMode,
          remainingTime: remainingTime,
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
          child: Row(
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
          const SizedBox(height: 16.0),
          Text(
            widget.chatRoom.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24.0),
          // 生成したウィジェットのリストを使用して展開
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: generateSeatWidgets(), //ここはあってる
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
          const SizedBox(height: 32.0),
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
      final buttonText = currentUserOccupied ? '離席' : isOccupied
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
                  title: const Text('目標を入力しよう！'),
                  content: TextField(
                    controller: _textInputController,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        //TODO:index番目のUserIDがnullかどうかで、判別
                        print(index);
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
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('chat_rooms')
                  .doc(widget.chatRoom.id) // チャットルームドキュメントにアクセス
                  .collection('seats') // 投稿サブコレクションにアクセス
                  .snapshots(),
              // ここで受け取っている snapshot に stream で流れてきたデータが入っています。
              builder: (context, snapshot) {
                // docs には Collection に保存されたすべてのドキュメントが入ります。
                // 取得までには時間がかかるのではじめは null が入っています。
                // null の場合は空配列が代入されるようにしています。
                final docs = snapshot.data?.docs ?? [];
                    return Column(
                      children: [
                        ParentWidget(seat: Seat.fromSnapshot(docs[index])),
                        //ParentWidget(userID: Seat.fromSnapshot(docs[index]).userID),
                        SizedBox(height: 2.0),
                        ElevatedButton(
                          onPressed: onPressed,
                          style: ElevatedButton.styleFrom(
                            primary: (isCurrentUserOccupyingSeat && currentUserOccupiedSeatNumber == seatNumber)
                                ? Colors.green
                                // ignore: unnecessary_null_comparison
                                : (Seat.fromSnapshot(docs[index]).userID != null)
                                ? Colors.blue
                                : Colors.red,
                            elevation: 16,
                          ),
                          child: Text(buttonText),
                        )
                      ],
                    );
              },
            ),
          ),
        ],
      );
    });
  }
}

class ParentWidget extends ConsumerWidget {
  //final String userID;
  final Seat seat;

  const ParentWidget({required this.seat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsyncValue = ref.watch(someoneProfileProvider(seat.userID));

    return userProfileAsyncValue.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('プロフィールデータの取得中にエラーが発生しました: $error'),
      data: (userProfile) {
        return SeatWidget(userProfile: userProfile,seat: seat);
      },
    );
  }
}

class SeatWidget extends StatelessWidget {
  const SeatWidget({
    super.key,
    required this.userProfile, // ユーザープロファイル情報を受け取る
    required this.seat,
  });

  final UserProfile userProfile; // ユーザープロファイル情報を保持する
  final Seat seat;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
            child:CircleAvatar(
              backgroundImage: NetworkImage(userProfile?.iconImageUrl ?? "https://yt3.googleusercontent.com/CK6GCZPybwzJwuQfPFiL0b9-Ep7tAZ_MQf_GhZgq2POTULUNyeVUa5ERhebNGBIf-bM0ukipxow=s900-c-k-c0x00ffffff-no-rj"),

            ),
        ),
        const SizedBox(height: 3.0),
        Text(userProfile.name == "ゲスト" ? "" : userProfile.name),
        const SizedBox(height: 3.0),
        //TODO:もしかしてストリームにしないといけない？
        Text(seat.aim == "デフォルトのAim" ? "" :seat.aim),
      ],
    );
  }
}


