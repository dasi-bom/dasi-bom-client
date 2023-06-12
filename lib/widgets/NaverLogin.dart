import 'package:flutter/material.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';

class NaverLoginButton extends StatefulWidget {
  const NaverLoginButton({Key? key}) : super(key: key);

  @override
  State<NaverLoginButton> createState() => _NaverLoginButtonState();
}

class _NaverLoginButtonState extends State<NaverLoginButton> {
  bool isLogin = false;
  String? name;
  String? email;
  String? accessToken;
  String? refreshToken;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 340,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 50),
          child: ElevatedButton(
            onPressed: () {
              print('naver login');
              signInWithNaver();
            },
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(
                  Color.fromRGBO(3, 199, 90, 1)),
            ),
            child: Image.asset(
              'assets/naver_login_btn.png',
              fit: BoxFit.fill,
              height: 60,
            ),
          ),
        ));
  }

  Future<void> signInWithNaver() async {
    try {
      final NaverLoginResult res = await FlutterNaverLogin.logIn();
      print(res);
      setState(() {
        isLogin = true;
        name = res.account.name;
        email = res.account.email;
        print(res.accessToken);
      });
    } catch (err) {
      print(err);
    }
  }

  Future<void> signOut() async {
    try {
      await FlutterNaverLogin.logOut();
      setState(() {
        isLogin = false;
        name = null;
        email = null;
        accessToken = null;
      });
    } catch (err) {
      print(err);
    }
  }
}
