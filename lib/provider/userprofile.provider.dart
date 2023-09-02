import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/userdata.dart';

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final user = await FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('profiles').doc(user.uid);
      final userSnapshot = await userDoc.get();
      print(userSnapshot);
      if (userSnapshot.exists) {
        print("get");
        return UserProfile.fromFirestore(userSnapshot);
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }
  return UserProfile(
    name: 'ゲスト',
    grade: 'No Data',
    iconImageUrl: 'https://ascii.jp/img/2023/05/01/3531840/l/f3cf566db48c40e1.png',
    location: 'No Data',
    bio: 'Welcome to Our School',
    userID: 'ex',
    reference: FirebaseFirestore.instance.collection('dummy').doc(), // ダミーの reference を指定
    // friendRequests: [],
    // friends: [],
  );
});

class UserProfileWidget extends ConsumerWidget {
  const UserProfileWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.refresh(userProfileProvider);
    final userProfile = ref.watch(userProfileProvider);
    return userProfile.when(
      data: (data) =>
          Column(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(data.iconImageUrl),
                radius: 45,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                data.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
      loading: () => const CircularProgressIndicator(), // 読み込み中の表示
      error: (error, stackTrace) =>
          Text('Error fetching profile data: $error'), // エラー時の表示
    );
  }
}
