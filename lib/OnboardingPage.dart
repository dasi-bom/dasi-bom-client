import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:dasi_bom_client/MainPage.dart';
import 'Kakao_Login.dart';
import 'main_view_model.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
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

    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 600,
            child: Container(
              // height: screenHeight(context, dividedBy:1.3),
              child: IntroductionScreen(
                pages: [
                  PageViewModel(
                      title: '안녕하세요!',
                      body: '''건강하고 특별하게,
  동물친구들과 하루를 기록하는
  임시보호 일지 앱 다시, 봄입니다.''',
                      image: Image.asset('assets/dasibom_ch.png'),
                      decoration: getPageDecoration()),
                  PageViewModel(
                      title: '추억하기',
                      body: '''다시, 봄에서는 임시보호 중인 동물과 추억을
 더욱 특별하게 기록하고, 공유할 수 있습니다.
   임시보호가 종료되어도, 추억을 다시 볼 수 있는 
   숨겨진 선물도 있답니다.''',
                      image: Image.asset('assets/dasibom_ch.png'),
                      decoration: getPageDecoration()),
                  PageViewModel(
                      title: '기록하기',
                      body: '''격주마다 다시, 봄 챌린지가 열려요. 
      원하는 테마를 골라 5개 이상의 일기를 쓰면, 챌린지 성공!
                  
연속으로 2개의 챌린지에 성공하면
동물 친구와 함께 필름 사진을 찍어드려요!''',
                      image: Image.asset('assets/dasibom_ch.png'),
                      decoration: getPageDecoration()),
                ],
                done: const Text('done'),
                // Onboarding page가 끝나면 어떻게 할 지
                // onDone: () {
                //   Navigator.of(context).pushReplacement(MaterialPageRoute(
                //       builder: (context) => const MyLoginPage()));
                // },
                next: const Icon(Icons.arrow_forward),
                // skip 버튼 추가
                // showSkipButton: true,
                // skip: Text('skip'),
                // page 표시하는 dot 꾸미기
                dotsDecorator: DotsDecorator(
                    color: Colors.grey,
                    size: const Size(10, 10),
                    // active 상태인 dot 꾸미기
                    activeColor: Colors.orange,
                    activeSize: Size(22, 10),
                    activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24))),
                // 애니메이션 효과 적용
                curve: Curves.ease,
              ),
            ),
          ),
          SizedBox(
            height: 205,
            child: Container(
              color: Colors.white,
              margin: EdgeInsets.all(80),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFFFCE301)),
                ),
                onPressed: () async {
                  await viewModel.login();
                  setState(() {});
                  // 로그인 되면 MainPage로 화면 이동
                  final result = await Navigator.pushNamed(context, '/main');
                },
                child: Image.asset('assets/kakao_login_medium_wide.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// PageViewModel의 이미지 decoration 인자 값으로 주기 위한 메서드
PageDecoration getPageDecoration() {
  return PageDecoration(
    // title 스타일
      titleTextStyle: TextStyle(
          fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
      // 본문 스타일
      bodyTextStyle: TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
      imageAlignment: Alignment.bottomRight,
      imagePadding: EdgeInsets.only(top: 40),
      pageColor: Colors.white);
}
