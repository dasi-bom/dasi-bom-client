import 'package:dasi_bom_client/community/Com_WritingPage.dart';
import 'package:dasi_bom_client/mypage/dasibom_content.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dasi_bom_client/widgets/Kakao_Login.dart';
import 'package:dasi_bom_client/widgets/main_view_model.dart';
import 'package:dasi_bom_client/writing/WritingPage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

// 커뮤니티 클래스-> Scaffold의 body 프로퍼티에 코드 연동
class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with TickerProviderStateMixin {
  // Tab 변수 선언
  late TabController tabController;

  // Tab 변수 초기화
  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
              controller: tabController,
              indicatorColor: Colors.black,
              indicatorWeight: 1,
              tabs: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('카테고리1'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('카테고리2'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('카테고리3'),
                ),
              ]),
          Expanded(
            // 내 정보 내의 탭 컨트롤러 지정
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                Page11(),
                Page22(),
                Page33(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/com_writing');
        },
        backgroundColor: Color(0xfffd8801),
        child: Image.asset(
          'assets/ic_floating_pen.png',
        ),
      ),
    );
  }
}

//// 커뮤니티 클래스 _ 카테고리1 탭
class Page11 extends StatelessWidget {
  const Page11({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = List.generate(20, (i) {
      // 0부터 9까지의 수를 생성하여 두 번째 인수의 함수에 i 매개변수로 전달함
      return ListTile(
        // i 값을 전달받아 ListTile 위젯 형태로 변환하여 그것들의 리스트가 반환됨
        leading: Icon(Icons.question_answer_sharp),
        title: Text('산책 메이트 구해요'),
        subtitle: Text('역삼동 근처에 임보하시는 분 계신다면 함께..'),
      );
    });

    return SingleChildScrollView(
      child: ListView(
        physics: NeverScrollableScrollPhysics(), // 이 리스트의 스크롤 동작 금지
        shrinkWrap: true, // 이 리스트의 다른 스크롤 객체 안에 있다면 true로 설정해야 함
        children: items,
      ),
    );
  }
}

//// 커뮤니티 클래스 _ 카테고리2 탭
class Page22 extends StatelessWidget {
  const Page22({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = List.generate(20, (i) {
      // 0부터 9까지의 수를 생성하여 두 번째 인수의 함수에 i 매개변수로 전달함
      return ListTile(
        // i 값을 전달받아 ListTile 위젯 형태로 변환하여 그것들의 리스트가 반환됨
        leading: Icon(Icons.question_answer_sharp),
        title: Text('입양 문의 드립니다.'),
        subtitle: Text('역삼동 근처에 임보하시는 분 계신다면 함께..'),
      );
    });

    return SingleChildScrollView(
      child: ListView(
        physics: NeverScrollableScrollPhysics(), // 이 리스트의 스크롤 동작 금지
        shrinkWrap: true, // 이 리스트의 다른 스크롤 객체 안에 있다면 true로 설정해야 함
        children: items,
      ),
    );
  }
}

//// 커뮤니티 클래스 _ 카테고리3 탭
class Page33 extends StatelessWidget {
  const Page33({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = List.generate(20, (i) {
      // 0부터 9까지의 수를 생성하여 두 번째 인수의 함수에 i 매개변수로 전달함
      return ListTile(
        // i 값을 전달받아 ListTile 위젯 형태로 변환하여 그것들의 리스트가 반환됨
        leading: Icon(Icons.question_answer_sharp),
        title: Text('임보 물품 구해요!'),
        subtitle: Text('역삼동 근처에 임보하시는 분 계신다면 함께..'),
      );
    });

    return SingleChildScrollView(
      child: ListView(
        physics: NeverScrollableScrollPhysics(), // 이 리스트의 스크롤 동작 금지
        shrinkWrap: true, // 이 리스트의 다른 스크롤 객체 안에 있다면 true로 설정해야 함
        children: items,
      ),
    );
  }
}