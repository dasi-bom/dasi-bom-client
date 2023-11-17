import 'dart:convert';

import 'package:dasi_bom_client/profile/profile_register_ani.dart';
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
  final getUserInfoUrl = dotenv.env['GET_USER_INFO_API'].toString();

  var user_name = '';
  var pet_list = 0;

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
      try {
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
            print('tokenUrl ==> $tokenUrl');
            final accessToken =
                tokenUrl.queryParameters["token"]; // token 값 가져오기
            final isNewMember = tokenUrl.queryParameters['isNewMember'];

            await storage.write(
                key: 'accessToken', value: accessToken.toString());
            await storage.write(key: 'isNewMember', value: isNewMember);
            await storage.write(key: 'loginType', value: 'kakao');

            // ======================
            final userToken = await storage.read(key: 'accessToken');
            final url = Uri.parse('$baseUrl$getUserInfoUrl');
            final headers = {'Authorization': 'Bearer $userToken'};

            final userInfoResponse = await http.get(url, headers: headers);
            final userInfoStatus = userInfoResponse.statusCode;
            print('${userInfoResponse.request} ==> $userInfoStatus');

            if (userInfoStatus == 200) {
              final responseBody = utf8.decode(userInfoResponse.bodyBytes);
              final dynamic info = await jsonDecode(responseBody);
              print('유저 정보 ==> $info');

              if (info['nickname'] == null) {
                await Navigator.of(context).push(_createRoute());
              } else if (info['petProfileResponses'].length == 0) {
                await Navigator.of(context).push(_createRoute());
              } else {
                setState(() {
                  user_name = info['nickname'];
                  pet_list = info['petProfileResponses'].length;
                });

                await Navigator.of(context).push(_createRoute());
                // await Navigator.pushNamed(context, '/main');
              }
            } else {
              print('유저 정보 조회 Error ## ');
            }
          }
        } else {
          print('kakao login fail');
        }
      } catch (err) {
        print('err ==> $err');
      }
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          // 온보딩 페이지
          Flexible(
            flex: 10,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: IntroductionScreen(
                globalBackgroundColor: Colors.white,
                pages: [
                  PageViewModel(
                      reverse: true,
                      titleWidget: Padding(
                        padding: const EdgeInsets.only(left: 16, top: 50),
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '안녕하세요!',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                      ),
                      bodyWidget: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '건강하고 재밌게,',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                '동물 친구들과 하루를 기록하는 ',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '임시보호 일지',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    ' 다시, 봄',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.orange),
                                  ),
                                  Text(
                                    '입니다.',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      image: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Image.asset('assets/onboard_3.png'),
                      ),
                      decoration: PageDecoration(
                          pageColor: Colors.white,
                          imageAlignment: Alignment.bottomCenter)),
                  PageViewModel(
                      reverse: true,
                      titleWidget: Padding(
                        padding: const EdgeInsets.only(left: 16, top: 50),
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '기록하기',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                      ),
                      bodyWidget: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '일상을 기록하거나',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '다시, 봄',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.orange),
                                  ),
                                  Text(
                                    ' 챌린지에서',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                              Text(
                                '동물 친구들의 귀여운 모습을',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                '마음껏 자랑해요',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                      image: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Image.asset('assets/onboard_2.png'),
                      ),
                      decoration: PageDecoration(
                          pageColor: Colors.white,
                          imageAlignment: Alignment.bottomCenter)),
                  PageViewModel(
                      reverse: true,
                      titleWidget: Padding(
                        padding: const EdgeInsets.only(left: 16, top: 50),
                        child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '추억하기',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            )),
                      ),
                      bodyWidget: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '임시보호가 끝나도',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                '추억을 다시 돌아봐요',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                '어떤 재밌는 일들이 일어날지',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                '지금 바로 시작해 보세요!',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal),
                              ),
                            ],
                          ),
                        ),
                      ),
                      image: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Image.asset('assets/onboard_1.png'),
                      ),
                      decoration: PageDecoration(
                          pageColor: Colors.white,
                          imageAlignment: Alignment.bottomCenter)),
                ],
                showSkipButton: false,
                showDoneButton: false,
                showNextButton: false,
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
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15))),
                    backgroundColor:
                        MaterialStateProperty.all(Color(0xFFFCE301)),
                  ),
                  onPressed: () async {
                    signIn();
                    setState(() {});
                  },
                  child: Image.asset('assets/btn_kakao.png'),
                ),
              ),
            ),
          ),
          // 네이버 로그인
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: NaverLoginButton(),
            ),
          ),
          // 둘러보기
          Flexible(
            child: SizedBox(
              child: Container(
                color: Colors.white,
                margin: EdgeInsets.only(top: 10),
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
          ),
        ],
      ),
    );
  }

  // 페이지 전환 애니메이션
  Route _createRoute() {
    if (user_name == '') {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RegisterProfileProtector(),
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
    } else if (pet_list == 0) {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RegisterProfileAnimal(),
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
    } else {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainPage(),
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
}
