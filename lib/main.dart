import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:dasi_bom_client/SplashPage.dart';
import 'package:dasi_bom_client/OnboardingPage.dart';
import 'package:dasi_bom_client/profile/profile_register_ani.dart';
import 'package:dasi_bom_client/profile/profile_register_pro.dart';
import 'package:dasi_bom_client/MainPage.dart';

void main() async {
  // 웹 환경에서 카카오 로그인을 정상적으로 완료하려면 runApp() 호출 전 아래 메서드 호출 필요
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: '0f1772d6ba49dbd308c3df9873edf6e1',
  );
  // 로고 스플래시 호출
  await initialization(null);
  // FlutterNativeSplash.removeAfter(initialization);

  runApp(const MyApp());
}

// 로고 스플래시 구현
Future initialization(BuildContext? context) async {
  await Future.delayed(Duration(seconds: 1));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'dasi-bom',
      theme: ThemeData(primaryColor: Colors.white),
      home: SplashPage(),
      // 라우터로 페이지 이동
      routes: {
        '/login': (context) => OnboardingPage(),
        '/main': (context) => MainPage(),
    '/register1': (context) => RegisterProfileProtector(),
    '/register2': (context) => RegisterProfileAnimal(),
      },
    );
  }
}
