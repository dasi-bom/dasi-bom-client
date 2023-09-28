import 'package:dasi_bom_client/SeeingPage.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:dasi_bom_client/SplashPage.dart';
import 'package:dasi_bom_client/OnboardingPage.dart';
import 'package:dasi_bom_client/profile/profile_register_pro.dart';
import 'package:dasi_bom_client/profile/profile_register_ani.dart';
import 'package:dasi_bom_client/MainPage.dart';
import 'package:dasi_bom_client/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // 웹 환경에서 카카오 로그인을 정상적으로 완료하려면 runApp() 호출 전 아래 메서드 호출 필요
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  KakaoSdk.init(
    nativeAppKey: dotenv.env['KAKAO_SDK'].toString(),
  );
  // 로고 스플래시 호출
  await initialization(null);
  // FlutterNativeSplash.removeAfter(initialization);

  runApp(
    MultiProvider(
        providers: [
          // 아래와 같이 설정하면 스토어 여러개 사용 가능
          ChangeNotifierProvider(
            create: (c) => UserStore(),
            // create: (c) => UserStore2(),
            // create: (c) => UserStore3(),
          )
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'dasi-bom',
          theme: ThemeData(primaryColor: Colors.white),
          home: const MyApp(),
          routes: {
            '/login': (context) => OnboardingPage(),
            '/main': (context) => MainPage(),
            '/register1': (context) => RegisterProfileProtector(),
            '/register2': (context) => RegisterProfileAnimal(),
            '/diary_detail': (context) => Seeing(),
          },
        )),
  );
}

// 로고 스플래시 구현
Future initialization(BuildContext? context) async {
  await Future.delayed(Duration(seconds: 1));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplashPage(),
    );

    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: 'dasi-bom',
    //   theme: ThemeData(primaryColor: Colors.white),
    //   home: SplashPage(),
    //   // 라우터로 페이지 이동
    //   routes: {
    //     '/login': (context) => OnboardingPage(),
    //     '/main': (context) => MainPage(),
    //     '/register1': (context) => RegisterProfileProtector(),
    //     '/register2': (context) => RegisterProfileAnimal(),
    //   },
    // );
  }
}
