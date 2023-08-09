import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'widgets/Kakao_Login.dart';
import 'widgets/main_view_model.dart';
import 'package:dasi_bom_client/widgets/NaverLogin.dart';
import 'package:dasi_bom_client/MainPage.dart';
import 'package:dasi_bom_client/profile/profile_register_pro.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final storage = FlutterSecureStorage(); // Create storage
  final baseUrl = dotenv.env['BASE_URL'].toString();
  final urlScheme = dotenv.env['URL_SCHEME'].toString();
  final kakaoRedirectUri = dotenv.env['KAKAO_REDIRECT_URI'].toString();
  final kakaoAuthEndpoint =
      dotenv.env['KAKAO_AUTHORIZATION_ENDPOINT'].toString();

  // 로그인 생성자 생성
  final viewModel = MainViewModel(KakaoLogin());

  @override
  Widget build(BuildContext context) {
    // 화면 크기
    Size screenSize(BuildContext context) {
      return MediaQuery.of(context).size;
    }

    // 화면 높이
    double screenHeight(BuildContext context, {double dividedBy = 1}) {
      return screenSize(context).height / dividedBy;
    }

    // 화면 너비
    double screenWidth(BuildContext context, {double dividedBy = 1}) {
      return screenSize(context).width / dividedBy;
    }

    //상단 툴바를 제외한 화면 높이
    double screenHeightExcludingToolbar(BuildContext context,
        {double dividedBy = 1}) {
      return screenHeight(context, dividedBy: dividedBy);
    }

    Future<void> signIn() async {
      final redirectUri = Uri.parse('$baseUrl$kakaoRedirectUri');
      final authorizationEndpoint = Uri.parse('$baseUrl$kakaoAuthEndpoint');

      final result = await FlutterWebAuth.authenticate(
          url: '$authorizationEndpoint?redirect_uri=$redirectUri',
          callbackUrlScheme: urlScheme);

      if (result != null && result.isNotEmpty) {
        final res = await http.get(Uri.parse('$redirectUri?token=$result'));

        print('status ===>  ${res.statusCode}');
        if (res.statusCode == 200) {
          Uri tokenUrl = Uri.parse(result);
          final accessToken = tokenUrl.queryParameters["token"]; // token 값 가져오기
          final isNewMember = tokenUrl.queryParameters['isNewMember'];

          await storage.write(
              key: 'accessToken', value: accessToken.toString());
          await storage.write(key: 'isNewMember', value: isNewMember);

          final _next = await Navigator.of(context).push(_createRoute());
        } else {}
      } else {
        print('cancel @@@@@@');
      }
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          // 온보딩
          SizedBox(
            height: 535,
            child: Container(
              child: IntroductionScreen(
                pages: [
                  PageViewModel(
                      reverse: true,
                      title: '안녕하세요!',
                      body: '''건강하고 재밌게,
  동물 친구들과 하루를 기록하는                
  임시보호 일지 다시, 봄입니다.''',
                      image: Image.asset('assets/onboard_1.png'),
                      decoration: getPageDecoration()),
                  PageViewModel(
                      reverse: true,
                      title: '기록하기',
                      body: '''일상을 기록하거나
  다시, 봄 챌린지에서 
                 동물 친구들의 귀여운 모습을 
마음껏 자랑해요!''',
                      image: Image.asset('assets/onboard_2.png'),
                      decoration: getPageDecoration()),
                  PageViewModel(
                      reverse: true,
                      title: '추억하기',
                      body: '''임시보호가 끝나도 
 추억을 다시 돌아봐요
              어떤 재밌는 일들이 일어날지
        지금 바로 시작해 보세요!''',
                      image: Image.asset('assets/onboard_3.png'),
                      decoration: getPageDecoration()),
                ],
                done: const Text('done'),
                // Onboarding page가 끝나면 어떻게 할 지
                onDone: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const MainPage()));
                },
                next: const Icon(Icons.arrow_forward),
                // skip 버튼 추가
                showSkipButton: true,
                skip: Text('skip'),
                // page 표시하는 dot 꾸미기
                dotsDecorator: DotsDecorator(
                    color: Colors.grey,
                    size: const Size(10, 10),
                    // active 상태인 dot 꾸미기
                    activeColor: Colors.orange,
                    activeSize: Size(22, 10),
                    activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50))),
                // 애니메이션 효과 적용
                curve: Curves.ease,
              ),
            ),
          ),
          // 카카오 로그인
          SizedBox(
            child: Container(
              height: 45,
              width: 280,
              margin: EdgeInsets.only(top: 40, bottom: 10),
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
                  backgroundColor: MaterialStateProperty.all(Color(0xFFFCE301)),
                ),
                onPressed: () async {
                  signIn();
                  // await viewModel.login();
                  setState(() {});
                  // 로그인 되면 MainPage로 화면 이동
                  // final result =
                  //     await Navigator.of(context).push(_createRoute());
                },
                child: Image.asset('assets/btn_kakao.png'),
              ),
            ),
          ),
          // 네이버 로그인
          SizedBox(
            child: NaverLoginButton(),
          ),
          // 둘러보기
          SizedBox(
            child: Container(
              height: 25,
              color: Colors.white,
              margin: EdgeInsets.only(top: 30),
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "둘러보기",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 페이지 전환 애니메이션
Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        const RegisterProfileProtector(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 10.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

// PageViewModel의 이미지 decoration 인자 값으로 주기 위한 메서드
PageDecoration getPageDecoration() {
  return PageDecoration(
      // title 스타일
      titlePadding: EdgeInsets.only(top: 60),
      bodyAlignment: Alignment.topLeft,
      titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
      // 본문 스타일
      bodyPadding: EdgeInsets.only(top: 15),
      bodyTextStyle: TextStyle(
        fontSize: 15,
        color: Colors.black,
      ),
      imageAlignment: Alignment.bottomRight,
      imagePadding: EdgeInsets.only(top: 45, bottom: 50),
      pageColor: Color(0xFFF8F8F9));
}
