import 'package:confetti/confetti.dart';
import 'package:dasi_bom_client/MainPage.dart';
import 'package:dasi_bom_client/mypage/dasibom_content2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../writing/WritingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DasibomContent extends StatefulWidget {
  const DasibomContent({Key? key, this.data}) : super(key: key);
  final data;

  @override
  State<DasibomContent> createState() => _DasibomContentState();
}

class _DasibomContentState extends State<DasibomContent> {
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['BASE_URL'].toString();
  final getCreateProfile = dotenv.env['GET_CREATE_PROFILE_API'].toString();
  var count = 0;
  Map createInfo = {};

  // 가입 완료 폭죽 효과
  bool isPlaying = false;
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 1));
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xffFDFAEE),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/main');
              },
              child: Icon(
                Icons.close_sharp,
                color: Colors.black,
              ),
            ),
          ),
          Stack(
            children: <Widget>[
              buildConfetti(),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Text(
                  '다시,봄 카드가',
                  style: TextStyle(color: Colors.black, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '도착했어요!',
                  style: TextStyle(color: Colors.black, fontSize: 25),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 150,
            width: 150,
            child: Image.asset('assets/ic_envelope.png'),
          ),
          createInfo['profileImage'] != null
              ? SizedBox(
                  child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network('${createInfo['profileImage']}',
                      width: 100, height: 100, fit: BoxFit.cover),
                ))
              : SizedBox(
                  height: 100,
                  width: 100,
                  child: Image.asset('assets/user_default.png'),
                ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            height: 50,
            width: 350,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
                backgroundColor: MaterialStateProperty.all(Color(0xFFFFED8E)),
              ),
              onPressed: () => setState(
                () {
                  // 홈 화면으로 이동
                  final result = Navigator.of(context).push(_createRoute());
                  // getCreateProfileInfo();
                },
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "카야",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "와의 추억을 다시, 봄",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }

  // 폭죽 효과 애니메이션
  Widget buildConfetti() => Align(
        alignment: Alignment.center,
        child: ConfettiWidget(
          confettiController: _controller,
          blastDirectionality: BlastDirectionality.explosive,
          colors: [
            Colors.yellowAccent,
          ],
          shouldLoop: false,
        ),
      );

  // 페이지 전환 애니메이션
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const DasibomContent2(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 10.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
