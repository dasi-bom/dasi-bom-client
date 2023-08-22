import 'package:confetti/confetti.dart';
import 'package:dasi_bom_client/MainPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../WritingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterFinish extends StatefulWidget {
  const RegisterFinish({Key? key, this.data}) : super(key: key);
  final data;

  @override
  State<RegisterFinish> createState() => _RegisterFinishState();
}

class _RegisterFinishState extends State<RegisterFinish> {
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['BASE_URL'].toString();
  final getCreateProfile = dotenv.env['GET_CREATE_PROFILE_API'].toString();
  final createInfo = {};

  Future<void> getCreateProfileInfo() async {
    try {
      final data = jsonDecode(widget.data);
      final accessToken = await storage.read(key: 'accessToken');
      final url = Uri.parse('$baseUrl$getCreateProfile');
      final headers = {'Authorization': 'Bearer $accessToken'};

      final res = await http.get(url, headers: headers);
      final status = res.statusCode;
      print('${res.request} ==> $status');
      print(res);

      final info = jsonDecode(res.body);
      if (status == 200) {
        createInfo['nickname'] = info['nickname'];
        createInfo['profileImage'] = info['profileImage'];

        if (info['petProfileResponses'] &&
            info['petProfileResponses'].length > 0) {
          var petId = data['petId'];
          var findItemIdx = info['petProfileResponses'].indexOf(petId);
          createInfo['petName'] =
              info['petProfileResponses'][findItemIdx]['petInfo']['name'];
          createInfo['petProfileImage'] =
              info['petProfileResponses'][findItemIdx]; // 수정 필요
        } else {
          createInfo['petName'] = '';
          createInfo['petProfileImage'] = null;
        }

        // createInfo['petProfileImage'] = info['petProfileImage'];
        print(createInfo);
      } else {
        print('fail');
      }
    } catch (err) {
      print('err => $err');
    }
  }

  // 가입 완료 폭죽 효과
  bool isPlaying = false;
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: const Duration(seconds: 5));
    _controller.play();
    getCreateProfileInfo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Stack(
            children: <Widget>[
              buildConfetti(),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Text(
              '''프로필 등록이 
완료되었습니다!''',
              style: TextStyle(color: Colors.black, fontSize: 25),
              textAlign: TextAlign.center,
            ),
          ),
          if (createInfo['nickname'] != null && createInfo['petName'] != null)
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                '''${createInfo['nickname']}님 반가워요!
오늘부터 ${createInfo['petName']}와 
소중한 일상을 나눠주세요!''',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Text('XXXX'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              createInfo['profileImage'] != null
                  ? SizedBox(
                      child: Image.network(
                        '${createInfo['profileImage']}',
                        width: 100,
                        height: 100,
                      ),
                    )
                  : SizedBox(
                      height: 100,
                      width: 100,
                      child: Image.asset('assets/user_default.png'),
                    ),
              SizedBox(
                height: 100,
                width: 100,
                child: Image.asset('assets/ic_heart.png'),
              ),
              createInfo['petProfileImage'] != null
                  ? SizedBox(
                      child: Image.network(
                        '${createInfo['petProfileImage']}',
                        width: 100,
                        height: 100,
                      ),
                    )
                  : SizedBox(
                      height: 100,
                      width: 100,
                      child: Image.asset('assets/pet_default.png')),
            ],
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
                () async {
                  // 홈 화면으로 이동
                  final result =
                      await Navigator.of(context).push(_createRoute());
                  // getCreateProfileInfo();
                },
              ),
              child: Text(
                "다시,봄 시작하기",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
            Colors.red,
            Colors.blue,
            Colors.orange,
            Colors.yellow,
            Colors.pink,
            Colors.green,
          ],
          shouldLoop: true,
        ),
      );

  // 페이지 전환 애니메이션
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const MainPage(),
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
