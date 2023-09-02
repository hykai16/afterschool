// import 'package:afterschool/utils/chatroomdata.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
//
// import 'chatRoom.provider.dart';
//
// final seatsProvider = StreamProvider.autoDispose.family<Seat?, int>((ref, seatNumber) {
//   final chatRoom = ref.watch(chatRoomProvider); // chatRoomProvider を適切に置き換える必要があります
//   final seatRefs = chatRoom.seatsRef;
//   final seatDoc = seatRefs.doc('$seatNumber');
//
//   return seatDoc.snapshots().map((seatSnapshot) {
//     if (seatSnapshot.exists) {
//       final seatData = seatSnapshot.data();
//       return Seat(
//         occupied: seatData['occupied'],
//         aim: seatData['aim'],
//       );
//     } else {
//       print('Seat document does not exist.');
//       return null;
//     }
//   });
// });