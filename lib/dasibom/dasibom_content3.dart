import 'package:carousel_slider/carousel_slider.dart';
import 'package:confetti/confetti.dart';
import 'package:dasi_bom_client/MainPage.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../WritingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DasibomContent3 extends StatefulWidget {
  const DasibomContent3({Key? key, this.data}) : super(key: key);
  final data;

  @override
  State<DasibomContent3> createState() => _DasibomContent3State();
}

class _DasibomContent3State extends State<DasibomContent3> {
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['BASE_URL'].toString();
  final getCreateProfile = dotenv.env['GET_CREATE_PROFILE_API'].toString();
  var count = 0;
  Map createInfo = {};

  DateTime date = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/content2');
                  },
                  child: Icon(
                    Icons.arrow_back_ios_sharp,
                    color: Colors.black,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/main');
                  },
                  child: Icon(
                    Icons.close_sharp,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '함께 산책했던 시간들',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  date.toString().split(" ")[0],
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.width*1.3,
                      viewportFraction: 1.2,
                      enlargeCenterPage: true,
                      autoPlay: false,
                      autoPlayCurve: Curves.fastOutSlowIn,
                    ),
                    items: dummyItems.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                    // ClipRRect는 child를 둥근 사각형으로 자르는 위젯
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ExpandableText(
                                // 피드 내용
                                '카야랑 오늘은 한강을 따라 산책을 갔다.\n흙냄새가 좋은지..마구 달리던 카야\n너무 귀여웠다.\n오늘의 산책 완료!',
                                expandText: '더보기', //더보기 글자
                                linkColor: Colors.grey, //더보기 글자 색 지정
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.normal),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                            ],
                          );
                        },
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
