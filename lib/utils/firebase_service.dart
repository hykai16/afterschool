import 'package:afterschool/utils/chatroomdata.dart';
import 'package:afterschool/utils/userdata.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // 他のメソッドやコード...

  Future<void> saveUserProfile(UserProfile profile) async {
    final userProfileCollection = FirebaseFirestore.instance.collection('profiles');

    await userProfileCollection.add(profile.toMap()); // モデルの toMap メソッドを使用
  }

  Future<void> createNewRoom(ChatRoom chatRoom) async{
    final chatRoomCollection = FirebaseFirestore.instance.collection('chat_rooms');

    await chatRoomCollection.add(chatRoom.toMap());
  }

  DocumentReference getUserProfileReference(String userID) {
    return FirebaseFirestore.instance
        .collection('profiles')
        .doc(userID);
  }
}
