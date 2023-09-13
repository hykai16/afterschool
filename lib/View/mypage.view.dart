import 'package:afterschool/utils/firebase_service.dart';
import 'package:afterschool/view/login.view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../provider/userprofile.provider.dart';
import '../test/profilepage.dart';
import '../utils/global.colors.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.refresh(userProfileProvider);
    final userProfile = ref.watch(userProfileProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/kyositu2.jpg', // 背景画像のパスを指定
              fit: BoxFit.cover, // 画像をカバーするように調整
            ),
          ),
          userProfile.when(
            data: (data) => SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      ClipPath(
                        clipper: MyClipper(),
                        child: Opacity(
                          opacity: 0.3,
                          child: Container(
                            decoration: const BoxDecoration(
                                // gradient: LinearGradient(
                                //   colors: [Color(0xfff36c20), Color(0xffffeb3b)],
                                //   stops: [0, 1],
                                //   begin: Alignment.bottomLeft,
                                //   end: Alignment.topRight,
                                // ),
                                color: CupertinoColors.white),
                            width: double.infinity,
                            height: 200,
                          ),
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
                      //TODO:ここで、フォロー・フォロワーの表示
                      // Positioned(
                      //   top: 60,
                      //   right: 300,
                      //   child:const FollowNumber()
                      // ),
                      // Positioned(
                      //     top: 60,
                      //     right: 40,
                      //     child:const FollowNumber()
                      // ),
                      //顔面と名前
                      Positioned(
                        right: 150,
                        top: 50,
                        child: Column(
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
                                fontFamily: 'Kiwi',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Column(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          const Text(
                            '趣味',
                            style: TextStyle(
                              fontFamily: 'Kiwi',
                              fontSize: 19,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            data.hobby,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Kiwi',
                              fontSize: 25,
                              color: Colors.white,
                            ),),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: [
                          const Text('通ってる学校',
                            style: TextStyle(
                              fontFamily: 'Kiwi',
                              fontSize: 19,
                              color: Colors.white,
                            ),),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(data.school,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Kiwi',
                              fontSize: 25,
                              color: Colors.white,
                            ),),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: [
                          Text('得意科目',
                            style: TextStyle(
                              fontFamily: 'Kiwi',
                              fontSize: 19,
                              color: Colors.white,
                            ),),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(data.favsubject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Kiwi',
                              fontSize: 25,
                              color: Colors.white,
                            ),),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: [
                          Text('自己紹介',
                            style: TextStyle(
                              fontFamily: 'Kiwi',
                              fontSize: 19,
                              color: Colors.white,
                            ),),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(data.bio,
                            maxLines: 8,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Kiwi',
                              fontSize: 25,
                              color: Colors.white,
                            ),),
                        ],
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            loading: () => const CircularProgressIndicator(), // 読み込み中の表示
            error: (error, stackTrace) =>
                Text('Error fetching profile data: $error'), // エラー時の表示
          ),
        ],
      ),
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
        title: const Text('ログアウトしますか？'),
        actions: <Widget>[
          SimpleDialogOption(
            child: const Text('いいえ'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          SimpleDialogOption(
            child: const Text('はい'),
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


class FollowNumber extends StatefulWidget {
  const FollowNumber({super.key});

  @override
  State<FollowNumber> createState() => _FollowNumberState();
}

class _FollowNumberState extends State<FollowNumber> {

  int followersCount = 0;
  int followingCount = 0;

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("フォロー"),
        Text(followersCount.toString()),
      ],
    );
  }
}
