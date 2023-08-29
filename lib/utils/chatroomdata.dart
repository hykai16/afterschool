import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String title;
  final String introduce;
  final String creator;
  final bool public;
  final List<String> participants;
  final Timestamp createdAt; // ドキュメント作成日時
  /// Firestoreのどこにデータが存在するかを表すpath情報
  final DocumentReference reference;
  final String? passcode; // 新たに追加
  final CollectionReference seatsRef;


  ChatRoom({
    required this.id,
    required this.title,
    required this.introduce,
    required this.creator,
    required this.participants,
    required this.public,
    required this.createdAt,
    required this.reference,
    this.passcode, // パスコードを追加
    required this.seatsRef,
  });

  factory ChatRoom.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return ChatRoom(
      id: snapshot.id,
      title: data['title'],
      introduce: data['introduce'],
      creator: data['creator'],
      participants: List<String>.from(data['participants']),
      public: data['public'],
      createdAt: data['createdAt'],
        reference: snapshot.reference,
      passcode: data['passcode'], // パスコードを追加
      seatsRef: snapshot.reference.collection("seats"),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'introduce':introduce,
      'creator': creator,
      'participants': participants,
      'public': public,
      'createdAt': createdAt,
      'passcode': passcode, // パスコードを追加
    };
  }
}

class Seat{
  final bool occupied;
  final String aim;

  Seat({
    required this.occupied,
    required this.aim
  });
}