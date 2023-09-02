import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/chatroomdata.dart';

final chatRoomProvider = StreamProvider<List<ChatRoom>>((ref) {
  final chatRoomsCollection = FirebaseFirestore.instance.collection('chatRooms');
  return chatRoomsCollection.snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => ChatRoom.fromSnapshot(doc)).toList();
  });
});

final currentChatRoomProvider = FutureProvider.family<ChatRoom,String>((ref,chatRoomId) async {
//idで検索をかけます。
final chatRoomDoc = FirebaseFirestore.instance.collection('id').doc(chatRoomId);
try {
final chatRoomSnapshot = await chatRoomDoc.get();
if (chatRoomSnapshot.exists) {
return ChatRoom.fromSnapshot(chatRoomSnapshot);
}
} catch (e) {
print('Error fetching profile data: $e');
}
return ChatRoom(
    id: "id",
    title: "title",
    introduce: "your room",
    creator: "Yuma",
    participants: [],
    public: true,
    createdAt: Timestamp.now(),
    reference: FirebaseFirestore.instance.collection('dummy').doc(),
    seatsRef: FirebaseFirestore.instance.collection('dummy'));
});

