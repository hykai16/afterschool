import 'package:afterschool/test/mypagetest.dart';
import 'package:afterschool/utils/global.colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_sign_in/google_sign_in.dart';


import 'guest.view.dart';
import 'home.view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  Future<void> signInWithGoogle() async {
    // GoogleSignIn をして得られた情報を Firebase と関連づけることをやっています。
    // final googleUser = await GoogleSignIn(scopes: ['profile', 'email'])
    //     .signIn();
    //
    // final googleAuth = await googleUser?.authentication;
    //
    // final credential = GoogleAuthProvider.credential(
    //   accessToken: googleAuth?.accessToken,
    //   idToken: googleAuth?.idToken,
    // );
    //
    // await FirebaseAuth.instance.signInWithCredential(credential);
      try {
        //Google認証フローを起動する
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        //リクエストから認証情報を取得する
        final googleAuth = await googleUser?.authentication;
        //firebaseAuthで認証を行う為、credentialを作成
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        //作成したcredentialを元にfirebaseAuthで認証を行う
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.additionalUserInfo!.isNewUser) {
          //新規ユーザーの場合の処理
          print("new");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
              return ProfileInputScreen();
            }),
                (route) => false,
          );
        } else {
          //既存ユーザーの場合の処理
          print("exist");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) {
              //TODO:基本はHOMEView TestはMyPagedayo()
              return const HomeView();
            }),
                (route) => false,
          );
        }
      } on FirebaseException catch (e) {
        print(e.message);
      } catch (e) {
        print(e);
      }
  }



  //匿名サインイン
  Future<void> _onSignInWithAnonymousUser() async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    try{
      await firebaseAuth.signInAnonymously();

      Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const HomeView(),
          )
      );
    } catch(e) {
      await showDialog(
          context: context,
          builder: (context) {
            print(e.toString());
            return AlertDialog(
              title: Text('エラー'),
              content: Text(e.toString()),
            );
          }
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 200),
          child: Center(
            child: Column(
              children: [
                const Text(
                  'HELLO!',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 60,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Rem',
                  ),
                ),
                const Text('Please sign in to continue:-)',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold
                  ),),

                const SizedBox(height: 150,),
                Text("Sign up",
                  style: TextStyle(
                    color: GlobalColors.mainColor,
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Dosis',
                  ),),
                const SizedBox(height: 10,),
                Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 300,
                        height: 150,
                        decoration: BoxDecoration(
                          color: GlobalColors.mainColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 80),
                      child: Column(children: [
                        SignInButton(
                          Buttons.Google,
                          onPressed: () async {
                            await signInWithGoogle();
                            // ログインが成功すると FirebaseAuth.instance.currentUser にログイン中のユーザーの情報が入ります
                            print(FirebaseAuth.instance.currentUser?.displayName);
                          },
                        ),
                        const SizedBox(height: 10,),
                        ElevatedButton(style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                            fixedSize: Size(220, 25)),
                            onPressed: (){
                              _onSignInWithAnonymousUser();
                            }, child:
                            Row(
                              children: const [
                                Icon(Icons.account_circle,
                                  color: Colors.black54,),

                                SizedBox(width: 58,),
                                Text("Guest",
                                  style: TextStyle(
                                      color: Colors.black54
                                  ),),
                              ],
                            )),
                      ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
