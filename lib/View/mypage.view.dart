import 'package:afterschool/view/chat.view.dart';
import 'package:afterschool/view/login.view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../provider/userprofile.provider.dart';
import '../test/profilepage.dart';
import '../utils/getProfileData.dart';
import '../utils/global.colors.dart';
import '../utils/post.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  // final user = FirebaseAuth.instance.currentUser!;
  // final imano_loginshiteru_userno_id = FirebaseAuth.instance.currentUser!.uid;
  // //List<Map<String, dynamic>> _profileData = [];
  // String nameText = "";
  // String iconImageURL = "";

  //①
  // void _getProfileData() {
  //   ProfileUtils.getProfileData(imano_loginshiteru_userno_id, (name, iconUrl) {
  //     setState(() {
  //       nameText = name;
  //       iconImageURL = iconUrl;
  //     });
  //   });
  // }

  //②
  // void _getProfileData() async {
  //   List<String>? profileData = await ProfileUtils.getProfileData(imano_loginshiteru_userno_id);
  //   setState(() {
  //     if (profileData != null) {
  //       nameText = profileData[0];
  //       iconImageURL = profileData[1];
  //     } else {
  //       print('Profile data not available or an error occurred.');
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalColors.homecolor,
      body: Column(
        children: [
          Stack(children: [
            ClipPath(
              clipper: MyClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xfff36c20), Color(0xffffeb3b)],
                    stops: [0, 1],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                width: double.infinity,
                height: 200,
              ),
            ),
            Positioned(
              top: 60,
              right: 300,
              child: IconButton(
                  onPressed: () {
                    Get.to(ProfileInputScreen());
                  },
                  icon: const Icon(
                    Icons.manage_accounts_sharp,
                    size: 30,
                  )),
            ),
            Positioned(
              top: 60,
              right: 40,
              child: IconButton(
                  onPressed: () {
                    showDialog<void>(
                        context: context,
                        builder: (_) {
                          return const MyAlertDialog();
                        });
                  },
                  icon: Icon(Icons.logout)),
            ),
            const Positioned(
              right: 150,
              top: 50,
              child: UserProfileWidget()
            ),
          ]),
          const SizedBox(
            height: 20,
          ),
          // Stack(children: [
          //   Container(
          //     width: 370,
          //     height: 240,
          //     decoration: BoxDecoration(
          //       color: kBackgroundColor,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //   ),
          //   Text("フレンド",
          //     style: TextStyle(
          //       color: Colors.white,
          //       fontSize: 25,
          //       fontWeight: FontWeight.bold,
          //     ),)
          // ]),
          // SizedBox(
          //   height: 20,
          // ),
          // Stack(children: [
          //   Container(
          //     width: 370,
          //     height: 240,
          //     decoration: BoxDecoration(
          //       color: kBackgroundColor,
          //       borderRadius: BorderRadius.circular(10),
          //     ),
          //   ),
          //   Text(
          //     "今月の勉強時間",
          //     style: TextStyle(
          //       color: Colors.white,
          //       fontSize: 25,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   )
          // ]),
        ],
      ),

      //     child: Column(
      //
      //           Align(
      //             alignment: Alignment.centerLeft,
      //             // ユーザー ID
      //             child: Text('ユーザーID：${user.uid}'),
      //           ),
      //           ElevatedButton(onPressed: (){
      //             //Get.to(ChatView(chatRoom: null,));
      //           }, child:
      //           Text('chat')),
      //           const SizedBox(height: 16),
      //
      //         ],
      //       ),
      //   ),
    );
  }
}

class MyAlertDialog extends StatelessWidget {
  const MyAlertDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // プラットフォームをチェックして異なるダイアログを表示
    if (Theme.of(context).platform == TargetPlatform.android) {
      // Androidの場合はAlertDialogを表示
      return AlertDialog(
        title: Text('ログアウトしますか？'),
        actions: <Widget>[
          SimpleDialogOption(
            child: Text('いいえ'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          SimpleDialogOption(
            child: Text('はい'),
            onPressed: () async {
              // Google からサインアウト
              await GoogleSignIn().signOut();
              // Firebase からサインアウト
              await FirebaseAuth.instance.signOut();
              // SignInPage に遷移
              // このページには戻れないようにします。
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) {
                  return const LoginView();
                }),
                    (route) => false,
              );
            },
          )
        ],
      );
    } else {
      return CupertinoAlertDialog(
        title: const Text('ログアウトしますか？'),
        actions: <Widget>[
          CupertinoDialogAction(
            child: const Text('いいえ'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          CupertinoDialogAction(
            child: const Text('はい'),
            isDestructiveAction: true,
            onPressed: () async {
              // Google からサインアウト
              await GoogleSignIn().signOut();
              // Firebase からサインアウト
              await FirebaseAuth.instance.signOut();
              // SignInPage に遷移
              // このページには戻れないようにします。
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) {
                  return const LoginView();
                }),
                    (route) => false,
              );
            },
          )
        ],
      );
    }
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double w = size.width; //親Widgetのwidth
    double h = size.height / 1.2; //親Widetのheight

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, h);
    path.quadraticBezierTo(w / 2, h * 1.4, w, h);
    path.lineTo(w, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}











// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
//
// class MyPage extends StatefulWidget {
//   const MyPage({super.key});
//
//   @override
//   State<MyPage> createState() => _MyPageState();
// }
//
// class _MyPageState extends State<MyPage> {
//   String? userID;
//   late Stream<QuerySnapshot<Map<String, dynamic>>> user;
//
//   @override
//   void initState() {
//     super.initState();
//     userID = FirebaseAuth.instance.currentUser!.uid; // user変数にログイン中のユーザー情報を代入
//     print(userID);
//     user = FirebaseFirestore.instance
//         .collection('profiles')
//         .where('userID', isEqualTo: userID)
//         .snapshots();
//   }
//   final images = [
//     "https://imgs.aixifan.com/content/2020_4_9/1.5863761151962674E9.jpeg",
//     "https://i.pinimg.com/originals/2a/ec/1d/2aec1d13eac7e352f39151a9ad4c7184.jpg",
//     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTNtwEkHNXl12D2nN_zsohja2Ta5CipVd4Z46fxZwv2EH3P7_AhsJBQVovR5V-6XhIsVoA&usqp=CAU",
//   ];
//   int activeIndex = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 children: [
//                   Image.network(
//                     "https://static.xx.fbcdn.net/rsrc.php/v3/y_/r/2wPYyq9Ejn4.png",
//                     width: 20,
//                     height: 20,
//                   ),
//                   SizedBox(width: 8,),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         //TODO ここをuser.nameに変更
//                         "テスト",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           fontSize: 12,
//                         ),
//                       )
//                     ],
//                   ),
//                   Expanded(child: SizedBox()),
//                   Icon(Icons.more_horiz),
//                 ],
//               ),
//             ),
//             Stack(
//                 children:[
//                   CarouselSlider.builder(
//                     options: CarouselOptions(
//                       height: 400,
//                       initialPage: 0,
//                       viewportFraction: 1,
//                       enlargeCenterPage: true,
//                       onPageChanged: (index, reason) {
//                         setState(() {
//                           activeIndex = index;
//                         });
//                       },
//                     ),
//                     itemCount: images.length,
//                     itemBuilder: (context, index, realIndex) {
//                       final path = images[index];
//                       return buildImage(path, index);
//                     },
//                   ),
//                   Positioned(
//                     right: 10,
//                     top: 10,
//                     child: Container(
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: Colors.black.withOpacity(0.6),
//                       ),
//                       child:
//                       Text(
//                         "${activeIndex + 1}/${images.length}",
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                   Positioned(
//                     left: 10,
//                     bottom: 10,
//                     child: Container(
//                         padding: EdgeInsets.all(2),
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           color: Colors.black.withOpacity(0.6),
//                         ),
//                         child:
//                         Icon(Icons.person,
//                           color: Colors.white,)
//                     ),
//                   )
//                 ]
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: Row(
//                 children: [
//                   Icon(Icons.favorite_border,color: Colors.black,size: 35,),
//                   SizedBox(width: 10,),
//                   Icon(Icons.chat_bubble_outline,color: Colors.black,size: 35,),
//                   SizedBox(width:10),
//                   Icon(Icons.send,color: Colors.black,size: 35,),
//                   SizedBox(width:60),
//                   buildIndicator(),
//                   Expanded(child: SizedBox()),
//                   Icon(Icons.turned_in_not,color: Colors.black,size: 35,),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(6.0),
//               child: const Text(
//                 '「いいね！」704,899件',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: const Text(
//                 "ダーリンインザフランキスの02はかわいい。とてもかわいい。いいアニメだからぜひ見てみてください。かわいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいいい",
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 12,
//                 ),
//               ),
//             )
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildImage(path, index) => Container(
//     margin: EdgeInsets.symmetric(horizontal: 0),
//     color: Colors.grey,
//     child: Image.network(
//       path,
//       fit: BoxFit.cover,
//     ),
//   );
//
//   Widget buildIndicator() => AnimatedSmoothIndicator(
//     activeIndex: activeIndex,
//     count: images.length,
//     effect: JumpingDotEffect(
//       dotHeight: 6,
//       dotWidth: 6,
//       activeDotColor: Colors.green,
//       dotColor: Colors.grey,
//     ),
//   );
// }
