// ignore_for_file: library_private_types_in_public_api

import 'dart:async';
import 'dart:ui';

import 'package:afterschool/Widget/timer.dart';
import 'package:afterschool/provider/someoneprofile.provider.dart';
import 'package:afterschool/utils/firebase_service.dart';
import 'package:afterschool/utils/userdata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../Widget/profilewidget.dart';
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
  int studyingTime = 0;
  int minutes = 0;
  int seconds = 0;
  bool isCurrentUserOccupyingSeat = false;

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
    final elapsedPeriods = elapsedTime.inMinutes ~/
        (modeDurationStudy + modeDurationBreak).inMinutes;
    //0:21:20　分以下が残る
    final remainingPeriodTime = elapsedTime -
        Duration(
            minutes: elapsedPeriods *
                (modeDurationStudy + modeDurationBreak).inMinutes);

    //remainingPeriodTimeによって、モードを分けたい
    if (remainingPeriodTime < modeDurationStudy) {
      isStudyMode = true;
      remainingTime = modeDurationStudy - remainingPeriodTime;
    } else {
      isStudyMode = false;
      remainingTime =
          modeDurationBreak - (remainingPeriodTime - modeDurationStudy);
    }

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      updateCurrentTime();
      //258:33:46.00000
      // final elapsedDuration = currentTime.difference(startTime);
      // print(isStudyMode);

      if (remainingTime.inMinutes == 0 && remainingTime.inSeconds == 0) {
        //TODO:勉強時間が送られる
        FirebaseService.updateStudyData(FirebaseAuth.instance.currentUser!.uid, studyingTime, studyingTime);
        studyingTime = 0;
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
          if(isCurrentUserOccupyingSeat && isStudyMode){
            studyingTime += 1;
            seconds = studyingTime % 60;
            minutes = studyingTime ~/ 60;
          }
          print(remainingTime);
        });
      }
    });
  }

  //時間ここまで


  int currentUserOccupiedSeatNumber = -1;
  List<bool> someoneOccupyingSeats = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

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
        someoneOccupyingSeats[seatNumber - 1] = true;
        setState(() {
          isCurrentUserOccupyingSeat = true;
          currentUserOccupiedSeatNumber = seatNumber;
        });
        break;
      } else if (seatSnapshot.exists && seatSnapshot['userID'] != null) {
        // 別のユーザーが席に座っている場合、フラグを設定
        someoneOccupyingSeats[seatNumber - 1] = true;
        break;
      }
    }
  }

  void occupySeat(int seatNumber, String textInput) async {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    final seatDoc = widget.chatRoom.seatsRef.doc('$seatNumber');
    //TODO:呼び出し場所合っていますか？
    updateDailySeatingTime(isCurrentUserOccupyingSeat);

    // すでに座っている席がある場合、その席を解放する
    if (isCurrentUserOccupyingSeat) {
      vacateSeat(currentUserOccupiedSeatNumber);
    }

    await seatDoc.set({'userID': userID, 'aim': textInput});
    setState(() {
      isCurrentUserOccupyingSeat = true;
      currentUserOccupiedSeatNumber = seatNumber;
    });
  }

  void vacateSeat(int seatNumber) async {
    final seatDoc = widget.chatRoom.seatsRef.doc('$seatNumber');
    await seatDoc.update({'userID': null, 'aim': null}); // ユーザーIDをnullに設定
    FirebaseService.updateStudyData(FirebaseAuth.instance.currentUser!.uid, studyingTime, studyingTime);
    setState(() {
      isCurrentUserOccupyingSeat = false;
      currentUserOccupiedSeatNumber = -1;
      studyingTime = 0;
    });
  }

  // データベースへの書き込み（着席時に呼び出される関数）
  void updateDailySeatingTime(bool isSeated) async {
    final userID = FirebaseAuth.instance.currentUser!.uid;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userID);
    final currentDate = DateTime.now();
    final currentDateString =
        "${currentDate.year}-${currentDate.month}-${currentDate.day}";

    // ユーザーのデータを取得
    final userSnapshot = await userDoc.get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.data() as Map<String, dynamic>;

      // 日毎の着席時間を取得または初期化
      final dailySeatingTimes =
          userData['daily_seating_times'] as Map<String, dynamic>? ?? {};

      if (isSeated) {
        // 現在の日付に対応する日毎の着席時間を更新
        final currentSeatingTime =
            dailySeatingTimes[currentDateString] as int? ?? 0;
        dailySeatingTimes[currentDateString] =
            currentSeatingTime + 1; // 1分単位で着席時間を記録（例）
      }

      // 更新
      await userDoc.update({
        'daily_seating_times': dailySeatingTimes,
      });
    }
  }

  //personaldata取得
  final user = FirebaseAuth.instance.currentUser!;
  final imano_loginshiteru_userno_id = FirebaseAuth.instance.currentUser!.uid;

  //List<Map<String, dynamic>> _profileData = [];
  String nameText = "";
  String iconImageURL = "";

  void _getProfileData() async {
    List<String>? profileData =
        await ProfileUtils.getProfileData(imano_loginshiteru_userno_id);
    setState(() {
      if (profileData != null) {
        nameText = profileData[0];
        iconImageURL = profileData[1];
      } else {
        print('Profile data not available or an error occurred.');
      }
    });
  }

  //戻るボタンで離席
  void _onBackButtonPressed() {
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: TimerDisplay(
            isStudyMode: isStudyMode,
            remainingTime: remainingTime,
          ),
          backgroundColor:
              isStudyMode ? GlobalColors.mainColor : GlobalColors.restcolor,
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
        body: Container(
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.brown,
                  image: DecorationImage(
                    image: AssetImage('assets/images/black.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // テキストを中央に配置
                    children: [
                      Text(
                        widget.chatRoom.title + "  ",
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'chalks',
                            color: Colors.white),
                      ),
                      //TODO:最後に!つける
                      if (!isStudyMode)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      ChatView(chatRoom: widget.chatRoom)),
                            );
                          },
                          style:
                              ElevatedButton.styleFrom(primary: Colors.white),
                          child: Text(
                            '休憩しよう！',
                            style: TextStyle(fontFamily: 'Chalks',
                            color: Colors.black,),
                          ),
                        )
                      else
                        Text('$minutes:${seconds.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'chalks',
                          fontSize: 20,
                        ),),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  // 生成したウィジェットのリストを使用して展開
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: (2 / 3),
                      children: generateSeatWidgets(), //ここはあってる
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  // 着席ボタンを押した際のテキスト入力のコントローラー
  final TextEditingController _textInputController = TextEditingController();
  String _textInput = ""; // テキスト入力内容

  @override
  void dispose() {
    timer?.cancel(); // タイマーをキャンセル
    _textInputController.dispose(); // コントローラーを解放
    super.dispose();
  }

  List<Widget> generateSeatWidgets() {
    return List.generate(8, (index) {
      final seatNumber = index + 1;
      final isOccupied = someoneOccupyingSeats[index];
      final currentUserOccupied = currentUserOccupiedSeatNumber == seatNumber;
      final buttonText = currentUserOccupied
          ? '離席'
          : isOccupied
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
                  actions: <Widget>[
                    TextButton(
                      child: Text('キャンセル'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                        child: Text('OK'),
                        onPressed: () {
                          setState(
                            () {
                              _textInput = _textInputController.text;

                              occupySeat(seatNumber, _textInput); // テキストを座席に登録
                              Navigator.pop(context);
                            },
                          );
                        })
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
                if (snapshot.hasData) {
                    final docs = snapshot.data!.docs ?? [];
                    return Column(
                    children: [
                      if (docs.isNotEmpty)
                        ParentWidget(seat: Seat.fromSnapshot(docs[index])),
                      ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          primary: (isCurrentUserOccupyingSeat &&
                                  currentUserOccupiedSeatNumber == seatNumber)
                              ? Colors.green
                              : (Seat.fromSnapshot(docs[index]).userID != null)
                                  ? Colors.blue
                                  : Colors.red,
                          elevation: 16,
                        ),
                        child: Text(
                          buttonText,
                          style: TextStyle(fontFamily: 'Chalks'),
                        ),
                      )
                    ],
                  );
                } else {
                  // データがまだ利用できない場合のローディングインジケータ
                  return CircularProgressIndicator();
                }
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
    final userProfileAsyncValue =
        ref.watch(someoneProfileProvider(seat.userID));

    return userProfileAsyncValue.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) => Text('プロフィールデータの取得中にエラーが発生しました: $error'),
      data: (userProfile) {
        return SeatWidget(userProfile: userProfile, seat: seat);
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
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 150,
            height: 80,
            padding: const EdgeInsets.all(16),
            //吹き出し
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: BubbleBorder(),
            ),
            //TODO:文字数制限
            child: Text(
              seat.aim == "デフォルトのAim"? "空席だよ" : seat.aim,
              style: const TextStyle(
                  fontFamily: 'Chalks',
                fontSize: 12,
              ),
              maxLines: 2, // 最大行数を2に設定
              overflow: TextOverflow.ellipsis, // 範囲を超えた場合に省略記号（...）を表示
            ),
          ),
          Text(
            seat.userID == "デフォルトのUserID" ? "" : userProfile.name,
            style: const TextStyle(
              fontFamily: 'Chalks',
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  print(seat.userID);
                  if (userProfile.name != "ゲスト") {
                    // サークルアバターがタップされたときの処理をここに追加
                    // showDialog(
                    //   context: context,
                    //   builder: (_) {
                    //     return UserProfileWidget(userProfile: userProfile);
                    //   },
                    // );
                    showModalBottomSheet(
                        //モーダルの背景の色、透過
                        backgroundColor: Colors.transparent,
                        //ドラッグ可能にする（高さもハーフサイズからフルサイズになる様子）
                        isScrollControlled: true,
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            margin: const EdgeInsets.only(top: 64),
                            decoration: const BoxDecoration(
                              //モーダル自体の色
                              color: Colors.white,
                              //角丸にする
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Stack(
                              children: [
                                UserProfileScreen(userProfile: userProfile),
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  }
                },
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      child: const Image(
                        image: AssetImage('assets/images/desk.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 40,
                      child: CircleAvatar(
                        // で入る時は画像を変更する
                        backgroundImage: NetworkImage(userProfile
                                .iconImageUrl ??
                            "https://yt3.googleusercontent.com/CK6GCZPybwzJwuQfPFiL0b9-Ep7tAZ_MQf_GhZgq2POTULUNyeVUa5ERhebNGBIf-bM0ukipxow=s900-c-k-c0x00ffffff-no-rj"),
                        radius: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ]));

    //   Column(
    //   children: [
    //     Center(
    //         child:CircleAvatar(
    //           backgroundImage: NetworkImage(userProfile?.iconImageUrl ?? "https://yt3.googleusercontent.com/CK6GCZPybwzJwuQfPFiL0b9-Ep7tAZ_MQf_GhZgq2POTULUNyeVUa5ERhebNGBIf-bM0ukipxow=s900-c-k-c0x00ffffff-no-rj"),
    //
    //         ),
    //     ),
    //     const SizedBox(height: 3.0),
    //     Text(userProfile.name == "ゲスト" ? "" : userProfile.name),
    //     const SizedBox(height: 3.0),
    //     //TODO:もしかしてストリームにしないといけない？
    //     Text(seat.aim == "デフォルトのAim" ? "" :seat.aim),
    //   ],
    // );
  }
}

class BubbleBorder extends ShapeBorder {
  final bool usePadding;

  const BubbleBorder({this.usePadding = true});

  @override
  EdgeInsetsGeometry get dimensions =>
      EdgeInsets.only(bottom: usePadding ? 12 : 0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path();
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final r =
        Rect.fromPoints(rect.topLeft, rect.bottomRight - const Offset(0, 12));
    return Path()
      ..addRRect(RRect.fromRectAndRadius(r, Radius.circular(8)))
      ..moveTo(r.bottomCenter.dx - 10, r.bottomCenter.dy)
      ..relativeLineTo(10, 12)
      ..relativeLineTo(10, -12)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
