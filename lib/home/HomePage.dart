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

// Page1의 _buildMiddle() 메서드에 들어갈 사진 url
final dummyItems = [
  'https://cdn.pixabay.com/photo/2016/02/18/18/37/puppy-1207816_960_720.jpg',
  'https://cdn.pixabay.com/photo/2018/10/01/09/21/pets-3715733_960_720.jpg',
  'https://cdn.pixabay.com/photo/2017/09/25/13/14/dog-2785077_960_720.jpg',
];

// 홈 클래스-> Scaffold의 body 프로퍼티에 코드 연동
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      // Column을 ListView로 변경하면 상하 스크롤이 생김
      children: <Widget>[
        _buildTop(context),
        _buildMiddle(context),
        _buildBottom(),
      ],
    );
  }

  // 홈 클래스 _ 상단
  Widget _buildTop(BuildContext context) {
    return Container(
      // color: Color(0xffFFF1AA),
      height: 200,
      decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/img_back.png'),
          )),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 30, top: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                '봄님의 다시 봄 챌린지 현황',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 30, top: 10),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                '일기 하나만 더 쓰면, 챌린지 완료!',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.normal),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Image.asset('assets/user1.png'),
                Image.asset('assets/user2.png'),
                Image.asset('assets/user1.png'),
                Image.asset('assets/user2.png'),
                Image.asset('assets/user1.png'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                child: Text(
                  '다시 봄 챌린지 알아보기 ▶',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 11,
                      color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed('/challenge_page');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 홈 클래스 _ 중단
  Widget _buildMiddle(context) {
    var viewModel;
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  child: Text(
                    '날도 좋은데, 기분 좋은 산책일기 >',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  child: Text(
                    '+ 작성하기',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.orange),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 150,
            autoPlay: true,
          ),
          items: dummyItems.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: ClipRRect(
                    // ClipRRect는 child를 둥근 사각형으로 자르는 위젯
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  child: Text(
                    '웃긴 표정을 찰칵! 유쾌일기 >',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 60, top: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  child: Text(
                    '+ 작성하기',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.orange),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 120,
            autoPlay: true,
          ),
          items: dummyItems.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: ClipRRect(
                    // ClipRRect는 child를 둥근 사각형으로 자르는 위젯
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 30, top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  child: Text(
                    '무슨 꿈을 꾸나? 쿨쿨일기 >',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 70, top: 10),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  child: Text(
                    '+ 작성하기',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.orange),
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
        CarouselSlider(
          options: CarouselOptions(
            height: 120,
            autoPlay: true,
          ),
          items: dummyItems.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: ClipRRect(
                    // ClipRRect는 child를 둥근 사각형으로 자르는 위젯
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        SizedBox(
          height: 50,
        ),
        Container(
          height: 250,
          width: 500,
          color: Color(0xffFFF0DA),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30, top: 10),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: TextButton(
                    child: Text(
                      '오늘의 챌린지 랭킹 >',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black),
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      height: 170,
                      width: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Container(
                              height: 30,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.green,
                              ),
                              child: Text(
                                '산책왕',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage('assets/dog.jpg'),
                          ),
                          Text(
                            '곰곰이',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 170,
                      width: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Container(
                              height: 30,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.orange,
                              ),
                              child: Text(
                                '유쾌왕',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage('assets/dog.jpg'),
                          ),
                          Text(
                            '뭉치',
                          ),
                        ],
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      height: 170,
                      width: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Center(
                            child: Container(
                              height: 30,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.purple,
                              ),
                              child: Text(
                                '드림왕',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AssetImage('assets/dog.jpg'),
                          ),
                          Text(
                            '카야',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 30, top: 10),
          child: Align(
            alignment: Alignment.topLeft,
            child: TextButton(
              child: Text(
                '요즘 뜨는 이야기 >',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black),
              ),
              onPressed: () { },
            ),
          ),
        ),
        Container(
          height: 500,
          width: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: InkWell(
                          onTap: () {}, // Handle your callback.
                          splashColor: Colors.brown.withOpacity(0.5),
                          child: Ink(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage('assets/dog.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '뭉치의 낮잠',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '''고양이는 하루에 10시간을 넘게
잔다고 하는데...''',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: InkWell(
                          onTap: () {}, // Handle your callback.
                          splashColor: Colors.brown.withOpacity(0.5),
                          child: Ink(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage('assets/dog.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '샐리와 처음 만난 날',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '''운명처럼 만난 너무나 귀엽고
사람을 좋아하는 아이!''',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: InkWell(
                          onTap: () {}, // Handle your callback.
                          splashColor: Colors.brown.withOpacity(0.5),
                          child: Ink(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage('assets/dog.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '비누 이야기',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '''비누는 정말 똑똑합니다.
제가 일어나는 시간을 딱 맞춰서...''',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: InkWell(
                          onTap: () {}, // Handle your callback.
                          splashColor: Colors.brown.withOpacity(0.5),
                          child: Ink(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                image: AssetImage('assets/dog.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        '웃는게 넘 귀여운 우리 애기',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '''강아지의 웃음은 너무나 무해하다.
오늘은 특히나 산책하는데...''',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 홈 클래스 _ 하단
  Widget _buildBottom() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30, top: 10),
          child: Align(
            alignment: Alignment.topLeft,
            child: TextButton(
              child: Text(
                '임시보호 가이드 >',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black),
              ),
              onPressed: () {},
            ),
          ),
        ),
        SizedBox(
          height: 100,
          width: 350,
          child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
                backgroundColor:
                MaterialStateProperty.all(const Color(0xFFFF86B2)),
              ),
              onPressed: () => {},
              child: Image.asset('assets/ic_guide1.png')),
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          height: 100,
          width: 350,
          child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
                backgroundColor:
                MaterialStateProperty.all(const Color(0xFFFDCC85)),
              ),
              onPressed: () => {},
              child: Image.asset('assets/ic_guide2.png')),
        ),
      ],
    );
  }
}