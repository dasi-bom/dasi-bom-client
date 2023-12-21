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

// 마이페이지 클래스-> Scaffold의 body 프로퍼티에 코드 연동
class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with TickerProviderStateMixin {
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
                  child: Text('프로필'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('히스토리'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('내활동'),
                ),
              ]),
          Expanded(
            // 내 정보 내의 탭 컨트롤러 지정
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                Page111(),
                Page222(),
                Page333(),
              ],
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/content');
        },
        backgroundColor: Color(0xfffd8801),
        child: Image.asset(
          'assets/ic_envelope.png',
        ),
      ),
    );
  }
}

//// 마이페이지 클래스 _ 프로필 탭
class Page111 extends StatelessWidget {
  const Page111({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _information(),
          _menu(),
          const SizedBox(height: 20),
          _tabView()
        ],
      ),
    );
  }

  Widget _statisticsOne(String title, int value) {
    return TextButton(
      onPressed: () {
      },
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
                fontSize: 15,
                color: Colors.orange,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // 프로필 탭 _ 내정보 위젯
  Widget _information() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage('assets/user1.png'),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '카야',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(child: _statisticsOne('팔로우', 5)),
                        Expanded(child: _statisticsOne('팔로잉', 120)),
                        Expanded(child: _statisticsOne('북마크', 56)),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // 프로필 탭 _ Edit profile 위젯
  Widget _menu() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 50,
            width: 170,
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
                  backgroundColor:
                  MaterialStateProperty.all(const Color(0xFFFFED8E)),
                ),
                onPressed: () {},
                child: const Text(
                  "채팅",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
            width: 170,
            child: Container(
              color: Colors.white,
              margin: const EdgeInsets.only(top: 20),
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
                  backgroundColor:
                  MaterialStateProperty.all(const Color(0xFFFFED8E)),
                ),
                onPressed: () {},
                child: const Text(
                  "팔로우",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 프로필 탭 _ 게시물 GridView 위젯
  Widget _tabView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: 100,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                Navigator.of(context).pushNamed('/detail');
              },
              splashColor: Colors.white.withOpacity(0.05),
              child: Ink(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage('assets/dog.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }),
    );
  }
}

//// 마이페이지 클래스 _ 히스토리 탭
class Page222 extends StatelessWidget {
  const Page222({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('history');
  }
}

//// 마이페이지 클래스 _ 내활동 탭
class Page333 extends StatelessWidget {
  const Page333({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text('activity');
  }
}