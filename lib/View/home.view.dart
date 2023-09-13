// ignore_for_file: use_build_context_synchronously

import 'package:afterschool/View/login.view.dart';
import 'package:afterschool/View/newroom.view.dart';
import 'package:afterschool/View/roomsearch.view.dart';
import 'package:afterschool/test/pagetest.dart';
import 'package:afterschool/utils/global.colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';

import '../test/profilepage.dart';
import 'mypage.view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  final _pageWidgets = [
    const HomePage(),
    const RoomSearchView(),
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   //  （1） タイトルの指定
        //   title: Text("After School"),
        //   centerTitle: true,
        //   // （2） 背景色の指定
        //   backgroundColor: Colors.white,
        //   // （3） 左アイコン
        //   leading: IconButton(
        //     icon: const Icon(Icons.logout),
        //     onPressed: () {
        //       showDialog<void>(
        //           context: context,
        //           builder: (_) {
        //             return const MyAlertDialog();
        //           });
        //     }
        //   ),
        //   // （4） 右アイコン
        //   actions: [
        //     IconButton(icon: const Icon(Icons.add), onPressed: (){
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => const CreateNewRoom()),
        //       );
        //     }),
        //   ],
        // ),
        body: _pageWidgets.elementAt(_currentIndex),
        bottomNavigationBar: SizedBox(
          height: 87,
          child: BottomNavigationBar(
            selectedItemColor: GlobalColors.mainColor,
            selectedLabelStyle: TextStyle(
              fontFamily: 'Kiwi'
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Kiwi'
            ),
            iconSize: 18,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'mypage'),
              BottomNavigationBarItem(icon: Icon(Icons.border_color_sharp), label: 'rooms'),
            ],
            currentIndex: _currentIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
          ),
        ),
    );
  }
  //indexをタップされたものに変える
  void _onItemTapped(int index) => setState(() => _currentIndex = index );
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
            child: const Text('はい'),
          )
        ],
      );
    }
  }
}

