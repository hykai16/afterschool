// const functions = require('firebase-functions');
// const admin = require('firebase-admin');
// admin.initializeApp();
//
// // 4時にDailyStudyTimeをリセットする関数
// exports.resetDailyStudyTime = functions.pubsub.schedule('0 4 * * *')
// .timeZone('Asia/Tokyo') // タイムゾーンを指定
//     .onRun(async (context) => {
// // DailyStudyTimeをリセットする処理をここに記述
// const db = admin.firestore();
//
// // すべてのユーザーのDailyStudyTimeをリセット
// const usersRef = db.collection('profiles');
// const usersSnapshot = await usersRef.get();
// usersSnapshot.forEach(async (doc) => {
// const userData = doc.data();
// await doc.ref.update({
// dailyStudyTime: 0
// });
// });
//
// return null;
// });
