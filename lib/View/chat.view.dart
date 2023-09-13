import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../utils/chatroomdata.dart';
import '../utils/global.colors.dart';
import '../utils/post.dart';


class ChatView extends StatefulWidget {
  final ChatRoom chatRoom; // チャットルーム情報を受け取るパラメータを追加
  const ChatView({Key? key, required this.chatRoom}) : super(key: key);


  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  Future<void> sendPost(String text) async {
    final user = FirebaseAuth.instance.currentUser!;
    final posterId = user.uid;
    final posterName = user.displayName!;
    final posterImageUrl = user.photoURL!;

    final chatRoomId = widget.chatRoom.id; // チャットルームのIDを取得

    final newDocumentReference = FirebaseFirestore.instance
        .collection('chat_rooms') // チャットルームコレクションにアクセス
        .doc(chatRoomId) // チャットルームドキュメントにアクセス
        .collection('posts') // 投稿サブコレクションにアクセス
        .doc(); // 新しい投稿ドキュメントを作成

    final newPost = Post(
      text: text,
      createdAt: Timestamp.now(),
      posterName: posterName,
      posterImageUrl: posterImageUrl,
      posterId: posterId,
      reference: newDocumentReference,
    );

    await newDocumentReference.set(newPost.toMap());
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold 全体を GestureDetector で囲むことでタップ可能になります。
    return GestureDetector(
      onTap: () {
        // キーボードを閉じたい時はこれを呼びます。
        primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: GlobalColors.mainColor,
        appBar: AppBar(
          //TODO:chatRoomのtitleを表示させたい
          title: Text(widget.chatRoom.title),
          backgroundColor: GlobalColors.mainColor,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('chat_rooms')
                    .doc(widget.chatRoom.id) // チャットルームドキュメントにアクセス
                    .collection('posts') // 投稿サブコレクションにアクセス
                    .orderBy('createdAt')
                    .snapshots(),
                // ここで受け取っている snapshot に stream で流れてきたデータが入っています。
                builder: (context, snapshot) {
                  // docs には Collection に保存されたすべてのドキュメントが入ります。
                  // 取得までには時間がかかるのではじめは null が入っています。
                  // null の場合は空配列が代入されるようにしています。
                  final docs = snapshot.data?.docs ?? [];
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final post = Post.fromFirestore(docs[index]);
                      return PostWidget(post: post);
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  // 未選択時の枠線
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  // 選択時の枠線
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  // 中を塗りつぶす色
                  fillColor: Colors.white,
                  // 中を塗りつぶすかどうか
                  filled: true,
                ),
                onFieldSubmitted: (text) {
                  sendPost(text);
                  controller.clear();
                },
              ),
            ),


          ],
        ),
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  const PostWidget({
    super.key,
    required this.post,
  });

  final Post post;

  //TODO:改良
  // void _onIconTap(int seatNumber) {
  //   // タップされた座席のユーザーIDを取得
  //   final seatDoc = widget.chatRoom.seatsRef.doc('$seatNumber');
  //   seatDoc.get().then((seatSnapshot) {
  //     if (seatSnapshot.exists) {
  //       final userId = seatSnapshot['userID'];
  //       if (userId != null) {
  //         // タップされたユーザーのプロフィール情報を表示するウィジェットを表示
  //         _showUserProfileDialog(userId);
  //       }
  //     }
  //   });
  // }
  //
  // // 3. プロフィール情報を表示するウィジェット
  // void _showUserProfileDialog(String userId) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       // ユーザープロフィール情報を取得するロジック
  //       // 必要な情報は、ユーザー名、アイコン、バイオなどです
  //       // ProfileUtils.getProfileData(userId) などを使用して取得できます
  //
  //       return AlertDialog(
  //         title: Text('ユーザープロフィール'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             CircleAvatar(
  //               backgroundImage: NetworkImage(userProfile?.iconImageUrl ?? "デフォルトのアイコンURL"),
  //             ),
  //             const SizedBox(height: 8.0),
  //             Text(userProfile?.name ?? "ユーザー名なし"),
  //             const SizedBox(height: 8.0),
  //             Text(userProfile?.bio ?? "バイオなし"),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context); // ダイアログを閉じる
  //             },
  //             child: Text('閉じる'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = FirebaseAuth.instance.currentUser!.uid == post.posterId;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          !isCurrentUser?
          InkWell(
            onTap: () {
// TODO:タップされた人の情報を取得
//               showModalBottomSheet(
//                 //モーダルの背景の色、透過
//                   backgroundColor: Colors.transparent,
//                   //ドラッグ可能にする（高さもハーフサイズからフルサイズになる様子）
//                   isScrollControlled: true,
//                   context: context,
//                   builder: (BuildContext context) {
//                     return Container(
//                       margin: const EdgeInsets.only(top: 64),
//                       decoration: const BoxDecoration(
//                         //モーダル自体の色
//                         color: Colors.white,
//                         //角丸にする
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20),
//                         ),
//                       ),
//                       child: Stack(
//                         children: [
//                           UserProfileScreen(userProfile: userProfile),
//                           Positioned(
//                             top: 16,
//                             right: 16,
//                             child: IconButton(
//                               icon: Icon(Icons.close),
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   });
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                post.posterImageUrl,
              ),
            ),
          ):
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // toDate() で Timestamp から DateTime に変換できます。
                      DateFormat('MM/dd HH:mm').format(post.createdAt.toDate()),
                      style: const TextStyle(fontSize: 10),
                    ),
                    Text(
                      post.posterName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Container()),
                    IconButton(
                      onPressed: () {
                        // 削除は reference に対して delete() を呼ぶだけでよい。
                        post.reference.delete();
                      },
                      icon: const Icon(
                        Icons.delete,
                        size: 15,
                      ),
                    ),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          // 角丸にするにはこれを追加します。
                          // 4 の数字を大きくするともっと丸くなります。
                          borderRadius: BorderRadius.circular(40),
                          // 色はここで変えられます
                          // [100] この数字を小さくすると色が薄くなります。
                          // [条件式] ? A : B の三項演算子を使っています。
                          color: FirebaseAuth.instance.currentUser!.uid == post.posterId ? Colors.blueAccent[100]: Colors.white,
                        ),
                        child: Text(post.text),
                      ),
                    ),
                  ],
                ),
                // List の中の場合は if 文であっても {} この波かっこはつけなくてよい
              ],
            ),
          ),
          const SizedBox(width: 8),
          !isCurrentUser?
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      post.posterName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      // toDate() で Timestamp から DateTime に変換できます。
                      DateFormat('MM/dd HH:mm').format(post.createdAt.toDate()),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          // 角丸にするにはこれを追加します。
                          // 4 の数字を大きくするともっと丸くなります。
                          borderRadius: BorderRadius.circular(40),
                          // 色はここで変えられます
                          // [100] この数字を小さくすると色が薄くなります。
                          // [条件式] ? A : B の三項演算子を使っています。
                          color: FirebaseAuth.instance.currentUser!.uid == post.posterId ? Colors.blueAccent[100]: Colors.white,
                        ),
                        child: Text(post.text),
                      ),
                    ),
                    if (FirebaseAuth.instance.currentUser!.uid == post.posterId)
                      IconButton(
                        onPressed: () {
                          // 削除は reference に対して delete() を呼ぶだけでよい。
                          post.reference.delete();
                        },
                        icon: const Icon(
                          Icons.delete,
                          size: 15,
                        ),
                      ),
                  ],
                ),
                // List の中の場合は if 文であっても {} この波かっこはつけなくてよい
              ],
            ),
          ):
          InkWell(
            onTap: () {
// TODO:タップされた人の情報を取得
//               showModalBottomSheet(
//                 //モーダルの背景の色、透過
//                   backgroundColor: Colors.transparent,
//                   //ドラッグ可能にする（高さもハーフサイズからフルサイズになる様子）
//                   isScrollControlled: true,
//                   context: context,
//                   builder: (BuildContext context) {
//                     return Container(
//                       margin: const EdgeInsets.only(top: 64),
//                       decoration: const BoxDecoration(
//                         //モーダル自体の色
//                         color: Colors.white,
//                         //角丸にする
//                         borderRadius: BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           topRight: Radius.circular(20),
//                         ),
//                       ),
//                       child: Stack(
//                         children: [
//                           UserProfileScreen(userProfile: userProfile),
//                           Positioned(
//                             top: 16,
//                             right: 16,
//                             child: IconButton(
//                               icon: Icon(Icons.close),
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   });
            },
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                post.posterImageUrl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}