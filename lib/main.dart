import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:dasi_bom_client/MainPage.dart';
import 'package:dasi_bom_client/OnboardingPage.dart';
import 'package:dasi_bom_client/SplashPage.dart';

void main() async {
  // 웹 환경에서 카카오 로그인을 정상적으로 완료하려면 runApp() 호출 전 아래 메서드 호출 필요
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: '0f1772d6ba49dbd308c3df9873edf6e1',
    // javaScriptAppKey: '19ef6355b4d2cb8afc9c439c165794be',
  );
  await initialization(null);
  // FlutterNativeSplash.removeAfter(initialization);

  runApp(const MyApp());
}

Future initialization(BuildContext? context) async {
  await Future.delayed(Duration(seconds: 2));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'dasi-bom',
      theme: ThemeData(primaryColor: Colors.white),
      home: OnboardingPage(),
      // 라우터로 페이지 이동
      routes: {
        '/main': (context) => MainPage(),
      },
    );
  }
}
