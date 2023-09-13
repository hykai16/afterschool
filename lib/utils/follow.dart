import 'package:cloud_firestore/cloud_firestore.dart';

class Follow {
  final String userId;
  final List<String> follower;
  final List<String> following; // フォローしているユーザーIDのリスト

  Follow({
    required this.userId,
    required this.follower,
    required this.following,
  });

  // UserオブジェクトをFirestoreにマップするためのメソッド
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'follower': follower,
      'following': following,
    };
  }
}

final firestore = FirebaseFirestore.instance;


void followUser(String myId, String yourId) async {
  final myRef = firestore.collection('profiles').doc(myId).collection('Follow').doc();
  final yourRef = firestore.collection('profiles').doc(yourId).collection('Follow').doc();
  final myDoc = await myRef.get();
  final yourDoc = await yourRef.get();

  if (yourDoc.exists && myDoc.exists) {
    final myData = myDoc.data() as Map<String, dynamic>;
    final yourData = yourDoc.data() as Map<String, dynamic>;
    final List<String> myFollow = List<String>.from(myData['following'] ?? []);
    final List<String> yourFollower = List<String>.from(yourData['follower'] ?? []);
    myFollow.add(myId);
    yourFollower.add(myId);

    // フォロー情報を更新
    await myRef.update({'following':myFollow});
    await yourRef.update({'follower':yourFollower});
  }
}

