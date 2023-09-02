import 'package:afterschool/utils/chatroomdata.dart';
import 'package:afterschool/utils/userdata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // 他のメソッドやコード...

  Future<void> saveUserProfile(UserProfile profile) async {
    final userProfileCollection = FirebaseFirestore.instance.collection('profiles');

    // userID をドキュメントIDとして指定してドキュメントを作成
    final userDoc = userProfileCollection.doc(profile.userID);

    await userDoc.set(profile.toMap()); // モデルの toMap メソッドを使用
  }

  Future<void> createNewRoom(ChatRoom chatRoom) async{
    final chatRoomCollection = FirebaseFirestore.instance.collection('chat_rooms');

    // チャットルームを追加し、追加後のドキュメント参照を取得
    final DocumentReference newChatRoomDocRef = await chatRoomCollection.add(chatRoom.toMap());

    // チャットルームに対応するサブコレクションを作成
    final CollectionReference seatsCollection = newChatRoomDocRef.collection('seats');

    // 1から8までのドキュメントを追加
    for (int i = 1; i <= 8; i++) {
      await seatsCollection.doc('$i').set({
        'userID': null,
        'aim': null,
        // 他のフィールドも追加
      });
    }
  }


  DocumentReference getUserProfileReference(String userID) {
    return FirebaseFirestore.instance
        .collection('profiles')
        .doc(userID);
  }
}
