import 'package:afterschool/utils/global.colors.dart';
import 'package:flutter/material.dart';

import '../utils/userdata.dart';

class UserProfileScreen extends StatelessWidget {
  final UserProfile userProfile;

  const UserProfileScreen({Key? key, required this.userProfile}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/kyositu.png'),
            fit: BoxFit.fill,
        )),
        //   gradient: LinearGradient(
        //     colors: [
        //       Colors.red,
        //       Colors.orange,
        //       Colors.yellow,
        //       Colors.green,
        //       Colors.blue,
        //       Colors.indigo,
        //       Colors.purple,
        //     ],
        //     begin: Alignment.topLeft,
        //     end: Alignment.bottomRight,
        //     stops: [0.0, 0.1, 0.2, 0.3, 0.4, 0.6, 1.0],
        //   ),
        // ),
          child: Stack(
            children: [
              Container(
                color: Colors.white.withOpacity(0.5),
                width: 400,
                height: 800,
              ),
              Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(userProfile.iconImageUrl),
                ),
                const SizedBox(height: 10),
                Text(
                  '名前',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 10),
                Text(userProfile.name,
                  style: TextStyle(fontSize: 18,
                  color: Colors.black
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '趣味',
                  style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 10),
                Text(userProfile.hobby,
                  style: TextStyle(fontSize: 18,
                      color: Colors.black),
                ),
                const SizedBox(height: 10),
                Text(
                  '自己紹介',
                  style: TextStyle(fontSize: 18,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 10),
                Text(userProfile.bio,
                  style: TextStyle(fontSize: 18,
                      color: Colors.black),
                ),
              ],
            ),
        ]
          ),
        ),
      );
  }
}
