import 'package:dasi_bom_client/widgets/AppDrawer.dart';
import 'package:dasi_bom_client/widgets/BaseAppBar.dart';
import 'package:dasi_bom_client/widgets/BottomMenu.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dasi_bom_client/widgets/Kakao_Login.dart';
import 'package:dasi_bom_client/widgets/main_view_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home/HomePage.dart';
import 'package:dasi_bom_client/writing/WritingPage.dart';
import 'community/CommunityPage.dart';
import 'mypage/MyPage.dart';

// Page1의 _buildMiddle() 메서드에 들어갈 사진 url
final dummyItems = [
  'https://cdn.pixabay.com/photo/2016/02/18/18/37/puppy-1207816_960_720.jpg',
  'https://cdn.pixabay.com/photo/2018/10/01/09/21/pets-3715733_960_720.jpg',
  'https://cdn.pixabay.com/photo/2017/09/25/13/14/dog-2785077_960_720.jpg',
];

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final storage = FlutterSecureStorage();
  final baseUrl = dotenv.env['BASE_URL'].toString();
  final getDiaryListUrl = dotenv.env['GET_DIARY_LIST_API'].toString();

  var cursor = 20;
  var diaryList = [];

  Future<void> getDiaryList() async {
    try {
      final accessToken = await storage.read(key: 'accessToken');
      final url = Uri.parse('$baseUrl$getDiaryListUrl?cursor=$cursor');
      final headers = {
        'Content-Type': 'application/json ',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken'
      };

      final res = await http.get(url, headers: headers);
      final status = res.statusCode;
      print('${res.request} ==> $status');

      if (status == 200) {
        var result = jsonDecode(res.body);
        print(result);
      }
    } catch (err) {
      print('err ===> $err');
    }
  }

  // 로그인 생성자
  final viewModel = MainViewModel(KakaoLogin());

  // 하단 바 페이지 전환 변수 선언
  var _index = 0; // 페이지 인덱스 0,1,2,3
  final _pages = [
    // Page1,2,3,4 클래스와 연동하여 변수 선언(페이지를 _pages 리스트 변수의 값으로 정의)
    Page1(),
    Page2(),
    Page3(),
    Page4(),
  ];

  @override
  void initState() {
    getDiaryList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: _scaffoldKey,
      // 상단 앱 바
      appBar: BaseAppBar(
        appBar: AppBar(),
      ),
      // 햄버거 메뉴 버튼 구성
      endDrawer: AppDrawr(),
      // index에 따라 페이지 바뀜
      body: _pages[_index],

      // 하단 내비게이션 바
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _index = index; // 선택된 탭의 인덱스로 _index를 변경
          });
        },
        currentIndex: _index,
        // 선택된 인덱스
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            // 하단 탭 아이템리스트 선언
            label: '',
            icon: Icon(Icons.home_outlined),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.border_color_outlined),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.people_outline),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.account_circle_outlined),
          ),
        ],
      ),

      // bottomNavigationBar: BottomMenu(),
    );
  }
}

// 홈 클래스-> Scaffold의 body 프로퍼티에 코드 연동
class Page1 extends StatelessWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HomePage();
  }
}

// 일기쓰기 클래스-> Scaffold의 body 프로퍼티에 코드 연동
class Page2 extends StatefulWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  @override
  Widget build(BuildContext context) {
    return Writing();
  }
}

// 커뮤니티 클래스-> Scaffold의 body 프로퍼티에 코드 연동
class Page3 extends StatefulWidget {
  const Page3({Key? key}) : super(key: key);

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  @override
  Widget build(BuildContext context) {
    return CommunityPage();
  }
}

// 마이페이지 클래스-> Scaffold의 body 프로퍼티에 코드 연동
class Page4 extends StatefulWidget {
  const Page4({Key? key}) : super(key: key);

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  @override
  Widget build(BuildContext context) {
    return MyPage();
  }
}
