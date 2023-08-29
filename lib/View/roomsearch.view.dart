import 'package:afterschool/View/study.view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/chatroomdata.dart';
import 'chat.view.dart';


class RoomSearchView extends StatefulWidget {
  const RoomSearchView({super.key});

  @override
  State<RoomSearchView> createState() => _RoomSearchViewState();
}

class _RoomSearchViewState extends State<RoomSearchView> {
  final chatRooms = <ChatRoom>[]; // chatRoomsリストを作成
  Stream<QuerySnapshot<Map<String, dynamic>>> chatRoomsStream = FirebaseFirestore.instance
      .collection('chat_rooms')
      .orderBy('participants', descending: true)
      .snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: '検索キーワードを入力してください',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                final keyword = value;
                // Firestoreのコレクション参照
                final chatRoomsCollection = FirebaseFirestore.instance.collection('chat_rooms');

                // 検索キーワードに合致するチャットルームを取得
                QuerySnapshot<Map<String, dynamic>> querySnapshot = await chatRoomsCollection
                    .where('title', isGreaterThanOrEqualTo: keyword) // キーワード以上の文字を含む
                    .where('title', isLessThan: keyword + 'z') // キーワード以下の文字を含む
                    .get();

                // QuerySnapshotからChatRoomリストを作成
                List<ChatRoom> chatRooms = querySnapshot.docs.map((doc) => ChatRoom.fromSnapshot(doc)).toList();
              },
            ),
            const SizedBox(height: 16.0),
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
                    chatRooms.addAll(snapshot.data!.docs.map((doc) => ChatRoom.fromSnapshot(doc)));

                    return ListView.builder(
                      itemCount: chatRooms.length,
                      itemBuilder: (context, index) {
                        final chatRoom = chatRooms[index];
                        return ListTile(
                          //TODO:participantsとmaxparticipantsを載せる
                          title: Text(chatRoom.title),
                          subtitle: Text(chatRoom.introduce),
                          onTap: () {
                            // TODO:タップされたチャットルームに遷移する処理
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => StudyView(chatRoom: chatRoom)), // パラメータを渡して遷移
                            );
                          },
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
