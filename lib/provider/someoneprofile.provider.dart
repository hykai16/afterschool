import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/userdata.dart';

final someoneProfileProvider = FutureProvider.family<UserProfile,String>((ref,id) async {
  //idで検索をかけます。
  final userDoc = FirebaseFirestore.instance.collection('profiles').doc(id);
  try {
    final userSnapshot = await userDoc.get();
    if (userSnapshot.exists) {
      return UserProfile.fromFirestore(userSnapshot);
    }
  } catch (e) {
    print('Error fetching profile data: $e');
  }
  return UserProfile(
    name: 'ゲスト',
    grade: 'No Data',
    iconImageUrl: 'https://www.google.com/url?sa=i&url=https%3A%2F%2Fleaf.aquaplus.jp%2Fproduct%2Fth2x%2Fif_chr2.html&psig=AOvVaw2flXMe5YcfpHqEWYTuJwgw&ust=1693326081014000&source=images&cd=vfe&opi=89978449&ved=0CBAQjRxqFwoTCKC0x6_h_4ADFQAAAAAdAAAAABAD',
    location: 'No Data',
    bio: 'Welcome to Our School',
    userID: 'ex',
    reference: FirebaseFirestore.instance.collection('dummy').doc(), // ダミーの reference を指定
    // friendRequests: [],
    // friends: [],
  );
});