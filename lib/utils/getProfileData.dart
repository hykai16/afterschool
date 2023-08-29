
import 'package:cloud_firestore/cloud_firestore.dart';
 import 'package:firebase_auth/firebase_auth.dart';

 class ProfileUtils {
   static Future<List<String>?> getProfileData(String userID) async {
     try {
       final userDoc = FirebaseFirestore.instance.collection('profiles').doc(userID);
       final userSnapshot = await userDoc.get();
       if (userSnapshot.exists) {
         final name = userSnapshot['name'];
         final iconUrl = userSnapshot['iconUrl'];
         return [name, iconUrl];
       }
     } catch (e) {
       print('Error fetching profile data: $e');
     }
     return null; // データが存在しない場合やエラーが発生した場合は null を返す
   }
 }



 // class ProfileUtils {
//   static Future<void> getProfileData(String userID, Function(String, String) onProfileDataFetched) async {
//     try {
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('profiles')
//           .where('userID', isEqualTo: userID)
//           .get();
//
//       final profileData = querySnapshot.docs
//           .map((doc) => doc.data() as Map<String, dynamic>)
//           .toList();
//
//       if (profileData.isNotEmpty) {
//         final nameText = profileData[0]["name"];
//         final iconImageUrl = profileData[0]["iconImageUrl"]; // アイコンのURLを取得
//
//         onProfileDataFetched(nameText, iconImageUrl); // 引数を追加してコールバック関数を呼び出す
//       } else {
//         final nameText = "ゲスト";
//         final iconImageUrl = "デフォルトのアイコンURL"; // デフォルトのアイコンURLを指定
//         onProfileDataFetched(nameText, iconImageUrl); // 引数を追加してコールバック関数を呼び出す
//       }
//     } catch (error) {
//       print("Error: $error");
//     }
//   }
// }
