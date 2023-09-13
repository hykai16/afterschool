import 'package:afterschool/utils/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/userdata.dart';

final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final user = await FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('profiles').doc(user.uid);
      final userSnapshot = await userDoc.get();
      if (userSnapshot.exists) {
        FirebaseService.updateUserProfileLastLoginTime(user.uid);
        return UserProfile.fromFirestore(userSnapshot);
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }
  return UserProfile(
    name: 'ゲスト',
    grade: 'No Data',
    iconImageUrl:
        'https://ascii.jp/img/2023/05/01/3531840/l/f3cf566db48c40e1.png',
    location: 'No Data',
    hobby: 'No Data',
    school: 'underground',
    favsubject: 'No Data',
    bio: 'Welcome to Our School',
    userID: 'ex',
    reference: FirebaseFirestore.instance
        .collection('dummy')
        .doc(), // ダミーの reference を指定
    lastLoginTime:Timestamp.now(), // 追加: 最終ログイン時間
    dailyStudyTime:0, // 追加: デイリーの学習時間（例: 分単位）
    totalStudyTime:0, // 追加: これまでのトータル学習時間（例: 分単位）
    // friendRequests: [],
    // friends: [],
  );
});

// class UserProfileWidget extends ConsumerWidget {
//   const UserProfileWidget({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     ref.refresh(userProfileProvider);
//     final userProfile = ref.watch(userProfileProvider);
//     return userProfile.when(
//       data: (data) => Column(
//         children: [
//           CircleAvatar(
//             backgroundImage: NetworkImage(data.iconImageUrl),
//             radius: 45,
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           Text(
//             data.name,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 20,
//               fontFamily: 'Kiwi',
//             ),
//           ),
//           //TODO:ここより下を別ウィジェットにしたいのだが、userProfileProviderは適用したい。どうすれば？
//           Column(
//             children: [
//               Row(children: [
//                 Text('趣味'),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Text(data.hobby)
//               ]),
//               const SizedBox(
//                 height: 10,
//               ),
//               Row(children: [
//                 Text('通ってる学校'),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Text(data.school)
//               ]),
//               const SizedBox(
//                 height: 10,
//               ),
//               Row(children: [
//                 Text('得意科目'),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Text(data.favsubject)
//               ]),
//               const SizedBox(
//                 height: 10,
//               ),
//               Row(children: [
//                 Text('自己紹介文'),
//                 SizedBox(
//                   width: 10,
//                 ),
//                 Text(data.bio)
//               ]),
//             ],
//           ),
//         ],
//       ),
//
//       loading: () => const CircularProgressIndicator(), // 読み込み中の表示
//       error: (error, stackTrace) =>
//           Text('Error fetching profile data: $error'), // エラー時の表示
//     );
//   }
// }
//
// class ProfileDetailsWidget extends StatelessWidget {
//   final UserProfile data;
//
//   const ProfileDetailsWidget({required this.data, Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: [
//             Text('趣味'),
//             SizedBox(
//               width: 10,
//             ),
//             Text(data.hobby),
//           ],
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//         Row(
//           children: [
//             Text('通ってる学校'),
//             SizedBox(
//               width: 10,
//             ),
//             Text(data.school),
//           ],
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//         Row(
//           children: [
//             Text('得意科目'),
//             SizedBox(
//               width: 10,
//             ),
//             Text(data.favsubject),
//           ],
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//         Row(
//           children: [
//             Text('自己紹介文'),
//             SizedBox(
//               width: 10,
//             ),
//             Text(data.bio),
//           ],
//         ),
//       ],
//     );
//   }
// }


