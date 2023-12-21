import 'package:carousel_slider/carousel_slider.dart';
import 'package:confetti/confetti.dart';
import 'package:dasi_bom_client/MainPage.dart';
import 'package:dasi_bom_client/mypage/dasibom_content3.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DasibomContent2 extends StatefulWidget {
  const DasibomContent2({Key? key, this.data}) : super(key: key);
  final data;

  @override
  State<DasibomContent2> createState() => _DasibomContent2State();
}

class _DasibomContent2State extends State<DasibomContent2> {
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['BASE_URL'].toString();
  final getCreateProfile = dotenv.env['GET_CREATE_PROFILE_API'].toString();
  var count = 0;
  Map createInfo = {};

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
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height / 2.5,
          width: double.infinity,
          color: Color(0xfffdf2bb),
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
                        Navigator.of(context).pushNamed('/content');
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
                padding: const EdgeInsets.only(left: 28),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '다시,봄 카드가',
                        style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        '도착했어요!',
                        style: TextStyle(color: Colors.black, fontSize: 16 ,fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Text(
                            '카야',
                            style: TextStyle(color: Colors.black, fontSize: 16,fontWeight: FontWeight.bold),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            '와의 추억을 다시,봄',
                            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.normal),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ],
                  ),
              ),
            ],
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height/1.68,
          width: double.infinity,
          color: Colors.white,
          child: SizedBox(
            child: CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.width/1.2,
                viewportFraction: 1,
                enlargeCenterPage: true,
                autoPlay: false,
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
              items: dummyItems.map((url) {
                return Builder(
                  builder: (BuildContext context) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: TextButton(
                        onPressed: (){
                          final result = Navigator.of(context).push(_createRoute());
                        },
                        child: ClipRRect(
                          // ClipRRect는 child를 둥근 사각형으로 자르는 위젯
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          )
        ),
      ],
    );
  }

  // 페이지 전환 애니메이션
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const DasibomContent3(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 10.0);
        const end = Offset.zero;
        const curve = Curves.slowMiddle;

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
