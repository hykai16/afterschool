import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/userdata.dart';

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  //そもそもここが動かないのどうして？？
  print("動いてんで");
  if (user != null) {
    try {
      final userDoc = FirebaseFirestore.instance.collection('profiles').doc(user.uid);
      final userSnapshot = await userDoc.get();
      print("ヌルちゃうで");
      if (userSnapshot.exists) {
        return UserProfile.fromFirestore(userSnapshot);
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }
  return UserProfile(
    name: 'ゲスト',
    grade: 'No Data',
    iconImageUrl: 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fleaf.aquaplus.jp%2Fproduct%2Fth2x%2Fif_chr2.html&psig=AOvVaw2flXMe5YcfpHqEWYTuJwgw&ust=1693326081014000&source=images&cd=vfe&opi=89978449&ved=0CBAQjRxqFwoTCKC0x6_h_4ADFQAAAAAdAAAAABAD',
    location: 'No Data',
    bio: 'Welcome to Our School',
    userID: 'ex',
    reference: FirebaseFirestore.instance.collection('dummy').doc(), // ダミーの reference を指定
  );
});

class UserProfileWidget extends ConsumerWidget {
  const UserProfileWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
