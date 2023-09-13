import 'package:afterschool/View/passcord.view.dart';
import 'package:afterschool/View/study.view.dart';
import 'package:afterschool/utils/global.colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/chatroomdata.dart';
import 'chat.view.dart';
import 'newroom.view.dart';

class RoomSearchView extends StatefulWidget {
  const RoomSearchView({super.key});

  @override
  State<RoomSearchView> createState() => _RoomSearchViewState();
}

class _RoomSearchViewState extends State<RoomSearchView> {
  final chatRooms = <ChatRoom>[]; // chatRoomsリストを作成
  List<ChatRoom> _searchChatRoomsList = []; //空のchatRoomsリストを作成
  bool _showOnlyPublic = false; // チェックボックスの初期状態
  final TextEditingController _searchWordController = TextEditingController();
  Stream<QuerySnapshot<Map<String, dynamic>>> chatRoomsStream =
      FirebaseFirestore.instance
          .collection('chat_rooms')
          .orderBy('public', descending: true)
          .snapshots();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    search("");
  }

  void search(String s) {
    setState(() {
      if (s.trim().isEmpty) {
        _searchChatRoomsList = chatRooms;
      } else {
        _searchChatRoomsList = [];
        for (int i = 0; i < chatRooms.length; i++) {
          //roomのタイトルが入力された文字を含んでいればlistに追加
          //あんま自信なし
          if (chatRooms[i].title.contains(s)) {
            _searchChatRoomsList.add(chatRooms[i]);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          top: 50,
          right: 20,
          left: 20,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'rooms',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      fontFamily: 'Dosis',
                      color: GlobalColors.mainColor),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: GlobalColors.mainColor,
                ),
                SizedBox(
                  width: 190,
                ),
                IconButton(
                    icon: Icon(Icons.add,
                    color: GlobalColors.mainColor),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateNewRoom()),
                      );
                    }),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _searchWordController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(1),
                hintText: '検索キーワードを入力してください',
                hintStyle: TextStyle(
                  fontFamily: 'Kiwi',
                  fontSize: 15,
                ),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              onChanged: search, //エンターキー押したらサーチ開始
            ),

            Row(
              children: [
                Text(
                  '公開のみ表示',
                  style: TextStyle(
                    fontFamily: 'Kiwi',
                  ),
                ),
                Checkbox(
                  value: _showOnlyPublic,
                  onChanged: (newValue) {
                    setState(() {
                      _showOnlyPublic = newValue ?? false;
                      search(_searchWordController.text); // チェックボックスが変更されたら再検索
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            // 検索結果を表示するウィジェットをここに配置
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: chatRoomsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(); // ローディング表示
                  } else if (snapshot.hasError) {
                    return const Text('エラーが発生しました');
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('チャットルームが見つかりません');
                  } else {
                    chatRooms.clear(); // リストをクリアして新たに追加
                    chatRooms.addAll(snapshot.data!.docs
                        .map((doc) => ChatRoom.fromSnapshot(doc)));
                    // フィルタリングされたリストを作成
                    final filteredChatRooms = _showOnlyPublic
                        ? _searchChatRoomsList
                            .where((chatRoom) => chatRoom.public)
                            .toList()
                        : _searchChatRoomsList;

                    return ListView.builder(
                      itemCount: filteredChatRooms.length,
                      itemBuilder: (context, index) {
                        final chatRoom =
                            filteredChatRooms[index]; // chatRoomIndexを直接使用
                        return Container(
                          decoration: BoxDecoration(
                              border: Border(
                            bottom: BorderSide(width: 1.0, color: Colors.grey),
                          )),
                          child: ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    chatRoom.title,
                                    style: TextStyle(fontFamily: 'Kiwi'),
                                  ),
                                  Spacer(),
                                  if (!chatRoom.public) // 非公開の場合のみ鍵アイコンを表示
                                    //Icon(Icons.lock, color: Colors.black),
                                    Image.asset(
                                      "assets/images/lock.png",
                                    height: 40,
                                    width: 40,
                                    )
                                  // 鍵アイコン
                                ],
                              ),
                              subtitle: Text(chatRoom.introduce),
                              onTap: () {
                                if (chatRoom.public == false) {
                                  // パスコードが設定されている場合、パスコード入力画面に遷移
                                  // ここでパスコード入力画面への遷移処理を追加
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PasscodeScreen(
                                              chatRoom: chatRoom)));
                                } else {
                                  // パスコードが設定されていない場合、通常のChatRoomに遷移
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => StudyView(
                                            chatRoom: chatRoom)), // パラメータを渡して遷移
                                  );
                                }
                              }),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
